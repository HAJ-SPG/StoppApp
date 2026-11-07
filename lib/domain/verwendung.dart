import 'datenbestand.dart';
import 'tag.dart';

/// Wochentage kompakt, z. B. „Mo–Fr“, „Mo, Mi, Fr“, „Mo–Mi, Sa“.
String wochentageText(Iterable<int> wochentage) {
  final tage = wochentage.toSet().toList()..sort();
  if (tage.isEmpty) return '';
  final teile = <String>[];
  var i = 0;
  while (i < tage.length) {
    var j = i;
    while (j + 1 < tage.length && tage[j + 1] == tage[j] + 1) {
      j++;
    }
    if (j - i >= 2) {
      teile.add('${wochentagKurz[tage[i] - 1]}–${wochentagKurz[tage[j] - 1]}');
    } else {
      for (var k = i; k <= j; k++) {
        teile.add(wochentagKurz[tage[k] - 1]);
      }
    }
    i = j + 1;
  }
  return teile.join(', ');
}

/// Verwendung einer Kette, z. B. „Mo–Fr · 2 Ausnahmen“.
String kettenVerwendung(Datenbestand d, int ketteId) {
  final tage = d.wochenregel.entries.where((e) => e.value == ketteId).map((e) => e.key);
  final ausnahmen = d.tagesausnahmen.values.where((v) => v == ketteId).length;
  final teile = <String>[
    if (tage.isNotEmpty) wochentageText(tage),
    if (ausnahmen == 1) '1 Ausnahme',
    if (ausnahmen > 1) '$ausnahmen Ausnahmen',
  ];
  return teile.isEmpty ? 'nicht eingeplant' : teile.join(' · ');
}

/// Wird die Kette in Wochenregel oder Tagesausnahmen verwendet?
bool ketteWirdVerwendet(Datenbestand d, int ketteId) =>
    d.wochenregel.values.contains(ketteId) || d.tagesausnahmen.values.contains(ketteId);

int anzahlMessungen(Datenbestand d, int ereignisId) =>
    d.messungen.values.where((m) => m.ereignisId == ereignisId).length;

/// Verwendung eines Ereignisses, z. B. „Arbeitstag ×2, Homeoffice · 301 Messungen“.
String ereignisVerwendung(Datenbestand d, int ereignisId) {
  final ketten = <String>[];
  for (final k in d.kettenSortiert) {
    final n = k.schritte.where((e) => e == ereignisId).length;
    if (n == 1) ketten.add(k.name);
    if (n > 1) ketten.add('${k.name} ×$n');
  }
  final m = anzahlMessungen(d, ereignisId);
  final messText = m == 1 ? '1 Messung' : '$m Messungen';
  return ketten.isEmpty ? messText : '${ketten.join(', ')} · $messText';
}

class EreignisSuche {
  const EreignisSuche({required this.treffer, this.archiviertExakt, required this.neuMoeglich});

  /// Aktive Ereignisse, deren Name die Eingabe enthält.
  final List<int> treffer;

  /// Ein archiviertes Ereignis mit genau diesem Namen („wiederherstellen und einfügen“).
  final int? archiviertExakt;

  /// „+ „xyz“ als neues Ereignis anlegen“ anbieten.
  final bool neuMoeglich;
}

EreignisSuche ereignisSuche(Datenbestand d, String eingabe) {
  final q = eingabe.trim().toLowerCase();
  final treffer = d.aktiveEreignisse
      .where((e) => q.isEmpty || e.name.toLowerCase().contains(q))
      .map((e) => e.id)
      .toList();
  if (q.isEmpty) return EreignisSuche(treffer: treffer, neuMoeglich: false);
  final exakt = d.ereignisse.values.where((e) => e.name.toLowerCase() == q);
  final archiviert = exakt.where((e) => e.archiviert).map((e) => e.id).firstOrNull;
  return EreignisSuche(
    treffer: treffer,
    archiviertExakt: archiviert,
    neuMoeglich: exakt.isEmpty,
  );
}
