import 'package:drift/drift.dart';

part 'datenbank.g.dart';

@DataClassName('EreignisZeile')
class Ereignisse extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text().customConstraint('NOT NULL UNIQUE COLLATE NOCASE')();
  BoolColumn get archiviert => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('KetteZeile')
class Ketten extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text().customConstraint('NOT NULL UNIQUE COLLATE NOCASE')();
  IntColumn get farbe => integer()();
  IntColumn get sortierung => integer()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SchrittZeile')
class Schritte extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ketteId => integer().references(Ketten, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  IntColumn get ereignisId => integer().references(Ereignisse, #id)();
}

@DataClassName('WochenregelZeile')
class Wochenregel extends Table {
  IntColumn get wochentag => integer()();
  IntColumn get ketteId => integer().nullable()();
  @override
  Set<Column> get primaryKey => {wochentag};
}

@DataClassName('TagesausnahmeZeile')
class Tagesausnahmen extends Table {
  TextColumn get tag => text()();
  IntColumn get ketteId => integer().nullable()();
  @override
  Set<Column> get primaryKey => {tag};
}

@DataClassName('MessungZeile')
class Messungen extends Table {
  IntColumn get id => integer()();
  IntColumn get ereignisId => integer()();

  /// UTC-Millisekunden.
  IntColumn get start => integer()();
  IntColumn get stopp => integer().nullable()();
  TextColumn get tag => text()();
  TextColumn get ketteName => text().nullable()();
  IntColumn get schrittPosition => integer().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TageslaufZeile')
class Tageslaeufe extends Table {
  TextColumn get tag => text()();
  IntColumn get ketteId => integer().nullable()();
  TextColumn get ketteName => text()();

  /// JSON-Liste von `ereignis_id`.
  TextColumn get schritte => text()();
  IntColumn get naechster => integer().nullable()();
  @override
  Set<Column> get primaryKey => {tag};
}

@DataClassName('UebersprungenZeile')
class Uebersprungen extends Table {
  TextColumn get tag => text()();
  IntColumn get position => integer()();
  @override
  Set<Column> get primaryKey => {tag, position};
}

@DataClassName('EinstellungZeile')
class Einstellungen extends Table {
  TextColumn get schluessel => text()();
  TextColumn get wert => text()();
  @override
  Set<Column> get primaryKey => {schluessel};
}

@DriftDatabase(tables: [
  Ereignisse,
  Ketten,
  Schritte,
  Wochenregel,
  Tagesausnahmen,
  Messungen,
  Tageslaeufe,
  Uebersprungen,
  Einstellungen,
])
class StoppDatenbank extends _$StoppDatenbank {
  StoppDatenbank(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await customStatement('CREATE INDEX messungen_tag ON messungen (tag)');
          // höchstens eine laufende Messung
          await customStatement(
              'CREATE UNIQUE INDEX messungen_eine_laufende ON messungen ((stopp IS NULL)) WHERE stopp IS NULL');
        },
        // Schrittweise Migrationen ab Version 2 kommen hierher:
        // onUpgrade: stepByStep(from1To2: ...)
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
