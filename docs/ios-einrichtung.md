# StoppApp aufs iPhone bringen (Anleitung für den Mac)

Diese Anleitung beginnt bei einem Mac, auf dem noch nichts installiert ist, und endet mit der App samt Widget und Live Activity auf deinem iPhone. Teil A machst du nur einmal pro Mac, Teil B einmal pro Projekt, Teil C immer wieder (spätestens alle 7 Tage).

**Was du brauchst**

- Einen Mac mit aktuellem macOS. Das neueste Xcode braucht meist die neueste oder vorletzte macOS-Version. Ob das passt, steht im App Store bei Xcode unter „Kompatibilität“.
- Etwa 40 GB freien Speicher.
- Ein iPhone mit **iOS 17 oder neuer** und ein USB-Kabel.
- Eine Apple-ID. Die kostenlose reicht, du brauchst keinen bezahlten Entwickler-Account.

**So liest du die Anleitung**

- 🖥 **Terminal** heißt: Öffne das Programm *Terminal* (`⌘ Leertaste`, „Terminal“ tippen, Enter). Kopiere den Befehl hinein und drück Enter. Warte, bis wieder eine Eingabezeile mit `%` erscheint, bevor du den nächsten Befehl eingibst.
- 🔨 **Xcode** heißt: Klicken in der App Xcode.
- 📱 **iPhone** heißt: auf dem iPhone, meist in der App *Einstellungen*.
- Fragt das Terminal nach einem **Passwort**, ist das dein Mac-Anmeldepasswort. Beim Tippen siehst du nichts, nicht einmal Sternchen. Das ist normal: Tipp es trotzdem ein und drück Enter.

---

## Teil A: Mac einrichten (einmalig)

### A1. Xcode installieren

1. 🖥 **App Store**: Such nach **Xcode** und klick auf *Laden*. Der Download ist über 10 GB groß und dauert oft eine Stunde oder länger.
2. 🔨 **Xcode** einmal öffnen und alles bestätigen. Fragt Xcode, welche Plattformen du willst, wähl **iOS** aus. Den Simulator brauchst du nicht unbedingt.
3. 🖥 **Terminal**: Xcode als Werkzeug festlegen, die Lizenz annehmen und die Ersteinrichtung abschließen. Gib die drei Befehle einzeln ein:

   ```sh
   sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
   ```
   ```sh
   sudo xcodebuild -license accept
   ```
   ```sh
   sudo xcodebuild -runFirstLaunch
   ```

4. 🖥 **Terminal**: die iOS-Plattform laden. Wenn du sie schon in Schritt 2 gewählt hast, ist dieser Befehl schnell fertig.

   ```sh
   xcodebuild -downloadPlatform iOS
   ```

### A2. Rosetta installieren (nur bei Apple-Chip M1/M2/M3/M4…)

Ob du so einen Chip hast, siehst du unter  → *Über diesen Mac*. Steht dort „Chip Apple M…“, dann:

🖥 **Terminal**:

```sh
sudo softwareupdate --install-rosetta --agree-to-license
```

### A3. Homebrew und CocoaPods installieren

Homebrew ist ein Installationsprogramm für Entwickler-Werkzeuge. CocoaPods braucht Flutter für manche iOS-Pakete.

