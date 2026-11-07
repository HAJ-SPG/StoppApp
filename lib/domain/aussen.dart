import 'dart:convert';

import 'datenbestand.dart';
import 'modelle.dart';
import 'stopp_dienst.dart';
import 'tag.dart';
import 'tageslauf_logik.dart';

/// Widget-Schnappschuss (Spec Abschnitt 11, ADR 0002): alles, was Widget,
/// Live Activity und Notification anzeigen. Die App schreibt ihn nach jeder
/// Änderung als JSON unter einem einzigen Schlüssel.
Map<String, Object?> widgetSchnappschuss(Datenbestand d, DateTime jetzt) {
  final z = heuteZustand(d, jetzt);
  final laufend = z.laufend;
  final n = z.naechster;
  return {
    'tag': z.tag.toString(),
    'zustand': switch (z.modus) {
      HeuteModus.keineKette => 'keine',
      HeuteModus.bereit => 'bereit',
      HeuteModus.laeuft => 'laeuft',
      HeuteModus.erledigt => 'erledigt',
    },
    'kette': z.ketteName,
    'laufend': laufend == null
        ? null
        : {
            'ereignis': d.ereignisName(laufend.ereignisId),
            'start': laufend.start.millisecondsSinceEpoch,
            'schritt_position': laufend.schrittPosition,
          },
    'naechstes': n == null
        ? null
        : {
            'ereignis': d.ereignisName(z.schritte[n].ereignisId),
            'schritt_position': n,
          },
    'erledigt': z.erledigt,
    'schritte_gesamt': z.anzahlSchritte,
  };
}

String widgetSchnappschussJson(Datenbestand d, DateTime jetzt) => jsonEncode(widgetSchnappschuss(d, jetzt));

enum FernArt { start, stopp }

/// Ein Tipp auf Start oder Stopp außerhalb der App, als Eintrag der
/// Warteschlange: was, wann (Moment des Tippens), woher und welche
/// `schritt_position` der Schnappschuss beim Tippen zeigte.
class FernAktion {
  const FernAktion({
    required this.id,
    required this.art,
    required this.zeitpunkt,
    required this.quelle,
    this.schrittPosition,
  });

  factory FernAktion.ausJson(Map<String, Object?> j) => FernAktion(
        id: j['id'].toString(),
        art: j['aktion'] == 'stopp' ? FernArt.stopp : FernArt.start,
        zeitpunkt: DateTime.fromMillisecondsSinceEpoch((j['zeitpunkt'] as num).toInt(), isUtc: true),
        quelle: (j['quelle'] ?? 'widget').toString(),
        schrittPosition: (j['schritt_position'] as num?)?.toInt(),
      );

  final String id;
  final FernArt art;
  final DateTime zeitpunkt;

  /// `widget`, `live_activity` oder `notification`.
  final String quelle;
  final int? schrittPosition;

  Map<String, Object?> alsJson() => {
        'id': id,
        'aktion': art.name,
        'zeitpunkt': zeitpunkt.millisecondsSinceEpoch,
        'quelle': quelle,
        'schritt_position': schrittPosition,
      };
}

/// Liest die Warteschlange; unlesbare Einträge werden übergangen.
List<FernAktion> warteschlangeLesen(String? json) {
  if (json == null || json.isEmpty) return const [];
  try {
    final liste = jsonDecode(json);
    if (liste is! List) return const [];
    final ergebnis = <FernAktion>[];
    for (final e in liste) {
      try {
        ergebnis.add(FernAktion.ausJson(Map<String, Object?>.from(e as Map)));
      } catch (_) {}
    }
    ergebnis.sort((a, b) => a.zeitpunkt.compareTo(b.zeitpunkt));
    return ergebnis;
  } on FormatException {
    return const [];
  }
}

extension FernAusfuehren on StoppDienst {
  /// Wendet eine Aktion von außerhalb der App mit ihrem eigenen Zeitpunkt an.
  /// Passt sie nicht mehr zum Zustand (andere Position, Stopp ohne laufende
  /// Messung, Doppeltipp), wird sie verworfen. Gibt zurück, ob sie angewendet wurde.
  bool fernAusfuehren(FernAktion a) {
    tagesSicherstellen();
    switch (a.art) {
      case FernArt.start:
        if (daten.laufendeMessung != null) return false;
        final z = this.heuteZustand;
        if (z.naechster == null || z.naechster != a.schrittPosition) return false;
        if (tagFuer(a.zeitpunkt, daten.tageswechsel) != z.tag) return false;
        // Nicht vor dem Stopp einer früheren Messung beginnen.
        var start = a.zeitpunkt;
        final letzterStopp = spaetesterStoppVor(daten, a.zeitpunkt);
        if (letzterStopp != null && letzterStopp.isAfter(start)) start = letzterStopp;
        if (start.isAfter(jetzt)) start = jetzt;
        starten(zeit: start);
        return true;
      case FernArt.stopp:
        final m = daten.laufendeMessung;
        if (m == null || m.schrittPosition != a.schrittPosition) return false;
        if (a.zeitpunkt.isBefore(m.start)) return false;
        stoppen(zeit: a.zeitpunkt);
        return true;
    }
  }

  /// Wendet alle [aktionen] der Reihe nach an; gibt die Zahl der angewendeten zurück.
  int fernAbarbeiten(Iterable<FernAktion> aktionen) {
    var n = 0;
    for (final a in aktionen) {
      if (fernAusfuehren(a)) n++;
    }
    return n;
  }
}

/// Der späteste Stopp einer abgeschlossenen Messung, die vor [zeitpunkt] begann.
DateTime? spaetesterStoppVor(Datenbestand d, DateTime zeitpunkt) {
  DateTime? s;
  for (final Messung m in d.messungen.values) {
    final stopp = m.stopp;
    if (stopp == null || !m.start.isBefore(zeitpunkt)) continue;
    if (s == null || stopp.isAfter(s)) s = stopp;
  }
  return s;
}

/// Für Tests und die Anzeige: der Tag eines Schnappschusses.
Tag schnappschussTag(Map<String, Object?> s) => Tag.parse(s['tag']! as String);

String warteschlangeJson(Iterable<FernAktion> aktionen) =>
    jsonEncode([for (final a in aktionen) a.alsJson()]);
