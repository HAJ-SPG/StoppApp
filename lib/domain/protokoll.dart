import 'datenbestand.dart';
import 'dauer_format.dart';
import 'fehler.dart';
import 'modelle.dart';
import 'tag.dart';
import 'tageskette.dart';

/// Lücken ab dieser Länge erscheinen im Tagesprotokoll.
const sichtbareLuecke = Duration(minutes: 5);

class Luecke {
  const Luecke(this.von, this.bis);
  final DateTime von;
  final DateTime bis;
  Duration get dauer => bis.difference(von);
}

/// Ein Eintrag im Tagesprotokoll: entweder Messung oder Lücke.
class ProtokollEintrag {
  const ProtokollEintrag.messung(Messung this.messung, {this.anderemKettennamen = false})
      : luecke = null;
  const ProtokollEintrag.luecke(Luecke this.luecke)
      : messung = null,
        anderemKettennamen = false;
  final Messung? messung;
  final Luecke? luecke;

  /// Die Messung entstand unter einem anderen Kettennamen („gemessen unter …“).
  final bool anderemKettennamen;
}

class TagesProtokoll {
  const TagesProtokoll({
    required this.tag,
    required this.kette,
    required this.messungen,
    required this.eintraege,
    required this.summe,
    required this.lueckenSumme,
    required this.istZukunft,
  });
  final Tag tag;
  final TagesketteInfo kette;
  final List<Messung> messungen;
  final List<ProtokollEintrag> eintraege;
  final Duration summe;
  final Duration lueckenSumme;
  final bool istZukunft;
}

/// Summe der abgeschlossenen Messungen eines Tages.
Duration gemesseneSumme(Iterable<Messung> messungen) => messungen
    .where((m) => !m.laeuft)
    .fold(Duration.zero, (s, m) => s + m.stopp!.difference(m.start));

TagesProtokoll tagesProtokoll(Datenbestand d, Tag tag, DateTime jetzt) {
  final heute = tagFuer(jetzt, d.tageswechsel);
  final kette = tageskette(d, tag);
  final messungen = d.messungenAm(tag);
  final kettenname = d.tageslaeufe[tag]?.ketteName ?? kette.kette?.name;
  final eintraege = <ProtokollEintrag>[];
  var luecken = Duration.zero;
  for (var i = 0; i < messungen.length; i++) {
    final m = messungen[i];
    if (i > 0) {
      final vorher = messungen[i - 1];
      final von = vorher.ende(jetzt);
      if (m.start.isAfter(von)) {
        final l = Luecke(von, m.start);
        luecken += l.dauer;
        if (l.dauer >= sichtbareLuecke) eintraege.add(ProtokollEintrag.luecke(l));
      }
    }
    eintraege.add(ProtokollEintrag.messung(m,
        anderemKettennamen: m.ketteName != null && m.ketteName != kettenname));
  }
  return TagesProtokoll(
    tag: tag,
    kette: kette,
    messungen: messungen,
    eintraege: eintraege,
    summe: gemesseneSumme(messungen),
    lueckenSumme: luecken,
    istZukunft: tag.istNach(heute),
  );
}

/// Prüft eine Messung vor dem Speichern: Stopp nach Start, nicht in der
/// Zukunft, keine Überschneidung mit einer anderen Messung (die laufende
/// zählt bis jetzt). [ignorieren] ist die bearbeitete Messung selbst.
void pruefeMessung(
  Datenbestand d, {
  required DateTime start,
  required DateTime stopp,
  required DateTime jetzt,
  int? ignorieren,
}) {
  if (!stopp.isAfter(start)) {
    throw const FachFehler('Der Stopp muss nach dem Start liegen.');
  }
  if (stopp.isAfter(jetzt)) {
    throw const FachFehler('Der Stopp darf nicht in der Zukunft liegen.');
  }
  final kandidaten = d.messungen.values.toList()..sort((a, b) => a.start.compareTo(b.start));
  for (final m in kandidaten) {
    if (m.id == ignorieren) continue;
    if (start.isBefore(m.ende(jetzt)) && m.start.isBefore(stopp)) {
      final bis = m.laeuft ? 'läuft' : formatUhrzeit(m.stopp!);
      throw UeberschneidungFehler(
        m,
        'Überschneidet sich mit „${d.ereignisName(m.ereignisId)}“ '
        '(${formatUhrzeit(m.start)}–$bis).',
      );
    }
  }
}
