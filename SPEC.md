# StoppApp – Spezifikation v1

Eine mobile Ein-Knopf-Stoppuhr für Ereignisketten, für Android und iPhone, für den persönlichen Gebrauch. Begriffe wie in [`GLOSSARY.md`](GLOSSARY.md), Architektur wie in [`docs/adr/`](docs/adr/).

**Stand:** 6. Nov 2026. Alles ist entschieden: Haupt-Screen, Kalender & Tagesprotokoll, Ereignis- & Ketten-Editor, Statistik, Navigation, Tech-Stack und Widget, Live Activity & Notification ([#10](https://github.com/HAJ-SPG/StoppApp/issues/10)). Export & Import gibt es nicht ([#9](https://github.com/HAJ-SPG/StoppApp/issues/9)). Die Annahmen aus dem ersten Build sind geklärt ([#12](https://github.com/HAJ-SPG/StoppApp/issues/12)) und in die Abschnitte eingearbeitet.

Jede Ansicht hat einen Wegwerf-Prototyp als Primärquelle. Bei Widerspruch gilt diese Spec, der Prototyp zeigt Aussehen und Verhalten im Detail:

| Bereich | Entscheidung | Prototyp (Variante) |
|---|---|---|
| Haupt-Screen | [#5](https://github.com/HAJ-SPG/StoppApp/issues/5) | [`prototype/haupt-screen`](https://github.com/HAJ-SPG/StoppApp/blob/prototype/haupt-screen/prototypes/haupt-screen/index.html) (A Fokus + B Zeitleiste) |
| Kalender & Tagesprotokoll | [#6](https://github.com/HAJ-SPG/StoppApp/issues/6) | [`prototype/kalender-tagesprotokoll`](https://github.com/HAJ-SPG/StoppApp/blob/prototype/kalender-tagesprotokoll/prototypes/kalender/index.html) (A Raster + Protokoll-Panel aus C) |
| Ereignis- & Ketten-Editor | [#7](https://github.com/HAJ-SPG/StoppApp/issues/7) | [`prototype/editor`](https://github.com/HAJ-SPG/StoppApp/blob/prototype/editor/prototypes/editor/index.html) (A Listen) |
| Statistik | [#8](https://github.com/HAJ-SPG/StoppApp/issues/8) | [`prototype/statistik`](https://github.com/HAJ-SPG/StoppApp/blob/prototype/statistik/prototypes/statistik/index.html) (A Übersicht → Detail) |
| Widget, Live Activity & Notification | [#10](https://github.com/HAJ-SPG/StoppApp/issues/10), geändert in [#12](https://github.com/HAJ-SPG/StoppApp/issues/12) | [`prototype/widget`](https://github.com/HAJ-SPG/StoppApp/blob/prototype/widget/prototypes/widget/index.html) (A Nur der Knopf, `#knopf`) |

## 1. Grundregeln

- Ein Klick startet, der nächste Klick stoppt. Zwischen zwei Messungen darf eine Lücke liegen, die nicht erfasst wird.
- Es läuft **höchstens eine Messung** zur gleichen Zeit.
- **Ereignisse** bilden eine eigenständige Bibliothek. Eine **Ereigniskette** besteht aus **Schritten**, jeder Schritt verweist auf ein Ereignis. Dasselbe Ereignis darf mehrfach in einer Kette vorkommen.
- Die **Tageskette** eines Datums ist seine Tagesausnahme, falls vorhanden, sonst die Kette aus der Wochenregel. Gibt es keine von beiden, hat der Tag keine Kette, und man wählt spontan.
- Eine **Messung** speichert Ereignis, Start, Stopp und den *Namen* der Tageskette, unter der sie entstand (nur zur Information). Ändert oder löscht man später Ketten oder Zuweisungen, ändert das **nie** bestehende Messungen.
- **Tageswechsel:** einstellbar, Standard 04:00. Ein Tag läuft vom Tageswechsel bis zum nächsten Tageswechsel. Eine Messung zählt zum Tag, an dem sie gestartet wurde. Eine unfertige Kette verfällt beim Tageswechsel, und gezählt wird nur, was gemessen wurde.
- Alle Daten liegen nur lokal auf dem Gerät. Es gibt kein Konto und keinen Sync.
- Die App ist durchgehend Deutsch. Sie ist nur für Smartphones gebaut, im Hochformat.

## 2. Navigation

Unten eine Tab-Leiste mit vier Tabs:

1. **Heute**: der Haupt-Screen, Start-Tab
2. **Kalender**: Kalender und Tagesprotokoll
3. **Statistik**
4. **Ketten**: Ketten und Ereignisse

**Einstellungen** öffnet man über ein Zahnrad oben rechts auf dem Tab „Heute“, als eigenen Screen mit Zurück.

## 3. Heute (Haupt-Screen)

Zwei umschaltbare Ansichten mit denselben Funktionen:

- **Fokus** (Standard): Oben steht „Als Nächstes“ bzw. „Läuft“, groß der Name des Ereignisses, darunter ein großer runder Button.
  - Unter dem Button: Fortschrittspunkte der Kette und „x von n erledigt · Danach: …“.
  - Im Leerlauf drei Textknöpfe: **Überspringen**, **Einschieben**, **Nächstes wählen**.
  - Während eine Messung läuft: **Zeit korrigieren**.
- **Zeitleiste**: chronologische Liste des Tages.
  - Gemessene Ereignisse mit Uhrzeit und Dauer, übersprungene Schritte durchgestrichen, eingeschobene Ereignisse markiert.
  - Die laufende Messung mit Live-Zeit, danach die kommenden Schritte. Ein kommender Schritt lässt sich antippen und wird damit zum nächsten.
  - Unten eine Leiste mit dem runden Button und der benannten Aktion („Arbeit fahren starten“).
- **Umschalten**: über einen Umschalter oben rechts neben dem Ketten-Chip, außerdem wechselt Hochwischen in Fokus zur Zeitleiste. Die App startet immer in Fokus. Ein Wechsel hält, bis man zurückschaltet oder die App neu startet.
- **Kopf**: Datum und Ketten-Chip (Name der Tageskette, antippen = „Kette für heute wählen“). Hat heute eine Tagesausnahme, bietet das Sheet auch „Wochenregel verwenden“.

**Zustände des Buttons**

| Zustand | Anzeige | Button |
|---|---|---|
| Keine Tageskette | „Heute ist keine Kette geplant“ | öffnet „Kette für heute wählen“. Gilt nur für heute und legt eine Tagesausnahme für heute an; die Wochenregel bleibt unverändert. |
| Bereit | „Als Nächstes: X“ | startet X |
| Läuft | „Läuft: X“ + Live-Zeit + „seit HH:MM“ | stoppt |
| Kette erledigt | „Fertig für heute“ | „+ Extra-Ereignis“ öffnet Einschieben |

**Aktionen**

- **Überspringen** markiert den nächsten Schritt als übersprungen.
- **Einschieben** startet sofort ein beliebiges Ereignis aus der Bibliothek oder ein neu angelegtes. Danach macht die Kette dort weiter, wo sie war. Einschieben geht auch an Tagen ohne Kette (dann ohne Kettennamen).
- **Nächstes wählen** zeigt die offenen und die übersprungenen Schritte. Der gewählte Schritt wird zum nächsten, und der große Button macht immer diesen Standardschritt. Die Wahl gilt für **einen** Start, danach ist wieder der erste offene Schritt dran. Wer den gewählten Schritt überspringt, hebt die Wahl auf.
- **Zeit korrigieren** öffnet ein Sheet bei laufender Messung:
  - „Gestoppt vor 2 / 5 / 10 / 15 / 30 Min“ stoppt mit Stopp = jetzt − X. Eine Stufe wird nur angeboten, wenn die Messung schon länger als X läuft.
  - „Begonnen vor 2 / 5 / 10 / 15 / 30 Min“ setzt Start = jetzt − X. Das darf den Start auch nach vorne schieben.
  - „Messung verwerfen“ löscht die Messung, und der Schritt ist wieder offen.
  - Korrekturen dürfen keine Überschneidung mit der vorigen Messung erzeugen. „Vorige Messung“ ist jede abgeschlossene Messung, die vor der laufenden begann. Start wird höchstens bis zu deren spätestem Stopp zurückgesetzt.
- **Rückgängig** (Hinweis ca. 5 s) gibt es nach Überspringen, Einschieben, Korrekturen und Kettenwahl. Start, Stopp und Nächstes wählen zeigen keinen Hinweis: Dort reicht der Button bzw. „Messung verwerfen“.

## 4. Kalender & Tagesprotokoll

**Monatsraster** (Mo–So) mit ‹ › für die Monate.
- Jede Zelle zeigt die Tageskette in ihrer Kettenfarbe.
- Ein **heller Ton** heißt „aus der Wochenregel“, eine **kräftige Füllung mit Punkt** heißt „Tagesausnahme“.
- **Heute** hat einen Rahmen. Vergangene Tage zeigen die gemessene Summe, kompakt als `25m` bzw. `1h05` (nur hier, sonst gilt das Dauerformat aus Abschnitt 6).
- **Vergangene Tage** zeigen die Kette, die tatsächlich gelaufen ist, nicht die heutige Wochenregel: zuerst eine Tagesausnahme des Tages, sonst die Kette aus seinem Tageslauf. Gibt es keinen Tageslauf (App an dem Tag nicht benutzt) oder wurde die Kette inzwischen gelöscht, bleibt die Zelle neutral ohne Kettenfarbe. Heute und künftige Tage zeigen die Tageskette.
- Darunter eine Legende.

**Tag antippen** wählt den Tag aus, und sein **Tagesprotokoll erscheint unter dem Raster**. Beim Öffnen ist heute ausgewählt.

**Kette eines Tages ändern:** über den Ketten-Chip im Kopf des Protokolls. Das Sheet bietet alle Ketten, „Keine Kette“ und, falls der Tag eine Ausnahme hat, „Wochenregel verwenden“. Auch vergangene Tage dürfen eine Ausnahme bekommen. Bestehende Messungen behalten ihren Kettennamen.

**Mehrere Tage:**
- **Auswählen**: einzelne Tage antippen.
- **Von–bis**: ersten und letzten Tag antippen. Ein dritter Tipp startet eine neue Spanne.
- Der Modus wird über einen Umschalter „Tag / Auswählen / Von–bis“ über dem Raster gewählt.
- Eine Aktionsleiste unten („n Tage · Kette …“) öffnet dasselbe Ketten-Sheet.

**Wochenregel:** Knopf oben, öffnet ein Sheet mit einer Auswahl je Wochentag (Kette oder „Keine Kette“). Ausnahmen bleiben bestehen.

**Tagesprotokoll**
- **Kopf**: Datum, Ketten-Chip, Anzahl Messungen, gemessene Summe, Summe der Lücken.
- **Liste**: chronologisch, mit Uhrzeit, Ereignis und Dauer. Messungen, die unter einem anderen Kettennamen entstanden sind, zeigen „gemessen unter …“. Verglichen wird mit dem Kettennamen des Tageslaufs, sonst mit der aktuellen Tageskette. Messungen ohne Kettennamen zeigen nichts.
- **Summe der Lücken** zählt alle Abstände zwischen aufeinanderfolgenden Messungen, auch unter 5 Min.
- **Lücken** ab 5 Min stehen sichtbar zwischen den Messungen, mit „+ nachtragen“. Das öffnet das Nachtragen mit Start und Stopp der Lücke vorbelegt.
- Am Ende: **„+ Messung nachtragen“**.
- **Messung antippen** öffnet das Sheet zum Bearbeiten: Ereignis, Start und Stopp. Die Messung behält ihren Tag. **Löschen** braucht einen zweiten Tipp zur Bestätigung.
- **Nachtragen und Schritte** (gilt auch, wenn man beim Bearbeiten das Ereignis ändert):
  - Hat das Ereignis im Tageslauf einen **übersprungenen** Schritt, erledigt die Nachtragung den ersten davon. Beispiel: Kette Aufstehen → Duschen → Frühstück → Duschen, das erste Duschen wurde übersprungen. Die Nachtragung „Duschen“ erledigt das erste Duschen, das zweite wird normal gemessen.
  - Hat das Ereignis heute nur einen noch **offenen** Schritt, ist Nachtragen dafür gesperrt, mit dem Hinweis „Erst überspringen oder normal messen“. Nachtragen heißt nachher eintragen, nicht vorab.
  - An vergangenen Tagen ist die Kette verfallen. Dort zählen offene Schritte wie übersprungene.
  - Kommt das Ereignis in der Kette nicht vor (oder hat der Tag keine Kette), ist Nachtragen frei, und die Messung zählt wie eingeschoben.
  - Löscht man die Nachtragung, ist der Schritt wieder übersprungen.
  - Der Kettenname der Nachtragung ist der Name aus dem Tageslauf des Tages, sonst der Name der aktuellen Tageskette.
- **Prüfung beim Speichern**: Stopp muss nach dem Start liegen, darf nicht in der Zukunft liegen und darf sich nicht mit einer anderen Messung überschneiden. Sonst gibt es eine Fehlermeldung, die die störende Messung nennt.
  - Uhrzeiten beziehen sich auf den Tag vom Tageswechsel bis zum nächsten Tageswechsel: Bei 04:00 bedeutet 01:30 den folgenden Kalendertag.
- **Die laufende Messung** ist sichtbar, wird aber nur auf dem Haupt-Screen korrigiert.
- **Zukünftige Tage** haben kein Protokoll, nur die Kettenzuweisung.
- **Rückgängig**: Jede Änderung zeigt einen Hinweis mit „Rückgängig“ (ca. 5 s). Rückgängig gilt nur für die jeweils letzte Änderung und verfällt mit der nächsten (überall in der App).

## 5. Ketten (Editor)

Zwei Tabs: **Ketten** und **Ereignisse**.

**Ketten-Tab**
- Liste der Ketten mit Farbe, Name, Anzahl Schritte, Verwendung (z. B. „Mo–Fr · 2 Ausnahmen“, gezählt werden alle Ausnahmen, vergangene und künftige; ohne Verwendung „nicht eingeplant“) und einer Vorschau der Schritte. Darunter „+ Neue Kette“.
- **Neue Kette**: Name und Farbe (6 Farben für den Kalender). Sie startet leer.

**Kette öffnen**
- Kopf mit Farbe und Name. Antippen öffnet das Sheet für Name und Farbe.
- Darunter, wo die Kette gilt, und die Schritte als nummerierte Liste.
- Mit dem **Ziehgriff ≡** sortiert man um, **×** entfernt einen Schritt. Kommt ein Ereignis mehrfach vor, steht „n× in der Kette“ daneben.
- **„+ Schritt hinzufügen“** öffnet eine Suche über die aktiven Ereignisse. Trifft die Eingabe kein Ereignis, bietet die Suche „+ „xyz“ als neues Ereignis anlegen“ an. Trifft sie ein archiviertes, bietet sie „wiederherstellen und einfügen“ an.
- **Menü ⋯**: Name und Farbe, Duplizieren (Name „… (Kopie)“, bei Kollision „… (Kopie 2)“ usw.; die Kopie steht direkt hinter dem Original), Kette löschen.
- **Läuft die Kette heute**, gelten Änderungen erst **ab morgen**. Der Editor weist darauf hin: „Heute läuft diese Kette (x von n erledigt). Änderungen gelten ab morgen.“

**Ereignisse-Tab**
- Aktive Ereignisse mit Verwendung („Arbeitstag ×2, Homeoffice · 301 Messungen“) und „+ Neues Ereignis“.
- Abschnitt **Archiviert** mit „Wiederherstellen“.
- **Ereignis antippen**: umbenennen, archivieren oder löschen.

**Regeln**
- Ereignis- und Kettennamen sind eindeutig, ohne Rücksicht auf Groß- und Kleinschreibung (auch bei Umlauten). Leerzeichen an den Rändern werden entfernt. Leere Namen sind nicht erlaubt.
- **Ereignis umbenennen**: Der neue Name gilt überall, auch in alten Messungen.
- **Kette umbenennen**: Alte Messungen behalten den Namen, unter dem sie gemessen wurden.
- **Ereignis entfernen**:
  - Mit Messungen wird es **archiviert**, nach Bestätigung. Es wird dabei aus allen Ketten entfernt, erscheint in keiner Auswahl mehr und bleibt in Messungen und Statistik sichtbar.
  - Ohne Messungen wird es **gelöscht**, ohne Rückfrage (Rückgängig möglich).
- **Kette löschen oder Ereignis archivieren** lässt den heutigen Tageslauf unverändert.
- **Kette löschen**:
  - Wird sie in der Wochenregel oder in Tagesausnahmen verwendet, fragt ein Sheet, welche Kette diese Tage stattdessen bekommen, oder „Keine Kette“.
  - Sonst genügt eine einfache Bestätigung.
  - Messungen bleiben erhalten.
- **Rückgängig** nach jeder Änderung.

## 6. Statistik

**Filter oben** (gelten für alles darunter):
- Zeitraum: **Woche / Monat / Jahr / Frei**.
  - Woche, Monat und Jahr sind Kalenderzeiträume mit ‹ ›, nicht über heute hinaus. Eine Woche läuft Mo–So.
  - Frei: Datum von und bis. Bis man einen Zeitraum wählt, gilt das laufende Jahr.
- **Tageskette**: „Alle Ketten“ oder eine Kette. Gefiltert wird nach dem Kettennamen an der Messung. Zur Auswahl stehen alle Kettennamen, die in Messungen vorkommen.
- **Wochentage** Mo–So zum An- und Abschalten. Sind alle aus, gelten alle.
- Darunter eine Zeile: „n Tage mit Messungen“ und, wenn Filter aktiv sind, „zurücksetzen“.

**Tab „Ereignisse“**: Liste aller Ereignisse mit Messungen im Filter, sortiert nach Summe. Jede Zeile zeigt Name, Anzahl, Summe, einen kleinen Verlauf und Ø.

**Detail** (Ereignis antippen, gleiche Filter):
- **Kennzahlen**: Ø, Median, Anzahl, Min, Max, Summe.
- **Verlauf**: Ø pro Tag als Linie, bei Zeiträumen über 45 Tage Ø pro Woche (ab Montag). Nur Tage bzw. Wochen mit Messungen erscheinen. Eine gestrichelte Linie zeigt den Median.
- **Uhrzeit**: Startzeit jeder Messung als Punkt über das Datum, dazu der Ø-Start als Etikett. Startzeiten werden als Minuten seit Tageswechsel gemittelt, damit der Ø nicht über Mitternacht springt.
- **Verteilung**: Histogramm der Dauer, ⌈√n⌉ gleich breite Klassen, begrenzt auf 5–12.
- **Nach Wochentag**: Ø-Dauer je Wochentag als Balken.

**Tab „Mein Tag“**: Ø Minuten pro Tag (bezogen auf Tage mit Messungen im Filter) je Ereignis als Balken, dazu die gemessene Ø-Summe pro Tag.

**Darstellung**
- Eine Datenfarbe, zurückhaltendes Raster.
- Tooltip beim Antippen eines Punkts oder Balkens.
- **Dauerformat** (überall in der App): unter 10 Min `m:ss Min`, unter 60 Min `n Min`, ab 60 Min `h h mm`.
- Die laufende Messung zählt nicht in die Statistik.

## 7. Einstellungen

- **Tageswechsel**: Uhrzeit 00:00–06:00 in 15-Minuten-Schritten, Standard 04:00. Eine Änderung gilt ab sofort für die Zuordnung neuer Messungen und für die Frage, welcher Tag heute ist. Bestehende Messungen behalten ihren Tag, ein bestehender Tageslauf bleibt unverändert.
- **Info**: App-Version.
- Es gibt keinen Export, keinen Import und keine Sicherung ([#9](https://github.com/HAJ-SPG/StoppApp/issues/9)). Wer die App löscht oder das Gerät wechselt, verliert die Daten. Das ist bewusst so.

## 8. Aussehen

- Gestaltung wie in den Prototypen:
  - Grundfläche leicht grünstichig, Grün für Start/Bereit, Rot für Stopp/Läuft.
  - Schriften: Bricolage Grotesque (Überschriften), Atkinson Hyperlegible (Text), IBM Plex Mono (Zahlen und Zeiten).
- **Dark Mode** folgt dem System. Die Farben stehen in den Prototypen unter `@media (prefers-color-scheme: dark)`.
- **Kettenfarben**: 6 feste Farben (Blau, Ocker, Violett, Grün, Beere, Schiefer) mit je einer hellen Variante für „Wochenregel“ im Kalender. Werte aus dem Editor-Prototyp, Tokens `--k1`…`--k6`.
- Ereignisse haben in v1 keine Farben und keine Icons.

## 9. Datenmodell (drift / SQLite)

Nur die App öffnet die Datenbank ([ADR 0002](docs/adr/0002-app-besitzt-datenbank.md)). Zeiten werden als UTC-Millisekunden gespeichert, Datumswerte (`tag`) als `YYYY-MM-DD` im Sinne des Tageswechsels.

| Tabelle | Felder | Hinweise |
|---|---|---|
| `ereignisse` | `id`, `name` (eindeutig, ohne Groß/Klein), `archiviert` (bool) | |
| `ketten` | `id`, `name` (eindeutig, ohne Groß/Klein), `farbe` (0–5), `sortierung` | |
| `schritte` | `id`, `kette_id` → ketten (cascade), `position`, `ereignis_id` → ereignisse | Positionen lückenlos ab 0 |
| `wochenregel` | `wochentag` (1=Mo … 7=So, PK), `kette_id` (nullable) | null = keine Kette |
| `tagesausnahmen` | `tag` (PK), `kette_id` (nullable) | null = „Keine Kette“ als Ausnahme |
| `messungen` | `id`, `ereignis_id`, `start`, `stopp` (nullable = läuft), `tag`, `kette_name` (nullable), `schritt_position` (nullable) | höchstens eine Zeile mit `stopp IS NULL` |
| `tageslaeufe` | `tag` (PK), `kette_id` (nullable), `kette_name`, `schritte` (JSON-Liste von `ereignis_id`), `naechster` (nullable, gewählte Position) | Schnappschuss der Kette für den Tag |
| `uebersprungen` | `tag`, `position` | PK (`tag`, `position`) |
| `einstellungen` | `schluessel`, `wert` | z. B. `tageswechsel = 240` (Minuten) |

- **Tageslauf**: Beim ersten Öffnen oder der ersten Aktion eines Tages wird die Tageskette als Schnappschuss in `tageslaeufe` gelegt. Deshalb gelten Änderungen am Editor erst ab morgen. Ändert man die Tageskette von heute (Ausnahme im Kalender oder „Kette für heute wählen“), wird der Tageslauf mit der neuen Kette neu angelegt. Gemessenes bleibt, und Schritte gelten als erledigt, wenn es eine Messung mit dieser `schritt_position` gibt.
  - Neu angelegt wird nur, wenn sich die Tageskette von heute wirklich ändert (andere Kette oder keine). Wählt man dieselbe Kette erneut, bleibt der Fortschritt. Beim Neuanlegen werden „übersprungen“ und `naechster` zurückgesetzt.
  - Eine geänderte **Wochenregel** legt den heutigen Tageslauf nicht neu an, sie gilt wie eine Editor-Änderung ab morgen. Nur Tagesausnahmen und „Kette für heute wählen“ erneuern ihn.
  - Hat ein Tag keine Tageskette, wird kein Tageslauf angelegt. Bekommt er später eine, gilt sie sofort.
  - Wird eine Kette gelöscht, wird `kette_id` in ihren Tagesläufen `null`; `kette_name` bleibt.
- **Schrittstatus** wird abgeleitet: *erledigt* = Messung mit `schritt_position`, *läuft* = laufende Messung mit `schritt_position`, *übersprungen* = Eintrag in `uebersprungen` (ohne Messung), sonst *offen*. Der nächste Schritt ist `naechster`, falls offen oder übersprungen, sonst der erste offene Schritt.
- **Eingeschobene** Messungen haben `schritt_position = null`. Nachgetragene ebenfalls, außer sie erledigen einen übersprungenen Schritt (Abschnitt 4).
- **IDs** vergibt die Fachlogik (höchste ID + 1), damit Rückgängig nach dem Löschen dieselben IDs wiederherstellt.
- **Migrationen**: drift `schemaVersion` mit schrittweisen Migrationen. v1 ist Version 1.
- **Widget-Schnappschuss und Warteschlange** (ADR 0002): siehe Abschnitt 11. Die Fachlogik meldet nach jeder Änderung „Zustand geändert“, daran hängt das Schreiben des Schnappschusses.

## 10. Architektur

- Flutter (Dart), iOS 17+ / Android 10+, Riverpod, drift ([ADR 0001](docs/adr/0001-flutter-stack.md)).
- Die **Fachlogik** liegt in reinem Dart ohne Flutter-Abhängigkeit, mit Unit-Tests: Tageskette auflösen, Tag aus Zeitpunkt + Tageswechsel, Tageslauf und Schrittstatus, Start/Stopp/Überspringen/Einschieben/Nächstes wählen, Korrekturen, Überschneidungsprüfung, Kette löschen mit Ersatz, Ereignis archivieren/löschen, Statistik (Ø, Median, Min, Max, Summe, Buckets, Histogramm, Wochentage, Tagesverteilung).
- **Uhr** über eine injizierbare Zeitquelle, damit Tests feste Zeiten nutzen.
- **Bundle-ID** / applicationId: `com.hajspg.stoppapp`. Sie bleibt stabil, weil iOS-Installationen mit kostenloser Apple-ID daran hängen.
- **Locale** `de_AT` für Datum und Uhrzeit.

## 11. Außerhalb der App: Widget, Live Activity, Notification

Variante **A · Nur der Knopf** ([#10](https://github.com/HAJ-SPG/StoppApp/issues/10), in [#12](https://github.com/HAJ-SPG/StoppApp/issues/12) von B auf A geändert). Außerhalb der App gibt es nur **Start** und **Stopp** des Standardschritts. Überspringen, Einschieben, Nächstes wählen und Kette wählen gehen nur in der App; wo nötig, öffnet ein Tipp die App an der passenden Stelle.

**Homescreen-Widget:** nur klein (iOS small / Android 2×2), auf beiden Plattformen gleich.

| Zustand | Anzeige | Knopf |
|---|---|---|
| Bereit | „Als Nächstes“, Name, „x von n“ | **Start** |
| Läuft | „Läuft“, Name, Live-Zeit | **Stopp** |
| Keine Kette | „Keine Kette“ | **Wählen** öffnet die App bei „Kette für heute wählen“ |
| Kette erledigt | Kettenname, „Erledigt“, „x von n“ | **+** öffnet die App bei Einschieben |

**iOS-Live-Activity:** nur während einer Messung. Inhalt: „StoppApp“, Name, Live-Zeit, Knopf **Stopp**. Dynamic Island kompakt: roter Punkt, Name, Zeit. Stopp beendet die Live Activity. Läuft eine Live Activity länger als 8 h, startet die App sie beim nächsten Öffnen neu ([ADR 0001](docs/adr/0001-flutter-stack.md)).

**Android-Notification:** nur während einer Messung, dauerhaft. Inhalt: „StoppApp · Kette“, Name, „läuft seit HH:MM“ mit Chronometer, Aktion **STOPP**. Wird sie weggewischt (Android 14+), legt die App sie beim nächsten Öffnen neu an.

**Widget-Schnappschuss** ([ADR 0002](docs/adr/0002-app-besitzt-datenbank.md)): Die App schreibt ihn nach jeder Änderung als JSON unter einem einzigen Schlüssel (App Group bzw. SharedPreferences). Felder: `tag`, `zustand` (`keine|bereit|laeuft|erledigt`), `kette`, `laufend` (`ereignis`, `start` als UTC-ms, `schritt_position`), `naechstes` (`ereignis`, `schritt_position`), `erledigt`, `schritte_gesamt`.
- Die Live-Zeit rechnen Widget und Live Activity selbst aus `start` (`Text(timerInterval:)` bzw. Chronometer).
- Keine optimistische Anzeige: Die Anzeige ändert sich, sobald die App den neuen Schnappschuss geschrieben hat. Im ersten Build prüfen, ob die Verzögerung spürbar ist.

**Warteschlange:** Ein Eintrag hält `aktion` (`start|stopp`), `zeitpunkt` (UTC-ms, Moment des Tippens), `quelle` (`widget|live_activity|notification`) und die `schritt_position`, die der Schnappschuss beim Tippen zeigte.
- Wacht die App im Hintergrund auf, wendet sie die Aktion sofort an. Die Warteschlange ist nur der Rückfall.
- Die App arbeitet Einträge der Reihe nach mit ihrem eigenen Zeitpunkt ab.
- Ein Eintrag, der nicht mehr zum Zustand passt (andere Position, Stopp ohne laufende Messung, Doppeltipp), wird verworfen.

## 12. Nicht in v1

- Cloud-Sync, Konto, Veröffentlichung in Stores, Ziele/Streaks, Tablet und Web.
- Export, Import und Sicherung ([#9](https://github.com/HAJ-SPG/StoppApp/issues/9)).
- Mittleres Widget, „Weiter“ (stoppen und nächsten Schritt sofort starten) und Überspringen außerhalb der App (Variante B aus [#10](https://github.com/HAJ-SPG/StoppApp/issues/10), verworfen).
