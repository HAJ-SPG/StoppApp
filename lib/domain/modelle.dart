import 'tag.dart';

bool _listenGleich<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

bool _mengenGleich<T>(Set<T> a, Set<T> b) => a.length == b.length && a.containsAll(b);

class Ereignis {
  const Ereignis({required this.id, required this.name, this.archiviert = false});
  final int id;
  final String name;
  final bool archiviert;

  Ereignis kopie({String? name, bool? archiviert}) =>
      Ereignis(id: id, name: name ?? this.name, archiviert: archiviert ?? this.archiviert);

  @override
  bool operator ==(Object other) =>
      other is Ereignis && other.id == id && other.name == name && other.archiviert == archiviert;
  @override
  int get hashCode => Object.hash(id, name, archiviert);
}

/// Eine Ereigniskette. [schritte] enthält je Schritt die `ereignis_id`,
/// die Position ist der Index.
class Kette {
  const Kette({
    required this.id,
    required this.name,
    required this.farbe,
    required this.sortierung,
    this.schritte = const [],
  });
  final int id;
  final String name;

  /// 0–5: Blau, Ocker, Violett, Grün, Beere, Schiefer.
  final int farbe;
  final int sortierung;
  final List<int> schritte;

  Kette kopie({String? name, int? farbe, int? sortierung, List<int>? schritte}) => Kette(
        id: id,
        name: name ?? this.name,
        farbe: farbe ?? this.farbe,
        sortierung: sortierung ?? this.sortierung,
        schritte: schritte ?? this.schritte,
      );

  @override
  bool operator ==(Object other) =>
      other is Kette &&
      other.id == id &&
      other.name == name &&
      other.farbe == farbe &&
      other.sortierung == sortierung &&
      _listenGleich(other.schritte, schritte);
  @override
  int get hashCode => Object.hash(id, name, farbe, sortierung, Object.hashAll(schritte));
}

class Messung {
  const Messung({
    required this.id,
    required this.ereignisId,
    required this.start,
    required this.tag,
    this.stopp,
    this.ketteName,
    this.schrittPosition,
  });
  final int id;
  final int ereignisId;
  final DateTime start;

  /// `null` = läuft.
  final DateTime? stopp;
  final Tag tag;

  /// Name der Tageskette, unter der die Messung entstand (nur zur Information).
  final String? ketteName;

  /// `null` = eingeschoben bzw. nachgetragen, ohne einen Schritt zu erledigen.
  final int? schrittPosition;

  bool get laeuft => stopp == null;

  /// Ende für Berechnungen; eine laufende Messung endet „jetzt“.
  DateTime ende(DateTime jetzt) => stopp ?? jetzt;

  Duration dauer(DateTime jetzt) => ende(jetzt).difference(start);

  Messung kopie({
    int? ereignisId,
    DateTime? start,
    DateTime? stopp,
    bool stoppLoeschen = false,
    Tag? tag,
    int? schrittPosition,
    bool schrittPositionLoeschen = false,
  }) =>
      Messung(
        id: id,
        ereignisId: ereignisId ?? this.ereignisId,
        start: start ?? this.start,
        stopp: stoppLoeschen ? null : (stopp ?? this.stopp),
        tag: tag ?? this.tag,
        ketteName: ketteName,
        schrittPosition: schrittPositionLoeschen ? null : (schrittPosition ?? this.schrittPosition),
      );

  @override
  bool operator ==(Object other) =>
      other is Messung &&
      other.id == id &&
      other.ereignisId == ereignisId &&
      other.start.isAtSameMomentAs(start) &&
      (other.stopp == null ? stopp == null : stopp != null && other.stopp!.isAtSameMomentAs(stopp!)) &&
      other.tag == tag &&
      other.ketteName == ketteName &&
      other.schrittPosition == schrittPosition;
  @override
  int get hashCode => Object.hash(id, ereignisId, start.millisecondsSinceEpoch,
      stopp?.millisecondsSinceEpoch, tag, ketteName, schrittPosition);
}

/// Schnappschuss der Tageskette für einen Tag samt Fortschritt.
class Tageslauf {
  const Tageslauf({
    required this.tag,
    required this.ketteId,
    required this.ketteName,
    required this.schritte,
    this.naechster,
    this.uebersprungen = const {},
  });
  final Tag tag;
  final int? ketteId;
  final String ketteName;
  final List<int> schritte;

  /// Vom Nutzer gewählte Position für den nächsten Schritt.
  final int? naechster;
  final Set<int> uebersprungen;

  Tageslauf kopie({int? naechster, bool naechsterLoeschen = false, Set<int>? uebersprungen}) =>
      Tageslauf(
        tag: tag,
        ketteId: ketteId,
        ketteName: ketteName,
        schritte: schritte,
        naechster: naechsterLoeschen ? null : (naechster ?? this.naechster),
        uebersprungen: uebersprungen ?? this.uebersprungen,
      );

  @override
  bool operator ==(Object other) =>
      other is Tageslauf &&
      other.tag == tag &&
      other.ketteId == ketteId &&
      other.ketteName == ketteName &&
      _listenGleich(other.schritte, schritte) &&
      other.naechster == naechster &&
      _mengenGleich(other.uebersprungen, uebersprungen);
  @override
  int get hashCode => Object.hash(tag, ketteId, ketteName, Object.hashAll(schritte), naechster);
}

class Einstellungen {
  const Einstellungen({this.tageswechsel = standardTageswechsel});

  /// Minuten nach Mitternacht (0–360, in 15-Minuten-Schritten).
  final int tageswechsel;

  @override
  bool operator ==(Object other) => other is Einstellungen && other.tageswechsel == tageswechsel;
  @override
  int get hashCode => tageswechsel.hashCode;
}
