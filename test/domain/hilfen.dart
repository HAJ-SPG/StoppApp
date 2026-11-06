import 'package:stoppapp/domain/domain.dart';

/// Ereignisse: 1 Aufstehen, 2 Zähneputzen, 3 Arbeit fahren, 4 Kaffee.
/// Kette 1 „Arbeitstag“ (1, 2, 3) Mo–Fr, Kette 2 „Wochenende“ (1, 4) Sa–So.
Datenbestand beispielDaten() => const Datenbestand(
      ereignisse: {
        1: Ereignis(id: 1, name: 'Aufstehen'),
        2: Ereignis(id: 2, name: 'Zähneputzen'),
        3: Ereignis(id: 3, name: 'Arbeit fahren'),
        4: Ereignis(id: 4, name: 'Kaffee'),
      },
      ketten: {
        1: Kette(id: 1, name: 'Arbeitstag', farbe: 0, sortierung: 0, schritte: [1, 2, 3]),
        2: Kette(id: 2, name: 'Wochenende', farbe: 1, sortierung: 1, schritte: [1, 4]),
      },
      wochenregel: {1: 1, 2: 1, 3: 1, 4: 1, 5: 1, 6: 2, 7: 2},
    );

/// Freitag, 6. Nov 2026.
const freitag = Tag(2026, 11, 6);

DateTime um(int stunde, int minute, {Tag tag = freitag}) =>
    DateTime(tag.jahr, tag.monat, tag.tagImMonat, stunde, minute);

(StoppDienst, FesteUhr, SpeicherImSpeicher) dienst({Datenbestand? daten, DateTime? jetzt}) {
  final uhr = FesteUhr(jetzt ?? um(7, 0));
  final d = daten ?? beispielDaten();
  final speicher = SpeicherImSpeicher(d);
  return (StoppDienst(daten: d, uhr: uhr, speicher: speicher), uhr, speicher);
}
