import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/domain.dart';
import '../../state/providers.dart';
import '../gemeinsam.dart';
import '../theme.dart';

int isoKalenderwoche(Tag t) {
  final donnerstag = t.plusTage(4 - t.wochentag);
  final jan1 = Tag(donnerstag.jahr, 1, 1);
  return donnerstag.tageSeit(jan1) ~/ 7 + 1;
}

String zeitraumText(StatistikAuswahl a) {
  switch (a.zeitraum) {
    case Zeitraum.woche:
      return 'KW ${isoKalenderwoche(a.von)} · ${datumKurz(a.von)}–${datumKurz(a.bis)} ${a.bis.jahr}';
    case Zeitraum.monat:
      return monatJahr(a.von.datum);
    case Zeitraum.jahr:
      return '${a.von.jahr}';
    case Zeitraum.frei:
      final fmt = DateFormat('d. M. yyyy', locale);
      return '${fmt.format(a.von.datum)} – ${fmt.format(a.bis.datum)}';
  }
}

/// Filter oben: Zeitraum, Tageskette, Wochentage, Zusammenfassung.
class StatistikFilterKopf extends ConsumerWidget {
  const StatistikFilterKopf({super.key});

  Future<void> _freiWaehlen(BuildContext context, WidgetRef ref, StatistikAuswahl a) async {
    final heute = ref.read(dienstProvider).heute;
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: heute.datum,
      initialDateRange: DateTimeRange(
        start: a.von.datum,
        end: a.bis.istNach(heute) ? heute.datum : a.bis.datum,
      ),
      locale: const Locale('de', 'AT'),
    );
    if (r == null) return;
    ref.read(statistikProvider.notifier).freiSetzen(Tag.ausDatum(r.start), Tag.ausDatum(r.end));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(statistikProvider);
    final notifier = ref.read(statistikProvider.notifier);
    final daten = ref.watch(datenProvider);
    final f = context.farben;
    final namen = kettennamenInMessungen(daten);
    final tage = tageMitMessungen(gefilterteMessungen(daten, a.filter));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SegmentedButton<Zeitraum>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(value: Zeitraum.woche, label: Text('Woche')),
          ButtonSegment(value: Zeitraum.monat, label: Text('Monat')),
          ButtonSegment(value: Zeitraum.jahr, label: Text('Jahr')),
          ButtonSegment(value: Zeitraum.frei, label: Text('Frei')),
        ],
        selected: {a.zeitraum},
        onSelectionChanged: (s) {
          notifier.zeitraumWaehlen(s.first);
          if (s.first == Zeitraum.frei) _freiWaehlen(context, ref, ref.read(statistikProvider));
        },
      ),
      const SizedBox(height: 4),
      Row(children: [
        if (a.zeitraum != Zeitraum.frei)
          IconButton(
              tooltip: 'Zurück', icon: const Icon(Icons.chevron_left), onPressed: () => notifier.blaettern(-1)),
        Expanded(
          child: a.zeitraum == Zeitraum.frei
              ? TextButton(onPressed: () => _freiWaehlen(context, ref, a), child: Text(zeitraumText(a)))
              : Text(zeitraumText(a), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
        if (a.zeitraum != Zeitraum.frei)
          IconButton(
            tooltip: 'Weiter',
            icon: const Icon(Icons.chevron_right),
            onPressed: notifier.kannVor ? () => notifier.blaettern(1) : null,
          ),
      ]),
      Row(children: [
        Text('Tageskette', style: TextStyle(color: f.muted)),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButton<String?>(
            isExpanded: true,
            value: namen.contains(a.ketteName) ? a.ketteName : null,
            underline: const SizedBox(),
            items: [
              const DropdownMenuItem(value: null, child: Text('Alle Ketten')),
              for (final n in namen) DropdownMenuItem(value: n, child: Text(n)),
            ],
            onChanged: notifier.ketteSetzen,
          ),
        ),
      ]),
      Wrap(spacing: 4, runSpacing: 4, children: [
        for (var w = 1; w <= 7; w++)
          FilterChip(
            label: Text(wochentagKurz[w - 1]),
            selected: a.wochentage.contains(w),
            showCheckmark: false,
            visualDensity: VisualDensity.compact,
            onSelected: (_) => notifier.wochentagUmschalten(w),
          ),
      ]),
      const SizedBox(height: 6),
      Row(children: [
        Text('$tage ${tage == 1 ? 'Tag' : 'Tage'} mit Messungen', style: TextStyle(color: f.muted)),
        const Spacer(),
        if (a.filterAktiv)
          TextButton(
            style: TextButton.styleFrom(foregroundColor: f.go),
            onPressed: notifier.zuruecksetzen,
            child: const Text('zurücksetzen'),
          ),
      ]),
    ]);
  }
}

/// Minuten als Zahl für Diagramme.
double minuten(Duration d) => d.inSeconds / 60;

TextStyle achsenStil(BuildContext context) => zahl(10, farbe: context.farben.muted);
