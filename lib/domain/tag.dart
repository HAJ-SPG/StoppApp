/// Ein Datum im Sinne des Tageswechsels (`YYYY-MM-DD`).
class Tag implements Comparable<Tag> {
  const Tag(this.jahr, this.monat, this.tagImMonat);

  factory Tag.ausDatum(DateTime d) => Tag(d.year, d.month, d.day);

  factory Tag.parse(String s) {
    final teile = s.split('-');
    if (teile.length != 3) throw FormatException('Ungültiger Tag: $s');
    return Tag(int.parse(teile[0]), int.parse(teile[1]), int.parse(teile[2]));
  }

  final int jahr;
  final int monat;
  final int tagImMonat;

  DateTime get _utc => DateTime.utc(jahr, monat, tagImMonat);

  /// Lokale Mitternacht dieses Kalenderdatums.
  DateTime get datum => DateTime(jahr, monat, tagImMonat);

  /// 1 = Montag … 7 = Sonntag.
  int get wochentag => _utc.weekday;

  Tag plusTage(int n) => Tag.ausDatum(DateTime.utc(jahr, monat, tagImMonat + n));

  /// Anzahl Tage von [anderer] bis zu diesem Tag.
  int tageSeit(Tag anderer) => _utc.difference(anderer._utc).inDays;

  bool istVor(Tag t) => compareTo(t) < 0;
  bool istNach(Tag t) => compareTo(t) > 0;

  @override
  int compareTo(Tag other) => _utc.compareTo(other._utc);

  @override
  bool operator ==(Object other) =>
      other is Tag && other.jahr == jahr && other.monat == monat && other.tagImMonat == tagImMonat;

  @override
  int get hashCode => Object.hash(jahr, monat, tagImMonat);

  @override
  String toString() =>
      '${jahr.toString().padLeft(4, '0')}-${monat.toString().padLeft(2, '0')}-${tagImMonat.toString().padLeft(2, '0')}';
}

/// Standard-Tageswechsel 04:00 in Minuten nach Mitternacht.
const standardTageswechsel = 240;

/// Der Tag, zu dem ein Zeitpunkt gehört.
Tag tagFuer(DateTime zeitpunkt, int tageswechselMinuten) {
  final lokal = zeitpunkt.toLocal();
  final minuten = lokal.hour * 60 + lokal.minute;
  final t = Tag(lokal.year, lokal.month, lokal.day);
  return minuten < tageswechselMinuten ? t.plusTage(-1) : t;
}

/// Beginn des Tages (lokal) beim Tageswechsel.
DateTime tagesBeginn(Tag t, int tageswechselMinuten) =>
    DateTime(t.jahr, t.monat, t.tagImMonat, 0, tageswechselMinuten);

/// Ende des Tages = Beginn des nächsten Tages.
DateTime tagesEnde(Tag t, int tageswechselMinuten) =>
    tagesBeginn(t.plusTage(1), tageswechselMinuten);

/// Eine Uhrzeit innerhalb eines Tages. Uhrzeiten vor dem Tageswechsel
/// gehören zum folgenden Kalendertag (bei 04:00 ist 01:30 der nächste Tag).
DateTime uhrzeitImTag(Tag t, int stunde, int minute, int tageswechselMinuten) {
  final d = stunde * 60 + minute < tageswechselMinuten ? t.plusTage(1) : t;
  return DateTime(d.jahr, d.monat, d.tagImMonat, stunde, minute);
}

const wochentagKurz = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
