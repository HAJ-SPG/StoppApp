import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../state/providers.dart';
import 'gemeinsam.dart';
import 'theme.dart';

final _versionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
});

String uhrzeitAusMinutenNachMitternacht(int m) =>
    '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';

class EinstellungenScreen extends ConsumerWidget {
  const EinstellungenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daten = ref.watch(datenProvider);
    final version = ref.watch(_versionProvider);
    final f = context.farben;
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(children: [
              ListTile(
                title: const Text('Tageswechsel', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Ein Tag läuft vom Tageswechsel bis zum nächsten. '
                    'Eine Änderung gilt ab sofort für neue Messungen; bestehende behalten ihren Tag.'),
                trailing: DropdownButton<int>(
                  value: daten.tageswechsel,
                  underline: const SizedBox(),
                  style: zahl(16, farbe: f.ink),
                  items: [
                    for (var m = 0; m <= 360; m += 15)
                      DropdownMenuItem(value: m, child: Text(uhrzeitAusMinutenNachMitternacht(m))),
                  ],
                  onChanged: (m) {
                    if (m == null) return;
                    final dienst = ref.read(dienstProvider);
                    aktion(context, dienst, () => dienst.tageswechselSetzen(m),
                        meldung: 'Tageswechsel ${uhrzeitAusMinutenNachMitternacht(m)}');
                  },
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: const Text('Info', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('StoppApp · Version ${version.value ?? '…'}'),
            ),
          ),
        ],
      ),
    );
  }
}
