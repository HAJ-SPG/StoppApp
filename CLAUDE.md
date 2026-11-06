# StoppApp – Anweisungen für Agenten

Lies zuerst `SPEC.md`, `GLOSSARY.md` und `docs/adr/`. Begriffe aus dem Glossar konsequent verwenden, auch im Code (z. B. `Messung`, `Ereigniskette`, `Tageslauf`).

## Bau-Runde v1 (über Nacht, ohne Menschen)

- Arbeite auf Branch `build/v1`. Committe nach jedem Meilenstein und pushe sofort, damit nichts verloren geht. Öffne früh einen Draft-PR nach `main` und halte seine Beschreibung aktuell.
- Flutter installieren, falls nicht vorhanden: `git clone https://github.com/flutter/flutter.git -b stable --depth 1 ~/flutter` und `export PATH="$HOME/flutter/bin:$PATH"`. Klappt das nicht, schreibe trotzdem den Code und vermerke es.
- Projekt im Repo-Wurzelverzeichnis: `flutter create --org com.hajspg --project-name stoppapp --platforms android,ios .`
- Reihenfolge:
  1. Fachlogik in reinem Dart (`lib/domain/`), test-first (Skill `tdd`).
  2. drift-Datenbank + Repositories (`lib/data/`).
  3. Riverpod-Provider.
  4. Screens: Heute, Kalender, Ketten, Statistik, Einstellungen, Tab-Navigation.
- Fertig heißt: `flutter analyze` ohne Fehler und `flutter test` grün. Wenn ein Android-SDK verfügbar ist, zusätzlich `flutter build apk --debug`.
- **Keine Produktentscheidungen treffen.** Ist etwas in der Spec unklar, nimm die einfachste Lösung, die zur Spec passt, und schreibe sie unter „Annahmen“ in `docs/build-notes.md`.
- **Widget, Live Activity, Notification:** nach `SPEC.md` Abschnitt 11 (Variante A, nur Start/Stopp). Swift-Code ist in der Cloud nicht baubar. **Export/Import gibt es nicht** (#9).
- Am Ende in `docs/build-notes.md`: was fertig ist, was fehlt, Annahmen, nächste Schritte.
