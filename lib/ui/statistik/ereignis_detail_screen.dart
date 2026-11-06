import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/domain.dart';
import '../../state/providers.dart';
import '../gemeinsam.dart';
import '../theme.dart';
import 'statistik_filter.dart';

class EreignisDetailScreen extends ConsumerWidget {
  const EreignisDetailScreen({super.key, required this.ereignisId});
  final int ereignisId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daten = ref.watch(datenProvider);
    final a = ref.watch(statistikProvider);
    final messungen = gefilterteMessungen(daten, a.filter).where((m) => m.ereignisId == ereignisId).toList();
    final dauern = [for (final m in messungen) m.stopp!.difference(m.start)];
    final k = kennzahlen(dauern);
    return Scaffold(
      appBar: AppBar(title: Text(daten.ereignisName(ereignisId))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          const StatistikFilterKopf(),
          const SizedBox(height: 8),
          if (messungen.isEmpty)
            const LeerHinweis('Keine Messungen im gewählten Zeitraum.')
          else ...[
            _Kennzahlen(k),
            _Abschnitt(
              titel: verlaufProWoche(a.filter) ? 'Verlauf (Ø pro Woche)' : 'Verlauf (Ø pro Tag)',
              child: _VerlaufDiagramm(verlauf(messungen, a.filter), k.median, a.filter),
            ),
            _Abschnitt(
              titel: 'Uhrzeit',
              child: _UhrzeitDiagramm(uhrzeiten(messungen, daten.tageswechsel), daten.tageswechsel, a.filter),
            ),
            _Abschnitt(titel: 'Verteilung', child: _Histogramm(histogramm(dauern))),
            _Abschnitt(titel: 'Nach Wochentag', child: _Wochentage(nachWochentag(messungen))),
          ],
        ],
      ),
    );
  }
}

class _Kennzahlen extends StatelessWidget {
  const _Kennzahlen(this.k);
  final Kennzahlen k;
  @override
  Widget build(BuildContext context) {
    final f = context.farben;
    final werte = [
      ('Ø', formatDauer(k.durchschnitt)),
      ('Median', formatDauer(k.median)),
      ('Anzahl', '${k.anzahl}'),
      ('Min', formatDauer(k.min)),
      ('Max', formatDauer(k.max)),
      ('Summe', formatDauer(k.summe)),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.2,
          children: [
            for (final (t, w) in werte)
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(t, style: TextStyle(fontSize: 12, color: f.muted)),
                FittedBox(child: Text(w, style: zahl(16, gewicht: FontWeight.w600))),
              ]),
          ],
        ),
      ),
    );
  }
}

class _Abschnitt extends StatelessWidget {
  const _Abschnitt({required this.titel, required this.child});
  final String titel;
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(titel, style: ueberschrift(17)),
          const SizedBox(height: 10),
          SizedBox(height: 180, child: child),
        ]),
      );
}

FlGridData _raster(BuildContext context) => FlGridData(
      drawVerticalLine: false,
      getDrawingHorizontalLine: (_) => FlLine(color: context.farben.line.withValues(alpha: 0.6), strokeWidth: 1),
    );

AxisTitles _keine() => const AxisTitles();

AxisTitles _minutenAchse(BuildContext context) => AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 34,
        getTitlesWidget: (v, meta) =>
            v == meta.max ? const SizedBox() : Text(v.round().toString(), style: achsenStil(context)),
      ),
    );

LineTouchTooltipData _linienTooltip(BuildContext context, String Function(LineBarSpot) text) =>
    LineTouchTooltipData(
      getTooltipColor: (_) => context.farben.ink,
      getTooltipItems: (spots) => [
        for (final s in spots)
          s.barIndex == 0 ? LineTooltipItem(text(s), TextStyle(color: context.farben.paper, fontSize: 12)) : null,
      ],
    );

class _VerlaufDiagramm extends StatelessWidget {
  const _VerlaufDiagramm(this.punkte, this.median, this.filter);
  final List<VerlaufPunkt> punkte;
  final Duration median;
  final StatistikFilter filter;

  @override
  Widget build(BuildContext context) {
    final f = context.farben;
    double x(Tag t) => t.tageSeit(filter.von).toDouble();
    return LineChart(LineChartData(
      minX: 0,
      maxX: math.max(1, filter.anzahlTage - 1).toDouble(),
      minY: 0,
      gridData: _raster(context),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: _keine(),
        rightTitles: _keine(),
        leftTitles: _minutenAchse(context),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            interval: math.max(1, (filter.anzahlTage / 4).floorToDouble()),
            getTitlesWidget: (v, meta) => Text(datumKurz(filter.von.plusTage(v.round())), style: achsenStil(context)),
          ),
        ),
      ),
      extraLinesData: ExtraLinesData(horizontalLines: [
        HorizontalLine(y: minuten(median), color: f.muted, strokeWidth: 1, dashArray: const [5, 4]),
      ]),
      lineTouchData: LineTouchData(
        touchTooltipData: _linienTooltip(context, (s) {
          final p = punkte[s.spotIndex];
          return '${datumKurz(p.tag)}: Ø ${formatDauer(p.durchschnitt)}';
        }),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: [for (final p in punkte) FlSpot(x(p.tag), minuten(p.durchschnitt))],
          color: f.go,
          barWidth: 2.5,
          dotData: FlDotData(show: punkte.length < 40),
        ),
      ],
    ));
  }
}

