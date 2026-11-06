import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/domain.dart';
import '../../state/providers.dart';
import '../gemeinsam.dart';
import '../theme.dart';
import 'tagesprotokoll.dart';

enum _Auswahlmodus { tag, auswaehlen, vonBis }

class KalenderScreen extends ConsumerStatefulWidget {
  const KalenderScreen({super.key});
  @override
  ConsumerState<KalenderScreen> createState() => _KalenderScreenState();
}

class _KalenderScreenState extends ConsumerState<KalenderScreen> {
  late DateTime _monat;
  late Tag _gewaehlt;
  _Auswahlmodus _modus = _Auswahlmodus.tag;
  final Set<Tag> _mehrere = {};
  Tag? _vonBisStart;

  @override
  void initState() {
    super.initState();
    final heute = ref.read(dienstProvider).heute;
    _gewaehlt = heute;
    _monat = DateTime(heute.jahr, heute.monat);
  }

  void _antippen(Tag t) {
    setState(() {
      switch (_modus) {
        case _Auswahlmodus.tag:
          _gewaehlt = t;
        case _Auswahlmodus.auswaehlen:
          if (!_mehrere.remove(t)) _mehrere.add(t);
        case _Auswahlmodus.vonBis:
          final start = _vonBisStart;
          if (start == null || _mehrere.length > 1) {
            _vonBisStart = t;
            _mehrere
              ..clear()
              ..add(t);
          } else {
            final (a, b) = start.istVor(t) ? (start, t) : (t, start);
            _mehrere.clear();
            for (var d = a; !d.istNach(b); d = d.plusTage(1)) {
              _mehrere.add(d);
            }
            _vonBisStart = null;
          }
      }
    });
  }

  void _modusSetzen(_Auswahlmodus m) => setState(() {
        _modus = m;
        _mehrere.clear();
        _vonBisStart = null;
      });

  Future<void> _mehrereZuweisen() async {
    final dienst = ref.read(dienstProvider);
    final tage = _mehrere.toList()..sort();
    final mitAusnahme = tage.any((t) => dienst.daten.tagesausnahmen.containsKey(t));
    final wahl = await kettenSheet(context, dienst.daten,
        titel: '${tage.length} ${tage.length == 1 ? 'Tag' : 'Tage'} · Kette', wochenregelAnbieten: mitAusnahme);
    if (wahl == null || !mounted) return;
    final ok = switch (wahl) {
      KetteGewaehlt(:final ketteId) => aktion(context, dienst, () => dienst.ketteFuerTageSetzen(tage, ketteId),
          meldung: '${tage.length} Tage: ${dienst.daten.ketten[ketteId]?.name}'),
      KeineKetteGewaehlt() => aktion(context, dienst, () => dienst.ketteFuerTageSetzen(tage, null),
          meldung: '${tage.length} Tage: Keine Kette'),
      WochenregelGewaehlt() => aktion(context, dienst, () => dienst.wochenregelVerwenden(tage),
          meldung: '${tage.length} Tage: Wochenregel'),
    };
    if (ok) setState(_mehrere.clear);
  }

