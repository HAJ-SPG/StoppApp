import 'dart:async';

import 'datenbestand.dart';
import 'fehler.dart';
import 'modelle.dart';
import 'protokoll.dart';
import 'tag.dart';
import 'tageskette.dart';
import 'tageslauf_logik.dart';
import 'uhr.dart';

/// Schreibt Datenbestände dauerhaft. Die Datenschicht implementiert das mit
/// drift; Tests nutzen [SpeicherImSpeicher].
abstract class Speicher {
  Future<Datenbestand> laden();
  Future<void> speichern(Datenbestand alt, Datenbestand neu);
}

class SpeicherImSpeicher implements Speicher {
  SpeicherImSpeicher([this.stand = const Datenbestand()]);
  Datenbestand stand;
  @override
  Future<Datenbestand> laden() async => stand;
  @override
  Future<void> speichern(Datenbestand alt, Datenbestand neu) async => stand = neu;
}

/// Kennzeichnet eine Änderung, die man rückgängig machen kann.
class Aenderung {
  const Aenderung(this.version);
  final int version;
}

enum EntfernenErgebnis { archiviert, geloescht }

/// Die Fachlogik der StoppApp. Hält den aktuellen [Datenbestand], führt
/// Aktionen aus, speichert und meldet nach jeder Änderung „Zustand geändert“.
class StoppDienst {
  // ignore: prefer_initializing_formals
  StoppDienst({required Datenbestand daten, required this.uhr, this.speicher}) : _daten = daten;

  final Uhr uhr;
  final Speicher? speicher;
  Datenbestand _daten;
  Datenbestand get daten => _daten;

  final List<void Function()> _beobachter = [];
  int _version = 0;
  Datenbestand? _vorher;
  int? _rueckgaengigVersion;
  Future<void> _schreiben = Future.value();

  /// Wartet, bis alle Änderungen geschrieben sind.
  Future<void> get gespeichert => _schreiben;

  DateTime get jetzt => uhr.jetzt();
  Tag get heute => tagFuer(jetzt, _daten.tageswechsel);
  HeuteZustand get heuteZustand => heuteZustandVon(_daten, jetzt);

  // ---------------------------------------------------------------- Beobachter

  /// Punkt, an dem nach jeder Änderung „Zustand geändert“ gemeldet wird.
  /// Daran hängt auch der Widget-Schnappschuss (Spec Abschnitt 11).
  void beobachten(void Function() f) => _beobachter.add(f);
  void nichtMehrBeobachten(void Function() f) => _beobachter.remove(f);

  void _setzen(Datenbestand neu, {bool rueckgaengig = true}) {
    final alt = _daten;
    if (identical(alt, neu)) return;
    _daten = neu;
    if (rueckgaengig) {
      _version++;
      _vorher = alt;
      _rueckgaengigVersion = _version;
    }
    final s = speicher;
    if (s != null) {
      _schreiben = _schreiben.then((_) => s.speichern(alt, neu)).catchError((Object e, StackTrace st) {
        Zone.current.handleUncaughtError(e, st);
      });
    }
    for (final f in List.of(_beobachter)) {
      f();
    }
  }

  Aenderung _aendern(Datenbestand Function(Datenbestand d) f) {
    tagesSicherstellen();
    _setzen(f(_daten));
    return Aenderung(_version);
  }

  /// Macht die Änderung [a] rückgängig, wenn seitdem nichts anderes geändert wurde.
  bool rueckgaengig(Aenderung a) {
    final v = _vorher;
    if (v == null || a.version != _rueckgaengigVersion) return false;
    _vorher = null;
    _rueckgaengigVersion = null;
    _version++;
    _setzen(v, rueckgaengig: false);
    tagesSicherstellen();
    return true;
  }

  bool kannRueckgaengig(Aenderung a) => _vorher != null && a.version == _rueckgaengigVersion;

  // ---------------------------------------------------------------- Tageslauf

