import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/domain.dart';
import '../../state/providers.dart';
import '../gemeinsam.dart';
import '../theme.dart';

/// Der große Button je nach Zustand.
void grosserKnopf(BuildContext context, WidgetRef ref, HeuteZustand z) {
  final dienst = ref.read(dienstProvider);
  switch (z.modus) {
    case HeuteModus.bereit:
    case HeuteModus.laeuft:
      aktion(context, dienst, dienst.knopfDruecken, rueckgaengig: false);
    case HeuteModus.keineKette:
      ketteFuerHeuteWaehlen(context, ref);
    case HeuteModus.erledigt:
      einschieben(context, ref);
  }
}

/// „Kette für heute wählen“: legt eine Tagesausnahme für heute an.
Future<void> ketteFuerHeuteWaehlen(BuildContext context, WidgetRef ref) async {
  final dienst = ref.read(dienstProvider);
  final heute = dienst.heute;
  final info = tageskette(dienst.daten, heute);
  final wahl = await kettenSheet(
    context,
    dienst.daten,
    titel: 'Kette für heute wählen',
    untertitel: 'Gilt nur für heute. Die Wochenregel bleibt unverändert.',
    wochenregelAnbieten: info.hatAusnahme,
    aktuell: dienst.daten.tageslaeufe[heute]?.ketteId,
  );
  if (wahl == null || !context.mounted) return;
  switch (wahl) {
    case KetteGewaehlt(:final ketteId):
      aktion(context, dienst, () => dienst.ketteFuerTageSetzen([heute], ketteId),
          meldung: 'Kette für heute: ${dienst.daten.ketten[ketteId]?.name}');
    case KeineKetteGewaehlt():
      aktion(context, dienst, () => dienst.ketteFuerTageSetzen([heute], null), meldung: 'Heute keine Kette');
    case WochenregelGewaehlt():
      aktion(context, dienst, () => dienst.wochenregelVerwenden([heute]), meldung: 'Wochenregel für heute');
  }
}

void ueberspringen(BuildContext context, WidgetRef ref) {
  final dienst = ref.read(dienstProvider);
  final z = dienst.heuteZustand;
  final name = z.naechstesEreignisId == null ? '' : dienst.daten.ereignisName(z.naechstesEreignisId!);
  aktion(context, dienst, dienst.ueberspringen, meldung: '„$name“ übersprungen');
}

Future<void> einschieben(BuildContext context, WidgetRef ref) async {
  final dienst = ref.read(dienstProvider);
  final wahl = await ereignisSucheSheet(context, dienst.daten, titel: 'Einschieben');
  if (wahl == null || !context.mounted) return;
  switch (wahl) {
    case EreignisBestehend(:final id):
      aktion(context, dienst, () => dienst.einschieben(id), meldung: '„${dienst.daten.ereignisName(id)}“ läuft');
    case EreignisNeu(:final name):
      aktion(context, dienst, () => dienst.einschiebenNeu(name), meldung: '„${name.trim()}“ läuft');
    case EreignisWiederherstellen():
      break;
  }
}

Future<void> naechstesWaehlen(BuildContext context, WidgetRef ref, HeuteZustand z) async {
  final dienst = ref.read(dienstProvider);
  final d = dienst.daten;
  final pos = await showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    builder: (c) {
      final f = c.farben;
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(c).size.height * 0.75),
          child: ListView(
            shrinkWrap: true,
            children: [
              const SheetTitel('Nächstes wählen', untertitel: 'Der große Button macht dann diesen Schritt.'),
              for (final s in z.waehlbareSchritte)
                ListTile(
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: s.position == z.naechster ? f.goSoft : f.paper,
                    child: Text('${s.position + 1}', style: zahl(12, farbe: f.ink)),
                  ),
                  title: Text(
                    d.ereignisName(s.ereignisId),
                    style: s.status == SchrittStatus.uebersprungen
                        ? TextStyle(color: f.muted, decoration: TextDecoration.lineThrough)
                        : const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: s.status == SchrittStatus.uebersprungen ? const Text('übersprungen') : null,
                  trailing: s.position == z.naechster ? Icon(Icons.check, color: f.go) : null,
                  onTap: () => Navigator.pop(c, s.position),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
  if (pos == null || !context.mounted) return;
  aktion(context, dienst, () => dienst.naechstesWaehlen(pos), rueckgaengig: false);
}

const _korrekturMinuten = [2, 5, 10, 15, 30];

Future<void> zeitKorrigieren(BuildContext context, WidgetRef ref) async {
  final dienst = ref.read(dienstProvider);
  await showModalBottomSheet<void>(
    context: context,
    builder: (c) {
      final f = c.farben;
      Widget reihe(String titel, bool Function(Duration) moeglich, void Function(Duration) los) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(titel, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final m in _korrekturMinuten)
                  ActionChip(
                    label: Text('$m Min', style: zahl(14)),
                    onPressed: moeglich(Duration(minutes: m))
                        ? () {
                            Navigator.pop(c);
                            los(Duration(minutes: m));
                          }
                        : null,
                  ),
              ]),
            ]),
          );
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetTitel('Zeit korrigieren'),
            reihe('Gestoppt vor', dienst.kannGestopptVor, (d) {
              aktion(context, dienst, () => dienst.gestopptVor(d), meldung: 'Gestoppt vor ${d.inMinutes} Min');
            }),
            reihe('Begonnen vor', (_) => true, (d) {
              aktion(context, dienst, () => dienst.begonnenVor(d), meldung: 'Start korrigiert');
            }),
            ListTile(
              leading: Icon(Icons.delete_outline, color: f.stop),
              title: Text('Messung verwerfen', style: TextStyle(color: f.stop, fontWeight: FontWeight.w700)),
              onTap: () {
                Navigator.pop(c);
                aktion(context, dienst, dienst.verwerfen, meldung: 'Messung verworfen');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
