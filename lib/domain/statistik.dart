import 'dart:math' as math;

import 'datenbestand.dart';
import 'modelle.dart';
import 'tag.dart';

enum Zeitraum { woche, monat, jahr, frei }

/// Filter der Statistik. [ketteName] `null` = „Alle Ketten“.
/// [wochentage] leer = alle Wochentage.
class StatistikFilter {
  const StatistikFilter({
    required this.von,
    required this.bis,
    this.ketteName,
    this.wochentage = const {},
  });
  final Tag von;
  final Tag bis;
  final String? ketteName;
  final Set<int> wochentage;

  int get anzahlTage => bis.tageSeit(von) + 1;

  bool passt(Messung m) =>
      !m.laeuft &&
      !m.tag.istVor(von) &&
      !m.tag.istNach(bis) &&
      (ketteName == null || m.ketteName == ketteName) &&
      (wochentage.isEmpty || wochentage.contains(m.tag.wochentag));
}

/// Kalenderzeitraum, der [tag] enthält.
(Tag, Tag) kalenderZeitraum(Zeitraum z, Tag tag) {
  switch (z) {
    case Zeitraum.woche:
      final von = tag.plusTage(1 - tag.wochentag);
      return (von, von.plusTage(6));
    case Zeitraum.monat:
      final von = Tag(tag.jahr, tag.monat, 1);
      final bis = Tag.ausDatum(DateTime.utc(tag.jahr, tag.monat + 1, 0));
      return (von, bis);
    case Zeitraum.jahr:
    case Zeitraum.frei:
      return (Tag(tag.jahr, 1, 1), Tag(tag.jahr, 12, 31));
  }
}

/// Der vorige (‹, [richtung] −1) bzw. nächste (›, +1) Kalenderzeitraum.
(Tag, Tag) zeitraumVerschieben(Zeitraum z, Tag von, int richtung) {
  switch (z) {
    case Zeitraum.woche:
      return kalenderZeitraum(z, von.plusTage(7 * richtung));
    case Zeitraum.monat:
      return kalenderZeitraum(z, Tag.ausDatum(DateTime.utc(von.jahr, von.monat + richtung, 1)));
    case Zeitraum.jahr:
    case Zeitraum.frei:
      return kalenderZeitraum(Zeitraum.jahr, Tag(von.jahr + richtung, 1, 1));
  }
}

/// Alle Kettennamen, die in Messungen vorkommen (für den Ketten-Filter).
List<String> kettennamenInMessungen(Datenbestand d) {
  final namen = d.messungen.values.map((m) => m.ketteName).whereType<String>().toSet().toList();
  namen.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return namen;
}

List<Messung> gefilterteMessungen(Datenbestand d, StatistikFilter f) =>
    d.messungen.values.where(f.passt).toList()..sort((a, b) => a.start.compareTo(b.start));

int tageMitMessungen(Iterable<Messung> messungen) => messungen.map((m) => m.tag).toSet().length;

Duration _dauer(Messung m) => m.stopp!.difference(m.start);

class Kennzahlen {
  const Kennzahlen({
    required this.anzahl,
    required this.summe,
    required this.durchschnitt,
    required this.median,
    required this.min,
    required this.max,
  });
  final int anzahl;
  final Duration summe;
  final Duration durchschnitt;
  final Duration median;
  final Duration min;
  final Duration max;
}

Duration mittelwert(List<Duration> d) => d.isEmpty
    ? Duration.zero
    : Duration(microseconds: (d.fold<int>(0, (s, x) => s + x.inMicroseconds) / d.length).round());

Duration medianVon(List<Duration> d) {
  if (d.isEmpty) return Duration.zero;
  final s = List.of(d)..sort();
  final mitte = s.length ~/ 2;
  if (s.length.isOdd) return s[mitte];
  return Duration(microseconds: ((s[mitte - 1].inMicroseconds + s[mitte].inMicroseconds) / 2).round());
}

Kennzahlen kennzahlen(List<Duration> d) {
  if (d.isEmpty) {
    return const Kennzahlen(
        anzahl: 0,
        summe: Duration.zero,
        durchschnitt: Duration.zero,
        median: Duration.zero,
        min: Duration.zero,
        max: Duration.zero);
  }
  final s = List.of(d)..sort();
  return Kennzahlen(
    anzahl: s.length,
    summe: s.fold(Duration.zero, (a, b) => a + b),
    durchschnitt: mittelwert(s),
    median: medianVon(s),
    min: s.first,
    max: s.last,
  );
}

/// Ein Punkt im Verlauf: Ø-Dauer im Zeitraum ab [tag] (Tag oder Wochenbeginn).
class VerlaufPunkt {
  const VerlaufPunkt(this.tag, this.durchschnitt);
  final Tag tag;
  final Duration durchschnitt;
}

/// Ab dieser Zeitraumlänge zeigt der Verlauf Ø pro Woche statt pro Tag.
const verlaufWochenAb = 45;

bool verlaufProWoche(StatistikFilter f) => f.anzahlTage > verlaufWochenAb;

/// Ø pro Tag, bei Zeiträumen über 45 Tage Ø pro Woche (nur Zeiträume mit Messungen).
List<VerlaufPunkt> verlauf(List<Messung> messungen, StatistikFilter f) {
  final proWoche = verlaufProWoche(f);
  final gruppen = <Tag, List<Duration>>{};
  for (final m in messungen) {
    final schluessel = proWoche ? m.tag.plusTage(1 - m.tag.wochentag) : m.tag;
    gruppen.putIfAbsent(schluessel, () => []).add(_dauer(m));
  }
  final tage = gruppen.keys.toList()..sort();
  return [for (final t in tage) VerlaufPunkt(t, mittelwert(gruppen[t]!))];
}

