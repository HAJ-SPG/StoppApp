// Gehört nur zum Target StoppWidgetExtension.
import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit

// MARK: - Farben wie in der App (hell / dunkel)

private func farbe(_ hell: UInt32, _ dunkel: UInt32) -> Color {
  func ui(_ hex: UInt32) -> UIColor {
    UIColor(
      red: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255,
      blue: CGFloat(hex & 0xFF) / 255, alpha: 1)
  }
  return Color(UIColor { $0.userInterfaceStyle == .dark ? ui(dunkel) : ui(hell) })
}

private let gruen = farbe(0x1E7A57, 0x3FBF8A)
private let rot = farbe(0xC8442C, 0xF06A50)
private let leise = farbe(0x5E6D66, 0x93A39B)

// MARK: - Schnappschuss

/// Der Widget-Schnappschuss, den die App in die App Group schreibt (Spec Abschnitt 11).
struct Schnappschuss {
  var zustand: String
  var kette: String?
  var laufendName: String?
  var laufendStart: Date?
  var laufendPosition: Int?
  var naechstesName: String?
  var naechstesPosition: Int?
  var erledigt: Int
  var gesamt: Int

  static func laden() -> Schnappschuss? {
    guard let roh = UserDefaults(suiteName: stoppAppGroup)?.string(forKey: "schnappschuss"),
      let daten = roh.data(using: .utf8),
      let s = try? JSONSerialization.jsonObject(with: daten) as? [String: Any]
    else { return nil }
    let laufend = s["laufend"] as? [String: Any]
    let naechstes = s["naechstes"] as? [String: Any]
    return Schnappschuss(
      zustand: s["zustand"] as? String ?? "keine",
      kette: s["kette"] as? String,
      laufendName: laufend?["ereignis"] as? String,
      laufendStart: (laufend?["start"] as? NSNumber).map {
        Date(timeIntervalSince1970: $0.doubleValue / 1000)
      },
      laufendPosition: (laufend?["schritt_position"] as? NSNumber)?.intValue,
      naechstesName: naechstes?["ereignis"] as? String,
      naechstesPosition: (naechstes?["schritt_position"] as? NSNumber)?.intValue,
      erledigt: (s["erledigt"] as? NSNumber)?.intValue ?? 0,
      gesamt: (s["schritte_gesamt"] as? NSNumber)?.intValue ?? 0
    )
  }
}

// MARK: - Widget (klein)

struct StoppEintrag: TimelineEntry {
  let date: Date
  let schnappschuss: Schnappschuss?
}

struct StoppProvider: TimelineProvider {
  func placeholder(in context: Context) -> StoppEintrag {
    StoppEintrag(date: Date(), schnappschuss: nil)
  }

