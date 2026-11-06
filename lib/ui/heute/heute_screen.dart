import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/domain.dart';
import '../../state/providers.dart';
import '../einstellungen_screen.dart';
import '../gemeinsam.dart';
import '../theme.dart';
import 'heute_aktionen.dart';

class HeuteScreen extends ConsumerWidget {
  const HeuteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = ref.watch(heuteProvider);
    final ansicht = ref.watch(heuteAnsichtProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
        child: Column(
          children: [
            _Kopf(z: z, ansicht: ansicht),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ansicht == HeuteAnsicht.fokus ? _Fokus(z: z) : _Zeitleiste(z: z),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Kopf extends ConsumerWidget {
  const _Kopf({required this.z, required this.ansicht});
  final HeuteZustand z;
  final HeuteAnsicht ansicht;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daten = ref.watch(datenProvider);
    final lauf = z.tageslauf;
    final farbe = lauf?.ketteId == null ? null : daten.ketten[lauf!.ketteId]?.farbe;
    final f = context.farben;
    return Row(
      children: [
        Expanded(
          child: Text(datumLang(z.tag),
              maxLines: 1, overflow: TextOverflow.ellipsis, style: ueberschrift(20, farbe: f.ink)),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: KettenChip(
            name: z.ketteName,
            farbe: farbe,
            warnung: z.modus == HeuteModus.keineKette,
            onTap: () => ketteFuerHeuteWaehlen(context, ref),
          ),
        ),
        IconButton(
          tooltip: ansicht == HeuteAnsicht.fokus ? 'Zeitleiste' : 'Fokus',
          icon: Icon(ansicht == HeuteAnsicht.fokus ? Icons.view_timeline_outlined : Icons.radio_button_checked),
          onPressed: () => ref.read(heuteAnsichtProvider.notifier).umschalten(),
        ),
        IconButton(
          tooltip: 'Einstellungen',
          icon: const Icon(Icons.settings_outlined),
          onPressed: () =>
              Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const EinstellungenScreen())),
        ),
      ],
    );
  }
}

/// Live-Zeit einer laufenden Messung.
class LiveZeit extends ConsumerWidget {
  const LiveZeit(this.messung, {super.key, this.stil});
  final Messung messung;
  final TextStyle? stil;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(sekundenProvider);
    final jetzt = ref.read(dienstProvider).jetzt;
    return Text(formatLaufzeit(messung.dauer(jetzt)), style: stil);
  }
}

// ---------------------------------------------------------------- Fokus

class _Fokus extends ConsumerWidget {
  const _Fokus({required this.z});
  final HeuteZustand z;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daten = ref.watch(datenProvider);
    final f = context.farben;
    final laufend = z.laufend;
    final String eyebrow;
    final String name;
    switch (z.modus) {
      case HeuteModus.bereit:
        eyebrow = 'Als Nächstes';
        name = daten.ereignisName(z.naechstesEreignisId!);
      case HeuteModus.laeuft:
        eyebrow = 'Läuft';
        name = daten.ereignisName(laufend!.ereignisId);
      case HeuteModus.keineKette:
        eyebrow = '';
        name = 'Heute ist keine Kette geplant';
      case HeuteModus.erledigt:
        eyebrow = '';
        name = 'Fertig für heute';
    }
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragEnd: (d) {
        if ((d.primaryVelocity ?? 0) < -300) {
          ref.read(heuteAnsichtProvider.notifier).setzen(HeuteAnsicht.zeitleiste);
        }
      },
      child: LayoutBuilder(
        builder: (context, c) => SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: c.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (eyebrow.isNotEmpty)
                  Text(eyebrow.toUpperCase(),
                      style: TextStyle(
                          letterSpacing: 1.6, fontSize: 12, fontWeight: FontWeight.w700, color: f.muted)),
                const SizedBox(height: 8),
                Text(name,
                    textAlign: TextAlign.center,
                    style: ueberschrift(z.modus == HeuteModus.keineKette ? 28 : 36, gewicht: FontWeight.w800)),
                const SizedBox(height: 28),
                _GrosserKnopf(z: z, groesse: (c.maxWidth * 0.7).clamp(160, 280).toDouble()),
                const SizedBox(height: 28),
                if (z.schritte.isNotEmpty) ...[
                  _Punkte(z: z),
                  const SizedBox(height: 8),
                  Text(_fortschritt(z, daten), textAlign: TextAlign.center, style: TextStyle(color: f.muted)),
                  const SizedBox(height: 12),
                ],
                _Aktionen(z: z),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _fortschritt(HeuteZustand z, Datenbestand d) {
  final teile = ['${z.erledigt} von ${z.anzahlSchritte} erledigt'];
  final danach = z.danachEreignisId;
  if (danach != null) teile.add('Danach: ${d.ereignisName(danach)}');
  return teile.join(' · ');
}

class _GrosserKnopf extends ConsumerWidget {
  const _GrosserKnopf({required this.z, required this.groesse});
  final HeuteZustand z;
  final double groesse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = context.farben;
    final Color hintergrund;
    final Color vordergrund;
    Color? ring;
    final Widget inhalt;
    switch (z.modus) {
      case HeuteModus.bereit:
        hintergrund = f.go;
        vordergrund = f.onSolid;
        ring = f.goSoft;
        inhalt = Text('Start', style: ueberschrift(34, gewicht: FontWeight.w800, farbe: vordergrund));
      case HeuteModus.laeuft:
        hintergrund = f.stop;
        vordergrund = f.onSolid;
        ring = f.stopSoft;
        inhalt = Column(mainAxisSize: MainAxisSize.min, children: [
          LiveZeit(z.laufend!, stil: zahl(30, gewicht: FontWeight.w600, farbe: vordergrund)),
          const SizedBox(height: 4),
          Text('seit ${formatUhrzeit(z.laufend!.start)}', style: TextStyle(fontSize: 13, color: vordergrund)),
          const SizedBox(height: 6),
          Text('Stopp', style: ueberschrift(22, gewicht: FontWeight.w800, farbe: vordergrund)),
        ]);
      case HeuteModus.keineKette:
        hintergrund = f.surface;
        vordergrund = f.ink;
        inhalt = Text('Kette\nwählen',
            textAlign: TextAlign.center, style: ueberschrift(26, gewicht: FontWeight.w800, farbe: vordergrund));
      case HeuteModus.erledigt:
        hintergrund = f.surface;
        vordergrund = f.ink;
        inhalt = Text('+ Extra-\nEreignis',
            textAlign: TextAlign.center, style: ueberschrift(24, gewicht: FontWeight.w800, farbe: vordergrund));
    }
    return Semantics(
      button: true,
      child: Container(
        width: groesse,
        height: groesse,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [if (ring != null) BoxShadow(color: ring, spreadRadius: 12)],
          border: ring == null ? Border.all(color: f.line, width: 2) : null,
        ),
        child: Material(
          color: hintergrund,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => grosserKnopf(context, ref, z),
            child: Center(child: inhalt),
          ),
        ),
      ),
    );
  }
}

