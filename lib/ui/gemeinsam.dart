import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../domain/domain.dart';
import 'theme.dart';

const locale = 'de_AT';

String datumKopf(Tag t) => DateFormat('EEE, d. MMM', locale).format(t.datum);
String datumLang(Tag t) => DateFormat('EEEE, d. MMMM', locale).format(t.datum);
String datumMittel(Tag t) => DateFormat('EEE, d. MMM yyyy', locale).format(t.datum);
String datumKurz(Tag t) => DateFormat('d. M.', locale).format(t.datum);
String monatJahr(DateTime d) => DateFormat('MMMM yyyy', locale).format(d);

/// Führt eine Änderung aus. Zeigt bei Erfolg einen Hinweis mit „Rückgängig“
/// (ca. 5 s), bei einem fachlichen Fehler dessen Meldung.
bool aktion(
  BuildContext context,
  StoppDienst dienst,
  Aenderung Function() f, {
  String? meldung,
  bool rueckgaengig = true,
}) {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final a = f();
    if (meldung != null || rueckgaengig) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(SnackBar(
        content: Text(meldung ?? 'Gespeichert'),
        duration: const Duration(seconds: 5),
        persist: false,
        action: rueckgaengig
            ? SnackBarAction(label: 'Rückgängig', onPressed: () => dienst.rueckgaengig(a))
            : null,
      ));
    }
    return true;
  } on FachFehler catch (e) {
    fehlerZeigen(context, e.meldung);
    return false;
  }
}

void fehlerZeigen(BuildContext context, String meldung) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(SnackBar(
    content: Text(meldung),
    backgroundColor: context.farben.stop,
    duration: const Duration(seconds: 4),
  ));
}

Future<bool> bestaetigen(BuildContext context,
    {required String titel, String? text, required String knopf, bool gefaehrlich = false}) async {
  final f = context.farben;
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      backgroundColor: f.surface,
      title: Text(titel, style: ueberschrift(20)),
      content: text == null ? null : Text(text),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Abbrechen')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: gefaehrlich ? f.stop : f.go, foregroundColor: f.onSolid),
          onPressed: () => Navigator.pop(c, true),
          child: Text(knopf),
        ),
      ],
    ),
  );
  return ok ?? false;
}

Future<String?> textEingeben(BuildContext context,
    {required String titel, String anfang = '', String knopf = 'Speichern', String? hinweis}) {
  final ctrl = TextEditingController(text: anfang);
  return showDialog<String>(
    context: context,
    builder: (c) => AlertDialog(
      backgroundColor: c.farben.surface,
      title: Text(titel, style: ueberschrift(20)),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(hintText: hinweis ?? 'Name'),
        onSubmitted: (v) => Navigator.pop(c, v),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Abbrechen')),
        FilledButton(onPressed: () => Navigator.pop(c, ctrl.text), child: Text(knopf)),
      ],
    ),
  );
}

/// Kopfzeile eines Sheets.
class SheetTitel extends StatelessWidget {
  const SheetTitel(this.titel, {super.key, this.untertitel});
  final String titel;
  final String? untertitel;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titel, style: ueberschrift(22, gewicht: FontWeight.w800)),
            if (untertitel != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(untertitel!, style: TextStyle(color: context.farben.muted)),
              ),
          ],
        ),
      );
}

/// Farbpunkt einer Kette.
class KettenPunkt extends StatelessWidget {
  const KettenPunkt(this.farbe, {super.key, this.groesse = 12});
  final int farbe;
  final double groesse;
  @override
  Widget build(BuildContext context) => Container(
        width: groesse,
        height: groesse,
        decoration: BoxDecoration(color: context.farben.kette(farbe), shape: BoxShape.circle),
      );
}

/// Ketten-Chip: Name der Tageskette, antippen öffnet die Auswahl.
class KettenChip extends StatelessWidget {
  const KettenChip({super.key, required this.name, this.farbe, this.onTap, this.warnung = false});
  final String? name;
  final int? farbe;
  final VoidCallback? onTap;
  final bool warnung;

  @override
  Widget build(BuildContext context) {
    final f = context.farben;
    final rand = warnung ? f.stop : f.line;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: rand, width: 1.5),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (farbe != null) ...[KettenPunkt(farbe!, groesse: 10), const SizedBox(width: 6)],
            Flexible(
              child: Text(
                name ?? 'Keine Kette',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: warnung ? f.stop : f.ink),
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.expand_more, size: 16, color: warnung ? f.stop : f.muted),
          ]),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Ketten-Sheet

sealed class KettenWahl {
  const KettenWahl();
}

class KetteGewaehlt extends KettenWahl {
  const KetteGewaehlt(this.ketteId);
  final int ketteId;
}

class KeineKetteGewaehlt extends KettenWahl {
  const KeineKetteGewaehlt();
}

class WochenregelGewaehlt extends KettenWahl {
  const WochenregelGewaehlt();
}

