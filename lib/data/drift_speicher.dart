import 'dart:convert';

import 'package:drift/drift.dart';

import '../domain/domain.dart' as d;
import 'datenbank.dart';

/// Schreibt Datenbestände in die drift-Datenbank. Gespeichert werden nur
/// die Unterschiede zwischen altem und neuem Datenbestand, in einer Transaktion.
class DriftSpeicher implements d.Speicher {
  DriftSpeicher(this.db);
  final StoppDatenbank db;

  static const _tageswechselSchluessel = 'tageswechsel';

  @override
  Future<d.Datenbestand> laden() async {
    final ereignisse = await db.select(db.ereignisse).get();
    final ketten = await db.select(db.ketten).get();
    final schritte = await (db.select(db.schritte)
          ..orderBy([(s) => OrderingTerm(expression: s.ketteId), (s) => OrderingTerm(expression: s.position)]))
        .get();
    final regel = await db.select(db.wochenregel).get();
    final ausnahmen = await db.select(db.tagesausnahmen).get();
    final messungen = await db.select(db.messungen).get();
    final laeufe = await db.select(db.tageslaeufe).get();
    final uebersprungen = await db.select(db.uebersprungen).get();
    final einstellungen = await db.select(db.einstellungen).get();

    final schritteJeKette = <int, List<int>>{};
    for (final s in schritte) {
      schritteJeKette.putIfAbsent(s.ketteId, () => []).add(s.ereignisId);
    }
    final uebersprungenJeTag = <String, Set<int>>{};
    for (final u in uebersprungen) {
      uebersprungenJeTag.putIfAbsent(u.tag, () => {}).add(u.position);
    }
    final tw = einstellungen.where((e) => e.schluessel == _tageswechselSchluessel).firstOrNull;

    return d.Datenbestand(
      ereignisse: {for (final e in ereignisse) e.id: d.Ereignis(id: e.id, name: e.name, archiviert: e.archiviert)},
      ketten: {
        for (final k in ketten)
          k.id: d.Kette(
              id: k.id,
              name: k.name,
              farbe: k.farbe,
              sortierung: k.sortierung,
              schritte: schritteJeKette[k.id] ?? const []),
      },
      wochenregel: {for (final r in regel) if (r.ketteId != null) r.wochentag: r.ketteId},
      tagesausnahmen: {for (final a in ausnahmen) d.Tag.parse(a.tag): a.ketteId},
      messungen: {
        for (final m in messungen)
          m.id: d.Messung(
            id: m.id,
            ereignisId: m.ereignisId,
            start: DateTime.fromMillisecondsSinceEpoch(m.start, isUtc: true),
            stopp: m.stopp == null ? null : DateTime.fromMillisecondsSinceEpoch(m.stopp!, isUtc: true),
            tag: d.Tag.parse(m.tag),
            ketteName: m.ketteName,
            schrittPosition: m.schrittPosition,
          ),
      },
      tageslaeufe: {
        for (final l in laeufe)
          d.Tag.parse(l.tag): d.Tageslauf(
            tag: d.Tag.parse(l.tag),
            ketteId: l.ketteId,
            ketteName: l.ketteName,
            schritte: (jsonDecode(l.schritte) as List).cast<int>(),
            naechster: l.naechster,
            uebersprungen: uebersprungenJeTag[l.tag] ?? const {},
          ),
      },
      einstellungen: d.Einstellungen(
          tageswechsel: tw == null ? d.standardTageswechsel : int.tryParse(tw.wert) ?? d.standardTageswechsel),
    );
  }

  /// Schlüssel, die in [neu] fehlen oder sich geändert haben.
  static (List<K> weg, List<V> neuOderGeaendert) _diff<K, V>(Map<K, V> alt, Map<K, V> neu) {
    final weg = [for (final k in alt.keys) if (!neu.containsKey(k)) k];
    final geaendert = [
      for (final e in neu.entries)
        if (alt[e.key] != e.value || !alt.containsKey(e.key)) e.value,
    ];
    return (weg, geaendert);
  }