class _Punkte extends StatelessWidget {
  const _Punkte({required this.z});
  final HeuteZustand z;
  @override
  Widget build(BuildContext context) {
    final f = context.farben;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: [
        for (final s in z.schritte)
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: switch (s.status) {
                SchrittStatus.erledigt => f.go,
                SchrittStatus.laeuft => f.stop,
                SchrittStatus.uebersprungen => f.skip.withValues(alpha: 0.5),
                SchrittStatus.offen => Colors.transparent,
              },
              border: Border.all(
                width: 2,
                color: switch (s.status) {
                  SchrittStatus.erledigt => f.go,
                  SchrittStatus.laeuft => f.stop,
                  SchrittStatus.uebersprungen => f.skip.withValues(alpha: 0.5),
                  SchrittStatus.offen => s.position == z.naechster ? f.go : f.line,
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _Aktionen extends ConsumerWidget {
  const _Aktionen({required this.z});
  final HeuteZustand z;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (z.modus == HeuteModus.laeuft) {
      return TextButton(onPressed: () => zeitKorrigieren(context, ref), child: const Text('Zeit korrigieren'));
    }
    final hatNaechsten = z.naechster != null;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      children: [
        TextButton(
            onPressed: hatNaechsten ? () => ueberspringen(context, ref) : null, child: const Text('Überspringen')),
        TextButton(onPressed: () => einschieben(context, ref), child: const Text('Einschieben')),
        TextButton(
          onPressed: z.waehlbareSchritte.isNotEmpty ? () => naechstesWaehlen(context, ref, z) : null,
          child: const Text('Nächstes wählen'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- Zeitleiste

class _Zeitleiste extends ConsumerWidget {
  const _Zeitleiste({required this.z});
  final HeuteZustand z;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daten = ref.watch(datenProvider);
    final f = context.farben;
    final zeilen = <Widget>[];
    final jetzt = ref.read(dienstProvider).jetzt;
    final laufend = z.laufend;
    for (final m in z.messungen) {
      if (m.laeuft) continue;
      zeilen.add(_Zeile(
        markierung: _Markierung.erledigt,
        name: daten.ereignisName(m.ereignisId),
        zusatz: m.schrittPosition == null ? 'eingeschoben' : null,
        meta: '${formatUhrzeit(m.start)} · ${formatDauer(m.dauer(jetzt))}',
      ));
    }
    if (laufend != null) {
      zeilen.add(_Zeile(
        markierung: _Markierung.laeuft,
        name: daten.ereignisName(laufend.ereignisId),
        zusatz: laufend.schrittPosition == null ? 'eingeschoben' : null,
        metaWidget: LiveZeit(laufend, stil: zahl(15, gewicht: FontWeight.w600, farbe: f.stop)),
      ));
    }
    for (final s in z.schritte) {
      if (!s.waehlbar) continue;
      final istNaechster = s.position == z.naechster;
      zeilen.add(_Zeile(
        markierung: s.status == SchrittStatus.uebersprungen
            ? _Markierung.uebersprungen
            : (istNaechster ? _Markierung.naechster : _Markierung.offen),
        name: daten.ereignisName(s.ereignisId),
        etikett: istNaechster ? 'Nächstes' : null,
        onTap: istNaechster
            ? null
            : () => aktion(context, ref.read(dienstProvider), () => ref.read(dienstProvider).naechstesWaehlen(s.position),
                rueckgaengig: false),
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Zeitleiste', style: ueberschrift(26, gewicht: FontWeight.w800)),
        const SizedBox(height: 8),
        Expanded(
          child: zeilen.isEmpty
              ? LeerHinweis(z.modus == HeuteModus.keineKette
                  ? 'Heute ist keine Kette geplant. Wähle eine Kette oder schiebe ein Ereignis ein.'
                  : 'Noch nichts gemessen.')
              : ListView(children: zeilen),
        ),
        const SizedBox(height: 8),
        _Dock(z: z),
      ],
    );
  }
}

enum _Markierung { erledigt, laeuft, uebersprungen, naechster, offen }

class _Zeile extends StatelessWidget {
  const _Zeile({
    required this.markierung,
    required this.name,
    this.zusatz,
    this.meta,
    this.metaWidget,
    this.etikett,
    this.onTap,
  });
  final _Markierung markierung;
  final String name;
  final String? zusatz;
  final String? meta;
  final Widget? metaWidget;
  final String? etikett;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final f = context.farben;
    final hintergrund = switch (markierung) {
      _Markierung.laeuft => f.stopSoft,
      _Markierung.naechster => f.goSoft,
      _ => Colors.transparent,
    };
    final punktFarbe = switch (markierung) {
      _Markierung.erledigt => f.go,
      _Markierung.laeuft => f.stop,
      _ => f.paper,
    };
    final randFarbe = switch (markierung) {
      _Markierung.erledigt => f.go,
      _Markierung.laeuft => f.stop,
      _Markierung.naechster => f.go,
      _ => f.line,
    };
    final nameStil = switch (markierung) {
      _Markierung.erledigt => TextStyle(color: f.muted),
      _Markierung.uebersprungen => TextStyle(color: f.skip, decoration: TextDecoration.lineThrough),
      _ => const TextStyle(fontWeight: FontWeight.w700),
    };
    return Material(
      color: hintergrund,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: punktFarbe,
                shape: BoxShape.circle,
                border: Border.all(color: randFarbe, width: 2),
              ),
              child: markierung == _Markierung.erledigt ? Icon(Icons.check, size: 12, color: f.onSolid) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text.rich(TextSpan(children: [
                TextSpan(text: name, style: nameStil),
                if (zusatz != null)
                  TextSpan(text: ' · $zusatz', style: TextStyle(color: f.muted, fontSize: 13)),
              ])),
            ),
            if (etikett != null)
              Text(etikett!.toUpperCase(),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: f.go, letterSpacing: 1)),
            if (meta != null) Text(meta!, style: zahl(13, farbe: f.muted)),
            ?metaWidget,
          ]),
        ),
      ),
    );
  }
}

class _Dock extends ConsumerWidget {
  const _Dock({required this.z});
  final HeuteZustand z;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = context.farben;
    final daten = ref.watch(datenProvider);
    final (knopfText, knopfFarbe, titel) = switch (z.modus) {
      HeuteModus.bereit => ('Start', f.go, '${daten.ereignisName(z.naechstesEreignisId!)} starten'),
      HeuteModus.laeuft => ('Stopp', f.stop, '${daten.ereignisName(z.laufend!.ereignisId)} stoppen'),
      HeuteModus.keineKette => ('Wählen', f.muted, 'Kette für heute wählen'),
      HeuteModus.erledigt => ('+', f.muted, 'Extra-Ereignis'),
    };
    final untertitel = z.schritte.isEmpty ? null : _fortschritt(z, daten);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: f.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: f.line),
      ),
      child: Row(children: [
        SizedBox(
          width: 84,
          height: 84,
          child: Material(
            color: knopfFarbe,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => grosserKnopf(context, ref, z),
              child: Center(
                child: Text(knopfText, style: ueberschrift(17, gewicht: FontWeight.w800, farbe: f.onSolid)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titel, style: ueberschrift(20)),
            if (untertitel != null) Text(untertitel, style: TextStyle(color: f.muted, fontSize: 13)),
          ]),
        ),
        Column(mainAxisSize: MainAxisSize.min, children: [
          if (z.modus == HeuteModus.laeuft)
            _KleinKnopf('Korrigieren', () => zeitKorrigieren(context, ref))
          else ...[
            if (z.naechster != null) _KleinKnopf('Überspringen', () => ueberspringen(context, ref)),
            _KleinKnopf('Einschieben', () => einschieben(context, ref)),
          ],
        ]),
      ]),
    );
  }
}

class _KleinKnopf extends StatelessWidget {
  const _KleinKnopf(this.text, this.onTap);
  final String text;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final f = context.farben;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: f.muted,
          side: BorderSide(color: f.line),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          minimumSize: const Size(0, 34),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        onPressed: onTap,
        child: Text(text),
      ),
    );
  }
}