  /// Legt beim ersten Öffnen oder der ersten Aktion eines Tages den
  /// Tageslauf als Schnappschuss der Tageskette an.
  void tagesSicherstellen() {
    final tag = heute;
    if (_daten.tageslaeufe.containsKey(tag)) return;
    final lauf = _tageslaufAus(_daten, tag);
    if (lauf == null) return;
    _setzen(_daten.kopie(tageslaeufe: {..._daten.tageslaeufe, tag: lauf}), rueckgaengig: false);
  }

  static Tageslauf? _tageslaufAus(Datenbestand d, Tag tag) {
    final k = tageskette(d, tag).kette;
    if (k == null) return null;
    return Tageslauf(tag: tag, ketteId: k.id, ketteName: k.name, schritte: List.of(k.schritte));
  }

  /// Legt den Tageslauf von heute neu an, wenn sich die Tageskette geändert hat.
  static Datenbestand _tageslaufErneuern(Datenbestand d, Tag tag) {
    final alt = d.tageslaeufe[tag];
    final k = tageskette(d, tag).kette;
    if (alt != null && k != null && alt.ketteId == k.id) return d;
    if (alt == null && k == null) return d;
    final laeufe = Map.of(d.tageslaeufe)..remove(tag);
    final neu = _tageslaufAus(d, tag);
    if (neu != null) laeufe[tag] = neu;
    return d.kopie(tageslaeufe: laeufe);
  }

  // ---------------------------------------------------------------- Heute

  Datenbestand _mitMessung(Datenbestand d, Messung m) =>
      d.kopie(messungen: {...d.messungen, m.id: m});

  void _keineLaufende() {
    if (_daten.laufendeMessung != null) throw const FachFehler('Es läuft schon eine Messung.');
  }

  /// Der große Button: stoppt die laufende Messung oder startet den nächsten Schritt.
  Aenderung knopfDruecken() =>
      _daten.laufendeMessung != null ? stoppen() : starten();

  /// Startet den nächsten Schritt der Kette, zum Zeitpunkt [zeit] (sonst jetzt).
  Aenderung starten({DateTime? zeit}) {
    tagesSicherstellen();
    _keineLaufende();
    final z = heuteZustand;
    final n = z.naechster;
    final lauf = z.tageslauf;
    if (n == null || lauf == null) throw const FachFehler('Kein Schritt zum Starten.');
    return _aendern((d) {
      final m = Messung(
        id: naechsteId(d.messungen.keys),
        ereignisId: lauf.schritte[n],
        start: (zeit ?? jetzt).toUtc(),
        tag: z.tag,
        ketteName: lauf.ketteName,
        schrittPosition: n,
      );
      return _mitMessung(d, m).kopie(tageslaeufe: {
        ...d.tageslaeufe,
        z.tag: lauf.kopie(naechsterLoeschen: true),
      });
    });
  }

  /// Stoppt die laufende Messung zum Zeitpunkt [zeit] (sonst jetzt).
  Aenderung stoppen({DateTime? zeit}) {
    final m = _daten.laufendeMessung;
    if (m == null) throw const FachFehler('Es läuft keine Messung.');
    var stopp = (zeit ?? jetzt).toUtc();
    if (!stopp.isAfter(m.start)) stopp = m.start.add(const Duration(seconds: 1));
    return _aendern((d) => _mitMessung(d, m.kopie(stopp: stopp)));
  }

  /// Markiert den nächsten Schritt als übersprungen.
  Aenderung ueberspringen() {
    tagesSicherstellen();
    final z = heuteZustand;
    final n = z.naechster;
    final lauf = z.tageslauf;
    if (n == null || lauf == null) throw const FachFehler('Kein Schritt zum Überspringen.');
    return _aendern((d) => d.kopie(tageslaeufe: {
          ...d.tageslaeufe,
          z.tag: lauf.kopie(
            uebersprungen: {...lauf.uebersprungen, n},
            naechsterLoeschen: lauf.naechster == n,
          ),
        }));
  }

  /// Macht einen offenen oder übersprungenen Schritt zum nächsten.
  Aenderung naechstesWaehlen(int position) {
    tagesSicherstellen();
    final z = heuteZustand;
    final lauf = z.tageslauf;
    if (lauf == null || position < 0 || position >= z.schritte.length || !z.schritte[position].waehlbar) {
      throw const FachFehler('Dieser Schritt kann nicht gewählt werden.');
    }
    return _aendern((d) => d.kopie(tageslaeufe: {
          ...d.tageslaeufe,
          z.tag: lauf.kopie(naechster: position),
        }));
  }