  @override
  Widget build(BuildContext context) {
    final daten = ref.watch(datenProvider);
    final heute = ref.watch(heuteTagProvider);
    ref.watch(sekundenProvider);
    final f = context.farben;
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                Row(children: [
                  Expanded(child: Text('Kalender', style: ueberschrift(26, gewicht: FontWeight.w800))),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.event_repeat, size: 18),
                    label: const Text('Wochenregel'),
                    onPressed: () => wochenregelSheet(context, ref),
                  ),
                ]),
                const SizedBox(height: 12),
                SegmentedButton<_Auswahlmodus>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: _Auswahlmodus.tag, label: Text('Tag')),
                    ButtonSegment(value: _Auswahlmodus.auswaehlen, label: Text('Auswählen')),
                    ButtonSegment(value: _Auswahlmodus.vonBis, label: Text('Von–bis')),
                  ],
                  selected: {_modus},
                  onSelectionChanged: (s) => _modusSetzen(s.first),
                ),
                const SizedBox(height: 12),
                _Monatsraster(
                  monat: _monat,
                  daten: daten,
                  heute: heute,
                  gewaehlt: _modus == _Auswahlmodus.tag ? {_gewaehlt} : _mehrere,
                  onTap: _antippen,
                  onMonat: (d) => setState(() => _monat = DateTime(_monat.year, _monat.month + d)),
                ),
                const SizedBox(height: 8),
                _Legende(daten: daten),
                const SizedBox(height: 16),
                if (_modus == _Auswahlmodus.tag)
                  Tagesprotokoll(tag: _gewaehlt)
                else
                  Text(
                    _modus == _Auswahlmodus.auswaehlen
                        ? 'Tippe einzelne Tage an.'
                        : (_vonBisStart == null ? 'Tippe den ersten Tag an.' : 'Tippe den letzten Tag an.'),
                    style: TextStyle(color: f.muted),
                  ),
              ],
            ),
          ),
          if (_modus != _Auswahlmodus.tag && _mehrere.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              decoration: BoxDecoration(color: f.surface, border: Border(top: BorderSide(color: f.line))),
              child: Row(children: [
                Expanded(
                  child: Text('${_mehrere.length} ${_mehrere.length == 1 ? 'Tag' : 'Tage'}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                TextButton(onPressed: () => setState(_mehrere.clear), child: const Text('Leeren')),
                FilledButton(onPressed: _mehrereZuweisen, child: const Text('Kette …')),
              ]),
            ),
        ],
      ),
    );
  }
}

class _Monatsraster extends StatelessWidget {
  const _Monatsraster({
    required this.monat,
    required this.daten,
    required this.heute,
    required this.gewaehlt,
    required this.onTap,
    required this.onMonat,
  });
  final DateTime monat;
  final Datenbestand daten;
  final Tag heute;
  final Set<Tag> gewaehlt;
  final void Function(Tag) onTap;
  final void Function(int) onMonat;

  @override
  Widget build(BuildContext context) {
    final f = context.farben;
    final erster = Tag(monat.year, monat.month, 1);
    final start = erster.plusTage(1 - erster.wochentag);
    final letzter = Tag.ausDatum(DateTime.utc(monat.year, monat.month + 1, 0));
    final wochen = ((letzter.tageSeit(start) + 1) / 7).ceil();
    final summen = <Tag, Duration>{};
    for (final m in daten.messungen.values) {
      if (m.laeuft) continue;
      summen[m.tag] = (summen[m.tag] ?? Duration.zero) + m.stopp!.difference(m.start);
    }
    return Column(children: [
      Row(children: [
        IconButton(tooltip: 'Voriger Monat', icon: const Icon(Icons.chevron_left), onPressed: () => onMonat(-1)),
        Expanded(
          child: Text(monatJahr(monat), textAlign: TextAlign.center, style: ueberschrift(18)),
        ),
        IconButton(tooltip: 'Nächster Monat', icon: const Icon(Icons.chevron_right), onPressed: () => onMonat(1)),
      ]),
      Row(children: [
        for (final w in wochentagKurz)
          Expanded(
            child: Center(
              child: Text(w, style: TextStyle(fontSize: 12, color: f.muted, fontWeight: FontWeight.w700)),
            ),
          ),
      ]),
      const SizedBox(height: 4),
      for (var w = 0; w < wochen; w++)
        Row(children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: _Zelle(
                tag: start.plusTage(w * 7 + i),
                imMonat: start.plusTage(w * 7 + i).monat == monat.month,
                daten: daten,
                heute: heute,
                summe: summen[start.plusTage(w * 7 + i)],
                gewaehlt: gewaehlt.contains(start.plusTage(w * 7 + i)),
                onTap: onTap,
              ),
            ),
        ]),
    ]);
  }
}

class _Zelle extends StatelessWidget {
  const _Zelle({
    required this.tag,
    required this.imMonat,
    required this.daten,
    required this.heute,
    required this.summe,
    required this.gewaehlt,
    required this.onTap,
  });
  final Tag tag;
  final bool imMonat;
  final Datenbestand daten;
  final Tag heute;
  final Duration? summe;
  final bool gewaehlt;
  final void Function(Tag) onTap;

