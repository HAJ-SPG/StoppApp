import 'dart:convert';

import 'package:stoppapp/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hilfen.dart';

FernAktion fern(FernArt art, DateTime zeit, int? pos, {String id = 'x'}) =>
    FernAktion(id: id, art: art, zeitpunkt: zeit.toUtc(), quelle: 'widget', schrittPosition: pos);

void main() {
  group('Schnappschuss', () {
    test('bereit', () {
      final (s, uhr, _) = dienst(jetzt: um(7, 0));
      s.tagesSicherstellen();
      final j = widgetSchnappschuss(s.daten, uhr.jetzt());
      expect(j['tag'], '2026-11-06');
      expect(j['zustand'], 'bereit');
      expect(j['kette'], 'Arbeitstag');
      expect(j['laufend'], isNull);
      expect(j['naechstes'], {'ereignis': 'Aufstehen', 'schritt_position': 0});
      expect(j['erledigt'], 0);
      expect(j['schritte_gesamt'], 3);
    });

    test('läuft, mit Startzeit in UTC-ms', () {
      final (s, uhr, _) = dienst(jetzt: um(7, 0));
      s.starten();
      final j = widgetSchnappschuss(s.daten, uhr.jetzt());
      expect(j['zustand'], 'laeuft');
      expect(j['laufend'], {
        'ereignis': 'Aufstehen',
        'start': um(7, 0).millisecondsSinceEpoch,
        'schritt_position': 0,
      });
      expect(jsonDecode(widgetSchnappschussJson(s.daten, uhr.jetzt())), isA<Map>());
    });

    test('keine Kette und erledigt', () {
      final (s, uhr, _) = dienst(jetzt: um(7, 0));
      s.ketteFuerTageSetzen([freitag], null);
      expect(widgetSchnappschuss(s.daten, uhr.jetzt())['zustand'], 'keine');
      s.wochenregelVerwenden([freitag]);
      for (var i = 0; i < 3; i++) {
        s.starten();
        uhr.vor(const Duration(minutes: 1));
        s.stoppen();
      }
      final j = widgetSchnappschuss(s.daten, uhr.jetzt());
      expect(j['zustand'], 'erledigt');
      expect(j['erledigt'], 3);
      expect(j['naechstes'], isNull);
    });
  });

  group('Warteschlange', () {
    test('Start und Stopp gelten mit dem Zeitpunkt des Tippens', () {
      final (s, uhr, _) = dienst(jetzt: um(7, 0));
      uhr.stellen(um(7, 5));
      final n = s.fernAbarbeiten([
        fern(FernArt.start, um(7, 0), 0, id: 'a'),
        fern(FernArt.stopp, um(7, 3), 0, id: 'b'),
      ]);
      expect(n, 2);
      final m = s.daten.messungenAm(freitag).single;
      expect(m.start, um(7, 0).toUtc());
      expect(m.stopp, um(7, 3).toUtc());
      expect(m.schrittPosition, 0);
    });

    test('passt nicht mehr zum Zustand: verworfen', () {
      final (s, _, _) = dienst(jetzt: um(7, 0));
      expect(s.fernAusfuehren(fern(FernArt.stopp, um(7, 0), 0)), isFalse, reason: 'Stopp ohne laufende Messung');
      expect(s.fernAusfuehren(fern(FernArt.start, um(7, 0), 1)), isFalse, reason: 'andere Position');
      expect(s.fernAusfuehren(fern(FernArt.start, um(7, 0), 0)), isTrue);
      expect(s.fernAusfuehren(fern(FernArt.start, um(7, 0), 0)), isFalse, reason: 'Doppeltipp');
      expect(s.fernAusfuehren(fern(FernArt.stopp, um(7, 0), 2)), isFalse, reason: 'andere laufende Position');
    });

    test('Start vom Vortag wird verworfen', () {
      final (s, _, _) = dienst(jetzt: um(7, 0));
      expect(s.fernAusfuehren(fern(FernArt.start, um(23, 0, tag: freitag.plusTage(-1)), 0)), isFalse);
    });

    test('Start nicht vor dem Stopp der vorigen Messung', () {
      final (s, uhr, _) = dienst(jetzt: um(7, 0));
      s.starten();
      uhr.stellen(um(7, 10));
      s.stoppen();
      expect(s.fernAusfuehren(fern(FernArt.start, um(7, 8), 1)), isTrue);
      expect(s.daten.laufendeMessung!.start, um(7, 10).toUtc());
    });

    test('Warteschlange lesen sortiert und übergeht Unlesbares', () {
      final json = jsonEncode([
        {'id': 'b', 'aktion': 'stopp', 'zeitpunkt': 2000, 'quelle': 'notification', 'schritt_position': 0},
        {'kaputt': true},
        {'id': 'a', 'aktion': 'start', 'zeitpunkt': 1000, 'quelle': 'widget', 'schritt_position': null},
      ]);
      final l = warteschlangeLesen(json);
      expect(l.map((a) => a.id), ['a', 'b']);
      expect(l.first.schrittPosition, isNull);
      expect(l.last.art, FernArt.stopp);
      expect(warteschlangeLesen('kein json'), isEmpty);
      expect(warteschlangeLesen(null), isEmpty);
    });
  });
}