  /// Startet sofort ein beliebiges Ereignis außerhalb der Kette.
  Aenderung einschieben(int ereignisId) {
    tagesSicherstellen();
    _keineLaufende();
    final e = _daten.ereignisse[ereignisId];
    if (e == null || e.archiviert) throw const FachFehler('Unbekanntes Ereignis.');
    return _aendern((d) => _einschiebenIn(d, ereignisId));
  }

  /// Legt ein neues Ereignis an und schiebt es sofort ein.
  Aenderung einschiebenNeu(String name) {
    tagesSicherstellen();
    _keineLaufende();
    return _aendern((d) {
      final (d2, id) = _ereignisAnlegenIn(d, name);
      return _einschiebenIn(d2, id);
    });
  }

  Datenbestand _einschiebenIn(Datenbestand d, int ereignisId) {
    final tag = heute;
    return _mitMessung(
      d,
      Messung(
        id: naechsteId(d.messungen.keys),
        ereignisId: ereignisId,
        start: jetzt.toUtc(),
        tag: tag,
        ketteName: d.tageslaeufe[tag]?.ketteName,
      ),
    );
  }

  Messung _laufende() {
    final m = _daten.laufendeMessung;
    if (m == null) throw const FachFehler('Es läuft keine Messung.');
    return m;
  }

  /// Kann „Gestoppt vor [vor]“ angeboten werden?
  bool kannGestopptVor(Duration vor) {
    final m = _daten.laufendeMessung;
    return m != null && jetzt.subtract(vor).isAfter(m.start);
  }

  /// Stoppt mit Stopp = jetzt − [vor].
  Aenderung gestopptVor(Duration vor) {
    final m = _laufende();
    final stopp = jetzt.subtract(vor).toUtc();
    if (!stopp.isAfter(m.start)) {
      throw const FachFehler('Die Messung läuft noch nicht so lange.');
    }
    return _aendern((d) => _mitMessung(d, m.kopie(stopp: stopp)));
  }

  /// Setzt Start = jetzt − [vor], höchstens bis zum Stopp der vorigen Messung.
  Aenderung begonnenVor(Duration vor) {
    final m = _laufende();
    var start = jetzt.subtract(vor).toUtc();
    for (final andere in _daten.messungen.values) {
      if (andere.id == m.id || andere.laeuft) continue;
      // vorige Messung = begann vor der laufenden
      final stopp = andere.stopp!;
      if (!andere.start.isAfter(m.start) && stopp.isAfter(start)) start = stopp;
    }
    return _aendern((d) => _mitMessung(d, m.kopie(start: start)));
  }

  /// Löscht die laufende Messung; ihr Schritt ist wieder offen.
  Aenderung verwerfen() {
    final m = _laufende();
    return _aendern((d) => d.kopie(messungen: Map.of(d.messungen)..remove(m.id)));
  }

  // ---------------------------------------------------------------- Kalender

  /// Setzt für [tage] eine Tagesausnahme ([ketteId] `null` = „Keine Kette“).
  Aenderung ketteFuerTageSetzen(Iterable<Tag> tage, int? ketteId) {
    if (ketteId != null && !_daten.ketten.containsKey(ketteId)) {
      throw const FachFehler('Unbekannte Kette.');
    }
    final liste = tage.toList();
    return _aendern((d) {
      var neu = d.kopie(tagesausnahmen: {...d.tagesausnahmen, for (final t in liste) t: ketteId});
      if (liste.contains(heute)) neu = _tageslaufErneuern(neu, heute);
      return neu;
    });
  }

  /// Entfernt die Tagesausnahmen von [tage] („Wochenregel verwenden“).
  Aenderung wochenregelVerwenden(Iterable<Tag> tage) {
    final liste = tage.toList();
    return _aendern((d) {
      var neu = d.kopie(tagesausnahmen: Map.of(d.tagesausnahmen)..removeWhere((t, _) => liste.contains(t)));
      if (liste.contains(heute)) neu = _tageslaufErneuern(neu, heute);
      return neu;
    });
  }

