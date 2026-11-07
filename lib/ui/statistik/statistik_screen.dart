import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/domain.dart';
import '../../state/providers.dart';
import '../gemeinsam.dart';
import '../theme.dart';
import 'ereignis_detail_screen.dart';
import 'statistik_filter.dart';

class StatistikScreen extends StatelessWidget {
  const StatistikScreen({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Text('Statistik', style: ueberschrift(26, gewicht: FontWeight.w800)),
                    const SizedBox(height: 12),
                    const StatistikFilterKopf(),
                  ]),
                ),
              ),
              const SliverToBoxAdapter(child: TabBar(tabs: [Tab(text: 'Ereignisse'), Tab(text: 'Mein Tag')])),
            ],
            body: const TabBarView(children: [_EreignisseTab(), _MeinTagTab()]),
          ),
        ),
      );
}

class _EreignisseTab extends ConsumerWidget {
  const _EreignisseTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daten = ref.watch(datenProvider);
    final a = ref.watch(statistikProvider);
    final zeilen = ereignisUebersicht(daten, a.filter);
    final f = context.farben;
    if (zeilen.isEmpty) return const LeerHinweis('Keine Messungen im gewählten Zeitraum.');
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: zeilen.length,
      separatorBuilder: (_, _) => const Divider(indent: 16, endIndent: 16),
      itemBuilder: (context, i) {
        final z = zeilen[i];
        return InkWell(
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute<void>(builder: (_) => EreignisDetailScreen(ereignisId: z.ereignisId))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(children: [
              Expanded(
                flex: 5,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(z.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text('${z.kennzahlen.anzahl}× · ${formatDauer(z.kennzahlen.summe)}',
                      style: zahl(12, farbe: f.muted)),
                ]),
              ),
              SizedBox(width: 70, height: 28, child: _Sparkline(z.verlauf)),
              const SizedBox(width: 12),
              SizedBox(
                width: 76,
                child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('Ø', style: TextStyle(fontSize: 11, color: f.muted)),
                  Text(formatDauer(z.kennzahlen.durchschnitt), style: zahl(13, gewicht: FontWeight.w600)),
                ]),
              ),
            ]),
          ),
        );
      },
    );
  }
}

class _Sparkline extends StatelessWidget {
  const _Sparkline(this.punkte);
  final List<VerlaufPunkt> punkte;
  @override
  Widget build(BuildContext context) {
    if (punkte.length < 2) return const SizedBox();
    final f = context.farben;
    return LineChart(LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineTouchData: const LineTouchData(enabled: false),
      lineBarsData: [
        LineChartBarData(
          spots: [for (var i = 0; i < punkte.length; i++) FlSpot(i.toDouble(), minuten(punkte[i].durchschnitt))],
          color: f.go,
          barWidth: 2,
          dotData: const FlDotData(show: false),
          isCurved: false,
        ),
      ],
    ));
  }
}

class _MeinTagTab extends ConsumerWidget {
  const _MeinTagTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daten = ref.watch(datenProvider);
    final a = ref.watch(statistikProvider);
    final t = meinTag(daten, a.filter);
    final f = context.farben;
    if (t.tage == 0) return const LeerHinweis('Keine Messungen im gewählten Zeitraum.');
    final maxMin = t.zeilen.map((z) => minuten(z.proTag)).fold<double>(0, (a, b) => a > b ? a : b);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Expanded(child: Text('Gemessen pro Tag (Ø)', style: TextStyle(color: f.muted))),
              Text(formatDauer(t.summeProTag), style: zahl(20, gewicht: FontWeight.w600)),
            ]),
          ),
        ),
        const SizedBox(height: 8),
        Text('Ø pro Tag, bezogen auf ${t.tage} ${t.tage == 1 ? 'Tag' : 'Tage'} mit Messungen',
            style: TextStyle(color: f.muted, fontSize: 12)),
        const SizedBox(height: 12),
        for (final z in t.zeilen)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Tooltip(
              triggerMode: TooltipTriggerMode.tap,
              message: '${z.name}: Ø ${formatDauer(z.proTag)} pro Tag',
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(z.name)),
                  Text(formatDauer(z.proTag), style: zahl(13)),
                ]),
                const SizedBox(height: 4),
                LayoutBuilder(
                  builder: (context, c) => Container(
                    height: 12,
                    width: maxMin == 0 ? 0 : c.maxWidth * minuten(z.proTag) / maxMin,
                    decoration: BoxDecoration(color: f.go, borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ]),
            ),
          ),
      ],
    );
  }
}
