import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/domain.dart';
import '../../state/providers.dart';
import '../gemeinsam.dart';
import '../theme.dart';
import 'kette_detail_screen.dart';

class KettenScreen extends StatelessWidget {
  const KettenScreen({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Ketten', style: ueberschrift(26, gewicht: FontWeight.w800)),
              ),
            ),
            const TabBar(tabs: [Tab(text: 'Ketten'), Tab(text: 'Ereignisse')]),
            const Expanded(child: TabBarView(children: [_KettenTab(), _EreignisseTab()])),
          ]),
        ),
      );
}

/// Sheet für Name und Farbe einer Kette. Liefert (Name, Farbe).
Future<(String, int)?> ketteFormSheet(BuildContext context, {String titel = 'Neue Kette', String name = '', int farbe = 0}) {
  final ctrl = TextEditingController(text: name);
  var gewaehlt = farbe;
  return showModalBottomSheet<(String, int)>(
    context: context,
    isScrollControlled: true,
    builder: (c) => StatefulBuilder(
      builder: (c, setState) {
        final f = c.farben;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
          child: SafeArea(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SheetTitel(titel),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: ctrl,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(spacing: 12, runSpacing: 12, children: [
                  for (var i = 0; i < 6; i++)
                    Tooltip(
                      message: kettenFarbNamen[i],
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => setState(() => gewaehlt = i),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: f.kette(i),
                            shape: BoxShape.circle,
                            border: gewaehlt == i ? Border.all(color: f.ink, width: 3) : null,
                          ),
                          child: gewaehlt == i ? Icon(Icons.check, color: f.onSolid) : null,
                        ),
                      ),
                    ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: () => Navigator.pop(c, (ctrl.text, gewaehlt)),
                  child: const Text('Speichern'),
                ),
              ),
            ]),
          ),
        );
      },
    ),
  );
}

class _KettenTab extends ConsumerWidget {
  const _KettenTab();

  Future<void> _neu(BuildContext context, WidgetRef ref) async {
    final dienst = ref.read(dienstProvider);
    final erg = await ketteFormSheet(context);
    if (erg == null || !context.mounted) return;
    late int id;
    final ok = aktion(context, dienst, () {
      final (a, i) = dienst.ketteAnlegen(erg.$1, erg.$2);
      id = i;
      return a;
    }, meldung: 'Kette angelegt');
    if (ok && context.mounted) {
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => KetteDetailScreen(ketteId: id)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daten = ref.watch(datenProvider);
    final f = context.farben;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final k in daten.kettenSortiert) ...[
          Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute<void>(builder: (_) => KetteDetailScreen(ketteId: k.id))),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 6,
                    height: 54,
                    decoration: BoxDecoration(color: f.kette(k.farbe), borderRadius: BorderRadius.circular(3)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(k.name, style: ueberschrift(18))),
                        Text('${k.schritte.length} Schritte', style: TextStyle(color: f.muted, fontSize: 13)),
                      ]),
                      const SizedBox(height: 2),
                      Text(kettenVerwendung(daten, k.id), style: TextStyle(color: f.muted, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        k.schritte.isEmpty ? 'Noch keine Schritte' : k.schritte.map(daten.ereignisName).join(' → '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ]),
                  ),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: f.go),
            onPressed: () => _neu(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Neue Kette'),
          ),
        ),
      ],
    );
  }
}

class _EreignisseTab extends ConsumerWidget {
  const _EreignisseTab();

  Future<void> _neu(BuildContext context, WidgetRef ref) async {
    final dienst = ref.read(dienstProvider);
    final name = await textEingeben(context, titel: 'Neues Ereignis', knopf: 'Anlegen');
    if (name == null || !context.mounted) return;
    aktion(context, dienst, () => dienst.ereignisAnlegen(name).$1, meldung: 'Ereignis angelegt');
  }

  Future<void> _bearbeiten(BuildContext context, WidgetRef ref, Ereignis e) async {
    final dienst = ref.read(dienstProvider);
    final f = context.farben;
    final mitMessungen = dienst.hatMessungen(e.id);
    final wahl = await showModalBottomSheet<String>(
      context: context,
      builder: (c) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SheetTitel(e.name, untertitel: ereignisVerwendung(dienst.daten, e.id)),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Umbenennen'),
            onTap: () => Navigator.pop(c, 'umbenennen'),
          ),
          ListTile(
            leading: Icon(mitMessungen ? Icons.archive_outlined : Icons.delete_outline, color: f.stop),
            title: Text(mitMessungen ? 'Archivieren' : 'Löschen', style: TextStyle(color: f.stop)),
            subtitle: Text(mitMessungen
                ? 'Hat Messungen: wird archiviert und aus allen Ketten entfernt.'
                : 'Keine Messungen: wird gelöscht.'),
            onTap: () => Navigator.pop(c, 'entfernen'),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
    if (!context.mounted) return;
    if (wahl == 'umbenennen') {
      final name = await textEingeben(context, titel: 'Ereignis umbenennen', anfang: e.name);
      if (name == null || !context.mounted) return;
      aktion(context, dienst, () => dienst.ereignisUmbenennen(e.id, name), meldung: 'Umbenannt');
    } else if (wahl == 'entfernen') {
      if (mitMessungen) {
        final ok = await bestaetigen(context,
            titel: '„${e.name}“ archivieren?',
            text: 'Das Ereignis wird aus allen Ketten entfernt und erscheint in keiner Auswahl mehr. '
                'In Messungen und Statistik bleibt es sichtbar.',
            knopf: 'Archivieren',
            gefaehrlich: true);
        if (!ok || !context.mounted) return;
      }
      aktion(context, dienst, () => dienst.ereignisEntfernen(e.id).$1,
          meldung: mitMessungen ? '„${e.name}“ archiviert' : '„${e.name}“ gelöscht');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daten = ref.watch(datenProvider);
    final f = context.farben;
    final archiviert = daten.archivierteEreignisse;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (final e in daten.aktiveEreignisse)
          ListTile(
            title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(ereignisVerwendung(daten, e.id)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _bearbeiten(context, ref, e),
          ),
        if (daten.aktiveEreignisse.isEmpty) const LeerHinweis('Noch keine Ereignisse.'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: f.go),
              onPressed: () => _neu(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Neues Ereignis'),
            ),
          ),
        ),
        if (archiviert.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('ARCHIVIERT',
                style: TextStyle(letterSpacing: 1.4, fontSize: 12, fontWeight: FontWeight.w700, color: f.muted)),
          ),
          for (final e in archiviert)
            ListTile(
              title: Text(e.name, style: TextStyle(color: f.muted)),
              subtitle: Text(ereignisVerwendung(daten, e.id)),
              trailing: TextButton(
                onPressed: () {
                  final dienst = ref.read(dienstProvider);
                  aktion(context, dienst, () => dienst.ereignisWiederherstellen(e.id),
                      meldung: '„${e.name}“ wiederhergestellt');
                },
                child: const Text('Wiederherstellen'),
              ),
            ),
        ],
      ],
    );
  }
}
