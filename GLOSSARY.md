# StoppApp

Eine mobile App, mit der man die Dauer wiederkehrender Tagesabläufe per Ein-Knopf-Bedienung misst.

## Sprache

**Ereignis**:
Eine benannte Tätigkeit, deren Dauer gemessen werden soll (z. B. „Zähneputzen“, „Arbeit fahren“). Existiert unabhängig von Ereignisketten und kann in mehreren davon vorkommen.
_Avoid_: Aktivität, Task, Aufgabe

**Ereigniskette**:
Eine geordnete Folge von Ereignissen, die an einem Tag nacheinander gemessen werden.
_Avoid_: Liste, Routine, Ablauf

**Schritt**:
Eine Position in einer Ereigniskette, die auf genau ein Ereignis verweist. Dasselbe Ereignis kann in mehreren Schritten einer Kette vorkommen.
_Avoid_: Eintrag, Glied, Item

**Messung**:
Ein einzelner Zeitraum von Start bis Stopp, der genau einem Ereignis zugeordnet ist. Zwischen zwei Messungen darf eine nicht erfasste Lücke liegen. Vermerkt den Namen der Tageskette, unter der sie entstand, hängt aber nicht von ihr ab.
_Avoid_: Eintrag, Session, Stoppung

**Tagesprotokoll**:
Alle Messungen eines Datums in zeitlicher Reihenfolge, einschließlich nachträglich bearbeiteter oder nachgetragener.
_Avoid_: Verlauf, Log, Tagebuch

## Planung

**Wochenregel**:
Die Standardzuordnung einer Ereigniskette zu einem Wochentag (z. B. Mo–Fr = „Arbeitstag“).
_Avoid_: Wiederholung, Serie, Vorlage

**Tagesausnahme**:
Eine Zuordnung einer Ereigniskette zu einem konkreten Datum, die die Wochenregel für diesen Tag überschreibt.
_Avoid_: Override, Sonderfall

**Tageskette**:
Die Ereigniskette, die an einem bestimmten Datum gilt: die Tagesausnahme, falls vorhanden, sonst die Wochenregel.
_Avoid_: aktive Kette, Tagesplan

**Tageslauf**:
Der Schnappschuss der Tageskette für ein Datum samt Fortschritt (erledigte, übersprungene, gewählte Schritte). Änderungen an der Ereigniskette wirken erst auf den Tageslauf des nächsten Tages.
_Avoid_: Session, Durchlauf
