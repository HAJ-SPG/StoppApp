import 'datenbestand.dart';
import 'modelle.dart';
import 'tag.dart';

enum KettenQuelle { keine, wochenregel, ausnahme }

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
