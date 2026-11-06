# Recherche: Cross-Platform-Stack für Widgets, Live Activities & lokale DB

Ticket: [#3](https://github.com/HAJ-SPG/StoppApp/issues/3) · Stand: 2026-11-06 · Teil der Karte [#1](https://github.com/HAJ-SPG/StoppApp/issues/1)

## Empfehlung (Kurzfassung)

**Flutter** für die App (Dart), dazu **dünne native Schichten** für alles außerhalb der App:

| Baustein | Wahl |
|---|---|
| App-UI, Logik | Flutter (Dart) |
| Datenbank | `drift` (SQLite, typisiert, Migrationen) im App-Prozess |
| Homescreen-Widget | `home_widget` als Brücke; Widget-UI nativ (iOS: SwiftUI/WidgetKit + `AppIntent`; Android: Glance oder RemoteViews mit `Chronometer`), optional per `home_widget_generator` |
| iOS Live Activity | eigene kleine Swift-Widget-Extension mit ActivityKit + `LiveActivityIntent` für den Stopp-Button; `live_activities` nur optional zum Starten/Beenden aus Dart |
| Android dauerhafte Notification | `flutter_local_notifications` (`ongoing`, `usesChronometer`, Aktions-Button) |
| Diagramme / Kalender | `fl_chart` (oder `syncfusion_flutter_charts`) / `table_calendar` |

**Ausschlaggebend:** Das Flutter-Ökosystem deckt *beide* Plattformen mit gereiften, aktiv gepflegten Paketen ab (Widget-Brücke seit Jahren, Notification-Chronometer, SQLite). Bei Expo ist die passende First-Party-Lösung (`expo-widgets`) für iOS gut, für Android aber erst seit SDK 58 (Herbst 2026) vorhanden; die Android-Ersatzbibliotheken haben harte Einschränkungen (Widget als Bild, Notifee archiviert). In **jedem** Stack wird für Widget und Live Activity ohnehin nativer Code (Swift/Kotlin) nötig, der Stack entscheidet also vor allem über den App-Rumpf (Kalender, Statistik, DB), und da ist Flutter unter Windows + Mac gut aufgestellt.

**Zweitplatz:** Expo SDK 58 mit `expo-widgets` (iOS-Widget + Live Activity in JS/TSX) + `expo-sqlite`. Wäre die erste Wahl, wenn man JS/TS klar bevorzugt; Risiko ist der junge Android-Teil (siehe unten).

**Getrennt nativ** (Swift + Kotlin) liefert die beste Widget-Integration, verdoppelt aber App-UI, Statistik, Kalender und DB-Logik. Für ein Ein-Personen-Projekt nicht empfohlen.

---

## 1. Plattform-Rahmenbedingungen (stackunabhängig)

### Kostenlose Apple-ID (Personal Team)

Apples offizielle Capability-Tabelle ([Supported capabilities (iOS)](https://developer.apple.com/help/account/reference/supported-capabilities-ios)) hat eine eigene Spalte „Apple Developer“ (kostenlos, ohne Programm). Daraus (HTML der Seite ausgewertet am 2026-11-06):

| Capability | ADP (bezahlt) | Apple Developer (kostenlos) |
|---|---|---|
| App groups | ja | **ja** |
| Background modes | ja | ja |
| Push notifications | ja | **nein** |
| Time Sensitive Notifications | ja | nein |

Folgen für die StoppApp:

- **App Groups gehen** → App und Widget-Extension können sich Daten (UserDefaults-Suite, Dateien, SQLite-Datei) im gemeinsamen Container teilen. Das ist die Grundvoraussetzung für jeden Stack.
- **Kein Push** → Live Activities können nicht per Push aktualisiert/gestartet werden. Für eine Stoppuhr ist das unkritisch: Die Anzeige läuft lokal mit `Text(timerInterval:)` bzw. Timer-Datumsstil von selbst hoch, Updates kommen nur bei Start/Stopp aus der App oder einem Intent.
- Live Activities selbst brauchen keine kostenpflichtige Capability, nur `NSSupportsLiveActivities` in der Info.plist.
- Bekannt (nicht von Apple dokumentiert, aber in Apple-Foren durchgängig berichtet): Provisioning-Profile des Personal Teams laufen nach **7 Tagen** ab, und die Zahl neuer App-IDs pro Woche ist begrenzt. App + Widget-Extension = 2 Bundle-IDs; nicht ständig umbenennen. Die 7-Tage-Neuinstallation ist in #1 bereits akzeptiert.

### iOS: Interaktion aus Widget und Live Activity

- Interaktive Widgets (Buttons mit `AppIntent`) ab **iOS 17**.
- [`LiveActivityIntent`](https://developer.apple.com/documentation/appintents/liveactivityintent): „When the system performs the intent, the system launches your app process without opening the app, performs the intent, and starts the Live Activity.“ → Ein Start-Button im Widget kann die Live Activity starten, ein Stopp-Button in der Live Activity kann sie beenden, **ohne die App zu öffnen**, und der Code läuft im **App-Prozess** (dort ist die DB erreichbar).

### iOS: SQLite im geteilten Container

Apple, [SIGKILL / Termination Reason](https://developer.apple.com/documentation/xcode/sigkill): Code `0xdead10cc` = „The operating system terminated the app because it held on to a file lock or SQLite database lock during suspension.“ Eine SQLite-Datei, die App **und** Extension gleichzeitig offen halten, ist darum eine bekannte Fehlerquelle.

**Architektur-Folgerung (für jeden Stack):** Die Datenbank gehört der App. Widget/Live Activity lesen einen kleinen **Widget-Schnappschuss** (laufende Messung: Ereignis + Startzeit; nächstes Ereignis der Tageskette; ggf. die restlichen Schritte des Tages) aus App-Group-UserDefaults bzw. Android SharedPreferences. Tippt man im Widget, wird entweder (a) per `LiveActivityIntent`/Background-Callback der App-Prozess geweckt und schreibt die Messung direkt in die DB, oder (b) das Widget hängt Start/Stopp-Zeitstempel an eine kleine Warteschlange im geteilten Speicher, die die App beim nächsten Start in Messungen überführt. (b) ist das robuste Fallback.

### Android

- Widget-Klick → `BroadcastReceiver`/Glance-`ActionCallback`, läuft ohne geöffnete App im App-Prozess; DB direkt erreichbar.
- Laufende Zeit im Widget/Notification ohne Dauer-Updates: `Chronometer` (RemoteViews) bzw. Notification mit `setUsesChronometer(true)`.
- APK-Build lokal unter Windows mit jedem Stack problemlos.

---

## 2. Expo / React Native

Versionen laut npm-Registry am 2026-11-06: `expo` 58.0.23, `expo-widgets` 58.0.27 (2026-11-03), `@bacons/apple-targets` 5.0.0 (2026-07-17), `react-native-android-widget` 0.26.0 (2026-10-29), `expo-sqlite` 58.0.15.

### `expo-widgets` (First-Party)

Quelle: [Expo-Doku `expo-widgets`](https://docs.expo.dev/versions/latest/sdk/widgets/), [CHANGELOG](https://github.com/expo/expo/blob/main/packages/expo-widgets/CHANGELOG.md).

- Existiert. Erste Alpha 55.0.0-alpha.0 am 2026-01-21, stabil 55.0.0 am 2026-02-25. **Android** erst ab 56.0.15 (2026-05-26) angelegt, Widgets in **58.0.0** umgesetzt; seither Android-Absturz- und Build-Fixes.
- Widgets und Live Activities werden in TSX mit `@expo/ui`-Komponenten (SwiftUI bzw. Jetpack Compose) beschrieben. iOS-`Text` hat `timerInterval` für hochzählende Timer ([expo-ui Text-Doku](https://github.com/expo/expo/blob/main/docs/pages/versions/v58.0.0/sdk/ui/swift-ui/text.mdx)).
- Interaktiv: Der Rückgabewert von `onPress` wird zu den neuen Props des Widgets; „The runtime persists it and reloads the widget on device, with no running app process required.“ Aber: Widget-Code läuft in einer isolierten Runtime, „cannot perform asynchronous work, import other modules, or access your app's runtime or in-memory state“. → **Kein DB-Zugriff aus dem Widget-Button**; `addUserInteractionListener` „only fires while the app process is alive“. Für die StoppApp hieße das: Zustand in Widget-Props halten, App gleicht beim Start ab (Muster (b)).
- **Live Activities nur iOS** („Timelines …, configurable widgets, and Live Activities are available only on iOS“). Für Android gibt es `createCustomNotification` mit `ongoing`-Option (seit 58.0.17); ein Chronometer ist dort nicht dokumentiert.
- Nicht in Expo Go, nur Development Builds/Prebuild; App Group standardmäßig `group.<bundle id>`.

### `expo-apple-targets` (Evan Bacon, Community)

Quelle: [GitHub](https://github.com/EvanBacon/expo-apple-targets). Config-Plugin, das echte Xcode-Targets (u. a. „Widget / Live Activity“) aus `/targets` per Prebuild erzeugt; Code ist **natives Swift**. App-Group-Daten über NSUserDefaults (`ExtensionStorage`). Aktiv (letzter Push 2026-11-05, 1,4k Sterne), aber Ein-Personen-Projekt mit Hinweisen wie „I haven't tested all of these“. Voraussetzung Xcode 16, Expo SDK 53+.

### Android-Widget außerhalb von `expo-widgets`

[`react-native-android-widget`](https://github.com/sAleksovski/react-native-android-widget): Widgets in JSX, Klicks über `registerWidgetTaskHandler` (Headless JS, auch async, also DB-Zugriff möglich), Expo-Config-Plugin vorhanden. Harte Einschränkung laut [Limitations](https://github.com/sAleksovski/react-native-android-widget/blob/master/docs/docs/limitations.md): „We cannot render React Native views directly to the widget … render the React Native views to an image“ → **keine selbst tickende Uhr** im Widget; jede Anzeigeänderung braucht ein neues Rendering. Für eine Stoppuhr ungünstig.

### Android-Notification

[Notifee](https://github.com/invertase/notifee) (früher Standard für Chronometer + Aktionen in RN) ist laut GitHub-API **archiviert**. Ersatz: `expo-widgets`-Custom-Notification (sehr neu) oder ein eigenes Expo-Modul in Kotlin.

### Datenbank

[`expo-sqlite`](https://docs.expo.dev/versions/latest/sdk/sqlite/): `openDatabaseAsync(name, options, directory)`; offizieller Abschnitt „Sharing a database between apps/extensions (iOS)“ mit `Paths.appleSharedContainers`; Drizzle-ORM-Integration dokumentiert. Solide.

### Charts / Kalender

`victory-native` 43.0.1 (2026-10-20, Skia-basiert), `react-native-gifted-charts` 1.4.81 (2026-10-05), `react-native-calendars` 1.1314.0 (2026-01-29). Ausreichend.

### Lokaler Build

`npx expo prebuild` + `npx expo run:ios --device` bzw. Xcode auf dem Mac; EAS ist nicht nötig. Android-APK über Gradle lokal unter Windows.

---

## 3. Flutter

Versionen laut pub.dev-API am 2026-11-06: `home_widget` 0.10.0 (2026-09-17), `live_activities` 2.6.0 (2026-09-11), `drift` 2.35.3 (2026-10-23), `sqflite` 2.4.5 (2026-10-21), `fl_chart` 1.3.0 (2026-10-21), `table_calendar` 3.3.0 (2026-10-01), `syncfusion_flutter_charts` 35.1.43 (2026-11-03).

### `home_widget`

Quellen: [pub.dev](https://pub.dev/packages/home_widget) (verifizierter Publisher, 2,2k Likes), [Doku Interactive Widgets](https://github.com/ABausG/home_widget/blob/main/docs/features/interactive-widgets.mdx), [Generator-Doku](https://github.com/ABausG/home_widget/blob/main/docs/generator/index.mdx). Repo aktiv (letzter Push 2026-10-30).

- Brücke App ↔ Widget: `saveWidgetData` / `updateWidget`, geteilter Speicher über App Group (iOS) bzw. SharedPreferences (Android).
- „HomeWidget does **not** allow writing Widgets with Flutter itself … It still requires writing the Widgets with native code.“ Neu: `home_widget_generator` erzeugt aus einem annotierten Dart-Schema SwiftUI/WidgetKit- und Jetpack-Glance-Code.
- **Interaktiv auf beiden Plattformen**: Dart-Callback via `registerInteractivityCallback`; iOS 17 über ein `AppIntent` mit `HomeWidgetBackgroundWorker.run(...)`, Android über Glance-`ActionCallback` + `HomeWidgetBackgroundIntent`. Mit `ForegroundContinuableIntent` weckt der Tipp die App im Hintergrund (dann startet `main`, App muss den Hintergrundstart erkennen). Damit kann der Dart-Code direkt in die drift-DB schreiben.

### `live_activities`

Quelle: [pub.dev](https://pub.dev/packages/live_activities). Aktuell gepflegt (2.6.0). iOS-UI als native Widget-Extension (SwiftUI); Daten über App-Group-UserDefaults. **Android „in beta“** (RemoteViews-XML + Kotlin-Manager). Buttons im Beispiel nur als `Link` mit URL-Scheme (öffnet die App). Setup verlangt die Push-Capability, die das kostenlose Konto **nicht** hat (siehe oben) → Plugin entweder ohne Push-Teil betreiben (lokal testen!) oder die Live Activity direkt in Swift (ActivityKit + `LiveActivityIntent`) ansteuern, aus Dart über einen kleinen MethodChannel. Letzteres ist für die StoppApp ohnehin sauberer.

### Android-Notification

[`flutter_local_notifications`](https://github.com/MaikuB/flutter_local_notifications) (aktiv, letzter Push 2026-11-05): `ongoing`, `usesChronometer` (Zeitstempel als Stoppuhr, im CHANGELOG dokumentiert), Aktions-Buttons mit Hintergrund-Handler. Deckt „dauerhafte Notification mit Stopp-Button“ vollständig ab.

### Datenbank

`drift` (typisierte Queries, Streams für reaktive UI, Migrationen) oder `sqflite`. Datei-Pfad frei wählbar; für den empfohlenen Schnappschuss-Ansatz liegt die DB im normalen App-Verzeichnis, nur der Schnappschuss im App-Group-Speicher.

### Charts / Kalender

`fl_chart` (Linie, Balken, Torte, Scatter; reicht für Verlauf, Tagesverteilung, Uhrzeit-Muster), `syncfusion_flutter_charts` (mächtiger, Community-Lizenz), `table_calendar` für Monatsansicht mit Mehrfach-/Bereichsauswahl.

### Lokaler Build

`flutter build apk` unter Windows; iOS: `flutter run`/Xcode auf dem Mac mit Personal Team, Widget-Extension als zusätzliches Target im `ios/Runner.xcworkspace` (einmalig in Xcode anlegen, dann versioniert).

---

## 4. Getrennt nativ

- iOS: SwiftUI + SwiftData/GRDB + WidgetKit + ActivityKit – alles First-Party, beste Integration, keine Brücken.
- Android: Kotlin + Compose + Room + Glance + Notification mit Chronometer – ebenso.
- Aufwand: Hauptbildschirm, Ketten-Editor, Kalender, Tagesprotokoll, Statistik, Export/Import und Datenmodell **zweimal**. Android-Entwicklung geht unter Windows, iOS nur auf dem Mac. Für eine persönliche App unverhältnismäßig.

---

## 5. Vergleich

| Kriterium | Expo/RN (SDK 58) | Flutter | Getrennt nativ |
|---|---|---|---|
| iOS-Widget interaktiv | gut (`expo-widgets`, TSX; Button ohne DB-Zugriff) | gut (Swift-Widget + `home_widget`-Callback in Dart) | sehr gut |
| Android-Widget interaktiv | jung (`expo-widgets` Android seit 58.0.0) oder Bild-Rendering (`react-native-android-widget`) | gereift (Glance/RemoteViews + `home_widget`) | sehr gut |
| iOS Live Activity | gut (`expo-widgets`, TSX) | Swift-Extension nötig; Plugin optional | sehr gut |
| Android dauerhafte Notification | schwach (Notifee archiviert; Custom-Notification neu) | gut (`flutter_local_notifications`) | sehr gut |
| DB teilen | `expo-sqlite` mit App-Group-Verzeichnis dokumentiert | drift/sqflite + App-Group-Pfad | nativ |
| Ohne bezahltes Apple-Konto | ja (Prebuild + Xcode) | ja (Xcode) | ja |
| Charts / Kalender | ausreichend | gut | gut (Swift Charts / Compose-Libs) |
| Nativer Code nötig | wenig (iOS), Android ggf. Kotlin-Modul | Swift (Widget, LA) + wenig Kotlin | alles |
| Gesamtaufwand | mittel | mittel | hoch |

## 6. Risiken der Empfehlung

1. **Native Pflichtteile**: Widget-UI und Live Activity sind in Swift/SwiftUI zu schreiben (Generator hilft nur beim Widget). Aufwand überschaubar (eine Ansicht, ein bis zwei Intents), aber nur auf dem Mac entwickel- und testbar.
2. **Zustand Widget ↔ App**: Wenn der Hintergrund-Callback auf einem Gerät nicht zuverlässig feuert, muss die Warteschlange (Muster b) greifen. Früh als Prototyp bauen: Widget-Tipp bei geschlossener App → Messung landet korrekt in der DB.
3. **`live_activities`-Plugin und Push-Capability**: mit kostenlosem Konto nicht signierbar, falls das Plugin die Capability zwingend braucht. Ausweg: ActivityKit direkt in Swift.
4. **Personal-Team-Grenzen**: 7-Tage-Profile, begrenzte neue App-IDs; Bundle-IDs früh festlegen.
5. **Glance vs. RemoteViews**: Glance hat keinen eingebauten Chronometer; für eine tickende Zeit im Android-Widget ggf. RemoteViews-`Chronometer` (z. B. über `AndroidRemoteViews` in Glance) einsetzen. Im Prototyp prüfen.
6. **Gegenrisiko Expo**: Wer Expo wählt, setzt beim Android-Widget auf einen erst wenige Monate alten Teil von `expo-widgets` und braucht für die Android-Notification eigenen Kotlin-Code.

## Quellen

- Apple: [Supported capabilities (iOS)](https://developer.apple.com/help/account/reference/supported-capabilities-ios), [LiveActivityIntent](https://developer.apple.com/documentation/appintents/liveactivityintent), [SIGKILL / 0xdead10cc](https://developer.apple.com/documentation/xcode/sigkill)
- Expo: [expo-widgets](https://docs.expo.dev/versions/latest/sdk/widgets/), [expo-widgets CHANGELOG](https://github.com/expo/expo/blob/main/packages/expo-widgets/CHANGELOG.md), [expo-sqlite](https://docs.expo.dev/versions/latest/sdk/sqlite/), [expo-ui Text (timerInterval)](https://github.com/expo/expo/blob/main/docs/pages/versions/v58.0.0/sdk/ui/swift-ui/text.mdx)
- [EvanBacon/expo-apple-targets](https://github.com/EvanBacon/expo-apple-targets), [sAleksovski/react-native-android-widget](https://github.com/sAleksovski/react-native-android-widget) (docs/limitations.md, docs/handling-clicks.md), [invertase/notifee](https://github.com/invertase/notifee) (archiviert)
- Flutter: [home_widget](https://pub.dev/packages/home_widget) + [Repo-Doku](https://github.com/ABausG/home_widget/tree/main/docs), [live_activities](https://pub.dev/packages/live_activities), [flutter_local_notifications](https://github.com/MaikuB/flutter_local_notifications)
- Versionen/Daten: npm-Registry (`registry.npmjs.org`) und pub.dev-API (`pub.dev/api/packages/...`), abgefragt 2026-11-06
