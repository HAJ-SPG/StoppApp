# Widgets & Live Activities mit kostenloser Apple-ID

Research zu Issue #2 · Stand: 2026-11-06 · Quellen: Apple Developer und Android Developer Docs (Primärquellen), abgerufen am 2026-11-06.

## Antwort

**iOS: Machbar, ohne Workaround.** Alle drei Bausteine laufen mit einem kostenlosen Personal Team:

1. **Interaktives Homescreen-Widget** (WidgetKit und App Intents, iOS 17+): braucht keine Capability. Es ist eine Widget-Extension mit `Button(intent:)`.
2. **Live Activity mit Stopp-Button**: braucht nur den Info.plist-Key `NSSupportsLiveActivities`. Start, Update und Ende laufen lokal per ActivityKit, ohne Push. Der Stopp-Button ist ein `LiveActivityIntent`.
3. **App Group**: Apples Capability-Tabelle führt „App groups“ ausdrücklich als verfügbar für die kostenlose Mitgliedschaft.

**Nicht verfügbar ist Push Notifications.** Das betrifft nur *Remote*-Updates der Live Activity über APNs. Eine lokale Stoppuhr braucht das nicht.

Die eigentlichen Kosten des Personal Teams sind organisatorisch:
- Neu-Installation via Xcode alle 7 Tage
- höchstens 10 App-IDs pro 7 Tage
- höchstens 3 Apps pro Gerät

**Android: Machbar.** Ein Foreground Service ist nicht nötig, wenn die Stoppuhr nur einen Startzeitpunkt speichert. Die Notification zeigt die laufende Zeit dann per Chronometer an, und ihr Stopp-Button ist ein `PendingIntent`. Für das Sideloading gilt:
- Per **ADB/Android Studio installieren:** bleibt auch nach Googles Developer Verification frei.
- **APK direkt auf dem Gerät öffnen:** ist bis Ende 2026 nur in BR/ID/SG/TH eingeschränkt. Ab 2027 wirkt die Einschränkung global, mit kostenlosem Ausweg (siehe unten).

---

## iOS im Detail

### Was das Personal Team erlaubt und was nicht