class _UhrzeitDiagramm extends StatelessWidget {
  const _UhrzeitDiagramm(this.u, this.tageswechsel, this.filter);
  final UhrzeitAuswertung u;
  final int tageswechsel;
  final StatistikFilter filter;

  @override
  Widget build(BuildContext context) {
    final f = context.farben;
    final ys = u.punkte.map((p) => p.minutenSeitTageswechsel.toDouble());
    final minY = (ys.reduce(math.min) / 60).floor() * 60.0;
    final maxY = math.max(minY + 60, (ys.reduce(math.max) / 60).ceil() * 60.0);
    return ScatterChart(ScatterChartData(
      minX: 0,
      maxX: math.max(1, filter.anzahlTage - 1).toDouble(),
      minY: minY,
      maxY: maxY,
      gridData: _raster(context),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: _keine(),
        rightTitles: _keine(),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: math.max(60, ((maxY - minY) / 4 / 60).ceil() * 60).toDouble(),
            getTitlesWidget: (v, meta) => Text(uhrzeitAusMinuten(v.round(), tageswechsel), style: achsenStil(context)),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            interval: math.max(1, (filter.anzahlTage / 4).floorToDouble()),
            getTitlesWidget: (v, meta) => Text(datumKurz(filter.von.plusTage(v.round())), style: achsenStil(context)),
          ),
        ),
      ),
      scatterSpots: [
        for (final p in u.punkte)
          ScatterSpot(
            p.tag.tageSeit(filter.von).toDouble(),
            p.minutenSeitTageswechsel.toDouble(),
            dotPainter: FlDotCirclePainter(radius: 4, color: f.go),
          ),
      ],
      scatterTouchData: ScatterTouchData(
        touchTooltipData: ScatterTouchTooltipData(
          getTooltipColor: (_) => f.ink,
          getTooltipItems: (s) => ScatterTooltipItem(
            '${datumKurz(filter.von.plusTage(s.x.round()))}: ${uhrzeitAusMinuten(s.y.round(), tageswechsel)}',
            textStyle: TextStyle(color: f.paper, fontSize: 12),
          ),
        ),
      ),
    ), duration: Duration.zero)
        .withDurchschnitt(context, u.durchschnitt, minY, maxY, tageswechsel);
  }
}

extension on ScatterChart {
  Widget withDurchschnitt(BuildContext context, int? avg, double minY, double maxY, int tageswechsel) {
    if (avg == null) return this;
    final f = context.farben;
    return Stack(children: [
      Positioned.fill(child: this),
      Positioned(
        right: 0,
        top: 0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: f.goSoft, borderRadius: BorderRadius.circular(8)),
          child: Text('Ø-Start ${uhrzeitAusMinuten(avg, tageswechsel)}', style: zahl(12, farbe: f.ink)),
        ),
      ),
    ]);
  }
}

BarTouchData _balkenTooltip(BuildContext context, String Function(int gruppe, double wert) text) => BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (_) => context.farben.ink,
        getTooltipItem: (g, gi, rod, ri) =>
            BarTooltipItem(text(g.x, rod.toY), TextStyle(color: context.farben.paper, fontSize: 12)),
      ),
    );

class _Histogramm extends StatelessWidget {
  const _Histogramm(this.klassen);
  final List<HistogrammKlasse> klassen;

  @override
  Widget build(BuildContext context) {
    final f = context.farben;
    String bereich(HistogrammKlasse k) => '${formatDauer(k.von)}–${formatDauer(k.bis)}';
    return BarChart(BarChartData(
      gridData: _raster(context),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: _keine(),
        rightTitles: _keine(),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            getTitlesWidget: (v, meta) => v == meta.max || v != v.roundToDouble()
                ? const SizedBox()
                : Text(v.round().toString(), style: achsenStil(context)),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTitlesWidget: (v, meta) {
              final i = v.round();
              if (i != 0 && i != klassen.length - 1 && i != klassen.length ~/ 2) return const SizedBox();
              return Text('${minuten(klassen[i].von).round()}′', style: achsenStil(context));
            },
          ),
        ),
      ),
      barTouchData: _balkenTooltip(context, (g, w) => '${bereich(klassen[g])}: ${w.round()}×'),
      barGroups: [
        for (var i = 0; i < klassen.length; i++)
          BarChartGroupData(x: i, barRods: [
            BarChartRodData(
              toY: klassen[i].anzahl.toDouble(),
              color: f.go,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
            ),
          ]),
      ],
    ));
  }
}

class _Wochentage extends StatelessWidget {
  const _Wochentage(this.werte);
  final List<Duration?> werte;
  @override
  Widget build(BuildContext context) {
    final f = context.farben;
    return BarChart(BarChartData(
      gridData: _raster(context),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: _keine(),
        rightTitles: _keine(),
        leftTitles: _minutenAchse(context),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTitlesWidget: (v, meta) => Text(wochentagKurz[v.round()], style: achsenStil(context)),
          ),
        ),
      ),
      barTouchData: _balkenTooltip(context, (g, w) {
        final d = werte[g];
        return '${wochentagKurz[g]}: ${d == null ? '–' : 'Ø ${formatDauer(d)}'}';
      }),
      barGroups: [
        for (var i = 0; i < 7; i++)
          BarChartGroupData(x: i, barRods: [
            BarChartRodData(
              toY: werte[i] == null ? 0 : minuten(werte[i]!),
              color: f.go,
              width: 18,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
            ),
          ]),
      ],
    ));
  }
}