/// Sheet mit allen Ketten, „Keine Kette“ und optional „Wochenregel verwenden“.
Future<KettenWahl?> kettenSheet(
  BuildContext context,
  Datenbestand daten, {
  required String titel,
  String? untertitel,
  bool wochenregelAnbieten = false,
  int? aktuell,
  int? ausser,
}) {
  return showModalBottomSheet<KettenWahl>(
    context: context,
    isScrollControlled: true,
    builder: (c) {
      final f = c.farben;
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(c).size.height * 0.8),
          child: ListView(
            shrinkWrap: true,
            children: [
              SheetTitel(titel, untertitel: untertitel),
              for (final k in daten.kettenSortiert.where((k) => k.id != ausser))
                ListTile(
                  leading: KettenPunkt(k.farbe, groesse: 16),
                  title: Text(k.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${k.schritte.length} Schritte'),
                  trailing: aktuell == k.id ? Icon(Icons.check, color: f.go) : null,
                  onTap: () => Navigator.pop(c, KetteGewaehlt(k.id)),
                ),
              ListTile(
                leading: Icon(Icons.block, color: f.muted),
                title: const Text('Keine Kette'),
                onTap: () => Navigator.pop(c, const KeineKetteGewaehlt()),
              ),
              if (wochenregelAnbieten)
                ListTile(
                  leading: Icon(Icons.event_repeat, color: f.muted),
                  title: const Text('Wochenregel verwenden'),
                  onTap: () => Navigator.pop(c, const WochenregelGewaehlt()),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}

// ---------------------------------------------------------------- Ereignis-Suche

sealed class EreignisWahl {
  const EreignisWahl();
}

class EreignisBestehend extends EreignisWahl {
  const EreignisBestehend(this.id);
  final int id;
}

class EreignisNeu extends EreignisWahl {
  const EreignisNeu(this.name);
  final String name;
}

class EreignisWiederherstellen extends EreignisWahl {
  const EreignisWiederherstellen(this.id);
  final int id;
}

/// Suche über die aktiven Ereignisse mit „+ „xyz“ als neues Ereignis anlegen“
/// und, bei einem archivierten Treffer, „wiederherstellen und einfügen“.
Future<EreignisWahl?> ereignisSucheSheet(
  BuildContext context,
  Datenbestand daten, {
  required String titel,
  bool neuAnbieten = true,
  bool wiederherstellenAnbieten = false,
}) {
  return showModalBottomSheet<EreignisWahl>(
    context: context,
    isScrollControlled: true,
    builder: (c) => _EreignisSuche(
      daten: daten,
      titel: titel,
      neuAnbieten: neuAnbieten,
      wiederherstellenAnbieten: wiederherstellenAnbieten,
    ),
  );
}

class _EreignisSuche extends StatefulWidget {
  const _EreignisSuche({
    required this.daten,
    required this.titel,
    required this.neuAnbieten,
    required this.wiederherstellenAnbieten,
  });
  final Datenbestand daten;
  final String titel;
  final bool neuAnbieten;
  final bool wiederherstellenAnbieten;

  @override
  State<_EreignisSuche> createState() => _EreignisSucheState();
}

class _EreignisSucheState extends State<_EreignisSuche> {
  String _eingabe = '';

  @override
  Widget build(BuildContext context) {
    final f = context.farben;
    final suche = ereignisSuche(widget.daten, _eingabe);
    final name = _eingabe.trim();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SheetTitel(widget.titel),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  autofocus: true,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Ereignis suchen'),
                  onChanged: (v) => setState(() => _eingabe = v),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: [
                    if (widget.wiederherstellenAnbieten && suche.archiviertExakt != null)
                      ListTile(
                        leading: Icon(Icons.unarchive_outlined, color: f.go),
                        title: Text('„${widget.daten.ereignisName(suche.archiviertExakt!)}“ wiederherstellen und einfügen'),
                        onTap: () => Navigator.pop(context, EreignisWiederherstellen(suche.archiviertExakt!)),
                      ),
                    if (widget.neuAnbieten && suche.neuMoeglich)
                      ListTile(
                        leading: Icon(Icons.add, color: f.go),
                        title: Text('+ „$name“ als neues Ereignis anlegen',
                            style: TextStyle(color: f.go, fontWeight: FontWeight.w700)),
                        onTap: () => Navigator.pop(context, EreignisNeu(name)),
                      ),
                    for (final id in suche.treffer)
                      ListTile(
                        title: Text(widget.daten.ereignisName(id)),
                        onTap: () => Navigator.pop(context, EreignisBestehend(id)),
                      ),
                    if (suche.treffer.isEmpty && !suche.neuMoeglich && suche.archiviertExakt == null)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text('Keine Ereignisse gefunden.', style: TextStyle(color: f.muted)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Leerer Zustand mit Hinweistext.
class LeerHinweis extends StatelessWidget {
  const LeerHinweis(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: context.farben.muted)),
        ),
      );
}
