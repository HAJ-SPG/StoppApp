import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/domain.dart';
import '../../state/providers.dart';
import '../gemeinsam.dart';
import '../theme.dart';

/// Sheet zum Nachtragen ([messung] `null`) oder Bearbeiten einer Messung.
Future<void> messungSheet(
  BuildContext context,
  WidgetRef ref, {
  required Tag tag,
  Messung? messung,
  DateTime? vorbelegtVon,
  DateTime? vorbelegtBis,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (c) => _MessungSheet(
        tag: tag,
        messung: messung,
        von: vorbelegtVon,
        bis: vorbelegtBis,
        elternKontext: context,
      ),
    );

class _MessungSheet extends ConsumerStatefulWidget {
  const _MessungSheet({required this.tag, this.messung, this.von, this.bis, required this.elternKontext});
  final Tag tag;
  final Messung? messung;
  final DateTime? von;
  final DateTime? bis;
  final BuildContext elternKontext;

  @override
  ConsumerState<_MessungSheet> createState() => _MessungSheetState();
}

class _MessungSheetState extends ConsumerState<_MessungSheet> {
  int? _ereignisId;
  late TimeOfDay _start;
  late TimeOfDay _stopp;
  String? _fehler;
  bool _loeschenBestaetigen = false;

  @override
  void initState() {
    super.initState();
    final m = widget.messung;
    final dienst = ref.read(dienstProvider);
    _ereignisId = m?.ereignisId;
    final start = (m?.start ?? widget.von)?.toLocal();
    final stopp = (m?.stopp ?? widget.bis)?.toLocal();
    if (start != null && stopp != null) {
      _start = TimeOfDay.fromDateTime(start);
      _stopp = TimeOfDay.fromDateTime(stopp);
    } else {
      final jetzt = dienst.jetzt;
      final ende = widget.tag == dienst.heute ? jetzt : tagesBeginn(widget.tag, dienst.daten.tageswechsel).add(const Duration(hours: 8));
      _stopp = TimeOfDay.fromDateTime(ende);
      _start = TimeOfDay.fromDateTime(ende.subtract(const Duration(minutes: 15)));
    }
  }

  DateTime _zeit(TimeOfDay t) =>
      uhrzeitImTag(widget.tag, t.hour, t.minute, ref.read(dienstProvider).daten.tageswechsel);

  Future<void> _ereignisWaehlen() async {
    final dienst = ref.read(dienstProvider);
    final wahl = await ereignisSucheSheet(context, dienst.daten, titel: 'Ereignis', neuAnbieten: true);
    if (wahl == null || !mounted) return;
    switch (wahl) {
      case EreignisBestehend(:final id):
        setState(() => _ereignisId = id);
      case EreignisNeu(:final name):
        try {
          final (_, id) = dienst.ereignisAnlegen(name);
          setState(() => _ereignisId = id);
        } on FachFehler catch (e) {
          setState(() => _fehler = e.meldung);
        }
      case EreignisWiederherstellen():
        break;
    }
  }

  Future<void> _zeitWaehlen(bool start) async {
    final t = await showTimePicker(
      context: context,
      initialTime: start ? _start : _stopp,
      builder: (c, child) => MediaQuery(data: MediaQuery.of(c).copyWith(alwaysUse24HourFormat: true), child: child!),
    );
    if (t == null) return;
    setState(() {
      if (start) {
        _start = t;
      } else {
        _stopp = t;
      }
      _fehler = null;
    });
  }

  void _speichern() {
    final dienst = ref.read(dienstProvider);
    final id = _ereignisId;
    if (id == null) {
      setState(() => _fehler = 'Bitte ein Ereignis wählen.');
      return;
    }
    try {
      final m = widget.messung;
      final Aenderung a;
      if (m == null) {
        a = dienst.messungNachtragen(tag: widget.tag, ereignisId: id, start: _zeit(_start), stopp: _zeit(_stopp));
      } else {
        a = dienst.messungBearbeiten(id: m.id, ereignisId: id, start: _zeit(_start), stopp: _zeit(_stopp));
      }
      Navigator.pop(context);
      _hinweis(m == null ? 'Messung nachgetragen' : 'Messung gespeichert', a);
    } on FachFehler catch (e) {
      setState(() => _fehler = e.meldung);
    }
  }

  void _hinweis(String text, Aenderung a) {
    final dienst = ref.read(dienstProvider);
    final messenger = ScaffoldMessenger.of(widget.elternKontext);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      content: Text(text),
      duration: const Duration(seconds: 5),
      persist: false,
      action: SnackBarAction(label: 'Rückgängig', onPressed: () => dienst.rueckgaengig(a)),
    ));
  }

  void _loeschen() {
    if (!_loeschenBestaetigen) {
      setState(() => _loeschenBestaetigen = true);
      return;
    }
    final dienst = ref.read(dienstProvider);
    final a = dienst.messungLoeschen(widget.messung!.id);
    Navigator.pop(context);
    _hinweis('Messung gelöscht', a);
  }

  @override
  Widget build(BuildContext context) {
    final f = context.farben;
    final daten = ref.watch(datenProvider);
    final tw = daten.tageswechsel;
    String folgetag(TimeOfDay t) => t.hour * 60 + t.minute < tw ? ' (+1 Tag)' : '';
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SheetTitel(widget.messung == null ? 'Messung nachtragen' : 'Messung bearbeiten',
              untertitel: datumLang(widget.tag)),
          ListTile(
            leading: const Icon(Icons.label_outline),
            title: Text(_ereignisId == null ? 'Ereignis wählen' : daten.ereignisName(_ereignisId!),
                style: const TextStyle(fontWeight: FontWeight.w700)),
            trailing: const Icon(Icons.chevron_right),
            onTap: _ereignisWaehlen,
          ),
          ListTile(
            leading: const Icon(Icons.play_arrow_outlined),
            title: const Text('Start'),
            trailing: Text('${_start.format24()}${folgetag(_start)}', style: zahl(16)),
            onTap: () => _zeitWaehlen(true),
          ),
          ListTile(
            leading: const Icon(Icons.stop_outlined),
            title: const Text('Stopp'),
            trailing: Text('${_stopp.format24()}${folgetag(_stopp)}', style: zahl(16)),
            onTap: () => _zeitWaehlen(false),
          ),
          if (_fehler != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(_fehler!, style: TextStyle(color: f.stop, fontWeight: FontWeight.w700)),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              if (widget.messung != null)
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: f.stop),
                  onPressed: _loeschen,
                  child: Text(_loeschenBestaetigen ? 'Wirklich löschen?' : 'Löschen'),
                ),
              const Spacer(),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
              const SizedBox(width: 8),
              FilledButton(onPressed: _speichern, child: const Text('Speichern')),
            ]),
          ),
        ]),
      ),
    );
  }
}

extension on TimeOfDay {
  String format24() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