  @override
  Future<void> speichern(d.Datenbestand alt, d.Datenbestand neu) => db.transaction(() async {
        final (ereignisWeg, ereignisNeu) = _diff(alt.ereignisse, neu.ereignisse);
        final (ketteWeg, ketteNeu) = _diff(alt.ketten, neu.ketten);
        final (messungWeg, messungNeu) = _diff(alt.messungen, neu.messungen);
        final (laufWeg, laufNeu) = _diff(alt.tageslaeufe, neu.tageslaeufe);
        final regelWeg = [for (final w in alt.wochenregel.keys) if (!neu.wochenregel.containsKey(w)) w];
        final regelNeu = [
          for (final e in neu.wochenregel.entries)
            if (alt.wochenregel[e.key] != e.value || !alt.wochenregel.containsKey(e.key)) e,
        ];
        final ausnahmeWeg = [for (final t in alt.tagesausnahmen.keys) if (!neu.tagesausnahmen.containsKey(t)) t];
        final ausnahmeNeu = [
          for (final e in neu.tagesausnahmen.entries)
            if (alt.tagesausnahmen[e.key] != e.value || !alt.tagesausnahmen.containsKey(e.key)) e,
        ];

        // 1. Löschen (Reihenfolge wegen Fremdschlüsseln und eindeutiger Namen)
        if (messungWeg.isNotEmpty) {
          await (db.delete(db.messungen)..where((m) => m.id.isIn(messungWeg))).go();
        }
        final ketteSchritteNeu = [...ketteWeg, ...ketteNeu.map((k) => k.id)];
        if (ketteSchritteNeu.isNotEmpty) {
          await (db.delete(db.schritte)..where((s) => s.ketteId.isIn(ketteSchritteNeu))).go();
        }
        final laufTageWeg = [...laufWeg, ...laufNeu.map((l) => l.tag)].map((t) => t.toString()).toList();
        if (laufTageWeg.isNotEmpty) {
          await (db.delete(db.uebersprungen)..where((u) => u.tag.isIn(laufTageWeg))).go();
          await (db.delete(db.tageslaeufe)..where((l) => l.tag.isIn(laufWeg.map((t) => t.toString())))).go();
        }
        if (regelWeg.isNotEmpty) {
          await (db.delete(db.wochenregel)..where((r) => r.wochentag.isIn(regelWeg))).go();
        }
        if (ausnahmeWeg.isNotEmpty) {
          await (db.delete(db.tagesausnahmen)..where((a) => a.tag.isIn(ausnahmeWeg.map((t) => t.toString())))).go();
        }
        if (ketteWeg.isNotEmpty) {
          await (db.delete(db.ketten)..where((k) => k.id.isIn(ketteWeg))).go();
        }
        if (ereignisWeg.isNotEmpty) {
          await (db.delete(db.ereignisse)..where((e) => e.id.isIn(ereignisWeg))).go();
        }

        // 2. Schreiben
        for (final e in ereignisNeu) {
          await db.into(db.ereignisse).insertOnConflictUpdate(
              EreignisseCompanion.insert(id: Value(e.id), name: e.name, archiviert: Value(e.archiviert)));
        }
        for (final k in ketteNeu) {
          await db.into(db.ketten).insertOnConflictUpdate(KettenCompanion.insert(
              id: Value(k.id), name: k.name, farbe: k.farbe, sortierung: k.sortierung));
          for (var p = 0; p < k.schritte.length; p++) {
            await db.into(db.schritte).insert(
                SchritteCompanion.insert(ketteId: k.id, position: p, ereignisId: k.schritte[p]));
          }
        }
        for (final r in regelNeu) {
          await db.into(db.wochenregel).insertOnConflictUpdate(
              WochenregelCompanion.insert(wochentag: Value(r.key), ketteId: Value(r.value)));
        }
        for (final a in ausnahmeNeu) {
          await db.into(db.tagesausnahmen).insertOnConflictUpdate(
              TagesausnahmenCompanion.insert(tag: a.key.toString(), ketteId: Value(a.value)));
        }
        // gestoppte vor neuen laufenden schreiben (eindeutiger Index)
        messungNeu.sort((a, b) => (a.laeuft ? 1 : 0).compareTo(b.laeuft ? 1 : 0));
        for (final m in messungNeu) {
          await db.into(db.messungen).insertOnConflictUpdate(MessungenCompanion.insert(
            id: Value(m.id),
            ereignisId: m.ereignisId,
            start: m.start.toUtc().millisecondsSinceEpoch,
            stopp: Value(m.stopp?.toUtc().millisecondsSinceEpoch),
            tag: m.tag.toString(),
            ketteName: Value(m.ketteName),
            schrittPosition: Value(m.schrittPosition),
          ));
        }
        for (final l in laufNeu) {
          await db.into(db.tageslaeufe).insertOnConflictUpdate(TageslaeufeCompanion.insert(
            tag: l.tag.toString(),
            ketteId: Value(l.ketteId),
            ketteName: l.ketteName,
            schritte: jsonEncode(l.schritte),
            naechster: Value(l.naechster),
          ));
          for (final p in l.uebersprungen) {
            await db.into(db.uebersprungen).insert(UebersprungenCompanion.insert(tag: l.tag.toString(), position: p));
          }
        }
        if (alt.einstellungen != neu.einstellungen) {
          await db.into(db.einstellungen).insertOnConflictUpdate(EinstellungenCompanion.insert(
              schluessel: _tageswechselSchluessel, wert: neu.einstellungen.tageswechsel.toString()));
        }
      });
}
