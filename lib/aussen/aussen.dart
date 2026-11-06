import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';

import '../data/datenbank.dart';
import '../data/drift_speicher.dart';
import '../domain/domain.dart';

/// Brücke zu Homescreen-Widget, iOS-Live-Activity und Android-Notification
/// (Spec Abschnitt 11, ADR 0002).
///
/// - Die App schreibt nach jeder Änderung den Widget-Schnappschuss und stößt
///   die nativen Anzeigen an.
/// - Ein Tipp außerhalb der App landet nativ mit Zeitstempel in der
///   Warteschlange und weckt die App im Hintergrund ([aussenHintergrund]).
///   Läuft die App, arbeitet sie die Warteschlange selbst ab, sonst tut es
///   der Hintergrund mit eigener Datenbankverbindung.
class Aussen {
  Aussen._();

  static const appGroup = 'group.com.hajspg.stoppapp';
  static const schnappschussSchluessel = 'schnappschuss';
  static const warteschlangeSchluessel = 'warteschlange';
  static const androidWidget = 'com.hajspg.stoppapp.StoppWidget';
  static const iosWidget = 'StoppWidget';
  static const portName = 'stoppapp.haupt';
  static const _kanal = MethodChannel('stoppapp/aussen');

  static bool get _plattform => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static Future<void> vorbereiten() async {
    if (Platform.isIOS) await HomeWidget.setAppGroupId(appGroup);
  }

  /// Einmal beim App-Start: Hintergrund-Rückruf registrieren, Port für den
  /// Hintergrund öffnen, Anzeigen bei jeder Änderung aktualisieren.
  static Future<void> starten(StoppDienst dienst) async {
    if (!_plattform) return;
    try {
      await vorbereiten();
      await HomeWidget.registerInteractivityCallback(aussenHintergrund);
    } catch (e) {
      debugPrint('Aussen: $e');
    }

    final port = ReceivePort();
    IsolateNameServer.removePortNameMapping(portName);
    IsolateNameServer.registerPortWithName(port.sendPort, portName);
    port.listen((nachricht) async {
      await abarbeiten(dienst);
      if (nachricht is SendPort) nachricht.send(true);
    });

    var geplant = false;
    dienst.beobachten(() {
      if (geplant) return;
      geplant = true;
      scheduleMicrotask(() {
        geplant = false;
        anzeigen(dienst);
      });
    });

    await abarbeiten(dienst);
    await anzeigen(dienst, erzwingen: true);
  }

  /// Beim Zurückkehren in die App: Warteschlange als Rückfall abarbeiten und
  /// die Anzeigen neu setzen (z. B. eine weggewischte Notification).
  static Future<void> fortsetzen(StoppDienst dienst) async {
    if (!_plattform) return;
    await abarbeiten(dienst);
    await anzeigen(dienst, erzwingen: true);
  }

  static String? _zuletzt;

  /// Schreibt den Schnappschuss und aktualisiert Widget, Live Activity und
  /// Notification. Ohne [erzwingen] nur, wenn sich der Schnappschuss geändert hat.
  static Future<void> anzeigen(StoppDienst dienst, {bool erzwingen = false}) async {
    if (!_plattform) return;
    final json = widgetSchnappschussJson(dienst.daten, dienst.jetzt);
    if (!erzwingen && json == _zuletzt) return;
    _zuletzt = json;
    try {
      await HomeWidget.saveWidgetData<String>(schnappschussSchluessel, json);
      await HomeWidget.updateWidget(qualifiedAndroidName: androidWidget, iOSName: iosWidget);
      if (Platform.isIOS) await _kanal.invokeMethod<void>('liveActivity', json);
    } catch (e) {
      debugPrint('Aussen.anzeigen: $e');
    }
  }

  /// Wendet alle wartenden Tipps der Reihe nach an und entfernt sie aus der
  /// Warteschlange. Gibt die Zahl der angewendeten zurück.
  static Future<int> abarbeiten(StoppDienst dienst) async {
    if (!_plattform) return 0;
    try {
      final aktionen = warteschlangeLesen(await HomeWidget.getWidgetData<String>(warteschlangeSchluessel));
      if (aktionen.isEmpty) return 0;
      final n = dienst.fernAbarbeiten(aktionen);
      // Nur die gelesenen Einträge entfernen; inzwischen neu getippte bleiben.
      final erledigt = aktionen.map((a) => a.id).toSet();
      final rest = warteschlangeLesen(await HomeWidget.getWidgetData<String>(warteschlangeSchluessel))
          .where((a) => !erledigt.contains(a.id))
          .toList();
      await HomeWidget.saveWidgetData<String>(warteschlangeSchluessel, rest.isEmpty ? null : warteschlangeJson(rest));
      await dienst.gespeichert;
      return n;
    } catch (e) {
      debugPrint('Aussen.abarbeiten: $e');
      return 0;
    }
  }
}

/// Wird von `home_widget` im Hintergrund aufgerufen, nachdem ein Tipp in die
/// Warteschlange geschrieben wurde.
@pragma('vm:entry-point')
Future<void> aussenHintergrund(Uri? uri) async {
  WidgetsFlutterBinding.ensureInitialized();
  final haupt = IsolateNameServer.lookupPortByName(Aussen.portName);
  if (haupt != null) {
    final antwort = ReceivePort();
    haupt.send(antwort.sendPort);
    try {
      await antwort.first.timeout(const Duration(seconds: 10));
      return;
    } on TimeoutException {
      // Die App reagiert nicht: selbst abarbeiten.
    } finally {
      antwort.close();
    }
  }

  await Aussen.vorbereiten();
  final db = StoppDatenbank(driftDatabase(name: 'stoppapp'));
  try {
    final speicher = DriftSpeicher(db);
    final dienst = StoppDienst(daten: await speicher.laden(), uhr: const SystemUhr(), speicher: speicher);
    await Aussen.abarbeiten(dienst);
    await dienst.gespeichert;
    await Aussen.anzeigen(dienst, erzwingen: true);
  } finally {
    await db.close();
  }
}

/// Ziel, wenn ein Tipp im Widget die App öffnet (`stoppapp://kette-waehlen`
/// bzw. `stoppapp://einschieben`).
enum AussenZiel { ketteWaehlen, einschieben }

AussenZiel? aussenZiel(Uri? uri) => switch (uri?.host) {
      'kette-waehlen' => AussenZiel.ketteWaehlen,
      'einschieben' => AussenZiel.einschieben,
      _ => null,
    };
