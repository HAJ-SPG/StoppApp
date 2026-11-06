import 'package:stoppapp/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hilfen.dart';

void main() {
  (StoppDienst, FesteUhr) mitMessungen() {
    final (s, uhr, _) = dienst(jetzt: um(12, 0));
    s.messungNachtragen(tag: freitag, ereignisId: 1, start: um(7, 0), stopp: um(7, 10));
    s.messungNachtragen(tag: freitag, ereignisId: 2, start: um(7, 12), stopp: um(7, 15));
    s.messungNachtragen(tag: freitag, ereignisId: 3, start: um(7, 30), stopp: um(8, 0));
    return (s, uhr);
  }

  test('Tagesprotokoll mit Summen und sichtbaren Lücken ab 5 Min', () {
    final (s, uhr) = mitMessungen();
    final p = tagesProtokoll(s.daten, freitag, uhr.jetzt());
    expect(p.messungen.length, 3);
    expect(p.summe, const Duration(minutes: 43));
    expect(p.lueckenSumme, const Duration(minutes: 17));
    final luecken = p.eintraege.where((e) => e.luecke != null).toList();
    expect(luecken.length, 1);
    expect(luecken.single.luecke!.von, um(7, 15).toUtc());
    expect(p.eintraege.length, 4);
  });

  test('nachgetragene Messungen bekommen den Kettennamen des Tages', () {
    final (s, _) = mitMessungen();
    expect(s.daten.messungen.values.every((m) => m.ketteName == 'Arbeitstag'), isTrue);
    expect(s.daten.messungen.values.every((m) => m.schrittPosition == null), isTrue);
  });

  test('„gemessen unter …“ bei anderem Kettennamen', () {
    final (s, uhr) = mitMessungen();
    s.ketteFuerTageSetzen([freitag], 2);
    final p = tagesProtokoll(s.daten, freitag, uhr.jetzt());
    expect(p.eintraege.where((e) => e.anderemKettennamen).length, 3);
  });

  group('Prüfung beim Speichern', () {
    test('Stopp muss nach dem Start liegen', () {
      final (s, _) = mitMessungen();
      expect(
          () => s.messungNachtragen(tag: freitag, ereignisId: 1, start: um(9, 0), stopp: um(9, 0)),
          throwsA(isA<FachFehler>()));
    });

    test('Stopp nicht in der Zukunft', () {
      final (s, _) = mitMessungen();
      expect(
          () => s.messungNachtragen(tag: freitag, ereignisId: 1, start: um(11, 0), stopp: um(12, 1)),
          throwsA(isA<FachFehler>()));
    });

    test('Überschneidung nennt die störende Messung', () {
      final (s, _) = mitMessungen();
      expect(
        () => s.messungNachtragen(tag: freitag, ereignisId: 4, start: um(7, 5), stopp: um(7, 11)),
        throwsA(isA<UeberschneidungFehler>()
            .having((e) => e.meldung, 'meldung', contains('Aufstehen'))
            .having((e) => e.andere.ereignisId, 'andere', 1)),
      );
    });

    test('angrenzende Messungen sind erlaubt', () {
      final (s, _) = mitMessungen();
      s.messungNachtragen(tag: freitag, ereignisId: 4, start: um(7, 15), stopp: um(7, 30));
      expect(s.daten.messungen.length, 4);
    });

    test('die laufende Messung zählt bis jetzt', () {
      final (s, uhr) = mitMessungen();
      s.einschieben(4); // läuft ab 12:00
      uhr.vor(const Duration(minutes: 30));
      expect(
          () => s.messungNachtragen(tag: freitag, ereignisId: 1, start: um(12, 10), stopp: um(12, 20)),
          throwsA(isA<UeberschneidungFehler>()));
    });

    test('Bearbeiten ignoriert die Messung selbst', () {
      final (s, _) = mitMessungen();
      final id = s.daten.messungenAm(freitag).first.id;
      s.messungBearbeiten(id: id, ereignisId: 4, start: um(6, 55), stopp: um(7, 11));
      expect(s.daten.messungen[id]!.ereignisId, 4);
      expect(s.daten.messungen[id]!.stopp, um(7, 11).toUtc());
    });
  });

  test('Löschen und Rückgängig', () {
    final (s, _) = mitMessungen();
    final id = s.daten.messungenAm(freitag).first.id;
    final a = s.messungLoeschen(id);
    expect(s.daten.messungen.length, 2);
    s.rueckgaengig(a);
    expect(s.daten.messungen.length, 3);
  });

  test('zukünftige Tage', () {
    final (s, uhr) = mitMessungen();
    expect(tagesProtokoll(s.daten, freitag.plusTage(1), uhr.jetzt()).istZukunft, isTrue);
    expect(tagesProtokoll(s.daten, freitag, uhr.jetzt()).istZukunft, isFalse);
  });

  test('Wochenregel setzen lässt Ausnahmen bestehen', () {
    final (s, _) = mitMessungen();
    s.ketteFuerTageSetzen([freitag.plusTage(3)], 2);
    s.wochenregelSetzen({1: 2, 2: null});
    expect(s.daten.wochenregel, {1: 2});
    expect(s.daten.tagesausnahmen[freitag.plusTage(3)], 2);
    s.wochenregelVerwenden([freitag.plusTage(3)]);
    expect(s.daten.tagesausnahmen, isEmpty);
  });
}
