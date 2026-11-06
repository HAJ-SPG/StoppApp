import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stoppapp/data/datenbank.dart';
import 'package:stoppapp/data/drift_speicher.dart';
import 'package:stoppapp/domain/domain.dart';

import '../domain/hilfen.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late StoppDatenbank db;
  late DriftSpeicher speicher;

  setUp(() {
    db = StoppDatenbank(NativeDatabase.memory());
    speicher = DriftSpeicher(db);
  });
  tearDown(() => db.close());

  Future<StoppDienst> dienstMitDb(FesteUhr uhr) async {
    await speicher.speichern(const Datenbestand(), beispielDaten());
    return StoppDienst(daten: await speicher.laden(), uhr: uhr, speicher: speicher);
  }

  test('leere Datenbank lädt einen leeren Datenbestand mit Standard-Tageswechsel', () async {
    final d = await speicher.laden();
    expect(d.ereignisse, isEmpty);
    expect(d.tageswechsel, 240);
  });

  test('Rundreise: alles, was die Fachlogik ändert, kommt identisch zurück', () async {
    final uhr = FesteUhr(um(7, 0));
    final s = await dienstMitDb(uhr);
    s.starten();
    uhr.vor(const Duration(minutes: 5));
    s.stoppen();
    s.ueberspringen();
    s.naechstesWaehlen(1);
    s.einschiebenNeu('Zeitung');
    s.ketteFuerTageSetzen([freitag.plusTage(2)], null);
    s.ketteFuerTageSetzen([freitag.plusTage(3)], 2);
    s.schrittHinzufuegen(1, 4);
    s.schrittVerschieben(1, 3, 0);
    s.tageswechselSetzen(180);
    await s.gespeichert;
    final geladen = await speicher.laden();
    expect(geladen.ereignisse, s.daten.ereignisse);
    expect(geladen.ketten, s.daten.ketten);
    expect(geladen.wochenregel, s.daten.wochenregel);
    expect(geladen.tagesausnahmen, s.daten.tagesausnahmen);
    expect(geladen.messungen, s.daten.messungen);
    expect(geladen.tageslaeufe, s.daten.tageslaeufe);
    expect(geladen.einstellungen, s.daten.einstellungen);
  });

  test('Löschen von Ketten und Ereignissen, Rückgängig', () async {
    final uhr = FesteUhr(um(7, 0));
    final s = await dienstMitDb(uhr);
    s.ereignisEntfernen(2);
    final a = s.ketteLoeschen(1, ersatz: 2);
    await s.gespeichert;
    var geladen = await speicher.laden();
    expect(geladen.ketten.keys, [2]);
    expect(geladen.ereignisse.containsKey(2), isFalse);
    expect(geladen.wochenregel.values.toSet(), {2});
    expect(await db.select(db.schritte).get(), hasLength(2));
    s.rueckgaengig(a);
    await s.gespeichert;
    geladen = await speicher.laden();
    expect(geladen.ketten, s.daten.ketten);
    expect(geladen.wochenregel, s.daten.wochenregel);
  });

  test('Datenbank erlaubt höchstens eine laufende Messung', () async {
    await db.into(db.messungen).insert(
        MessungenCompanion.insert(ereignisId: 1, start: 1, tag: '2026-11-06'));
    expect(
      () => db.into(db.messungen).insert(MessungenCompanion.insert(ereignisId: 1, start: 2, tag: '2026-11-06')),
      throwsA(anything),
    );
  });
}
