# Flutter als App-Stack, native Teile nur für Widget und Live Activity

Die StoppApp wird mit **Flutter (Dart)** gebaut, für **iOS 17+ und Android 10+**. Der gesamte App-Rumpf ist gemeinsamer Dart-Code: Haupt-Screen, Kalender, Editor, Statistik und Datenbank. Nativ geschrieben werden nur das Homescreen-Widget (SwiftUI + AppIntent bzw. Glance) und die iOS-Live-Activity (Swift-Extension mit ActivityKit + `LiveActivityIntent`). Grund: Widget und Notification mit Stopp-Button sind Kernfunktionen der Version 1. Flutter ist die einzige Option, die sie auf beiden Plattformen mit ausgereiften Bausteinen abdeckt. iOS 17 ist die Untergrenze, weil ein Widget-Button nur ab dort direkt stoppen kann, ohne die App zu öffnen.

## Considered Options

- **Expo / React Native:** Auf iOS eleganter, weil Widget und Live Activity in TSX geschrieben werden können. Auf Android aber zu unreif: `expo-widgets` gibt es dort erst seit SDK 58, Widget-Buttons kommen nicht an die Datenbank, Notifee ist archiviert, und es gibt kein tickendes Widget.
- **Getrennt nativ (Swift + Kotlin):** Beste Widget-Integration, aber jede Funktion doppelt. Bei einer App für den Eigengebrauch steht das in keinem Verhältnis zum Gewinn.

## Consequences

- Bausteine: `drift` (SQLite), Riverpod, `home_widget`, `flutter_local_notifications` (ongoing, Chronometer, Stopp-Aktion), `fl_chart`, `table_calendar`. Die Fachlogik (Ketten, Tageswechsel, Statistik) liegt in reinem Dart ohne Flutter-Abhängigkeit.
- Swift-Code ist Pflicht und nur am Mac baubar. iOS-Installation per Xcode mit kostenloser Apple-ID: alle 7 Tage neu, 2 App-IDs (App + Widget-Extension), Bundle-IDs bleiben stabil. Android per `flutter build apk` und ADB/APK.
- Eine Live Activity endet nach 8 h. Danach wird über das Widget oder die App gestoppt, und die App startet die Live Activity beim nächsten Öffnen neu, solange die Messung läuft. Eine weggewischte Android-Notification wird beim nächsten Öffnen der App wieder gesetzt.
- Im ersten Build prüfen: Zuverlässigkeit des Hintergrund-Callbacks, ob App Group und Extension gegen die Limits des Personal Teams zählen (10 App-IDs, 3 Apps), tickende Zeit im Android-Widget (RemoteViews-`Chronometer`).

Grundlage: [Recherche kostenlose Apple-ID](https://github.com/HAJ-SPG/StoppApp/blob/research/free-apple-id-widgets/docs/research/free-apple-id-widgets.md), [Recherche Cross-Platform-Stack](https://github.com/HAJ-SPG/StoppApp/blob/research/cross-platform-stack/docs/research/cross-platform-stack.md).
