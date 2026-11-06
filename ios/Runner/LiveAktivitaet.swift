// Gehört nur zum Target Runner.
import ActivityKit
import Flutter
import Foundation

/// Startet, aktualisiert und beendet die Live Activity nach dem
/// Widget-Schnappschuss, den die Dart-Seite über `stoppapp/aussen` schickt.
enum LiveAktivitaet {
  static let kanalName = "stoppapp/aussen"

  /// Kurz vor dem 8-h-Limit von iOS neu starten (Spec Abschnitt 11, ADR 0001).
  static let hoechstdauer: TimeInterval = 8 * 3600 - 10 * 60

  static func registrieren(_ messenger: FlutterBinaryMessenger) {
    let kanal = FlutterMethodChannel(name: kanalName, binaryMessenger: messenger)
    kanal.setMethodCallHandler { call, result in
      guard call.method == "liveActivity", let json = call.arguments as? String else {
        result(FlutterMethodNotImplemented)
        return
      }
      Task {
        await aktualisieren(json)
        result(nil)
      }
    }
  }

  static func aktualisieren(_ json: String) async {
    guard let daten = json.data(using: .utf8),
      let s = try? JSONSerialization.jsonObject(with: daten) as? [String: Any]
    else { return }

    guard s["zustand"] as? String == "laeuft",
      let laufend = s["laufend"] as? [String: Any],
      let startMs = laufend["start"] as? NSNumber
    else {
      await alleBeenden()
      return
    }

    let zustand = StoppAktivitaetAttribute.ContentState(
      ereignis: laufend["ereignis"] as? String ?? "",
      start: Date(timeIntervalSince1970: startMs.doubleValue / 1000),
      schrittPosition: (laufend["schritt_position"] as? NSNumber)?.intValue,
      kette: s["kette"] as? String
    )
    let inhalt = ActivityContent(state: zustand, staleDate: nil)
    let vorhandene = Activity<StoppAktivitaetAttribute>.activities

    if let aktiv = vorhandene.first(where: { $0.activityState == .active }),
      Date().timeIntervalSince(aktiv.attributes.gestartetAm) < hoechstdauer
    {
      for andere in vorhandene where andere.id != aktiv.id {
        await andere.end(nil, dismissalPolicy: .immediate)
      }
      if aktiv.content.state != zustand {
        await aktiv.update(inhalt)
      }
      return
    }

    for alt in vorhandene {
      await alt.end(nil, dismissalPolicy: .immediate)
    }
    guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
    do {
      _ = try Activity.request(
        attributes: StoppAktivitaetAttribute(gestartetAm: Date()), content: inhalt, pushType: nil)
    } catch {
      NSLog("StoppApp: Live Activity nicht gestartet: \(error)")
    }
  }

  static func alleBeenden() async {
    for a in Activity<StoppAktivitaetAttribute>.activities {
      await a.end(nil, dismissalPolicy: .immediate)
    }
  }
}
