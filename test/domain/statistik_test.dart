import 'package:stoppapp/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hilfen.dart';

Messung m(int id, int ereignis, Tag tag, int startMin, int dauerMin, {String? kette = 'Arbeitstag'}) {
  final start = DateTime(tag.jahr, tag.monat, tag.tagImMonat, 6).add(Duration(minutes: startMin));
  return Messung(
    id: id,
    ereignisId: ereignis,
    start: start.toUtc(),
    stopp: start.add(Duration(minutes: dauerMin)).toUtc(),
    tag: tag,
    ketteName: kette,
  );
}

void main() {
  final mo = const Tag(2026, 11, 2);
  final daten = beispielDaten().kopie(messungen: {
    1: m(1, 1, mo, 0, 10),
    2: m(2, 2, mo, 15, 4),
    3: m(3, 1, mo.plusTage(1), 30, 20),
    4: m(4, 1, mo.plusTage(5), 60, 30, kette: 'Wochenende'),
    5: m(5, 3, mo.plusTage(7), 0, 45), // nächste Woche
    6: Messung(id: 6, ereignisId: 4, start: DateTime.utc(2026, 11, 3, 8), tag: mo.plusTage(1)), // läuft
  });
  final woche = StatistikFilter(von: mo, bis: mo.plusTage(6));

  test('Kalenderzeiträume', () {
    expect(kalenderZeitraum(Zeitraum.woche, const Tag(2026, 11, 6)), (mo, const Tag(2026, 11, 8)));
    expect(kalenderZeitraum(Zeitraum.monat, const Tag(2026, 2, 10)),
        (const Tag(2026, 2, 1), const Tag(2026, 2, 28)));
    expect(zeitraumVerschieben(Zeitraum.monat, const Tag(2026, 1, 1), -1),
        (const Tag(2025, 12, 1), const Tag(2025, 12, 31)));
    expect(zeitraumVerschieben(Zeitraum.woche, mo, 1).$1, mo.plusTage(7));
  });

  test('Filter: Zeitraum, laufende zählt nicht', () {
    final ms = gefilterteMessungen(daten, woche);
    expect(ms.map((x) => x.id), [1, 2, 3, 4]);
    expect(tageMitMessungen(ms), 3);
  });

  test('Filter: Kettenname und Wochentage', () {
    final f = StatistikFilter(von: mo, bis: mo.plusTage(6), ketteName: 'Wochenende');
    expect(gefilterteMessungen(daten, f).map((x) => x.id), [4]);
    final f2 = StatistikFilter(von: mo, bis: mo.plusTage(6), wochentage: {2});
    expect(gefilterteMessungen(daten, f2).map((x) => x.id), [3]);
    expect(kettennamenInMessungen(daten), ['Arbeitstag', 'Wochenende']);
  });

  test('Ereignis-Übersicht nach Summe sortiert', () {
    final z = ereignisUebersicht(daten, woche);
    expect(z.map((x) => x.name), ['Aufstehen', 'Zähneputzen']);
    expect(z.first.kennzahlen.summe, const Duration(minutes: 60));
    expect(z.first.kennzahlen.anzahl, 3);
    expect(z.first.kennzahlen.durchschnitt, const Duration(minutes: 20));
  });

  test('Kennzahlen mit Median', () {
    final k = kennzahlen(const [Duration(minutes: 4), Duration(minutes: 1), Duration(minutes: 10), Duration(minutes: 3)]);
    expect(k.median, const Duration(seconds: 210));
    expect(k.min, const Duration(minutes: 1));
    expect(k.max, const Duration(minutes: 10));
    expect(k.summe, const Duration(minutes: 18));
    expect(kennzahlen(const [Duration(minutes: 4), Duration(minutes: 1), Duration(minutes: 9)]).median,
        const Duration(minutes: 4));
  });

  test('Verlauf pro Tag, über 45 Tage pro Woche', () {
    final ms = gefilterteMessungen(daten, woche).where((x) => x.ereignisId == 1).toList();
    expect(verlauf(ms, woche).length, 3);
    final lang = StatistikFilter(von: mo, bis: mo.plusTage(60));
    final ms2 = gefilterteMessungen(daten, lang).where((x) => x.ereignisId == 1).toList();
    final v = verlauf(ms2, lang);
    expect(v.length, 1);
    expect(v.single.tag, mo);
    expect(v.single.durchschnitt, const Duration(minutes: 20));
  });

  test('Uhrzeit: Startzeiten und Ø-Start', () {
    final ms = gefilterteMessungen(daten, woche).where((x) => x.ereignisId == 1).toList();
    final u = uhrzeiten(ms, 240);
    expect(u.punkte.map((p) => p.minutenSeitTageswechsel), [120, 150, 180]);
    expect(u.durchschnitt, 150);
    expect(uhrzeitAusMinuten(150, 240), '06:30');
  });

  test('Histogramm mit 5–12 Klassen', () {
    final h = histogramm([for (var i = 1; i <= 10; i++) Duration(minutes: i)]);
    expect(h.length, 5);
    expect(h.fold<int>(0, (s, k) => s + k.anzahl), 10);
    expect(histogramm([for (var i = 0; i < 400; i++) Duration(minutes: i)]).length, 12);
    expect(histogramm(const [Duration(minutes: 3), Duration(minutes: 3)]).first.anzahl, 2);
  });

  test('Nach Wochentag', () {
    final ms = gefilterteMessungen(daten, woche).where((x) => x.ereignisId == 1).toList();
    final w = nachWochentag(ms);
    expect(w[0], const Duration(minutes: 10));
    expect(w[1], const Duration(minutes: 20));
    expect(w[5], const Duration(minutes: 30));
    expect(w[2], isNull);
  });

  test('Mein Tag: Ø pro Tag mit Messungen', () {
    final t = meinTag(daten, woche);
    expect(t.tage, 3);
    expect(t.zeilen.first.name, 'Aufstehen');
    expect(t.zeilen.first.proTag, const Duration(minutes: 20));
    expect(t.summeProTag, const Duration(minutes: 64) ~/ 3);
  });
}
