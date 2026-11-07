// Gehört zu BEIDEN Targets: Runner und StoppWidgetExtension.
import ActivityKit
import Foundation

/// App Group, über die App, Widget und Live Activity den Schnappschuss und
/// die Warteschlange teilen (ADR 0002).
let stoppAppGroup = "group.com.hajspg.stoppapp"

/// Live Activity während einer Messung (Spec Abschnitt 11, Variante A).
struct StoppAktivitaetAttribute: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var ereignis: String
    var start: Date
    /// `nil` = eingeschobenes Ereignis.
    var schrittPosition: Int?
    var kette: String?
  }

  /// Wann die Live Activity gestartet wurde; nach knapp 8 h startet die App sie neu.
  var gestartetAm: Date
}