  /// Setzt die Wochenregel (Wochentag 1–7 → Kette oder `null`).
  Aenderung wochenregelSetzen(Map<int, int?> regel) => _aendern((d) => d.kopie(wochenregel: {
        for (var w = 1; w <= 7; w++)
          if (regel[w] != null) w: regel[w],
      }));

  Aenderung messungNachtragen({
    required Tag tag,
    required int ereignisId,
    required DateTime start,
    required DateTime stopp,
  }) {
    pruefeMessung(_daten, start: start, stopp: stopp, jetzt: jetzt);
    final e = _daten.ereignisse[ereignisId];
    if (e == null) throw const FachFehler('Unbekanntes Ereignis.');
    tagesSicherstellen();
    final position = nachtragungsSchritt(_daten, tag, ereignisId, heute: heute);
    return _aendern((d) => _mitMessung(
          d,
          Messung(
            id: naechsteId(d.messungen.keys),
            ereignisId: ereignisId,
            start: start.toUtc(),
            stopp: stopp.toUtc(),
            tag: tag,
            ketteName: d.tageslaeufe[tag]?.ketteName ?? tageskette(d, tag).kette?.name,
            schrittPosition: position,
          ),
        ));
  }

  Aenderung messungBearbeiten({
    required int id,
    required int ereignisId,
    required DateTime start,
    required DateTime stopp,
  }) {
    final m = _daten.messungen[id];
    if (m == null) throw const FachFehler('Unbekannte Messung.');
    if (m.laeuft) throw const FachFehler('Die laufende Messung wird auf dem Haupt-Screen korrigiert.');
    pruefeMessung(_daten, start: start, stopp: stopp, jetzt: jetzt, ignorieren: id);
    if (ereignisId == m.ereignisId) {
      return _aendern(
          (d) => _mitMessung(d, m.kopie(start: start.toUtc(), stopp: stopp.toUtc())));
    }
    // Neues Ereignis: Der alte Schritt wird frei, der neue folgt der Nachtragungs-Regel.
    tagesSicherstellen();
    final position = nachtragungsSchritt(_daten, m.tag, ereignisId, heute: heute, ignorieren: id);
    return _aendern((d) => _mitMessung(
        d,
        m.kopie(
          ereignisId: ereignisId,
          start: start.toUtc(),
          stopp: stopp.toUtc(),
          schrittPosition: position,
          schrittPositionLoeschen: position == null,
        )));
  }

  Aenderung messungLoeschen(int id) {
    final m = _daten.messungen[id];
    if (m == null) throw const FachFehler('Unbekannte Messung.');
    return _aendern((d) => d.kopie(messungen: Map.of(d.messungen)..remove(id)));
  }

  // ---------------------------------------------------------------- Editor: Ereignisse

  static String _nameNormal(String name) => name.trim();

  static void _namePruefen(String name, Iterable<String> vorhandene, String art) {
    if (name.isEmpty) throw const FachFehler('Der Name darf nicht leer sein.');
    final klein = name.toLowerCase();
    if (vorhandene.any((n) => n.toLowerCase() == klein)) {
      throw FachFehler('$art „$name“ gibt es schon.');
    }
  }

  (Datenbestand, int) _ereignisAnlegenIn(Datenbestand d, String roh) {
    final name = _nameNormal(roh);
    _namePruefen(name, d.ereignisse.values.map((e) => e.name), 'Ein Ereignis');
    final id = naechsteId(d.ereignisse.keys);
    return (d.kopie(ereignisse: {...d.ereignisse, id: Ereignis(id: id, name: name)}), id);
  }

  (Aenderung, int) ereignisAnlegen(String name) {
    late int id;
    final a = _aendern((d) {
      final (neu, i) = _ereignisAnlegenIn(d, name);
      id = i;
      return neu;
    });
    return (a, id);
  }

  Aenderung ereignisUmbenennen(int id, String roh) {
    final e = _daten.ereignisse[id];
    if (e == null) throw const FachFehler('Unbekanntes Ereignis.');
    final name = _nameNormal(roh);
    _namePruefen(name, _daten.ereignisse.values.where((x) => x.id != id).map((x) => x.name), 'Ein Ereignis');
    return _aendern((d) => d.kopie(ereignisse: {...d.ereignisse, id: e.kopie(name: name)}));
  }

