# Build-Notizen v1

Bau-Runde vom 6. Nov 2026 auf Branch `build/v1`, Draft-PR [#11](https://github.com/HAJ-SPG/StoppApp/pull/11).

## Stand

| Prüfung | Ergebnis |
|---|---|
| `flutter analyze` | keine Probleme |
| `flutter test` | 81 Tests grün (Fachlogik, drift-Rundreise, Widget-Smoke-Tests) |
| `flutter build apk --debug` | **nicht ausgeführt**: Kein Android-SDK in der Cloud-Umgebung, und deren Netzwerk sperrt `dl.google.com`, wo SDK und Google-Maven liegen |
| iOS-Build | nicht möglich (braucht einen Mac) |

Flutter 3.47.9 (stable), Dart 3.13.7.

## Was fertig ist

**Fachlogik** (`lib/domain/`, reines Dart ohne Flutter, mit Unit-Tests in `test/domain/`)
- `Tag` und Tageswechsel: Tag aus Zeitpunkt, Tagesbeginn/-ende, Uhrzeit im Tag (01:30 bei 04:00 = folgender Kalendertag).
- Tageskette auflösen (Tagesausnahme → Wochenregel → keine).
- Tageslauf als Schnappschuss, abgeleiteter Schrittstatus (offen, läuft, erledigt, übersprungen), nächster Schritt.
- Start, Stopp, Überspringen, Einschieben (auch mit neuem Ereignis), Nächstes wählen.
- Korrekturen: Gestoppt vor, Begonnen vor (begrenzt durch die vorige Messung), Messung verwerfen.
- Tagesprotokoll mit Lücken und Summen, Prüfung beim Speichern (Stopp nach Start, nicht in der Zukunft, keine Überschneidung; die Meldung nennt die störende Messung).
- Editor-Regeln: eindeutige Namen ohne Rücksicht auf Groß/Klein, Ereignis archivieren oder löschen, Kette löschen mit Ersatz, Duplizieren, Schritte hinzufügen, verschieben und entfernen, Verwendungstexte („Mo–Fr · 2 Ausnahmen“, „Arbeitstag ×2 · 301 Messungen“).
- Statistik: Filter, Kennzahlen (Ø, Median, Anzahl, Min, Max, Summe), Verlauf pro Tag bzw. ab 46 Tagen pro Woche, Uhrzeit mit Ø-Start, Histogramm mit 5–12 Klassen, Wochentage, „Mein Tag“.
- Dauerformat `m:ss Min` / `n Min` / `h h mm`.
- Rückgängig für die jeweils letzte Änderung.
- Injizierbare `Uhr` (`SystemUhr`, `FesteUhr` für Tests).
- **„Zustand geändert“**: `StoppDienst.beobachten(...)` meldet jede Änderung. Hier hängt später der Widget-Schnappschuss (#10) an.

**Daten** (`lib/data/`)
- drift-Schema v1 nach Spec Abschnitt 9 (`ereignisse`, `ketten`, `schritte`, `wochenregel`, `tagesausnahmen`, `messungen`, `tageslaeufe`, `uebersprungen`, `einstellungen`). Zeiten in UTC-Millisekunden, `tag` als `YYYY-MM-DD`.
- Eindeutige Namen per `UNIQUE COLLATE NOCASE`, höchstens eine laufende Messung per partiellem Unique-Index, `schritte` mit Cascade auf `ketten`.
- `DriftSpeicher` lädt beim Start alles und schreibt danach nur die Unterschiede zweier Datenbestände, jeweils in einer Transaktion.
- Generierter Code (`datenbank.g.dart`) ist eingecheckt. Neu erzeugen mit `dart run build_runner build`.

**State** (`lib/state/providers.dart`): Riverpod 3. `dienstProvider` wird in `main.dart` überschrieben, `datenProvider` folgt den Meldungen, dazu Sekunden- und Minutentakt, Heute-Zustand, Ansicht (Fokus/Zeitleiste) und Statistik-Filter.

**Screens** (`lib/ui/`, Screenshots in [`docs/screenshots/`](screenshots/))
- Tab-Leiste: Heute, Kalender, Statistik, Ketten. Einstellungen über das Zahnrad auf „Heute“.
- Heute: Fokus und Zeitleiste mit allen vier Button-Zuständen, Fortschrittspunkten, „x von n erledigt · Danach: …“, Überspringen, Einschieben, Nächstes wählen, Zeit korrigieren. Hochwischen öffnet die Zeitleiste, der Umschalter steht oben rechts. Die App startet immer in Fokus.
- Kalender: Monatsraster mit Kettenfarben (hell = Wochenregel, kräftig mit Punkt = Ausnahme), Rahmen für heute, Summen vergangener Tage, Legende. Darunter das Tagesprotokoll mit Ketten-Chip, Lücken mit „+ nachtragen“, „+ Messung nachtragen“, Bearbeiten-Sheet und Löschen mit zweitem Tipp. Mehrere Tage über „Auswählen“ und „Von–bis“, dazu das Wochenregel-Sheet.
- Ketten: Ketten-Tab mit Verwendung und Vorschau, Kette mit Ziehgriff, ×, „n× in der Kette“, Suche mit Neu-Anlegen und Wiederherstellen, Menü ⋯ und Hinweis „Heute läuft diese Kette …“. Ereignisse-Tab mit Archiv.
- Statistik: Woche/Monat/Jahr/Frei mit ‹ › (nicht über heute hinaus), Ketten- und Wochentagsfilter, „n Tage mit Messungen · zurücksetzen“, Ereignisliste mit Mini-Verlauf, Detail mit vier Diagrammen (fl_chart) und Tooltips, „Mein Tag“.
- Einstellungen: Tageswechsel 00:00–06:00 in 15-Minuten-Schritten, App-Version.
- Aussehen: Farben aus den Prototypen inkl. Dark Mode, Schriften Bricolage Grotesque, Atkinson Hyperlegible und IBM Plex Mono liegen in `assets/fonts/` (OFL-Lizenzen daneben).
- Plattform: `com.hajspg.stoppapp`, nur Hochformat, Android `minSdk 29` (Android 10), iOS 17.0, nur iPhone. Locale `de_AT`.

## Was fehlt

- Laut Auftrag nicht gebaut: Homescreen-Widget, Live Activity, Notification (#10), Export und Import (#9), Swift-Code.
- **Kein APK-Build geprüft.** Freischalten ließe sich das in den Netzwerkeinstellungen der Cloud-Umgebung (Hosts `dl.google.com` und `maven.google.com`) oder lokal mit `flutter build apk --debug`.
- Nicht auf echten Geräten getestet: Gefühl der Gesten, Tastatur über Sheets, Performance mit vielen Messungen.
- Kein App-Icon und kein Splash (Flutter-Standard).
- Die Widget-Tests nutzen die Testschrift von Flutter. Screenshots mit den echten Schriften entstanden über einen Hilfstest, der nicht eingecheckt ist.

## Annahmen

Wo die Spec offen war, habe ich die einfachste passende Lösung gewählt.

> **Geklärt in [#12](https://github.com/HAJ-SPG/StoppApp/issues/12):** Alle Annahmen sind in `SPEC.md` übernommen, **außer 7 und 13**, die geändert wurden: Nachtragungen erledigen einen übersprungenen Schritt (Abschnitt 4 „Nachtragen und Schritte“), vergangene Kalendertage zeigen die tatsächlich gelaufene Kette (Abschnitt 4). Die Spec gilt.

1. **Tag ohne Tageskette:** Es wird kein Tageslauf angelegt. Bekommt der Tag später eine Kette (Wochenregel oder „Kette für heute wählen“), gilt sie sofort.
2. **Tageslauf neu anlegen** nur, wenn sich die Tageskette von heute wirklich ändert (andere Kette oder keine). Wählt man dieselbe Kette erneut, bleibt der Fortschritt. Beim Neuanlegen werden „übersprungen“ und die gewählte Position zurückgesetzt. Erledigt bleibt, was eine Messung mit dieser `schritt_position` hat.
3. **Wochenregel ändern** legt den Tageslauf von heute nicht neu an. Es wirkt wie eine Editor-Änderung ab morgen. Nur Ausnahmen und „Kette für heute wählen“ erneuern den heutigen Tageslauf.
4. **Kette löschen oder Ereignis archivieren** lässt den Tageslauf von heute unverändert (Schnappschuss).
5. **Nächstes wählen** gilt für einen Start. Danach ist wieder der erste offene Schritt dran. Wer den gewählten Schritt überspringt, hebt die Wahl auf.
6. **Einschieben** geht auch an Tagen ohne Kette („spontan wählen“). `kette_name` ist dann leer.
7. **Nachgetragene Messungen** haben `schritt_position = null` und erledigen also keinen Schritt. `kette_name` ist der Name aus dem Tageslauf des Tages, sonst der Name der aktuellen Tageskette.
8. **Bearbeitete Messungen** behalten ihren `tag`. Start und Stopp werden im Sheet als Uhrzeiten des Protokolltags eingegeben (Tageswechsel-Regel, „+1 Tag“ wird angezeigt).
9. **Begonnen vor X:** „Vorige Messung“ heißt jede abgeschlossene Messung, die vor der laufenden begann. Der Start wird höchstens bis zu deren spätestem Stopp zurückgesetzt. „Begonnen vor“ darf den Start auch nach vorne schieben.
10. **Gestoppt vor X** wird nur angeboten, wenn die Messung schon länger als X läuft.
11. **Summe der Lücken** zählt alle Abstände zwischen aufeinanderfolgenden Messungen, auch unter 5 Min. Als Zeile sichtbar sind nur Lücken ab 5 Min.
12. **„gemessen unter …“** vergleicht mit dem Kettennamen des Tageslaufs, sonst mit der aktuellen Tageskette. Messungen ohne Kettennamen zeigen nichts.
13. **Kalenderfarben vergangener Tage** kommen aus der aktuellen Wochenregel und den Ausnahmen, nicht aus dem damaligen Tageslauf.
14. **Kalenderzelle:** Die Tagessumme steht kompakt als `25m` bzw. `1h05`, weil das volle Dauerformat nicht in die Zelle passt. Überall sonst gilt das Dauerformat der Spec. Die Live-Zeit läuft als `mm:ss` bzw. `h:mm:ss`.
15. **Duplizieren:** „… (Kopie)“, bei Kollision „… (Kopie 2)“ usw. Die Kopie steht direkt hinter dem Original.
16. **Namen** werden an den Rändern von Leerzeichen befreit. Groß/Klein vergleicht die Fachlogik per `toLowerCase` (auch Umlaute), die Datenbank zusätzlich mit `NOCASE` (nur ASCII).
17. **Rückgängig** gilt für die jeweils letzte Änderung und verfällt mit der nächsten. Technisch wird der vorige Datenbestand wiederhergestellt. Auf „Heute“ zeigen Start, Stopp und Nächstes wählen keinen Hinweis (dort reicht der Button bzw. „Messung verwerfen“). Überspringen, Einschieben, Korrekturen und Kettenwahl zeigen ihn.
18. **Ereignis ohne Messungen** wird ohne Rückfrage gelöscht (Rückgängig möglich). Archivieren fragt nach, wie in der Spec.
19. **Verwendung einer Kette** zählt alle Ausnahmen, vergangene und künftige. Ohne Verwendung steht „nicht eingeplant“.
20. **Statistik:** Woche = Mo–So. „Frei“ startet mit dem laufenden Jahr, bis man einen Zeitraum wählt. Der Verlauf zeigt nur Tage/Wochen mit Messungen, Wochen beginnen am Montag. Histogramm: ⌈√n⌉ Klassen, begrenzt auf 5–12, gleich breit. Startzeiten werden als Minuten seit Tageswechsel gemittelt, damit der Ø nicht über Mitternacht springt. Der Ø-Start steht als Etikett im Diagramm, weil das Streudiagramm von fl_chart keine Zusatzlinien kann.
21. **Tageswechsel ändern** wirkt sofort auf die Frage „welcher Tag ist heute“. Ein bestehender Tageslauf bleibt unverändert.
22. **IDs** vergibt die Fachlogik (höchste ID + 1), damit Rückgängig auch nach Löschen dieselben IDs wiederherstellt.
23. **Mehrfachauswahl im Kalender:** Umschalter „Tag / Auswählen / Von–bis“ über dem Raster. Bei „Von–bis“ startet ein dritter Tipp eine neue Spanne.
24. **Ketten-Chip auf „Heute“** bietet auch „Wochenregel verwenden“, wenn heute eine Ausnahme hat.

## Architektur in Kürze

```
lib/domain/   reines Dart: Modelle, Datenbestand, StoppDienst, Statistik
lib/data/     drift-Datenbank + DriftSpeicher (implementiert domain.Speicher)
lib/state/    Riverpod-Provider
lib/ui/       Screens, Theme, gemeinsame Sheets
```

Die App hält den ganzen Datenbestand im Speicher. `StoppDienst` rechnet ihn bei jeder Aktion in einen neuen um, meldet „Zustand geändert“ und lässt `DriftSpeicher` die Unterschiede schreiben. Das hält die Fachlogik ohne Datenbank testbar und macht Rückgängig einfach.

## Nächste Schritte

1. Android-Build lokal (`flutter build apk --debug`) und auf dem Gerät testen, danach iOS über Xcode.
2. Gesten und Sheets auf echten Geräten prüfen, vor allem Hochwischen, Ziehgriff und die Tastatur.
3. #10 entscheiden und an `StoppDienst.beobachten` den Widget-Schnappschuss und die Warteschlange (ADR 0002) anbinden.
4. #9 Export/Import in die Einstellungen.
5. App-Icon und Splash.
6. Bei sehr vielen Messungen (mehrere Jahre) die Ladezeit messen. Falls nötig, Messungen gezielt laden statt alles in den Speicher.
7. Annahmen oben gegenlesen und, wo nötig, in die Spec übernehmen.
