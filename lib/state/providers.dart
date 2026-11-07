import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/domain.dart';

/// Wird in `main.dart` mit der geladenen Fachlogik überschrieben.
final dienstProvider = Provider<StoppDienst>((ref) => throw UnimplementedError('dienstProvider überschreiben'));

/// Der aktuelle Datenbestand; aktualisiert sich bei jeder „Zustand geändert“-Meldung.
class DatenNotifier extends Notifier<Datenbestand> {
  @override
  Datenbestand build() {
    final dienst = ref.watch(dienstProvider);
    void geaendert() => state = dienst.daten;
    dienst.beobachten(geaendert);
    ref.onDispose(() => dienst.nichtMehrBeobachten(geaendert));
    return dienst.daten;
  }
}

final datenProvider = NotifierProvider<DatenNotifier, Datenbestand>(DatenNotifier.new);

/// Takt für Live-Zeiten (jede Sekunde).
final sekundenProvider = StreamProvider<DateTime>((ref) {
  final dienst = ref.watch(dienstProvider);
  return Stream.periodic(const Duration(seconds: 1), (_) => dienst.jetzt);
});

/// Takt für Tageswechsel und Datumsanzeigen (jede Minute).
final minutenProvider = StreamProvider<DateTime>((ref) {
  final dienst = ref.watch(dienstProvider);
  return Stream.periodic(const Duration(minutes: 1), (_) {
    dienst.tagesSicherstellen();
    return dienst.jetzt;
  });
});

final heuteProvider = Provider<HeuteZustand>((ref) {
  ref.watch(datenProvider);
  ref.watch(minutenProvider);
  return ref.watch(dienstProvider).heuteZustand;
});

final heuteTagProvider = Provider<Tag>((ref) => ref.watch(heuteProvider).tag);

// ---------------------------------------------------------------- Heute-Ansicht

enum HeuteAnsicht { fokus, zeitleiste }

/// Die App startet immer in Fokus; ein Wechsel hält bis zum Zurückschalten
/// oder Neustart (nicht gespeichert).
class HeuteAnsichtNotifier extends Notifier<HeuteAnsicht> {
  @override
  HeuteAnsicht build() => HeuteAnsicht.fokus;
  void setzen(HeuteAnsicht a) => state = a;
  void umschalten() => state = state == HeuteAnsicht.fokus ? HeuteAnsicht.zeitleiste : HeuteAnsicht.fokus;
}

final heuteAnsichtProvider = NotifierProvider<HeuteAnsichtNotifier, HeuteAnsicht>(HeuteAnsichtNotifier.new);

// ---------------------------------------------------------------- Statistik-Filter

class StatistikAuswahl {
  const StatistikAuswahl({
    required this.zeitraum,
    required this.von,
    required this.bis,
    this.ketteName,
    this.wochentage = const {},
  });
  final Zeitraum zeitraum;
  final Tag von;
  final Tag bis;
  final String? ketteName;
  final Set<int> wochentage;

  StatistikFilter get filter =>
      StatistikFilter(von: von, bis: bis, ketteName: ketteName, wochentage: wochentage);

  bool get filterAktiv => ketteName != null || wochentage.isNotEmpty;

  StatistikAuswahl kopie({
    Zeitraum? zeitraum,
    Tag? von,
    Tag? bis,
    String? ketteName,
    bool alleKetten = false,
    Set<int>? wochentage,
  }) =>
      StatistikAuswahl(
        zeitraum: zeitraum ?? this.zeitraum,
        von: von ?? this.von,
        bis: bis ?? this.bis,
        ketteName: alleKetten ? null : (ketteName ?? this.ketteName),
        wochentage: wochentage ?? this.wochentage,
      );
}

class StatistikNotifier extends Notifier<StatistikAuswahl> {
  @override
  StatistikAuswahl build() {
    final heute = ref.read(dienstProvider).heute;
    final (von, bis) = kalenderZeitraum(Zeitraum.woche, heute);
    return StatistikAuswahl(zeitraum: Zeitraum.woche, von: von, bis: bis);
  }

  Tag get _heute => ref.read(dienstProvider).heute;

  void zeitraumWaehlen(Zeitraum z) {
    if (z == Zeitraum.frei) {
      state = state.kopie(zeitraum: z);
      return;
    }
    final (von, bis) = kalenderZeitraum(z, _heute);
    state = state.kopie(zeitraum: z, von: von, bis: bis);
  }

  bool get kannVor => state.zeitraum != Zeitraum.frei && state.bis.istVor(_heute);

  void blaettern(int richtung) {
    if (state.zeitraum == Zeitraum.frei) return;
    if (richtung > 0 && !kannVor) return;
    final (von, bis) = zeitraumVerschieben(state.zeitraum, state.von, richtung);
    state = state.kopie(von: von, bis: bis);
  }

  void freiSetzen(Tag von, Tag bis) =>
      state = state.kopie(zeitraum: Zeitraum.frei, von: von.istNach(bis) ? bis : von, bis: von.istNach(bis) ? von : bis);

  void ketteSetzen(String? name) => state = name == null ? state.kopie(alleKetten: true) : state.kopie(ketteName: name);

  void wochentagUmschalten(int w) {
    final s = Set.of(state.wochentage);
    if (!s.remove(w)) s.add(w);
    state = state.kopie(wochentage: s);
  }

  void zuruecksetzen() => state = state.kopie(alleKetten: true, wochentage: const {});
}

final statistikProvider = NotifierProvider<StatistikNotifier, StatistikAuswahl>(StatistikNotifier.new);

