import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../aussen/aussen.dart';
import '../state/providers.dart';
import 'heute/heute_aktionen.dart';
import 'heute/heute_screen.dart';
import 'kalender/kalender_screen.dart';
import 'ketten/ketten_screen.dart';
import 'statistik/statistik_screen.dart';
import 'theme.dart';

class StoppApp extends StatelessWidget {
  const StoppApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'StoppApp',
        debugShowCheckedModeBanner: false,
        theme: stoppTheme(Brightness.light),
        darkTheme: stoppTheme(Brightness.dark),
        themeMode: ThemeMode.system,
        locale: const Locale('de', 'AT'),
        supportedLocales: const [Locale('de', 'AT'), Locale('de')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const Hauptnavigation(),
      );
}

/// Tab-Leiste: Heute, Kalender, Statistik, Ketten.
class Hauptnavigation extends ConsumerStatefulWidget {
  const Hauptnavigation({super.key});
  @override
  ConsumerState<Hauptnavigation> createState() => _HauptnavigationState();
}

class _HauptnavigationState extends ConsumerState<Hauptnavigation> with WidgetsBindingObserver {
  int _tab = 0;
  StreamSubscription<Uri?>? _widgetTipp;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(dienstProvider).tagesSicherstellen();
      try {
        _zielOeffnen(await HomeWidget.initiallyLaunchedFromHomeWidget());
        _widgetTipp = HomeWidget.widgetClicked.listen(_zielOeffnen);
      } catch (_) {
        // Keine Widget-Unterstützung (z. B. in Tests).
      }
    });
  }

  @override
  void dispose() {
    _widgetTipp?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Ein Tipp im Widget öffnet die App an der passenden Stelle.
  void _zielOeffnen(Uri? uri) {
    final ziel = aussenZiel(uri);
    if (ziel == null || !mounted) return;
    setState(() => _tab = 0);
    switch (ziel) {
      case AussenZiel.ketteWaehlen:
        ketteFuerHeuteWaehlen(context, ref);
      case AussenZiel.einschieben:
        einschieben(context, ref);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final dienst = ref.read(dienstProvider);
      dienst.tagesSicherstellen();
      ref.invalidate(heuteProvider);
      Aussen.fortsetzen(dienst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: const [HeuteScreen(), KalenderScreen(), StatistikScreen(), KettenScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.radio_button_checked), label: 'Heute'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), label: 'Kalender'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), label: 'Statistik'),
          NavigationDestination(icon: Icon(Icons.link), label: 'Ketten'),
        ],
      ),
    );
  }
}
