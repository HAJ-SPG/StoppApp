import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:stoppapp/domain/domain.dart';
import 'package:stoppapp/state/providers.dart';
import 'package:stoppapp/ui/app.dart';

import 'domain/hilfen.dart';

void main() {
  setUpAll(() async {
    Intl.defaultLocale = 'de_AT';
    await initializeDateFormatting('de_AT');
  });

  Future<StoppDienst> starteApp(WidgetTester tester, {Datenbestand? daten}) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final (dienst, _, _) = dienstMitUhr(daten: daten);
    await tester.pumpWidget(ProviderScope(
      overrides: [dienstProvider.overrideWithValue(dienst)],
      child: const StoppApp(),
    ));
    await tester.pump();
    return dienst;
  }

  testWidgets('Heute: Fokus zeigt das nächste Ereignis, Start und Stopp', (tester) async {
    final dienst = await starteApp(tester);
    expect(find.text('ALS NÄCHSTES'), findsOneWidget);
    expect(find.text('Aufstehen'), findsOneWidget);
    expect(find.text('0 von 3 erledigt · Danach: Zähneputzen'), findsOneWidget);
    await tester.tap(find.text('Start'));
    await tester.pump();
    expect(find.text('LÄUFT'), findsOneWidget);
    expect(find.text('Zeit korrigieren'), findsOneWidget);
    expect(dienst.daten.laufendeMessung, isNotNull);
    await tester.tap(find.text('Stopp'));
    await tester.pump();
    expect(find.text('Zähneputzen'), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('Heute: ohne Kette und Zeitleiste', (tester) async {
    await starteApp(tester, daten: beispielDaten().kopie(wochenregel: {}));
    expect(find.text('Heute ist keine Kette geplant'), findsOneWidget);
    await tester.tap(find.byTooltip('Zeitleiste'));
    await tester.pump();
    expect(find.text('Kette für heute wählen'), findsOneWidget);
  });

  testWidgets('alle Tabs lassen sich öffnen', (tester) async {
    await starteApp(tester);
    await tester.tap(find.text('Kalender'));
    await tester.pumpAndSettle();
    expect(find.text('Wochenregel'), findsWidgets);
    expect(find.text('Messung nachtragen'), findsOneWidget);
    await tester.tap(find.text('Statistik').last);
    await tester.pumpAndSettle();
    expect(find.text('Keine Messungen im gewählten Zeitraum.'), findsOneWidget);
    await tester.tap(find.text('Ketten').last);
    await tester.pumpAndSettle();
    expect(find.text('Arbeitstag'), findsOneWidget);
    await tester.tap(find.text('Arbeitstag'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Heute läuft diese Kette'), findsOneWidget);
  });

  testWidgets('Einstellungen über das Zahnrad', (tester) async {
    await starteApp(tester);
    await tester.tap(find.byTooltip('Einstellungen'));
    await tester.pumpAndSettle();
    expect(find.text('Tageswechsel'), findsOneWidget);
    expect(find.text('04:00'), findsOneWidget);
  });
}
