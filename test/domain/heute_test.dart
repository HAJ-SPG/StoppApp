import 'package:stoppapp/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hilfen.dart';

void main() {
  test('Tageslauf wird beim ersten Öffnen als Schnappschuss angelegt', () {
    final (s, _, _) = dienst();
    s.tagesSicherstellen();
    final lauf = s.daten.tageslaeufe[freitag]!;
    expect(lauf.ketteName, 'Arbeitstag');
    expect(lauf.schritte, [1, 2, 3]);
    expect(s.heuteZustand.modus, HeuteModus.bereit);
    expect(s.heuteZustand.naechstesEreignisId, 1);
    expect(s.heuteZustand.danachEreignisId, 2);
  });

  test('ohne Tageskette: Modus keineKette', () {
    final (s, _, _) = dienst(daten: beispielDaten().kopie(wochenregel: {}));
    s.tagesSicherstellen();
    expect(s.heuteZustand.modus, HeuteModus.keineKette);
  });

  test('Starten und Stoppen messen den nächsten Schritt', () {
    final (s, uhr, _) = dienst();
    s.knopfDruecken();
    var z = s.heuteZustand;
    expect(z.modus, HeuteModus.laeuft);
    expect(z.laufend!.ereignisId, 1);
    expect(z.laufend!.ketteName, 'Arbeitstag');
    expect(z.laufend!.schrittPosition, 0);
    expect(z.danachEreignisId, 2);
    uhr.vor(const Duration(minutes: 5));
    s.knopfDruecken();
    z = s.heuteZustand;
    expect(z.modus, HeuteModus.bereit);
    expect(z.erledigt, 1);
    expect(z.naechstesEreignisId, 2);
    expect(z.messungen.single.dauer(uhr.jetzt()), const Duration(minutes: 5));
  });

  test('höchstens eine Messung gleichzeitig', () {
    final (s, _, _) = dienst();
    s.starten();
    expect(() => s.starten(), throwsA(isA<FachFehler>()));
    expect(() => s.einschieben(4), throwsA(isA<FachFehler>()));
  });

  test('Kette erledigt: Fertig für heute', () {
    final (s, uhr, _) = dienst();
    for (var i = 0; i < 3; i++) {
      s.starten();
      uhr.vor(const Duration(minutes: 1));
      s.stoppen();
    }
    expect(s.heuteZustand.modus, HeuteModus.erledigt);
    expect(s.heuteZustand.erledigt, 3);
  });

  test('Überspringen markiert den nächsten Schritt', () {
    final (s, _, _) = dienst();
    s.ueberspringen();
    final z = s.heuteZustand;
    expect(z.schritte[0].status, SchrittStatus.uebersprungen);
    expect(z.naechstesEreignisId, 2);
    expect(z.waehlbareSchritte.map((x) => x.position), [0, 1, 2]);
  });

  test('Nächstes wählen macht den Schritt zum Standardschritt', () {
    final (s, uhr, _) = dienst();
    s.naechstesWaehlen(2);
    expect(s.heuteZustand.naechstesEreignisId, 3);
    s.starten();
    expect(s.heuteZustand.laufend!.schrittPosition, 2);
    uhr.vor(const Duration(minutes: 1));
    s.stoppen();
    expect(s.heuteZustand.naechstesEreignisId, 1);
  });

  test('übersprungener Schritt kann gewählt und gemessen werden', () {
    final (s, uhr, _) = dienst();
    s.ueberspringen();
    s.naechstesWaehlen(0);
    expect(s.heuteZustand.naechster, 0);
    s.starten();
    uhr.vor(const Duration(minutes: 1));
    s.stoppen();
    expect(s.heuteZustand.schritte[0].status, SchrittStatus.erledigt);
  });

  test('Einschieben misst außerhalb der Kette, die Kette macht weiter', () {
    final (s, uhr, _) = dienst();
    s.naechstesWaehlen(1);
    s.einschieben(4);
    final m = s.heuteZustand.laufend!;
    expect(m.schrittPosition, isNull);
    expect(m.ereignisId, 4);
    uhr.vor(const Duration(minutes: 3));
    s.stoppen();
    expect(s.heuteZustand.naechster, 1);
  });

  test('Einschieben mit neuem Ereignis', () {
    final (s, _, _) = dienst();
    s.einschiebenNeu('Zeitung');
    final m = s.heuteZustand.laufend!;
    expect(s.daten.ereignisse[m.ereignisId]!.name, 'Zeitung');
  });

  group('Zeit korrigieren', () {
    test('Gestoppt vor X Min', () {
      final (s, uhr, _) = dienst();
      s.starten();
      uhr.vor(const Duration(minutes: 20));
      expect(s.kannGestopptVor(const Duration(minutes: 30)), isFalse);
      s.gestopptVor(const Duration(minutes: 5));
      expect(s.heuteZustand.messungen.single.stopp, um(7, 15).toUtc());
    });

    test('Gestoppt vor mehr als der Laufzeit ist ein Fehler', () {
      final (s, uhr, _) = dienst();
      s.starten();
      uhr.vor(const Duration(minutes: 3));
      expect(() => s.gestopptVor(const Duration(minutes: 5)), throwsA(isA<FachFehler>()));
    });

    test('Begonnen vor X Min, höchstens bis zum Stopp der vorigen Messung', () {
      final (s, uhr, _) = dienst();
      s.starten();
      uhr.vor(const Duration(minutes: 10));
      s.stoppen(); // 07:00–07:10
      uhr.vor(const Duration(minutes: 5));
      s.starten(); // 07:15
      uhr.vor(const Duration(minutes: 2)); // 07:17
      s.begonnenVor(const Duration(minutes: 5));
      expect(s.heuteZustand.laufend!.start, um(7, 12).toUtc());
      s.begonnenVor(const Duration(minutes: 30));
      expect(s.heuteZustand.laufend!.start, um(7, 10).toUtc());
    });

    test('Messung verwerfen öffnet den Schritt wieder', () {
      final (s, _, _) = dienst();
      s.starten();
      s.verwerfen();
      expect(s.heuteZustand.messungen, isEmpty);
      expect(s.heuteZustand.naechster, 0);
    });
  });

  group('Tageswechsel', () {
    test('neuer Tag bekommt einen neuen Tageslauf, unfertige Kette verfällt', () {
      final (s, uhr, _) = dienst();
      s.starten();
      uhr.vor(const Duration(minutes: 1));
      s.stoppen();
      uhr.stellen(um(4, 0, tag: freitag.plusTage(1)));
      s.tagesSicherstellen();
      final z = s.heuteZustand;
      expect(z.tag, freitag.plusTage(1));
      expect(z.ketteName, 'Wochenende');
      expect(z.erledigt, 0);
    });

    test('Messung zählt zum Tag, an dem sie gestartet wurde', () {
      final (s, uhr, _) = dienst(jetzt: um(23, 50));
      s.starten();
      uhr.stellen(um(4, 30, tag: freitag.plusTage(1)));
      s.stoppen();
      expect(s.daten.messungen.values.single.tag, freitag);
    });

    test('Messung zwischen Mitternacht und Tageswechsel gehört zum Vortag', () {
      final (s, _, _) = dienst(jetzt: um(1, 0, tag: freitag.plusTage(1)));
      s.starten();
      expect(s.heuteZustand.laufend!.tag, freitag);
    });

    test('geänderter Tageswechsel gilt für neue Messungen', () {
      final (s, uhr, _) = dienst(jetzt: um(3, 0, tag: freitag.plusTage(1)));
      s.tageswechselSetzen(120);
      expect(s.heute, freitag.plusTage(1));
      expect(() => s.tageswechselSetzen(400), throwsA(isA<FachFehler>()));
      expect(uhr.jetzt(), isNotNull);
    });
  });

  group('Kette für heute ändern', () {
    test('Kette für heute wählen legt eine Ausnahme an und erneuert den Tageslauf', () {
      final (s, uhr, _) = dienst(daten: beispielDaten().kopie(wochenregel: {}));
      s.tagesSicherstellen();
      expect(s.heuteZustand.modus, HeuteModus.keineKette);
      s.ketteFuerTageSetzen([s.heute], 2);
      expect(s.daten.tagesausnahmen[freitag], 2);
      expect(s.daten.wochenregel, isEmpty);
      expect(s.heuteZustand.ketteName, 'Wochenende');
      expect(uhr.jetzt(), isNotNull);
    });

    test('Gemessenes bleibt, Schritte mit Messung gelten als erledigt', () {
      final (s, uhr, _) = dienst();
      s.starten();
      uhr.vor(const Duration(minutes: 1));
      s.stoppen(); // Position 0 = Aufstehen erledigt
      s.ketteFuerTageSetzen([freitag], 2); // Wochenende: Aufstehen, Kaffee
      final z = s.heuteZustand;
      expect(z.ketteName, 'Wochenende');
      expect(z.schritte[0].status, SchrittStatus.erledigt);
      expect(z.naechstesEreignisId, 4);
      expect(z.messungen.single.ketteName, 'Arbeitstag');
    });

    test('Änderungen im Editor gelten erst ab morgen', () {
      final (s, uhr, _) = dienst();
      s.tagesSicherstellen();
      s.schrittEntfernen(1, 0);
      expect(s.heuteZustand.schritte.length, 3);
      expect(s.laeuftHeute(1), (0, 3));
      uhr.stellen(um(5, 0, tag: const Tag(2026, 11, 9))); // Montag
      s.tagesSicherstellen();
      expect(s.heuteZustand.schritte.length, 2);
    });
  });

  group('Rückgängig', () {
    test('macht die letzte Änderung rückgängig', () {
      final (s, _, _) = dienst();
      final a = s.starten();
      expect(s.rueckgaengig(a), isTrue);
      expect(s.daten.messungen, isEmpty);
      expect(s.daten.tageslaeufe.containsKey(freitag), isTrue);
    });

    test('nicht mehr möglich nach einer weiteren Änderung', () {
      final (s, uhr, _) = dienst();
      final a = s.starten();
      uhr.vor(const Duration(minutes: 1));
      s.stoppen();
      expect(s.rueckgaengig(a), isFalse);
      expect(s.daten.messungen.length, 1);
    });
  });

  test('Änderungen werden gespeichert und gemeldet', () async {
    final (s, _, speicher) = dienst();
    var meldungen = 0;
    s.beobachten(() => meldungen++);
    s.starten();
    await s.gespeichert;
    expect(speicher.stand.messungen.length, 1);
    expect(meldungen, greaterThanOrEqualTo(1));
  });
}
