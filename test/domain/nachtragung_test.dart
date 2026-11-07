import 'package:stoppapp/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hilfen.dart';

/// Kette „Morgen“: Aufstehen → Duschen → Frühstück → Duschen, Mo–So.
Datenbestand morgenDaten() => const Datenbestand(
      ereignisse: {
        1: Ereignis(id: 1, name: 'Aufstehen'),
        2: Ereignis(id: 2, name: 'Duschen'),
        3: Ereignis(id: 3, name: 'Frühstück'),
        4: Ereignis(id: 4, name: 'Einkaufen'),
      },
      ketten: {
        1: Kette(id: 1, name: 'Morgen', farbe: 0, sortierung: 0, schritte: [1, 2, 3, 2]),
      },
      wochenregel: {1: 1, 2: 1, 3: 1, 4: 1, 5: 1, 6: 1, 7: 1},
    );

void main() {
  test('Nachtragung erledigt den ersten übersprungenen Schritt des Ereignisses', () {
    final (s, uhr, _) = dienst(daten: morgenDaten(), jetzt: um(7, 0));
    s.starten(); // Aufstehen
    uhr.vor(const Duration(minutes: 5));
    s.stoppen();
    s.ueberspringen(); // erstes Duschen
    expect(s.heuteZustand.naechster, 2);
    uhr.vor(const Duration(minutes: 30));
    s.messungNachtragen(tag: freitag, ereignisId: 2, start: um(7, 10), stopp: um(7, 20));
    final z = s.heuteZustand;
    expect(z.schritte[1].status, SchrittStatus.erledigt);
    expect(z.schritte[3].status, SchrittStatus.offen, reason: 'das zweite Duschen wird normal gemessen');
    expect(z.naechster, 2);
  });

  test('Nachtragen für einen noch offenen Schritt ist heute gesperrt', () {
    final (s, _, _) = dienst(daten: morgenDaten(), jetzt: um(8, 0));
    s.tagesSicherstellen();
    expect(
      () => s.messungNachtragen(tag: freitag, ereignisId: 2, start: um(7, 10), stopp: um(7, 20)),
      throwsA(isA<FachFehler>().having((e) => e.meldung, 'meldung', contains('Erst überspringen'))),
    );
  });

  test('Ereignis außerhalb der Kette ist frei nachtragbar und zählt wie eingeschoben', () {
    final (s, _, _) = dienst(daten: morgenDaten(), jetzt: um(9, 0));
    s.messungNachtragen(tag: freitag, ereignisId: 4, start: um(7, 10), stopp: um(7, 20));
    final m = s.daten.messungenAm(freitag).single;
    expect(m.schrittPosition, isNull);
    expect(m.ketteName, 'Morgen');
  });

  test('an vergangenen Tagen zählen offene Schritte wie übersprungene', () {
    final (s, uhr, _) = dienst(daten: morgenDaten(), jetzt: um(7, 0));
    s.tagesSicherstellen(); // Tageslauf für Freitag
    uhr.stellen(um(9, 0, tag: freitag.plusTage(1)));
    s.messungNachtragen(tag: freitag, ereignisId: 2, start: um(7, 10), stopp: um(7, 20));
    expect(s.daten.messungenAm(freitag).single.schrittPosition, 1);
  });

  test('Löschen der Nachtragung macht den Schritt wieder übersprungen', () {
    final (s, _, _) = dienst(daten: morgenDaten(), jetzt: um(9, 0));
    s.ueberspringen(); // Aufstehen
    s.messungNachtragen(tag: freitag, ereignisId: 1, start: um(7, 0), stopp: um(7, 5));
    expect(s.heuteZustand.schritte[0].status, SchrittStatus.erledigt);
    s.messungLoeschen(s.daten.messungenAm(freitag).single.id);
    expect(s.heuteZustand.schritte[0].status, SchrittStatus.uebersprungen);
  });

  test('Ereignis ändern beim Bearbeiten folgt derselben Regel', () {
    final (s, _, _) = dienst(daten: morgenDaten(), jetzt: um(9, 0));
    s.ueberspringen(); // Aufstehen
    s.messungNachtragen(tag: freitag, ereignisId: 1, start: um(7, 0), stopp: um(7, 5));
    final id = s.daten.messungenAm(freitag).single.id;
    // Duschen ist noch offen → gesperrt
    expect(() => s.messungBearbeiten(id: id, ereignisId: 2, start: um(7, 0), stopp: um(7, 5)),
        throwsA(isA<FachFehler>()));
    // Einkaufen ist nicht in der Kette → eingeschoben, Aufstehen wieder übersprungen
    s.messungBearbeiten(id: id, ereignisId: 4, start: um(7, 0), stopp: um(7, 5));
    expect(s.daten.messungen[id]!.schrittPosition, isNull);
    expect(s.heuteZustand.schritte[0].status, SchrittStatus.uebersprungen);
  });

  group('Kalenderfarbe', () {
    test('vergangene Tage zeigen die gelaufene Kette, nicht die neue Wochenregel', () {
      final d = beispielDaten();
      final (s, uhr, _) = dienst(daten: d, jetzt: um(7, 0));
      s.tagesSicherstellen(); // Freitag läuft „Arbeitstag“
      s.wochenregelSetzen({...d.wochenregel, 5: 2}); // Freitag künftig „Wochenende“
      uhr.stellen(um(9, 0, tag: freitag.plusTage(1)));
      final heute = freitag.plusTage(1);
      expect(kalenderKette(s.daten, freitag, heute).kette?.name, 'Arbeitstag');
      expect(kalenderKette(s.daten, freitag.plusTage(7), heute).kette?.name, 'Wochenende');
    });

    test('ohne Tageslauf oder mit gelöschter Kette bleibt der Tag neutral', () {
      final (s, uhr, _) = dienst(jetzt: um(7, 0));
      s.tagesSicherstellen();
      final heute = freitag.plusTage(1);
      uhr.stellen(um(9, 0, tag: heute));
      expect(kalenderKette(s.daten, freitag.plusTage(-1), heute).kette, isNull);
      s.ketteLoeschen(1);
      expect(kalenderKette(s.daten, freitag, heute).kette, isNull);
    });

    test('eine nachträgliche Ausnahme gewinnt', () {
      final (s, _, _) = dienst(jetzt: um(7, 0));
      s.tagesSicherstellen();
      s.ketteFuerTageSetzen([freitag.plusTage(-1)], 2);
      final k = kalenderKette(s.daten, freitag.plusTage(-1), freitag);
      expect(k.kette?.name, 'Wochenende');
      expect(k.hatAusnahme, isTrue);
    });
  });
}
