import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/domain.dart';
import '../../state/providers.dart';
import '../gemeinsam.dart';
import '../heute/heute_screen.dart' show LiveZeit;
import '../theme.dart';
import 'messung_sheet.dart';

class Tagesprotokoll extends ConsumerWidget {
  const Tagesprotokoll({super.key, required this.tag});
  final Tag tag;

  Future<void> _ketteAendern(BuildContext context, WidgetRef ref, TagesProtokoll p) async {
    final dienst = ref.read(dienstProvider);
    final wahl = await kettenSheet(
      context,
      dienst.daten,
      titel: 'Kette für ${datumMittel(tag)}',
      untertitel: 'Bestehende Messungen behalten ihren Kettennamen.',
      wochenregelAnbieten: p.kette.hatAusnahme,
      aktuell: p.kette.kette?.id,
    );
    if (wahl == null || !context.mounted) return;
    switch (wahl) {
      case KetteGewaehlt(:final ketteId):
        aktion(context, dienst, () => dienst.ketteFuerTageSetzen([tag], ketteId),
            meldung: 'Kette: ${dienst.daten.ketten[ketteId]?.name}');
      case KeineKetteGewaehlt():
        aktion(context, dienst, () => dienst.ketteFuerTageSetzen([tag], null), meldung: 'Keine Kette');
      case WochenregelGewaehlt():
        aktion(context, dienst, () => dienst.wochenregelVerwenden([tag]), meldung: 'Wochenregel verwendet');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daten = ref.watch(datenProvider);
    final dienst = ref.read(dienstProvider);
    final jetzt = dienst.jetzt;
    final p = tagesProtokoll(daten, tag, jetzt);
    final f = context.farben;
    final k = p.kette.kette;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(child: Text(datumLang(tag), style: ueberschrift(18))),
            Flexible(
              child: KettenChip(
                name: k?.name ?? (p.kette.hatAusnahme ? 'Keine Kette' : null),
                farbe: k?.farbe,
                onTap: () => _ketteAendern(context, ref, p),
              ),
            ),
          ]),
          if (p.kette.hatAusnahme)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Tagesausnahme', style: TextStyle(fontSize: 12, color: f.muted)),
            ),
          const SizedBox(height: 8),
          if (p.istZukunft)
            Text('Zukünftige Tage haben kein Protokoll, nur die Kettenzuweisung.', style: TextStyle(color: f.muted))
          else ...[
            Wrap(spacing: 14, runSpacing: 4, children: [
              _Kennzahl('Messungen', '${p.messungen.length}'),
              _Kennzahl('Gemessen', formatDauer(p.summe)),
              _Kennzahl('Lücken', formatDauer(p.lueckenSumme)),
            ]),
            const SizedBox(height: 8),
            const Divider(),
            for (final e in p.eintraege)
              if (e.messung != null)
                _MessungZeile(messung: e.messung!, daten: daten, anderemKettennamen: e.anderemKettennamen, tag: tag)
              else
                _LueckeZeile(luecke: e.luecke!, tag: tag),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: f.go),
                icon: const Icon(Icons.add),
                label: const Text('Messung nachtragen'),
                onPressed: () => messungSheet(context, ref, tag: tag),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

class _Kennzahl extends StatelessWidget {
  const _Kennzahl(this.titel, this.wert);
  final String titel;
  final String wert;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(titel, style: TextStyle(fontSize: 12, color: context.farben.muted)),
        Text(wert, style: zahl(15, gewicht: FontWeight.w600)),
      ]);
}

class _MessungZeile extends ConsumerWidget {
  const _MessungZeile({
    required this.messung,
    required this.daten,
    required this.anderemKettennamen,
    required this.tag,
  });
  final Messung messung;
  final Datenbestand daten;
  final bool anderemKettennamen;
  final Tag tag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = context.farben;
    final m = messung;
    final archiviert = daten.ereignisse[m.ereignisId]?.archiviert ?? false;
    return InkWell(
      onTap: m.laeuft
          ? () => fehlerZeigen(context, 'Die laufende Messung wird auf dem Haupt-Screen korrigiert.')
          : () => messungSheet(context, ref, tag: tag, messung: m),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 96,
            child: Text(
              m.laeuft ? '${formatUhrzeit(m.start)}–…' : '${formatUhrzeit(m.start)}–${formatUhrzeit(m.stopp!)}',
              style: zahl(13, farbe: f.muted),
            ),
          ),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(daten.ereignisName(m.ereignisId) + (archiviert ? ' (archiviert)' : ''),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              if (anderemKettennamen)
                Text('gemessen unter ${m.ketteName}', style: TextStyle(fontSize: 12, color: f.muted)),
              if (m.laeuft) Text('läuft', style: TextStyle(fontSize: 12, color: f.stop)),
            ]),
          ),
          if (m.laeuft)
            LiveZeit(m, stil: zahl(13, gewicht: FontWeight.w600, farbe: f.stop))
          else
            Text(formatDauer(m.stopp!.difference(m.start)), style: zahl(13)),
        ]),
      ),
    );
  }
}

class _LueckeZeile extends ConsumerWidget {
  const _LueckeZeile({required this.luecke, required this.tag});
  final Luecke luecke;
  final Tag tag;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = context.farben;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: f.paper,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        Icon(Icons.more_vert, size: 16, color: f.muted),
        const SizedBox(width: 6),
        Expanded(
          child: Text('Lücke ${formatDauer(luecke.dauer)}', style: TextStyle(color: f.muted, fontSize: 13)),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: f.go),
          onPressed: () => messungSheet(context, ref, tag: tag, vorbelegtVon: luecke.von, vorbelegtBis: luecke.bis),
          child: const Text('+ nachtragen'),
        ),
      ]),
    );
  }
}
