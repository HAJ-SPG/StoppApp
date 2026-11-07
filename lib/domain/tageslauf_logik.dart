import 'datenbestand.dart';
import 'fehler.dart';
import 'modelle.dart';
import 'tag.dart';

enum SchrittStatus { offen, erledigt, laeuft, uebersprungen }

class SchrittAnzeige {
  const SchrittAnzeige({
    required this.position,
    required this.ereignisId,
    required this.status,
    this.messung,
  });
  final int position;
  final int ereignisId;
  final SchrittStatus status;

  /// Messung, die diesen Schritt erledigt hat bzw. gerade misst.
  final Messung? messung;

  bool get waehlbar => status == SchrittStatus.offen || status == SchrittStatus.uebersprungen;
}

/// Leitet den Status jedes Schritts eines Tageslaufs ab.
List<SchrittAnzeige> schrittStatus(Tageslauf lauf, List<Messung> messungenDesTages) {
  final ergebnis = <SchrittAnzeige>[];
  for (var p = 0; p < lauf.schritte.length; p++) {
    Messung? fertig;
    Messung? laufend;
    for (final m in messungenDesTages) {
      if (m.schrittPosition != p) continue;
      if (m.laeuft) {
        laufend = m;
      } else {
        fertig ??= m;
      }
    }
    final SchrittStatus status;
    if (laufend != null) {
      status = SchrittStatus.laeuft;
    } else if (fertig != null) {
      status = SchrittStatus.erledigt;
    } else if (lauf.uebersprungen.contains(p)) {
      status = SchrittStatus.uebersprungen;
    } else {
      status = SchrittStatus.offen;
    }
    ergebnis.add(SchrittAnzeige(
        position: p, ereignisId: lauf.schritte[p], status: status, messung: laufend ?? fertig));
  }
  return ergebnis;
}

/// Der nächste Schritt: `naechster`, falls offen oder übersprungen, sonst
/// der erste offene Schritt.
int? naechsterSchritt(Tageslauf lauf, List<SchrittAnzeige> schritte) {
  final n = lauf.naechster;
  if (n != null && n >= 0 && n < schritte.length && schritte[n].waehlbar) return n;
  for (final s in schritte) {
    if (s.status == SchrittStatus.offen) return s.position;
  }
  return null;
}

enum HeuteModus { keineKette, bereit, laeuft, erledigt }

class HeuteZustand {
  const HeuteZustand({
    required this.tag,
    required this.modus,
    required this.tageslauf,
    required this.schritte,
    required this.naechster,
    required this.laufend,
    required this.messungen,
  });

  final Tag tag;
  final HeuteModus modus;
  final Tageslauf? tageslauf;
  final List<SchrittAnzeige> schritte;

  /// Position des nächsten Schritts (Standardschritt des großen Buttons).
  final int? naechster;
  final Messung? laufend;

  /// Alle Messungen des Tages, nach Start sortiert.
  final List<Messung> messungen;

  String? get ketteName => tageslauf?.ketteName;
  int get anzahlSchritte => schritte.length;
  int get erledigt => schritte.where((s) => s.status == SchrittStatus.erledigt).length;

  int? get naechstesEreignisId => naechster == null ? null : schritte[naechster!].ereignisId;

  /// Der Schritt nach dem nächsten (für „Danach: …“). Während eine Messung
  /// läuft, ist das der nächste Schritt selbst.
  int? get danachEreignisId {
    if (modus == HeuteModus.laeuft) return naechstesEreignisId;
    final n = naechster;
    if (n == null) return null;
    final offen = schritte.where((s) => s.status == SchrittStatus.offen && s.position != n).toList();
    if (offen.isEmpty) return null;
    final spaeter = offen.where((s) => s.position > n);
    return (spaeter.isNotEmpty ? spaeter.first : offen.first).ereignisId;
  }

  /// Offene und übersprungene Schritte für „Nächstes wählen“.
  List<SchrittAnzeige> get waehlbareSchritte => schritte.where((s) => s.waehlbar).toList();
}

HeuteZustand heuteZustand(Datenbestand d, DateTime jetzt) {
  final tag = tagFuer(jetzt, d.tageswechsel);
  final lauf = d.tageslaeufe[tag];
  final messungen = d.messungenAm(tag);
  final schritte = lauf == null ? const <SchrittAnzeige>[] : schrittStatus(lauf, messungen);
  final naechster = lauf == null ? null : naechsterSchritt(lauf, schritte);
  final laufend = d.laufendeMessung;
  final HeuteModus modus;
  if (laufend != null) {
    modus = HeuteModus.laeuft;
  } else if (lauf == null) {
    modus = HeuteModus.keineKette;
  } else if (naechster != null) {
    modus = HeuteModus.bereit;
  } else {
    modus = HeuteModus.erledigt;
  }
  return HeuteZustand(
    tag: tag,
    modus: modus,
    tageslauf: lauf,
    schritte: schritte,
    naechster: naechster,
    laufend: laufend,
    messungen: messungen,
  );
}

/// Der Schritt, den eine Nachtragung von [ereignisId] am [tag] erledigt.
///
/// - Hat das Ereignis im Tageslauf einen übersprungenen Schritt, ist es der
///   erste davon. An vergangenen Tagen ist die Kette verfallen, dort zählen
///   offene Schritte wie übersprungene.
/// - Wartet heute nur ein offener Schritt mit diesem Ereignis, ist Nachtragen
///   gesperrt: Nachtragen heißt nachher eintragen, nicht vorab.
/// - Sonst `null`: Die Messung zählt wie eingeschoben.
///
/// [ignorieren] ist die Messung, die gerade bearbeitet wird.
int? nachtragungsSchritt(Datenbestand d, Tag tag, int ereignisId, {required Tag heute, int? ignorieren}) {
  final lauf = d.tageslaeufe[tag];
  if (lauf == null) return null;
  final messungen = d.messungenAm(tag).where((m) => m.id != ignorieren).toList();
  final schritte = schrittStatus(lauf, messungen).where((s) => s.ereignisId == ereignisId).toList();
  final vergangen = tag.istVor(heute);
  for (final s in schritte) {
    if (s.status == SchrittStatus.uebersprungen || (vergangen && s.status == SchrittStatus.offen)) {
      return s.position;
    }
  }
  if (!vergangen && schritte.any((s) => s.status == SchrittStatus.offen)) {
    throw const FachFehler('Dieser Schritt ist noch offen. Erst überspringen oder normal messen.');
  }
  return null;
}