class EreignisZeile {
  const EreignisZeile({
    required this.ereignisId,
    required this.name,
    required this.kennzahlen,
    required this.verlauf,
  });
  final int ereignisId;
  final String name;
  final Kennzahlen kennzahlen;
  final List<VerlaufPunkt> verlauf;
}

/// Tab „Ereignisse“: alle Ereignisse mit Messungen im Filter, nach Summe sortiert.
List<EreignisZeile> ereignisUebersicht(Datenbestand d, StatistikFilter f) {
  final gruppen = <int, List<Messung>>{};
  for (final m in gefilterteMessungen(d, f)) {
    gruppen.putIfAbsent(m.ereignisId, () => []).add(m);
  }
  final zeilen = [
    for (final e in gruppen.entries)
      EreignisZeile(
        ereignisId: e.key,
        name: d.ereignisName(e.key),
        kennzahlen: kennzahlen(e.value.map(_dauer).toList()),
        verlauf: verlauf(e.value, f),
      ),
  ];
  zeilen.sort((a, b) {
    final s = b.kennzahlen.summe.compareTo(a.kennzahlen.summe);
    return s != 0 ? s : a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });
  return zeilen;
}

class UhrzeitPunkt {
  const UhrzeitPunkt(this.tag, this.minutenSeitTageswechsel);
  final Tag tag;

  /// Startzeit als Minuten seit Tagesbeginn (Tageswechsel).
  final int minutenSeitTageswechsel;
}

class UhrzeitAuswertung {
  const UhrzeitAuswertung(this.punkte, this.durchschnitt);
  final List<UhrzeitPunkt> punkte;

  /// Ø-Start in Minuten seit Tageswechsel, `null` ohne Messungen.
  final int? durchschnitt;
}

UhrzeitAuswertung uhrzeiten(List<Messung> messungen, int tageswechsel) {
  final punkte = [
    for (final m in messungen)
      UhrzeitPunkt(m.tag, m.start.toLocal().difference(tagesBeginn(m.tag, tageswechsel)).inMinutes),
  ];
  final avg = punkte.isEmpty
      ? null
      : (punkte.fold<int>(0, (s, p) => s + p.minutenSeitTageswechsel) / punkte.length).round();
  return UhrzeitAuswertung(punkte, avg);
}

/// Wandelt Minuten seit Tageswechsel in eine Uhrzeit `HH:MM` um.
String uhrzeitAusMinuten(int minutenSeitTageswechsel, int tageswechsel) {
  final m = (minutenSeitTageswechsel + tageswechsel) % 1440;
  return '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';
}

class HistogrammKlasse {
  const HistogrammKlasse(this.von, this.bis, this.anzahl);
  final Duration von;
  final Duration bis;
  final int anzahl;
}

/// Histogramm der Dauer mit 5–12 gleich breiten Klassen (Wurzelregel).
List<HistogrammKlasse> histogramm(List<Duration> dauern) {
  if (dauern.isEmpty) return const [];
  final klassen = math.sqrt(dauern.length).ceil().clamp(5, 12);
  final min = dauern.reduce((a, b) => a < b ? a : b).inSeconds;
  final max = dauern.reduce((a, b) => a > b ? a : b).inSeconds;
  var breite = ((max - min) / klassen).ceil();
  if (breite <= 0) breite = 60;
  final anzahl = List.filled(klassen, 0);
  for (final d in dauern) {
    final i = ((d.inSeconds - min) ~/ breite).clamp(0, klassen - 1);
    anzahl[i]++;
  }
  return [
    for (var i = 0; i < klassen; i++)
      HistogrammKlasse(
          Duration(seconds: min + i * breite), Duration(seconds: min + (i + 1) * breite), anzahl[i]),
  ];
}

/// Ø-Dauer je Wochentag (Index 0 = Mo); `null` ohne Messungen.
List<Duration?> nachWochentag(List<Messung> messungen) {
  final gruppen = List.generate(7, (_) => <Duration>[]);
  for (final m in messungen) {
    gruppen[m.tag.wochentag - 1].add(_dauer(m));
  }
  return [for (final g in gruppen) g.isEmpty ? null : mittelwert(g)];
}

class MeinTagZeile {
  const MeinTagZeile(this.ereignisId, this.name, this.proTag);
  final int ereignisId;
  final String name;

  /// Ø Dauer pro Tag, bezogen auf Tage mit Messungen im Filter.
  final Duration proTag;
}

class MeinTag {
  const MeinTag(this.zeilen, this.summeProTag, this.tage);
  final List<MeinTagZeile> zeilen;

  /// Gemessene Ø-Summe pro Tag.
  final Duration summeProTag;
  final int tage;
}

MeinTag meinTag(Datenbestand d, StatistikFilter f) {
  final messungen = gefilterteMessungen(d, f);
  final tage = tageMitMessungen(messungen);
  if (tage == 0) return const MeinTag([], Duration.zero, 0);
  final summen = <int, Duration>{};
  var gesamt = Duration.zero;
  for (final m in messungen) {
    summen[m.ereignisId] = (summen[m.ereignisId] ?? Duration.zero) + _dauer(m);
    gesamt += _dauer(m);
  }
  final zeilen = [
    for (final e in summen.entries)
      MeinTagZeile(e.key, d.ereignisName(e.key), Duration(microseconds: e.value.inMicroseconds ~/ tage)),
  ]..sort((a, b) => b.proTag.compareTo(a.proTag));
  return MeinTag(zeilen, Duration(microseconds: gesamt.inMicroseconds ~/ tage), tage);
}
