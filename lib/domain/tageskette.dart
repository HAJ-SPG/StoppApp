import 'datenbestand.dart';
import 'modelle.dart';
import 'tag.dart';

enum KettenQuelle { keine, wochenregel, ausnahme, tageslauf }

class TagesketteInfo {
  const TagesketteInfo(this.kette, this.quelle);
  final Kette? kette;
  final KettenQuelle quelle;
  bool get hatAusnahme => quelle == KettenQuelle.ausnahme;
}

/// Die Tageskette eines Datums: Tagesausnahme, sonst Wochenregel, sonst keine.
/// Ist die Ausnahme „Keine Kette“, ist [TagesketteInfo.kette] `null` und die
/// Quelle trotzdem [KettenQuelle.ausnahme].
TagesketteInfo tageskette(Datenbestand d, Tag tag) {
  if (d.tagesausnahmen.containsKey(tag)) {
    final id = d.tagesausnahmen[tag];
    return TagesketteInfo(id == null ? null : d.ketten[id], KettenQuelle.ausnahme);
  }
  final id = d.wochenregel[tag.wochentag];
  final k = id == null ? null : d.ketten[id];
  return TagesketteInfo(k, k == null ? KettenQuelle.keine : KettenQuelle.wochenregel);
}

/// Die Kette, die der Kalender für [tag] zeigt.
///
/// Heute und künftige Tage zeigen die Tageskette. Vergangene Tage zeigen,
/// was tatsächlich gelaufen ist: eine Tagesausnahme des Tages, sonst die Kette
/// aus seinem Tageslauf. Ohne Tageslauf, oder wenn die Kette inzwischen
/// gelöscht ist, zeigt der Tag keine Kette. Eine spätere Änderung der
/// Wochenregel färbt die Vergangenheit also nicht um.
TagesketteInfo kalenderKette(Datenbestand d, Tag tag, Tag heute) {
  if (!tag.istVor(heute) || d.tagesausnahmen.containsKey(tag)) return tageskette(d, tag);
  final id = d.tageslaeufe[tag]?.ketteId;
  final k = id == null ? null : d.ketten[id];
  return TagesketteInfo(k, k == null ? KettenQuelle.keine : KettenQuelle.tageslauf);
}