  @override
  Widget build(BuildContext context) {
    final f = context.farben;
    final info = tageskette(daten, tag);
    final k = info.kette;
    final ausnahme = info.hatAusnahme && k != null;
    final Color hintergrund = k == null ? Colors.transparent : (ausnahme ? f.kette(k.farbe) : f.ketteHell(k.farbe));
    final Color schrift = ausnahme ? f.onSolid : f.ink;
    final istHeute = tag == heute;
    final vergangen = tag.istVor(heute) || istHeute;
    return Opacity(
      opacity: imMonat ? 1 : 0.35,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Material(
          color: hintergrund,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => onTap(tag),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: gewaehlt
                    ? Border.all(color: f.ink, width: 2.5)
                    : (istHeute ? Border.all(color: f.go, width: 2) : null),
              ),
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text('${tag.tagImMonat}',
                        style: TextStyle(
                            fontWeight: istHeute ? FontWeight.w700 : FontWeight.w400, color: schrift, fontSize: 13)),
                    const Spacer(),
                    if (ausnahme)
                      Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(color: f.onSolid, shape: BoxShape.circle)),
                  ]),
                  const Spacer(),
                  if (vergangen && summe != null && summe! > Duration.zero)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(_kurzDauer(summe!), style: zahl(10, farbe: schrift)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kompakte Summe für die Kalenderzelle.
String _kurzDauer(Duration d) {
  final m = d.inMinutes;
  if (m < 60) return '${m}m';
  return '${m ~/ 60}h${(m % 60).toString().padLeft(2, '0')}';
}

class _Legende extends StatelessWidget {
  const _Legende({required this.daten});
  final Datenbestand daten;
  @override
  Widget build(BuildContext context) {
    final f = context.farben;
    Widget eintrag(Widget symbol, String text) => Row(mainAxisSize: MainAxisSize.min, children: [
          symbol,
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 12, color: f.muted)),
        ]);
    Widget feld(Color c, {bool punkt = false, Color? rand}) => Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(4),
            border: rand == null ? null : Border.all(color: rand, width: 2),
          ),
          alignment: Alignment.center,
          child: punkt
              ? Container(width: 5, height: 5, decoration: BoxDecoration(color: f.onSolid, shape: BoxShape.circle))
              : null,
        );
    return Wrap(spacing: 14, runSpacing: 6, children: [
      eintrag(feld(f.ketteHell(0)), 'Wochenregel'),
      eintrag(feld(f.kette(0), punkt: true), 'Tagesausnahme'),
      eintrag(feld(Colors.transparent, rand: f.go), 'Heute'),
      for (final k in daten.kettenSortiert) eintrag(KettenPunkt(k.farbe), k.name),
    ]);
  }
}

/// Sheet mit einer Auswahl je Wochentag. Ausnahmen bleiben bestehen.
Future<void> wochenregelSheet(BuildContext context, WidgetRef ref) async {
  final dienst = ref.read(dienstProvider);
  final daten = dienst.daten;
  final regel = <int, int?>{for (var w = 1; w <= 7; w++) w: daten.wochenregel[w]};
  final speichern = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (c) => StatefulBuilder(
      builder: (c, setState) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SheetTitel('Wochenregel', untertitel: 'Tagesausnahmen bleiben bestehen.'),
          for (var w = 1; w <= 7; w++)
            ListTile(
              title: Text(const ['Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag'][w - 1]),
              trailing: DropdownButton<int?>(
                value: regel[w],
                underline: const SizedBox(),
                items: [
                  for (final k in daten.kettenSortiert)
                    DropdownMenuItem(
                      value: k.id,
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        KettenPunkt(k.farbe),
                        const SizedBox(width: 8),
                        Text(k.name),
                      ]),
                    ),
                  const DropdownMenuItem(value: null, child: Text('Keine Kette')),
                ],
                onChanged: (v) => setState(() => regel[w] = v),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Speichern')),
          ),
        ]),
      ),
    ),
  );
  if (speichern == true && context.mounted) {
    aktion(context, dienst, () => dienst.wochenregelSetzen(regel), meldung: 'Wochenregel gespeichert');
  }
}
