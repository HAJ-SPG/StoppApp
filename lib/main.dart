import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'data/datenbank.dart';
import 'data/drift_speicher.dart';
import 'domain/domain.dart';
import 'state/providers.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  Intl.defaultLocale = 'de_AT';
  await initializeDateFormatting('de_AT');

  final db = StoppDatenbank(driftDatabase(name: 'stoppapp'));
  final speicher = DriftSpeicher(db);
  final dienst = StoppDienst(daten: await speicher.laden(), uhr: const SystemUhr(), speicher: speicher);
  dienst.tagesSicherstellen();

  runApp(ProviderScope(
    overrides: [dienstProvider.overrideWithValue(dienst)],
    child: const StoppApp(),
  ));
}