  bool hatMessungen(int ereignisId) => _daten.messungen.values.any((m) => m.ereignisId == ereignisId);

  /// Mit Messungen wird das Ereignis archiviert und aus allen Ketten
  /// entfernt, ohne Messungen gelöscht.
  (Aenderung, EntfernenErgebnis) ereignisEntfernen(int id) {
    final e = _daten.ereignisse[id];
    if (e == null) throw const FachFehler('Unbekanntes Ereignis.');
    final archivieren = hatMessungen(id);
    final a = _aendern((d) {
      final ketten = {
        for (final k in d.ketten.values)
          k.id: k.schritte.contains(id) ? k.kopie(schritte: k.schritte.where((x) => x != id).toList()) : k,
      };
      final ereignisse = Map.of(d.ereignisse);
      if (archivieren) {
        ereignisse[id] = e.kopie(archiviert: true);
      } else {
        ereignisse.remove(id);
      }
      return d.kopie(ereignisse: ereignisse, ketten: ketten);
    });
    return (a, archivieren ? EntfernenErgebnis.archiviert : EntfernenErgebnis.geloescht);
  }

  Aenderung ereignisWiederherstellen(int id) {
    final e = _daten.ereignisse[id];
    if (e == null) throw const FachFehler('Unbekanntes Ereignis.');
    return _aendern((d) => d.kopie(ereignisse: {...d.ereignisse, id: e.kopie(archiviert: false)}));
  }

  // ---------------------------------------------------------------- Editor: Ketten

  static void _farbePruefen(int farbe) {
    if (farbe < 0 || farbe > 5) throw const FachFehler('Ungültige Farbe.');
  }

  (Aenderung, int) ketteAnlegen(String roh, int farbe) {
    final name = _nameNormal(roh);
    _namePruefen(name, _daten.ketten.values.map((k) => k.name), 'Eine Kette');
    _farbePruefen(farbe);
    final id = naechsteId(_daten.ketten.keys);
    final sort = naechsteId(_daten.ketten.values.map((k) => k.sortierung));
    final a = _aendern((d) => d.kopie(
        ketten: {...d.ketten, id: Kette(id: id, name: name, farbe: farbe, sortierung: sort)}));
    return (a, id);
  }

  Kette _kette(int id) {
    final k = _daten.ketten[id];
    if (k == null) throw const FachFehler('Unbekannte Kette.');
    return k;
  }

  Aenderung ketteBearbeiten(int id, {required String name, required int farbe}) {
    final k = _kette(id);
    final n = _nameNormal(name);
    _namePruefen(n, _daten.ketten.values.where((x) => x.id != id).map((x) => x.name), 'Eine Kette');
    _farbePruefen(farbe);
    return _aendern((d) => d.kopie(ketten: {...d.ketten, id: k.kopie(name: n, farbe: farbe)}));
  }

  (Aenderung, int) ketteDuplizieren(int id) {
    final k = _kette(id);
    final namen = _daten.ketten.values.map((x) => x.name.toLowerCase()).toSet();
    var name = '${k.name} (Kopie)';
    for (var i = 2; namen.contains(name.toLowerCase()); i++) {
      name = '${k.name} (Kopie $i)';
    }
    final neuId = naechsteId(_daten.ketten.keys);
    final a = _aendern((d) {
      final sortiert = d.kettenSortiert;
      final ketten = <int, Kette>{};
      var s = 0;
      for (final x in sortiert) {
        ketten[x.id] = x.kopie(sortierung: s++);
        if (x.id == id) {
          ketten[neuId] = Kette(
              id: neuId, name: name, farbe: k.farbe, sortierung: s++, schritte: List.of(k.schritte));
        }
      }
      return d.kopie(ketten: ketten);
    });
    return (a, neuId);
  }