  func getSnapshot(in context: Context, completion: @escaping (StoppEintrag) -> Void) {
    completion(StoppEintrag(date: Date(), schnappschuss: Schnappschuss.laden()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<StoppEintrag>) -> Void) {
    // Die App lädt das Widget nach jedem neuen Schnappschuss neu.
    let eintrag = StoppEintrag(date: Date(), schnappschuss: Schnappschuss.laden())
    completion(Timeline(entries: [eintrag], policy: .never))
  }
}

struct StoppWidgetAnsicht: View {
  let eintrag: StoppEintrag

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(oben).font(.caption).foregroundStyle(leise).lineLimit(1)
      Text(name).font(.headline).lineLimit(2)
      Spacer(minLength: 0)
      HStack(alignment: .center) {
        links
        Spacer(minLength: 4)
        knopf
      }
    }
    .widgetURL(URL(string: "stoppapp://oeffnen?homeWidget"))
  }

  private var s: Schnappschuss? { eintrag.schnappschuss }
  private var fortschritt: String { "\(s?.erledigt ?? 0) von \(s?.gesamt ?? 0)" }

  private var oben: String {
    switch s?.zustand {
    case nil: return "StoppApp"
    case "laeuft": return "Läuft"
    case "bereit": return "Als Nächstes"
    case "erledigt": return s?.kette ?? "Heute"
    default: return "Heute"
    }
  }

  private var name: String {
    switch s?.zustand {
    case nil: return "App öffnen"
    case "laeuft": return s?.laufendName ?? ""
    case "bereit": return s?.naechstesName ?? ""
    case "erledigt": return "Erledigt"
    default: return "Keine Kette"
    }
  }

  @ViewBuilder private var links: some View {
    switch s?.zustand {
    case "laeuft":
      if let start = s?.laufendStart {
        Text(start, style: .timer).font(.subheadline.monospacedDigit().bold()).foregroundStyle(rot)
      }
    case "bereit", "erledigt":
      Text(fortschritt).font(.caption).foregroundStyle(leise)
    default:
      EmptyView()
    }
  }

  @ViewBuilder private var knopf: some View {
    switch s?.zustand {
    case "laeuft":
      Button(intent: StoppAktion(aktion: "stopp", schrittPosition: s?.laufendPosition, quelle: "widget")) {
        Text("Stopp").bold()
      }
      .buttonStyle(.borderedProminent).tint(rot)
    case "bereit":
      Button(intent: StoppAktion(aktion: "start", schrittPosition: s?.naechstesPosition, quelle: "widget")) {
        Text("Start").bold()
      }
      .buttonStyle(.borderedProminent).tint(gruen)
    case "erledigt":
      Link(destination: URL(string: "stoppapp://einschieben?homeWidget")!) {
        Text("+").bold().padding(.horizontal, 10).padding(.vertical, 4)
          .overlay(Capsule().stroke(.primary, lineWidth: 1.5))
      }
    case "keine":
      Link(destination: URL(string: "stoppapp://kette-waehlen?homeWidget")!) {
        Text("Wählen").bold().padding(.horizontal, 10).padding(.vertical, 4)
          .overlay(Capsule().stroke(.primary, lineWidth: 1.5))
      }
    default:
      EmptyView()
    }
  }
}

struct StoppWidget: Widget {
  let kind = "StoppWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: StoppProvider()) { eintrag in
      StoppWidgetAnsicht(eintrag: eintrag)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName("StoppApp")
    .description("Nächstes Ereignis starten oder die laufende Messung stoppen.")
    .supportedFamilies([.systemSmall])
  }
}

// MARK: - Live Activity

struct StoppKnopf: View {
  let zustand: StoppAktivitaetAttribute.ContentState

  var body: some View {
    Button(intent: StoppAktion(aktion: "stopp", schrittPosition: zustand.schrittPosition, quelle: "live_activity")) {
      Label("Stopp", systemImage: "stop.fill").bold()
    }
    .buttonStyle(.borderedProminent).tint(rot)
  }
}

struct StoppLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: StoppAktivitaetAttribute.self) { context in
      HStack(alignment: .center) {
        VStack(alignment: .leading, spacing: 2) {
          Text("StoppApp").font(.caption).foregroundStyle(.secondary)
          Text(context.state.ereignis).font(.headline).lineLimit(1)
          Text(context.state.start, style: .timer)
            .font(.title2.monospacedDigit().bold()).foregroundStyle(rot)
        }
        Spacer()
        StoppKnopf(zustand: context.state)
      }
      .padding()
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Text(context.state.ereignis).font(.headline).lineLimit(1)
        }
        DynamicIslandExpandedRegion(.trailing) {
          Text(context.state.start, style: .timer).monospacedDigit().foregroundStyle(rot)
        }
        DynamicIslandExpandedRegion(.bottom) {
          StoppKnopf(zustand: context.state)
        }
      } compactLeading: {
        HStack(spacing: 4) {
          Circle().fill(rot).frame(width: 8, height: 8)
          Text(context.state.ereignis).lineLimit(1)
        }
      } compactTrailing: {
        Text(context.state.start, style: .timer).monospacedDigit().frame(maxWidth: 56)
      } minimal: {
        Circle().fill(rot).frame(width: 10, height: 10)
      }
    }
  }
}

@main
struct StoppWidgetBundle: WidgetBundle {
  var body: some Widget {
    StoppWidget()
    StoppLiveActivity()
  }
}
