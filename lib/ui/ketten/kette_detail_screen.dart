import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/domain.dart';
import '../../state/providers.dart';
import '../gemeinsam.dart';
import '../theme.dart';
import 'ketten_screen.dart';

class KetteDetailScreen extends ConsumerWidget {
  const KetteDetailScreen({super.key, required this.ketteId});
  final int ketteId;

  Future<void> _nameFarbe(BuildContext context, WidgetRef ref, Kette k) async {
    final dienst = ref.read(dienstProvider);
    final erg = await ketteFormSheet(context, titel: 'Name und Farbe', name: k.name, farbe: k.farbe);
    if (erg == null || !context.mounted) return;
    aktion(context, dienst, () => dienst.ketteBearbeiten(k.id, name: erg.$1, farbe: erg.$2), meldung: 'Gespeichert');
  }

  Future<void> _loeschen(BuildContext context, WidgetRef ref, Kette k) async {
    final dienst = ref.read(dienstProvider);
    int? ersatz;
    if (ketteWirdVerwendet(dienst.daten, k.id)) {
      final wahl = await kettenSheet(
        context,
        dienst.daten,
        titel: '„${k.name}“ löschen',
        untertitel: 'Welche Kette bekommen die Tage (${kettenVerwendung(dienst.daten, k.id)}) stattdessen?',
        ausser: k.id,
      );
      if (wahl == null || !context.mounted) return;
      ersatz = wahl is KetteGewaehlt ? wahl.ketteId : null;
    } else {
      final ok = await bestaetigen(context,
          titel: '„${k.name}“ löschen?', text: 'Messungen bleiben erhalten.', knopf: 'Löschen', gefaehrlich: true);
      if (!ok || !context.mounted) return;
    }
    final navigator = Navigator.of(context);
    final ok = aktion(context, dienst, () => dienst.ketteLoeschen(k.id, ersatz: ersatz), meldung: '„${k.name}“ gelöscht');
    if (ok) navigator.pop();
  }

  Future<void> _schrittHinzufuegen(BuildContext context, WidgetRef ref, Kette k) async {
    final dienst = ref.read(dienstProvider);
    final wahl = await ereignisSucheSheet(context, dienst.daten,
        titel: 'Schritt hinzufügen', wiederherstellenAnbieten: true);
    if (wahl == null || !context.mounted) return;
    switch (wahl) {
      case EreignisBestehend(:final id):
        aktion(context, dienst, () => dienst.schrittHinzufuegen(k.id, id), meldung: 'Schritt hinzugefügt');
      case EreignisNeu(:final name):
        aktion(context, dienst, () => dienst.schrittHinzufuegenNeu(k.id, name), meldung: 'Ereignis angelegt und hinzugefügt');
      case EreignisWiederherstellen(:final id):
        aktion(context, dienst, () => dienst.schrittWiederherstellenUndEinfuegen(k.id, id),
            meldung: 'Wiederhergestellt und hinzugefügt');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daten = ref.watch(datenProvider);
    final dienst = ref.read(dienstProvider);
    final k = daten.ketten[ketteId];
    final f = context.farben;
    if (k == null) {
      return Scaffold(appBar: AppBar(), body: const LeerHinweis('Diese Kette gibt es nicht mehr.'));
    }
    final heute = dienst.laeuftHeute(k.id);
    final haeufigkeit = <int, int>{};
    for (final e in k.schritte) {
      haeufigkeit[e] = (haeufigkeit[e] ?? 0) + 1;
    }
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz),
            onSelected: (v) {
              switch (v) {
                case 'name':
                  _nameFarbe(context, ref, k);
                case 'dup':
                  late int neu;
                  final ok = aktion(context, dienst, () {
                    final (a, id) = dienst.ketteDuplizieren(k.id);
                    neu = id;
                    return a;
                  }, meldung: 'Kette dupliziert');
                  if (ok) {
                    Navigator.of(context)
                        .pushReplacement(MaterialPageRoute<void>(builder: (_) => KetteDetailScreen(ketteId: neu)));
                  }
                case 'del':
                  _loeschen(context, ref, k);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'name', child: Text('Name und Farbe')),
              PopupMenuItem(value: 'dup', child: Text('Duplizieren')),
              PopupMenuItem(value: 'del', child: Text('Kette löschen')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _nameFarbe(context, ref, k),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                KettenPunkt(k.farbe, groesse: 22),
                const SizedBox(width: 12),
                Expanded(child: Text(k.name, style: ueberschrift(28, gewicht: FontWeight.w800))),
                Icon(Icons.edit_outlined, color: f.muted, size: 20),
              ]),
            ),
          ),
          Text('Gilt: ${kettenVerwendung(daten, k.id)}', style: TextStyle(color: f.muted)),
          if (heute != null)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: f.warnSoft, borderRadius: BorderRadius.circular(12)),
              child: Text(
                'Heute läuft diese Kette (${heute.$1} von ${heute.$2} erledigt). Änderungen gelten ab morgen.',
                style: TextStyle(color: f.warn, fontWeight: FontWeight.w700),
              ),
            ),
          const SizedBox(height: 16),
          if (k.schritte.isEmpty) const LeerHinweis('Die Kette ist noch leer.'),
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            onReorderItem: (von, ziel) {
              if (ziel == von) return;
              aktion(context, dienst, () => dienst.schrittVerschieben(k.id, von, ziel), meldung: 'Umsortiert');
            },
            children: [
              for (var i = 0; i < k.schritte.length; i++)
                Container(
                  key: ValueKey('schritt-$i-${k.schritte[i]}'),
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: f.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: f.line),
                  ),
                  child: ListTile(
                    leading: ReorderableDragStartListener(
                      index: i,
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.drag_handle, color: f.muted),
                        const SizedBox(width: 8),
                        SizedBox(width: 22, child: Text('${i + 1}', style: zahl(14, farbe: f.muted))),
                      ]),
                    ),
                    title: Text(daten.ereignisName(k.schritte[i]), style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: (haeufigkeit[k.schritte[i]] ?? 0) > 1
                        ? Text('${haeufigkeit[k.schritte[i]]}× in der Kette')
                        : null,
                    trailing: IconButton(
                      tooltip: 'Schritt entfernen',
                      icon: const Icon(Icons.close),
                      onPressed: () =>
                          aktion(context, dienst, () => dienst.schrittEntfernen(k.id, i), meldung: 'Schritt entfernt'),
                    ),
                  ),
                ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: f.go),
              onPressed: () => _schrittHinzufuegen(context, ref, k),
              icon: const Icon(Icons.add),
              label: const Text('Schritt hinzufügen'),
            ),
          ),
        ],
      ),
    );
  }
}
