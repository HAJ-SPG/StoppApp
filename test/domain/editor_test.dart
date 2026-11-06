import 'package:stoppapp/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hilfen.dart';

void main() {
  group('Namen', () {
    test('eindeutig ohne Groß/Klein, nicht leer', () {
      final (s, _, _) = dienst();
      expect(() => s.ereignisAnlegen('kaffee'), throwsA(isA<FachFehler>()));
      expect(() => s.ereignisAnlegen('   '), throwsA(isA<FachFehler>()));
      expect(() => s.ketteAnlegen('ARBEITSTAG', 0), throwsA(isA<FachFehler>()));
      final (_, id) = s.ereignisAnlegen(' Duschen ');
      expect(s.daten.ereignisse[id]!.name, 'Duschen');
    });

    test('Ereignis umbenennen gilt auch in alten Messungen', () {
      final (s, _, _) = dienst();
      s.einschieben(4);
      s.ereignisUmbenennen(4, 'Espresso');
      final m = s.daten.laufendeMessung!;
      expect(s.daten.ereignisName(m.ereignisId), 'Espresso');
      s.ereignisUmbenennen(4, 'espresso'); // nur Schreibweise des eigenen Namens
      expect(s.daten.ereignisse[4]!.name, 'espresso');
    });

    test('Kette umbenennen ändert alte Messungen nicht', () {
      final (s, _, _) = dienst();
      s.starten();
      s.ketteBearbeiten(1, name: 'Bürotag', farbe: 3);
      expect(s.daten.laufendeMessung!.ketteName, 'Arbeitstag');
      expect(s.daten.ketten[1]!.farbe, 3);
    });
  });

  group('Ereignis entfernen', () {
    test('ohne Messungen wird gelöscht und aus Ketten entfernt', () {
      final (s, _, _) = dienst();
      final (_, erg) = s.ereignisEntfernen(2);
      expect(erg, EntfernenErgebnis.geloescht);
      expect(s.daten.ereignisse.containsKey(2), isFalse);
      expect(s.daten.ketten[1]!.schritte, [1, 3]);
    });

    test('mit Messungen wird archiviert', () {
      final (s, uhr, _) = dienst();
      s.starten();
      uhr.vor(const Duration(minutes: 1));
      s.stoppen();
      final (_, erg) = s.ereignisEntfernen(1);
      expect(erg, EntfernenErgebnis.archiviert);
      expect(s.daten.ereignisse[1]!.archiviert, isTrue);
      expect(s.daten.ketten[1]!.schritte, [2, 3]);
      expect(s.daten.ketten[2]!.schritte, [4]);
      expect(s.daten.aktiveEreignisse.any((e) => e.id == 1), isFalse);
      expect(s.daten.messungen.length, 1);
      s.ereignisWiederherstellen(1);
      expect(s.daten.ereignisse[1]!.archiviert, isFalse);
    });
  });

  group('Ketten', () {
    test('neue Kette startet leer', () {
      final (s, _, _) = dienst();
      final (_, id) = s.ketteAnlegen('Homeoffice', 2);
      expect(s.daten.ketten[id]!.schritte, isEmpty);
      expect(s.daten.kettenSortiert.last.id, id);
    });

    test('Schritte hinzufügen, verschieben, entfernen; Ereignis mehrfach erlaubt', () {
      final (s, _, _) = dienst();
      s.schrittHinzufuegen(1, 2);
      expect(s.daten.ketten[1]!.schritte, [1, 2, 3, 2]);
      s.schrittVerschieben(1, 3, 0);
      expect(s.daten.ketten[1]!.schritte, [2, 1, 2, 3]);
      s.schrittEntfernen(1, 2);
      expect(s.daten.ketten[1]!.schritte, [2, 1, 3]);
    });

    test('Schritt mit neuem oder archiviertem Ereignis', () {
      final (s, uhr, _) = dienst();
      s.schrittHinzufuegenNeu(2, 'Joggen');
      final neu = s.daten.ereignisse.values.firstWhere((e) => e.name == 'Joggen');
      expect(s.daten.ketten[2]!.schritte.last, neu.id);
      s.einschieben(4);
      uhr.vor(const Duration(minutes: 1));
      s.stoppen();
      s.ereignisEntfernen(4);
      final suche = ereignisSuche(s.daten, 'kaffee');
      expect(suche.archiviertExakt, 4);
      expect(suche.neuMoeglich, isFalse);
      s.schrittWiederherstellenUndEinfuegen(1, 4);
      expect(s.daten.ereignisse[4]!.archiviert, isFalse);
      expect(s.daten.ketten[1]!.schritte.last, 4);
    });

    test('Suche', () {
      final s = ereignisSuche(beispielDaten(), 'ar');
      expect(s.treffer, [3]);
      expect(s.neuMoeglich, isTrue);
      expect(ereignisSuche(beispielDaten(), 'Kaffee').neuMoeglich, isFalse);
    });

    test('Duplizieren', () {
      final (s, _, _) = dienst();
      final (_, id) = s.ketteDuplizieren(1);
      expect(s.daten.ketten[id]!.name, 'Arbeitstag (Kopie)');
      expect(s.daten.ketten[id]!.schritte, [1, 2, 3]);
      expect(s.daten.kettenSortiert.map((k) => k.name),
          ['Arbeitstag', 'Arbeitstag (Kopie)', 'Wochenende']);
      final (_, id2) = s.ketteDuplizieren(1);
      expect(s.daten.ketten[id2]!.name, 'Arbeitstag (Kopie 2)');
    });

    test('Kette löschen mit Ersatz', () {
      final (s, _, _) = dienst();
      s.ketteFuerTageSetzen([freitag.plusTage(7)], 1);
      expect(ketteWirdVerwendet(s.daten, 1), isTrue);
      s.ketteLoeschen(1, ersatz: 2);
      expect(s.daten.ketten.containsKey(1), isFalse);
      expect(s.daten.wochenregel.values.toSet(), {2});
      expect(s.daten.tagesausnahmen[freitag.plusTage(7)], 2);
    });

    test('Kette löschen ohne Ersatz: Keine Kette; Messungen bleiben', () {
      final (s, uhr, _) = dienst();
      s.starten();
      uhr.vor(const Duration(minutes: 1));
      s.stoppen();
      s.ketteLoeschen(1);
      expect(s.daten.wochenregel, {6: 2, 7: 2});
      expect(s.daten.messungen.values.single.ketteName, 'Arbeitstag');
    });
  });

  group('Verwendung', () {
    test('Wochentage kompakt', () {
      expect(wochentageText([1, 2, 3, 4, 5]), 'Mo–Fr');
      expect(wochentageText([1, 3, 5]), 'Mo, Mi, Fr');
      expect(wochentageText([6, 7]), 'Sa, So');
      expect(wochentageText([1, 2, 3, 6]), 'Mo–Mi, Sa');
    });

    test('Ketten- und Ereignisverwendung', () {
      final d = beispielDaten().kopie(tagesausnahmen: {freitag: 1, freitag.plusTage(1): 1});
      expect(kettenVerwendung(d, 1), 'Mo–Fr · 2 Ausnahmen');
      expect(kettenVerwendung(d.kopie(wochenregel: {}, tagesausnahmen: {}), 1), 'nicht eingeplant');
      final d2 = d.kopie(ketten: {
        ...d.ketten,
        1: d.ketten[1]!.kopie(schritte: [1, 2, 1]),
      });
      expect(ereignisVerwendung(d2, 1), 'Arbeitstag ×2, Wochenende · 0 Messungen');
    });
  });
}
