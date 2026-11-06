// Gehört zu BEIDEN Targets: Runner und StoppWidgetExtension.
import AppIntents
import Foundation

#if canImport(home_widget)
  import home_widget
#endif

/// Tipp auf Start oder Stopp in Widget oder Live Activity.
///
/// Als `LiveActivityIntent` läuft `perform()` im Prozess der App (die dafür im
/// Hintergrund gestartet wird), nicht im Widget. Der Tipp landet mit dem
/// Moment des Tippens in der Warteschlange; danach wird die Dart-Seite
/// geweckt, die ihn anwendet und einen neuen Schnappschuss schreibt.
@available(iOS 17.0, *)
struct StoppAktion: LiveActivityIntent {
  static let title: LocalizedStringResource = "Start oder Stopp"
  static let isDiscoverable = false

  @Parameter(title: "Aktion")
  var aktion: String

  /// -1 = kein Schritt (eingeschobenes Ereignis).
  @Parameter(title: "Schritt")
  var schrittPosition: Int

  @Parameter(title: "Quelle")
  var quelle: String

  init() {}

  init(aktion: String, schrittPosition: Int?, quelle: String) {
    self.aktion = aktion
    self.schrittPosition = schrittPosition ?? -1
    self.quelle = quelle
  }

  func perform() async throws -> some IntentResult {
    Warteschlange.anhaengen(
      aktion: aktion, schrittPosition: schrittPosition >= 0 ? schrittPosition : nil, quelle: quelle)
    #if canImport(home_widget)
      await Wecker.wecken()
    #endif
    return .result()
  }
}

/// Die Warteschlange liegt als JSON-Text unter `warteschlange` in der App Group
/// (gleiches Format wie auf Android, siehe Spec Abschnitt 11).
enum Warteschlange {
  static let schluessel = "warteschlange"
  private static let sperre = NSLock()

  static func anhaengen(aktion: String, schrittPosition: Int?, quelle: String) {
    sperre.lock()
    defer { sperre.unlock() }
    let defaults = UserDefaults(suiteName: stoppAppGroup)
    var liste: [[String: Any]] = []
    if let roh = defaults?.string(forKey: schluessel), let daten = roh.data(using: .utf8),
      let alt = try? JSONSerialization.jsonObject(with: daten) as? [[String: Any]]
    {
      liste = alt
    }
    liste.append([
      "id": UUID().uuidString,
      "aktion": aktion,
      "zeitpunkt": Int64(Date().timeIntervalSince1970 * 1000),
      "quelle": quelle,
      "schritt_position": schrittPosition.map { $0 as Any } ?? NSNull(),
    ])
    if let daten = try? JSONSerialization.data(withJSONObject: liste),
      let text = String(data: daten, encoding: .utf8)
    {
      defaults?.set(text, forKey: schluessel)
    }
  }
}

#if canImport(home_widget)
  /// Weckt die Dart-Seite über `home_widget`. Wartet höchstens 8 s; klappt es
  /// nicht, bleibt der Tipp in der Warteschlange, bis die App geöffnet wird.
  @available(iOS 17.0, *)
  enum Wecker {
    static func wecken() async {
      let url = URL(string: "stoppapp://warteschlange")
      await withCheckedContinuation { (fortsetzung: CheckedContinuation<Void, Never>) in
        let einmal = Einmal(fortsetzung)
        Task {
          await HomeWidgetBackgroundWorker.run(url: url, appGroup: stoppAppGroup)
          einmal.fertig()
        }
        Task {
          try? await Task.sleep(nanoseconds: 8_000_000_000)
          einmal.fertig()
        }
      }
    }
  }

  final class Einmal: @unchecked Sendable {
    private let sperre = NSLock()
    private var fortsetzung: CheckedContinuation<Void, Never>?

    init(_ fortsetzung: CheckedContinuation<Void, Never>) {
      self.fortsetzung = fortsetzung
    }

    func fertig() {
      sperre.lock()
      let f = fortsetzung
      fortsetzung = nil
      sperre.unlock()
      f?.resume()
    }
  }
#endif
