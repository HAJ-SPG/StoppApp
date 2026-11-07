import 'dart:math' as math;

import 'modelle.dart';
import 'tag.dart';

/// Der gesamte gespeicherte Zustand der App als unveränderlicher Wert.
/// Die Fachlogik rechnet einen Datenbestand in den nächsten um, die
/// Datenschicht schreibt die Unterschiede.
class Datenbestand {
  const Datenbestand({
    this.ereignisse = const {},
    this.ketten = const {},
    this.wochenregel = const {},
    this.tagesausnahmen = const {},
    this.messungen = const {},
    this.tageslaeufe = const {},
    this.einstellungen = const Einstellungen(),
  });

  final Map<int, Ereignis> ereignisse;
  final Map<int, Kette> ketten;

  /// Wochentag (1=Mo … 7=So) → Kette; fehlend oder `null` = keine Kette.
  final Map<int, int?> wochenregel;

  /// Tag → Kette; `null` = „Keine Kette“ als Ausnahme.
  final Map<Tag, int?> tagesausnahmen;
  final Map<int, Messung> messungen;
  final Map<Tag, Tageslauf> tageslaeufe;
  final Einstellungen einstellungen;

  Datenbestand kopie({
    Map<int, Ereignis>? ereignisse,
    Map<int, Kette>? ketten,
    Map<int, int?>? wochenregel,
    Map<Tag, int?>? tagesausnahmen,
    Map<int, Messung>? messungen,
    Map<Tag, Tageslauf>? tageslaeufe,
    Einstellungen? einstellungen,
  }) =>
      Datenbestand(
        ereignisse: ereignisse ?? this.ereignisse,
        ketten: ketten ?? this.ketten,
        wochenregel: wochenregel ?? this.wochenregel,
        tagesausnahmen: tagesausnahmen ?? this.tagesausnahmen,
        messungen: messungen ?? this.messungen,
        tageslaeufe: tageslaeufe ?? this.tageslaeufe,
        einstellungen: einstellungen ?? this.einstellungen,
      );

  int get tageswechsel => einstellungen.tageswechsel;

  Messung? get laufendeMessung {
    for (final m in messungen.values) {
      if (m.laeuft) return m;
    }
    return null;
  }

  /// Messungen eines Tages, nach Start sortiert.
  List<Messung> messungenAm(Tag tag) =>
      messungen.values.where((m) => m.tag == tag).toList()..sort((a, b) => a.start.compareTo(b.start));

  List<Ereignis> get aktiveEreignisse => ereignisse.values.where((e) => !e.archiviert).toList()
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  List<Ereignis> get archivierteEreignisse =>
      ereignisse.values.where((e) => e.archiviert).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  List<Kette> get kettenSortiert => ketten.values.toList()
    ..sort((a, b) {
      final s = a.sortierung.compareTo(b.sortierung);
      return s != 0 ? s : a.id.compareTo(b.id);
    });

  String ereignisName(int id) => ereignisse[id]?.name ?? '?';
}

int naechsteId(Iterable<int> ids) => ids.isEmpty ? 1 : ids.reduce(math.max) + 1;