Apple, *Compare memberships* ([Quelle](https://developer.apple.com/support/compare-memberships/)):

> „If your account is not associated with a developer program membership, Xcode will indicate it's a Personal Team. […] You can register up to 10 App IDs, which expire after 7 days. You can register up to 3 devices, which expire after 7 days. You can install up to 3 apps per device. Provisioning profiles that enable apps to be installed on a device will expire 7 days from issuance. You'll need to rebuild and reinstall your app to your device after expiration.“

Apple, *Supported capabilities (iOS)* ([Quelle](https://developer.apple.com/help/account/reference/supported-capabilities-ios)). Die Tabelle hat drei Spalten: ADP (bezahlt), ADEP (Enterprise) und „Apple Developer“ (kostenlos, „No cost is associated with this agreement and developers can't distribute apps“). Relevante Zeilen, aus dem HTML der Seite ausgelesen:

| Capability | ADP | ADEP | Apple Developer (kostenlos) |
|---|---|---|---|
| App groups | ja | ja | **ja** |
| Background modes | ja | ja | **ja** |
| Keychain sharing | ja | ja | **ja** |
| Data protection | ja | ja | **ja** |
| Push notifications | ja | ja | **nein** |
| Time Sensitive Notifications | ja | ja | **nein** |
| iCloud (CloudKit, Documents, KVS) | ja | ja | **nein** |
| Siri | ja | ja | **nein** |

WidgetKit, ActivityKit und App Intents stehen nicht in der Tabelle, weil sie keine Capability bzw. kein Entitlement sind. Die „Siri“-Capability betrifft SiriKit. App Intents für Widget-Buttons brauchen sie laut der WidgetKit-Doku nicht (siehe unten).

### (1) Interaktives Widget

Apple, *Adding interactivity to widgets and Live Activities* ([Quelle](https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities)):

- Buttons und Toggles gibt es in `systemSmall`, `systemMedium`, `systemLarge` sowie in `accessoryCircular`/`accessoryRectangular` (Sperrbildschirm-Widgets).
- „For a widget, create a new structure that adopts the AppIntent protocol and add it to your app target. […] add your custom app intent to your widget extension target and your app target.“
- „By default, the system runs the app intent in the same process as the widget extension.“ Nach `perform()` gilt: „the system reloads the widget's timeline […] Interactions with a toggle or button always guarantee a timeline reload.“
- „On a locked device, buttons and toggles are inactive and the system doesn't perform actions unless a person authenticates and unlocks their device.“

Die Doku nennt dafür kein Entitlement und keine Capability.

**Laufende Zeit im Widget ohne Reload-Budget.** Apple, *Displaying dynamic dates* ([Quelle](https://developer.apple.com/documentation/widgetkit/displaying-dynamic-dates)): Ein `Text` mit `.timer`-Style „counts down until the current time reaches the specified date and time, and counts up when the date passes“. `init(timerInterval:pauseTime:countsDown:showsHours:)` zeigt einen Zähler ohne Widget-Reload. Mit einem Startzeitpunkt in der Vergangenheit zählt das Widget also selbstständig hoch. Das ist wichtig, weil Reloads budgetiert sind: „a daily budget typically includes from 40 to 70 refreshes“ ([Keeping a widget up to date](https://developer.apple.com/documentation/widgetkit/keeping-a-widget-up-to-date)).

### (2) Live Activity mit Stopp-Button, lokal ohne Push

Apple, *Displaying live data with Live Activities* ([Quelle](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities)):

- **Setup:** Code in die (bestehende) Widget-Extension und `NSSupportsLiveActivities = YES` in die Info.plist der App. Die Seite nennt kein Entitlement.
- **Lokal starten:** „You start a Live Activity in your app's code while the app is in the foreground with the `request(attributes:content:pushType:)` function. Pass […] if you implement ActivityKit push notifications, the `pushType` parameter.“ Push ist also optional.
- **Lokal aktualisieren:** mit `update(_:)` auf dem `Activity`-Objekt. „You can update or end a Live Activity from your app while it runs in the background“.
- **Aus dem Hintergrund starten:** über einen `LiveActivityIntent` möglich, zum Beispiel per Widget-Button oder Control-Center-Control ([LiveActivityIntent](https://developer.apple.com/documentation/appintents/liveactivityintent)).
- **Push** ist nur eine zusätzliche Option („In addition to updating and ending a Live Activity from your app with ActivityKit, …“) und braucht einen eigenen APNs-Server ([Quelle](https://developer.apple.com/documentation/activitykit/starting-and-updating-live-activities-with-activitykit-push-notifications)). Mit dem Personal Team geht das nicht, weil die Push-Capability fehlt.
- **Stopp-Button:** „For a Live Activity interactive, adopt the LiveActivityIntent protocol.“ Ein solcher Intent läuft im **App-Prozess**: „the system runs the app intent in the app's process. Make sure to add your custom app intent to your app target.“ Buttons sind „in the expanded and the Lock Screen presentation“ möglich, also im Sperrbildschirm und in der expandierten Dynamic Island.
- **Limits:**
  - Eine Live Activity ist höchstens 8 Stunden aktiv und bleibt danach bis zu 4 weitere Stunden im Sperrbildschirm sichtbar, insgesamt also maximal 12 Stunden.
  - Statische und dynamische Daten zusammen sind auf 4 KB begrenzt.
  - Die Live Activity „can't access the network“.
  - Eine länger als 8 Stunden laufende Stoppuhr verliert ihre Live Activity. Die Zeitmessung selbst ist davon nicht betroffen, wenn sie auf einem gespeicherten Startzeitpunkt beruht.
- **Laufende Zeit:** In der Live Activity zählt ebenfalls `Text(timerInterval:…)` bzw. der `.timer`-Style selbstständig, also ohne ständige `update()`-Aufrufe.

### (3) App Group für den Datenaustausch

Apple, *Configuring app groups* ([Quelle](https://developer.apple.com/documentation/xcode/configuring-app-groups)): „You can also use an app group to share data between an app extension or App Clip and its host app.“ Der Zugriff läuft über `UserDefaults(suiteName:)` oder `containerURL(forSecurityApplicationGroupIdentifier:)`. Laut Capability-Tabelle ist App Groups im kostenlosen Account verfügbar. Xcode registriert die Gruppe beim Personal Team automatisch, weil es dort keinen Zugriff auf das Portal „Certificates, IDs & Profiles“ gibt.

### App-ID-Budget für die StoppApp

- Die App braucht eine App-ID für die App und eine für die Widget-Extension, also 2 der 10 App-IDs pro 7 Tage. Live Activity und interaktives Widget leben in derselben Extension. App Intents brauchen keine eigene App-ID.
- **Unsicher, weil Apple dazu schweigt:** ob die App-Group-Registrierung zusätzlich gegen das 10er-Limit zählt. Ein Blogbericht (sekundär, anekdotisch: [mybyways](https://mybyways.com/blog/new-limitations-imposed-on-free-apple-developer-account)) beschreibt, beim Hantieren mit App Groups ins 10-App-IDs-Limit gelaufen zu sein. **Empfehlung:** Bundle-IDs und Gruppennamen einmal festlegen und nicht ständig umbenennen. Jede neue Bundle-ID verbraucht eine App-ID für 7 Tage.
- **Unsicher, weil Apple dazu schweigt:** ob die Widget-Extension gegen das Limit von 3 Apps pro Gerät zählt. Sie ist in das App-Bundle eingebettet und wird nicht separat installiert. Vermutlich zählt nur die App, das ist aber nicht belegt.

### Workarounds, falls App Groups doch scheitern

Die Primärquellen geben dafür keinen Anlass. Falls es trotzdem klemmt:
- Der Stopp-Button der Live Activity braucht keine App Group, weil `LiveActivityIntent` im App-Prozess läuft und direkt auf den App-Speicher zugreift.
- Auch Widget-Intents lassen sich in den App-Prozess verlegen, über `openAppWhenRun = true` (öffnet die App) oder `ForegroundContinuableIntent`. Die Doku listet beide als Fälle, in denen „the system performs the app intent in the app's process“.
- Für die *Anzeige* braucht das Widget Daten, und der Timeline-Provider läuft in der Extension. Ohne App Group bleibt nur, den Zustand in der Timeline mitzugeben (`reloadTimelines` aus der App) oder für Configurable Widgets die Intent-Parameter zu nutzen. Das ist fragil. Deshalb ist die App Group der Normalweg.

### Praktische Folgen des Personal Teams

- Alle 7 Tage am Mac per Xcode neu bauen und installieren. Sonst startet die App nicht mehr, und Widget und Live Activity fallen mit ihr aus.
- Lokale Daten sollten eine Neuinstallation über dasselbe Bundle überstehen, weil die App nicht gelöscht, sondern überschrieben wird. Das ist plausibel, aber von Apple nicht explizit zugesichert.
- Dynamic Island gibt es nur auf entsprechender Hardware. Andere iPhones zeigen die Sperrbildschirm-Darstellung.

---

## Android im Detail

### Interaktives Homescreen-Widget

App Widgets (RemoteViews oder Jetpack Glance) unterstützen Buttons über `PendingIntent` bzw. Glance-Actions. Für Sideloading gibt es dabei keine Einschränkungen ([App widgets overview](https://developer.android.com/develop/ui/views/appwidgets/overview), [Glance user interaction](https://developer.android.com/develop/ui/compose/glance/user-interaction)).

### Dauerhafte Notification mit Stopp-Aktion

- **Benachrichtigungs-Berechtigung:** Ab Android 13 ist `POST_NOTIFICATIONS` eine Laufzeit-Berechtigung. Neu installierte Apps haben Notifications standardmäßig aus ([Notification permission](https://developer.android.com/develop/ui/views/notifications/notification-permission)). Die App muss also einmal fragen, und das gilt unabhängig vom Sideloading.
- **„Dauerhaft“ ist seit Android 14 relativ:** `setOngoing(true)`-Notifications sind jetzt vom Nutzer wegwischbar, außer bei gesperrtem Gerät und bei „Alle löschen“ ([Android 14 behavior changes](https://developer.android.com/about/versions/14/behavior-changes-all)). Die App sollte das per `setDeleteIntent` erkennen und den Timer trotzdem korrekt weiterführen.
- **Foreground Service nicht nötig:** Die Stoppuhr speichert nur den Startzeitpunkt. Die Notification nutzt `setUsesChronometer(true)` mit `setWhen(start)`, das System zählt dann selbst. Die Stopp-Aktion ist ein `PendingIntent` auf einen BroadcastReceiver. So entfallen die Android-14-Pflichten für FGS-Typen.
- **Falls doch ein Foreground Service:** Ab Android 14 ist ein Typ Pflicht ([FGS types](https://developer.android.com/develop/background-work/services/fgs/service-types)). Für eine Stoppuhr passt keiner der Fachtypen. Es bleibt `specialUse`, mit Permission `FOREGROUND_SERVICE_SPECIAL_USE` und `PROPERTY_SPECIAL_USE_FGS_SUBTYPE`. Die Prüfung dieser Begründung findet nur in der Play Console statt und spielt beim Sideloading also keine Rolle. `shortService` scheidet aus, weil es nur etwa 3 Minuten läuft.
- **Optional ab Android 16, „Live Updates“:** Eine Notification kann als „Live Update“ hervorgehoben werden: oben im Notification-Drawer, im Sperrbildschirm und als Chip in der Statusleiste. Der Chip kann den Chronometer zeigen. Das ist das Android-Gegenstück zur Live Activity.
  - Voraussetzungen: `POST_PROMOTED_NOTIFICATIONS` im Manifest, `setRequestPromotedOngoing(true)`, ongoing, keine `RemoteViews` ([Live Updates](https://developer.android.com/develop/ui/views/notifications/live-update)).
  - Hersteller können zusätzliche Kriterien durchsetzen.

### Sideloading und Developer Verification

Laut [Developer Verification](https://developer.android.com/developer-verification) und [FAQ](https://developer.android.com/developer-verification/guides/faq):

- **Seit 30.09.2026:** Durchsetzung nur bei Installation aus „participating stores“ in Brasilien, Indonesien, Singapur und Thailand. „If […] users sideload your app directly, these new verification requirements won't apply to your app yet.“
- **Ab 2027:** globale Durchsetzung auf zertifizierten Geräten ab Android 7.
- **ADB bleibt frei:** „Apps installed using ADB won't require verification.“ Das gilt auch für die Installation per Android Studio. „There are no changes to how ADB works.“
- **Kostenlose Auswege ab 2027:**
  - ein *Limited Distribution Account*: bis zu 20 Geräte, keine Gebühr, kein Ausweis
  - oder der *Advanced Flow* auf dem Gerät: Entwickleroptionen aktivieren, Neustart, 24 Stunden warten, danach „Install Anyway“
- **Updates:** Unregistrierte Apps lassen sich nur mit aktivem Advanced Flow oder per ADB installieren und aktualisieren.

**Empfehlung für die StoppApp:** per ADB/Android Studio installieren. Wer das APK ab 2027 direkt auf dem Gerät öffnen will, richtet einmalig den Advanced Flow ein oder legt einen kostenlosen Limited Distribution Account an.

---

## Offene Unsicherheiten

| Punkt | Status |
|---|---|
| App Group zählt gegen das 10-App-IDs-Limit? | Apple schweigt. Nur anekdotisch (Blog). Bundle-IDs stabil halten. |
| Widget-Extension zählt gegen das Limit von 3 Apps pro Gerät? | Apple schweigt. Vermutlich nein, weil eingebettet. |
| Live Activities und interaktive Widgets im Personal Team konkret getestet? | Keine Apple-Aussage speziell zum Personal Team. Die Herleitung stützt sich darauf, dass kein Entitlement nötig ist. Im ersten Prototyp verifizieren. |
| Herstellerspezifisches Verhalten von Live Updates (Android 16) | Laut Google können OEMs eigene Kriterien setzen. |
