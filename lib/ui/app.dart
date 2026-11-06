import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(dienstProvider).tagesSicherstellen());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(dienstProvider).tagesSicherstellen();
      ref.invalidate(heuteProvider);
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