1. 🖥 **Terminal**:

   ```sh
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

   Das Skript fragt nach deinem Passwort und will ein Enter zur Bestätigung.
2. **Wichtig:** Am Ende zeigt das Skript unter **„Next steps“** zwei oder drei Befehle an (sie beginnen mit `echo` bzw. `eval`). **Kopiere genau diese Befehle** aus deinem Terminal und führe sie aus. Sie sind je nach Mac verschieden.
3. 🖥 **Terminal**:

   ```sh
   brew install cocoapods
   ```

### A4. Flutter installieren

Wir nehmen genau die Flutter-Version, mit der die App gebaut wird (3.47.9).

1. 🖥 **Terminal**: Flutter herunterladen.

   ```sh
   git clone https://github.com/flutter/flutter.git -b 3.47.9 ~/development/flutter
   ```

   Kommt stattdessen ein Fenster „Befehlszeilenentwickler-Tools installieren?“, klick auf *Installieren*. Führ den Befehl danach noch einmal aus.
2. 🖥 **Terminal**: Flutter dauerhaft bekannt machen und das Terminal neu laden.

   ```sh
   echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zshrc
   ```
   ```sh
   source ~/.zshrc
   ```

3. 🖥 **Terminal**: Prüfen, ob alles da ist.

   ```sh
   flutter doctor
   ```

   Wichtig ist nur die Zeile **Xcode**: Sie muss einen grünen Haken ✓ haben. Meldungen zu Android, Chrome oder VS Code kannst du ignorieren. Steht bei Xcode etwas Rotes, führ den Befehl aus, den `flutter doctor` dort vorschlägt.

### A5. Apple-ID in Xcode eintragen

🔨 **Xcode** → Menü *Xcode* → *Settings…* (oder `⌘ ,`) → Reiter **Accounts** → unten links **+** → *Apple ID* → anmelden.

Danach steht dort ein Team mit deinem Namen und **„(Personal Team)“**.

---

## Teil B: Projekt holen und Widget einrichten (einmalig)

### B1. Projekt holen

🖥 **Terminal**:

```sh
git clone https://github.com/HAJ-SPG/StoppApp.git ~/StoppApp
```
```sh
cd ~/StoppApp
```
```sh
git checkout build/v1
```
```sh
flutter pub get
```

Wenn `main` später den Stand von `build/v1` enthält, entfällt `git checkout build/v1`.

### B2. Projekt in Xcode öffnen

🖥 **Terminal** (du bist noch im Ordner `~/StoppApp`):

```sh
open ios/Runner.xcworkspace
```

Öffne immer die Datei **`.xcworkspace`**, nicht `.xcodeproj`.

### B3. App signieren (Runner)

🔨 **Xcode**:

1. Klick links in der Seitenleiste ganz oben auf das blaue **Runner**-Symbol.
2. Wähl in der Mitte unter *TARGETS* **Runner** und dann oben den Reiter **Signing & Capabilities**.
3. Setz bei **Team** dein „(Personal Team)“.
4. **Bundle Identifier** bleibt `com.hajspg.stoppapp`.
5. Klick links oben im Reiter auf **+ Capability**, doppelklick auf **App Groups**.
6. Klick im neuen Abschnitt *App Groups* auf **+** und gib `group.com.hajspg.stoppapp` ein. Der Haken davor muss gesetzt sein.

### B4. Widget-Target anlegen

🔨 **Xcode** → Menü *File* → *New* → *Target…* → **Widget Extension** → *Next*.

- **Product Name:** `StoppWidget` (genau so geschrieben)
- **Team:** dein Personal Team
- **Include Live Activity:** Haken **weg**
- **Include Control:** Haken **weg** (falls angeboten)
- **Include Configuration App Intent:** Haken **weg**
- *Finish*. Fragt Xcode „Activate "StoppWidgetExtension" scheme?“, klick auf **Activate**.

### B5. Xcodes Beispielcode durch unseren ersetzen

Xcode hat in den Ordner `ios/StoppWidget` eigene Beispieldateien gelegt und dabei unsere `StoppWidget.swift` überschrieben.

🖥 **Terminal** (im Ordner `~/StoppApp`):

```sh
git checkout -- ios/StoppWidget/StoppWidget.swift
```
```sh
git clean -f -- 'ios/StoppWidget/*.swift'
```

Der erste Befehl holt unsere Datei zurück, der zweite löscht Xcodes übrige Beispiel-Dateien (`StoppWidgetBundle.swift` usw.). `Info.plist` und `Assets.xcassets` bleiben, die brauchen wir.

🔨 **Xcode**: Prüf links im Ordner **StoppWidget**, dass nur noch `StoppWidget.swift` (unsere), `Assets.xcassets` und `Info.plist` zu sehen sind. Stehen dort noch rot markierte Dateien, klick sie mit Rechtsklick an → *Delete*.

### B6. Gemeinsame Dateien auch fürs Widget freigeben

🔨 **Xcode**:

1. Öffne links den Ordner **Gemeinsam** und klick auf **StoppAktion.swift**.
2. Blende rechts die Inspektor-Leiste ein (`⌥ ⌘ 0`) und klick auf das erste Symbol (Datei).
3. Unter **Target Membership** müssen zwei Haken gesetzt sein: **Runner** (ist schon gesetzt) **und StoppWidgetExtension** (dazuklicken).
4. Wiederhol die Schritte 1–3 für **StoppAktivitaet.swift**.

Falls die Gruppe *Gemeinsam* links fehlt: Rechtsklick auf *Runner* (oberster Eintrag) → *Add Files to "Runner"…* → Ordner `ios/Gemeinsam` wählen. Dabei *Create groups* wählen und beide Targets anhaken.

### B7. Widget-Target einstellen

🔨 **Xcode** → blaues **Runner**-Symbol → unter *TARGETS* **StoppWidgetExtension**:

1. Reiter **General**: Stell **Minimum Deployments** auf **17.0**.
2. Reiter **Signing & Capabilities**:
   - Bei **Team** dein Personal Team auswählen.
   - **Bundle Identifier** muss `com.hajspg.stoppapp.StoppWidget` sein.
   - **+ Capability** → **App Groups** → `group.com.hajspg.stoppapp` anhaken. Die Gruppe ist schon da, du musst nur den Haken setzen.

### B8. Build-Reihenfolge reparieren (bekannte Flutter-Falle)

🔨 **Xcode** → *TARGETS* **Runner** → Reiter **Build Phases**:

Zieh die Zeile **„Embed Foundation Extensions“** (oder „Embed App Extensions“) mit der Maus **nach oben, über „Run Script“**. Liegt sie darunter, bricht der Build mit „Cycle inside Runner“ ab.

### B9. Prüfen, ob alles baut

🔨 **Xcode**: Wähl oben in der Mitte das Schema **Runner** aus (nicht StoppWidgetExtension) und drück `⌘ B` (Build).

Erscheint oben „Build Succeeded“, ist Teil B fertig. Bei roten Fehlern mach einen Screenshot und schick ihn mir.

---

## Teil C: Auf das iPhone installieren

### C1. iPhone vorbereiten (nur beim ersten Mal)

1. 📱 Steck das iPhone per Kabel an den Mac und entsperr es. Fragt das iPhone „Diesem Computer vertrauen?“, tipp auf **Vertrauen** und gib den Code ein.
2. 🔨 **Xcode** → Menü *Window* → *Devices and Simulators*. Warte, bis dein iPhone erscheint und Xcode es „vorbereitet“ hat. Das kann ein paar Minuten dauern.
3. 📱 **Einstellungen → Datenschutz & Sicherheit → Entwicklermodus** einschalten. Das iPhone startet neu. Danach bestätigst du mit **Einschalten** und dem Code. Der Punkt „Entwicklermodus“ erscheint erst, nachdem das iPhone mit Xcode verbunden war.

### C2. App installieren

🖥 **Terminal** (im Ordner `~/StoppApp`, iPhone angesteckt und entsperrt):

```sh
flutter run --release
```

Flutter fragt eventuell, auf welches Gerät es installieren soll. Tipp dann die Nummer deines iPhones ein. Beim ersten Mal dauert der Build mehrere Minuten.

**Warum `--release`?** Eine Debug-Version startet auf dem iPhone nur, solange der Mac verbunden ist. Die Release-Version kannst du ganz normal vom Homescreen starten.

Ist die App installiert, darfst du im Terminal `q` drücken und das Kabel abstecken.

### C3. Dem Entwickler vertrauen (nur beim ersten Mal)

Beim ersten Start meldet das iPhone „Nicht vertrauenswürdiger Entwickler“.

📱 **Einstellungen → Allgemein → VPN & Geräteverwaltung** → unter *Entwickler-App* deine Apple-ID antippen → **Vertrauen**.

Danach startet die App.

### C4. Widget hinzufügen

📱 Drück lange auf eine freie Stelle am Homescreen → oben links **+** (bzw. *Bearbeiten → Widget hinzufügen*) → **StoppApp** suchen → die **kleine** Größe wählen → *Widget hinzufügen*.

### C5. Nach 7 Tagen

Mit einer kostenlosen Apple-ID läuft die App nach 7 Tagen ab und startet nicht mehr. Steck das iPhone dann wieder an und führ im **Terminal** wieder aus:

```sh
cd ~/StoppApp
```
```sh
flutter run --release
```

Deine Messungen bleiben dabei erhalten.

Neue Versionen der App holst du vorher mit:

```sh
git pull
```

---

## Prüfen

- Das Widget zeigt „Als Nächstes …“ mit **Start**. Tipp auf Start: Nach kurzer Zeit zeigt es „Läuft“ mit Zeit und **Stopp**.
- Während einer Messung erscheint die Live Activity auf dem Sperrbildschirm und in der Dynamic Island, jeweils mit **Stopp**.
- „Wählen“ bzw. „+“ öffnet die App bei „Kette für heute wählen“ bzw. „Einschieben“.
- Miss, wie lange es vom Tippen bis zur neuen Anzeige dauert (Spec Abschnitt 11).
- Tipp im Widget, während die App ganz geschlossen ist. Wird die Messung sofort angelegt oder erst beim nächsten Öffnen? Beides funktioniert (die Warteschlange fängt den Tipp auf), Ziel ist aber „sofort“. Passiert es erst beim Öffnen, sag mir Bescheid.

## Wenn etwas schiefgeht

| Meldung | Was tun |
|---|---|
| `flutter: command not found` | Teil A4, Schritt 2 noch einmal ausführen, oder das Terminal schließen und neu öffnen. |
| „Failed to register bundle identifier“ / „not available“ | Die ID `com.hajspg.stoppapp` ist bei Apple schon vergeben. Schreib mir, dann ändere ich die IDs im Projekt. |
| Fehler bei *App Groups* mit Personal Team | Mach einen Screenshot und schick ihn mir. Notfalls läuft die App auch ohne Widget: Entferne dazu das Target StoppWidgetExtension (*TARGETS* → Rechtsklick → *Delete*). |
| „Cycle inside Runner“ | Schritt B8. |
| „Untrusted Developer“ / App startet nicht | Schritt C3. |
| App startet nach ein paar Tagen nicht mehr | Schritt C5 (7-Tage-Grenze). |
| `pod install` schlägt fehl | Im Terminal `brew upgrade cocoapods`, danach `flutter clean` und `flutter pub get` ausführen und es noch einmal versuchen. |

## Welche Datei gehört zu welchem Target (für später)

| Datei | Target |
|---|---|
| `ios/Runner/AppDelegate.swift`, `ios/Runner/LiveAktivitaet.swift` | Runner |
| `ios/Gemeinsam/StoppAktion.swift`, `ios/Gemeinsam/StoppAktivitaet.swift` | Runner **und** StoppWidgetExtension |
| `ios/StoppWidget/StoppWidget.swift` | nur StoppWidgetExtension |