  /// Löscht eine Kette. Tage in Wochenregel und Tagesausnahmen bekommen
  /// [ersatz] (oder keine Kette). Messungen und der Tageslauf von heute bleiben.
  Aenderung ketteLoeschen(int id, {int? ersatz}) {
    _kette(id);
    if (ersatz == id) throw const FachFehler('Die Ersatzkette muss eine andere sein.');
    if (ersatz != null) _kette(ersatz);
    return _aendern((d) {
      final regel = <int, int?>{};
      d.wochenregel.forEach((w, k) {
        final neu = k == id ? ersatz : k;
        if (neu != null) regel[w] = neu;
      });
      final ausnahmen = {
        for (final e in d.tagesausnahmen.entries) e.key: e.value == id ? ersatz : e.value,
      };
      return d.kopie(
        ketten: Map.of(d.ketten)..remove(id),
        wochenregel: regel,
        tagesausnahmen: ausnahmen,
      );
    });
  }

  Aenderung _schritteAendern(int ketteId, List<int> Function(List<int>) f) {
    final k = _kette(ketteId);
    return _aendern((d) => d.kopie(ketten: {...d.ketten, ketteId: k.kopie(schritte: f(List.of(k.schritte)))}));
  }

  Aenderung schrittHinzufuegen(int ketteId, int ereignisId) {
    final e = _daten.ereignisse[ereignisId];
    if (e == null || e.archiviert) throw const FachFehler('Unbekanntes Ereignis.');
    return _schritteAendern(ketteId, (s) => s..add(ereignisId));
  }

  /// „+ „xyz“ als neues Ereignis anlegen“ und als Schritt einfügen.
  Aenderung schrittHinzufuegenNeu(int ketteId, String name) {
    final k = _kette(ketteId);
    return _aendern((d) {
      final (d2, id) = _ereignisAnlegenIn(d, name);
      return d2.kopie(ketten: {...d2.ketten, ketteId: k.kopie(schritte: [...k.schritte, id])});
    });
  }

  /// „wiederherstellen und einfügen“ für ein archiviertes Ereignis.
  Aenderung schrittWiederherstellenUndEinfuegen(int ketteId, int ereignisId) {
    final k = _kette(ketteId);
    final e = _daten.ereignisse[ereignisId];
    if (e == null) throw const FachFehler('Unbekanntes Ereignis.');
    return _aendern((d) => d.kopie(
          ereignisse: {...d.ereignisse, ereignisId: e.kopie(archiviert: false)},
          ketten: {...d.ketten, ketteId: k.kopie(schritte: [...k.schritte, ereignisId])},
        ));
  }

  Aenderung schrittEntfernen(int ketteId, int position) => _schritteAendern(ketteId, (s) {
        if (position < 0 || position >= s.length) throw const FachFehler('Unbekannter Schritt.');
        return s..removeAt(position);
      });

  /// Verschiebt den Schritt an [von] so, dass er danach an [nach] steht.
  Aenderung schrittVerschieben(int ketteId, int von, int nach) => _schritteAendern(ketteId, (s) {
        if (von < 0 || von >= s.length || nach < 0 || nach >= s.length) {
          throw const FachFehler('Unbekannter Schritt.');
        }
        final e = s.removeAt(von);
        return s..insert(nach, e);
      });

  /// Hinweis im Editor, wenn die Kette heute läuft: (erledigt, gesamt) oder `null`.
  (int, int)? laeuftHeute(int ketteId) {
    final z = heuteZustandVon(_daten, jetzt);
    final lauf = z.tageslauf;
    if (lauf == null || lauf.ketteId != ketteId) return null;
    return (z.erledigt, z.anzahlSchritte);
  }

  // ---------------------------------------------------------------- Einstellungen

  Aenderung tageswechselSetzen(int minuten) {
    if (minuten < 0 || minuten > 360 || minuten % 15 != 0) {
      throw const FachFehler('Der Tageswechsel muss zwischen 00:00 und 06:00 liegen.');
    }
    return _aendern((d) => d.kopie(einstellungen: Einstellungen(tageswechsel: minuten)));
  }
}

/// Alias, damit [StoppDienst.heuteZustand] die freie Funktion nutzen kann.
HeuteZustand heuteZustandVon(Datenbestand d, DateTime jetzt) => heuteZustand(d, jetzt);
