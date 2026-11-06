# iOS einrichten (Mac + Xcode + kostenlose Apple-ID)

Einmalig nötig, damit Widget und Live Activity auf dem iPhone laufen. Der Swift-Code liegt schon im Repo; am Mac legst du nur das Widget-Target an und hängst die Dateien ein. Ohne diese Schritte läuft die App selbst trotzdem.

| Datei | Target |
|---|---|
| `ios/Runner/AppDelegate.swift`, `ios/Runner/LiveAktivitaet.swift` | Runner (schon eingetragen) |
| `ios/Gemeinsam/StoppAktion.swift`, `ios/Gemeinsam/StoppAktivitaet.swift` | Runner (schon eingetragen) **und** StoppWidgetExtension |
| `ios/StoppWidget/StoppWidget.swift` | nur StoppWidgetExtension |

## Schritte

1. `flutter pub get`, dann `ios/Runner.xcworkspace` in Xcode öffnen.
2. **Runner → Signing & Capabilities:** Team = deine Apple-ID. Bundle Identifier bleibt `com.hajspg.stoppapp`.
3. **App Group für Runner:** „+ Capability“ → *App Groups* → `group.com.hajspg.stoppapp` anlegen und anhaken.
4. **Widget-Target anlegen:** *File → New → Target… → Widget Extension*.
   - Product Name: `StoppWidget`
   - „Include Live Activity“ und „Include Configuration App Intent“ **abwählen**.
   - Bei „Activate scheme?“ → *Activate*.
5. Xcode legt im neuen Ordner `StoppWidget` eigene Beispieldateien an (`StoppWidget.swift`, `StoppWidgetBundle.swift` …). **Alle Swift-Dateien darin löschen** („Move to Trash“), die `Info.plist` und `Assets.xcassets` behalten.
6. **Unsere Dateien einhängen:** Rechtsklick auf die Gruppe `StoppWidget` → *Add Files to "Runner"…*
   - `ios/StoppWidget/StoppWidget.swift` → Target **nur StoppWidgetExtension**.
   - `ios/Gemeinsam/StoppAktion.swift` und `StoppAktivitaet.swift`: Datei im Navigator wählen und rechts unter *Target Membership* zusätzlich **StoppWidgetExtension** anhaken (Runner bleibt angehakt).
7. **StoppWidgetExtension → General:** Minimum Deployments = **iOS 17.0**.
8. **StoppWidgetExtension → Signing & Capabilities:** gleiches Team, Bundle Identifier `com.hajspg.stoppapp.StoppWidget`, *App Groups* → `group.com.hajspg.stoppapp` anhaken.
9. **Build-Reihenfolge (bekannte Flutter-Falle):** Runner → *Build Phases*: „Embed Foundation Extensions“ per Drag **über** „Run Script“ / „Thin Binary“ ziehen. Sonst meldet Xcode „Cycle inside Runner“.
10. iPhone anschließen, Scheme **Runner** wählen, ▶︎ Run. Auf dem iPhone einmal *Einstellungen → Allgemein → VPN & Geräteverwaltung* dem Entwickler vertrauen.
11. Widget auf den Homescreen legen (lange drücken → + → StoppApp, klein).

Mit kostenloser Apple-ID läuft die Installation 7 Tage, danach Schritt 10 wiederholen (Daten bleiben erhalten).

## Prüfen

- Widget zeigt „Als Nächstes …“ mit **Start**. Tippen → nach kurzer Zeit „Läuft“ mit Zeit und **Stopp**.
- Während einer Messung: Live Activity auf dem Sperrbildschirm und in der Dynamic Island mit **Stopp**.
- „Wählen“ bzw. „+“ öffnet die App bei „Kette für heute wählen“ bzw. „Einschieben“.
- Wie lange dauert es vom Tippen bis zur neuen Anzeige? (Spec Abschnitt 11: im ersten Build prüfen.)
- Tipp im Widget, während die App ganz geschlossen ist: Wird die Messung sofort angelegt, oder erst beim nächsten Öffnen? Beides ist korrekt (Warteschlange als Rückfall), aber sofort ist das Ziel. Wenn es erst beim Öffnen passiert, bitte melden.
