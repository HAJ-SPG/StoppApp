// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'datenbank.dart';

// ignore_for_file: type=lint
class $EreignisseTable extends Ereignisse
    with TableInfo<$EreignisseTable, EreignisZeile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EreignisseTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE COLLATE NOCASE',
  );
  static const VerificationMeta _archiviertMeta = const VerificationMeta(
    'archiviert',
  );
  @override
  late final GeneratedColumn<bool> archiviert = GeneratedColumn<bool>(
    'archiviert',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archiviert" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, archiviert];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ereignisse';
  @override
  VerificationContext validateIntegrity(
    Insertable<EreignisZeile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('archiviert')) {
      context.handle(
        _archiviertMeta,
        archiviert.isAcceptableOrUnknown(data['archiviert']!, _archiviertMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EreignisZeile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EreignisZeile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      archiviert: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archiviert'],
      )!,
    );
  }

  @override
  $EreignisseTable createAlias(String alias) {
    return $EreignisseTable(attachedDatabase, alias);
  }
}

class EreignisZeile extends DataClass implements Insertable<EreignisZeile> {
  final int id;
  final String name;
  final bool archiviert;
  const EreignisZeile({
    required this.id,
    required this.name,
    required this.archiviert,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['archiviert'] = Variable<bool>(archiviert);
    return map;
  }

  EreignisseCompanion toCompanion(bool nullToAbsent) {
    return EreignisseCompanion(
      id: Value(id),
      name: Value(name),
      archiviert: Value(archiviert),
    );
  }

  factory EreignisZeile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EreignisZeile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      archiviert: serializer.fromJson<bool>(json['archiviert']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'archiviert': serializer.toJson<bool>(archiviert),
    };
  }

  EreignisZeile copyWith({int? id, String? name, bool? archiviert}) =>
      EreignisZeile(
        id: id ?? this.id,
        name: name ?? this.name,
        archiviert: archiviert ?? this.archiviert,
      );
  EreignisZeile copyWithCompanion(EreignisseCompanion data) {
    return EreignisZeile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      archiviert: data.archiviert.present
          ? data.archiviert.value
          : this.archiviert,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EreignisZeile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('archiviert: $archiviert')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, archiviert);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EreignisZeile &&
          other.id == this.id &&
          other.name == this.name &&
          other.archiviert == this.archiviert);
}

class EreignisseCompanion extends UpdateCompanion<EreignisZeile> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> archiviert;
  const EreignisseCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.archiviert = const Value.absent(),
  });
  EreignisseCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.archiviert = const Value.absent(),
  }) : name = Value(name);
  static Insertable<EreignisZeile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? archiviert,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (archiviert != null) 'archiviert': archiviert,
    });
  }

  EreignisseCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<bool>? archiviert,
  }) {
    return EreignisseCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      archiviert: archiviert ?? this.archiviert,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (archiviert.present) {
      map['archiviert'] = Variable<bool>(archiviert.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EreignisseCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('archiviert: $archiviert')
          ..write(')'))
        .toString();
  }
}

class $KettenTable extends Ketten with TableInfo<$KettenTable, KetteZeile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KettenTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE COLLATE NOCASE',
  );
  static const VerificationMeta _farbeMeta = const VerificationMeta('farbe');
  @override
  late final GeneratedColumn<int> farbe = GeneratedColumn<int>(
    'farbe',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortierungMeta = const VerificationMeta(
    'sortierung',
  );
  @override
  late final GeneratedColumn<int> sortierung = GeneratedColumn<int>(
    'sortierung',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, farbe, sortierung];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ketten';
  @override
  VerificationContext validateIntegrity(
    Insertable<KetteZeile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('farbe')) {
      context.handle(
        _farbeMeta,
        farbe.isAcceptableOrUnknown(data['farbe']!, _farbeMeta),
      );
    } else if (isInserting) {
      context.missing(_farbeMeta);
    }
    if (data.containsKey('sortierung')) {
      context.handle(
        _sortierungMeta,
        sortierung.isAcceptableOrUnknown(data['sortierung']!, _sortierungMeta),
      );
    } else if (isInserting) {
      context.missing(_sortierungMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KetteZeile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KetteZeile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      farbe: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}farbe'],
      )!,
      sortierung: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sortierung'],
      )!,
    );
  }

  @override
  $KettenTable createAlias(String alias) {
    return $KettenTable(attachedDatabase, alias);
  }
}

class KetteZeile extends DataClass implements Insertable<KetteZeile> {
  final int id;
  final String name;
  final int farbe;
  final int sortierung;
  const KetteZeile({
    required this.id,
    required this.name,
    required this.farbe,
    required this.sortierung,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['farbe'] = Variable<int>(farbe);
    map['sortierung'] = Variable<int>(sortierung);
    return map;
  }

  KettenCompanion toCompanion(bool nullToAbsent) {
    return KettenCompanion(
      id: Value(id),
      name: Value(name),
      farbe: Value(farbe),
      sortierung: Value(sortierung),
    );
  }

  factory KetteZeile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KetteZeile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      farbe: serializer.fromJson<int>(json['farbe']),
      sortierung: serializer.fromJson<int>(json['sortierung']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'farbe': serializer.toJson<int>(farbe),
      'sortierung': serializer.toJson<int>(sortierung),
    };
  }

  KetteZeile copyWith({int? id, String? name, int? farbe, int? sortierung}) =>
      KetteZeile(
        id: id ?? this.id,
        name: name ?? this.name,
        farbe: farbe ?? this.farbe,
        sortierung: sortierung ?? this.sortierung,
      );
  KetteZeile copyWithCompanion(KettenCompanion data) {
    return KetteZeile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      farbe: data.farbe.present ? data.farbe.value : this.farbe,
      sortierung: data.sortierung.present
          ? data.sortierung.value
          : this.sortierung,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KetteZeile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('farbe: $farbe, ')
          ..write('sortierung: $sortierung')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, farbe, sortierung);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KetteZeile &&
          other.id == this.id &&
          other.name == this.name &&
          other.farbe == this.farbe &&
          other.sortierung == this.sortierung);
}

class KettenCompanion extends UpdateCompanion<KetteZeile> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> farbe;
  final Value<int> sortierung;
  const KettenCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.farbe = const Value.absent(),
    this.sortierung = const Value.absent(),
  });
  KettenCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int farbe,
    required int sortierung,
  }) : name = Value(name),
       farbe = Value(farbe),
       sortierung = Value(sortierung);
  static Insertable<KetteZeile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? farbe,
    Expression<int>? sortierung,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (farbe != null) 'farbe': farbe,
      if (sortierung != null) 'sortierung': sortierung,
    });
  }

  KettenCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? farbe,
    Value<int>? sortierung,
  }) {
    return KettenCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      farbe: farbe ?? this.farbe,
      sortierung: sortierung ?? this.sortierung,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (farbe.present) {
      map['farbe'] = Variable<int>(farbe.value);
    }
    if (sortierung.present) {
      map['sortierung'] = Variable<int>(sortierung.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KettenCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('farbe: $farbe, ')
          ..write('sortierung: $sortierung')
          ..write(')'))
        .toString();
  }
}

class $SchritteTable extends Schritte
    with TableInfo<$SchritteTable, SchrittZeile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchritteTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _ketteIdMeta = const VerificationMeta(
    'ketteId',
  );
  @override
  late final GeneratedColumn<int> ketteId = GeneratedColumn<int>(
    'kette_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ketten (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ereignisIdMeta = const VerificationMeta(
    'ereignisId',
  );
  @override
  late final GeneratedColumn<int> ereignisId = GeneratedColumn<int>(
    'ereignis_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ereignisse (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, ketteId, position, ereignisId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schritte';
  @override
  VerificationContext validateIntegrity(
    Insertable<SchrittZeile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kette_id')) {
      context.handle(
        _ketteIdMeta,
        ketteId.isAcceptableOrUnknown(data['kette_id']!, _ketteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ketteIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('ereignis_id')) {
      context.handle(
        _ereignisIdMeta,
        ereignisId.isAcceptableOrUnknown(data['ereignis_id']!, _ereignisIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ereignisIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SchrittZeile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SchrittZeile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ketteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kette_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      ereignisId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ereignis_id'],
      )!,
    );
  }

  @override
  $SchritteTable createAlias(String alias) {
    return $SchritteTable(attachedDatabase, alias);
  }
}

class SchrittZeile extends DataClass implements Insertable<SchrittZeile> {
  final int id;
  final int ketteId;
  final int position;
  final int ereignisId;
  const SchrittZeile({
    required this.id,
    required this.ketteId,
    required this.position,
    required this.ereignisId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kette_id'] = Variable<int>(ketteId);
    map['position'] = Variable<int>(position);
    map['ereignis_id'] = Variable<int>(ereignisId);
    return map;
  }

  SchritteCompanion toCompanion(bool nullToAbsent) {
    return SchritteCompanion(
      id: Value(id),
      ketteId: Value(ketteId),
      position: Value(position),
      ereignisId: Value(ereignisId),
    );
  }

  factory SchrittZeile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SchrittZeile(
      id: serializer.fromJson<int>(json['id']),
      ketteId: serializer.fromJson<int>(json['ketteId']),
      position: serializer.fromJson<int>(json['position']),
      ereignisId: serializer.fromJson<int>(json['ereignisId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ketteId': serializer.toJson<int>(ketteId),
      'position': serializer.toJson<int>(position),
      'ereignisId': serializer.toJson<int>(ereignisId),
    };
  }

  SchrittZeile copyWith({
    int? id,
    int? ketteId,
    int? position,
    int? ereignisId,
  }) => SchrittZeile(
    id: id ?? this.id,
    ketteId: ketteId ?? this.ketteId,
    position: position ?? this.position,
    ereignisId: ereignisId ?? this.ereignisId,
  );
  SchrittZeile copyWithCompanion(SchritteCompanion data) {
    return SchrittZeile(
      id: data.id.present ? data.id.value : this.id,
      ketteId: data.ketteId.present ? data.ketteId.value : this.ketteId,
      position: data.position.present ? data.position.value : this.position,
      ereignisId: data.ereignisId.present
          ? data.ereignisId.value
          : this.ereignisId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SchrittZeile(')
          ..write('id: $id, ')
          ..write('ketteId: $ketteId, ')
          ..write('position: $position, ')
          ..write('ereignisId: $ereignisId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ketteId, position, ereignisId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SchrittZeile &&
          other.id == this.id &&
          other.ketteId == this.ketteId &&
          other.position == this.position &&
          other.ereignisId == this.ereignisId);
}

class SchritteCompanion extends UpdateCompanion<SchrittZeile> {
  final Value<int> id;
  final Value<int> ketteId;
  final Value<int> position;
  final Value<int> ereignisId;
  const SchritteCompanion({
    this.id = const Value.absent(),
    this.ketteId = const Value.absent(),
    this.position = const Value.absent(),
    this.ereignisId = const Value.absent(),
  });
  SchritteCompanion.insert({
    this.id = const Value.absent(),
    required int ketteId,
    required int position,
    required int ereignisId,
  }) : ketteId = Value(ketteId),
       position = Value(position),
       ereignisId = Value(ereignisId);
  static Insertable<SchrittZeile> custom({
    Expression<int>? id,
    Expression<int>? ketteId,
    Expression<int>? position,
    Expression<int>? ereignisId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ketteId != null) 'kette_id': ketteId,
      if (position != null) 'position': position,
      if (ereignisId != null) 'ereignis_id': ereignisId,
    });
  }

  SchritteCompanion copyWith({
    Value<int>? id,
    Value<int>? ketteId,
    Value<int>? position,
    Value<int>? ereignisId,
  }) {
    return SchritteCompanion(
      id: id ?? this.id,
      ketteId: ketteId ?? this.ketteId,
      position: position ?? this.position,
      ereignisId: ereignisId ?? this.ereignisId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ketteId.present) {
      map['kette_id'] = Variable<int>(ketteId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (ereignisId.present) {
      map['ereignis_id'] = Variable<int>(ereignisId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchritteCompanion(')
          ..write('id: $id, ')
          ..write('ketteId: $ketteId, ')
          ..write('position: $position, ')
          ..write('ereignisId: $ereignisId')
          ..write(')'))
        .toString();
  }
}

class $WochenregelTable extends Wochenregel
    with TableInfo<$WochenregelTable, WochenregelZeile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WochenregelTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _wochentagMeta = const VerificationMeta(
    'wochentag',
  );
  @override
  late final GeneratedColumn<int> wochentag = GeneratedColumn<int>(
    'wochentag',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ketteIdMeta = const VerificationMeta(
    'ketteId',
  );
  @override
  late final GeneratedColumn<int> ketteId = GeneratedColumn<int>(
    'kette_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [wochentag, ketteId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wochenregel';
  @override
  VerificationContext validateIntegrity(
    Insertable<WochenregelZeile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('wochentag')) {
      context.handle(
        _wochentagMeta,
        wochentag.isAcceptableOrUnknown(data['wochentag']!, _wochentagMeta),
      );
    }
    if (data.containsKey('kette_id')) {
      context.handle(
        _ketteIdMeta,
        ketteId.isAcceptableOrUnknown(data['kette_id']!, _ketteIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {wochentag};
  @override
  WochenregelZeile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WochenregelZeile(
      wochentag: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wochentag'],
      )!,
      ketteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kette_id'],
      ),
    );
  }

  @override
  $WochenregelTable createAlias(String alias) {
    return $WochenregelTable(attachedDatabase, alias);
  }
}

class WochenregelZeile extends DataClass
    implements Insertable<WochenregelZeile> {
  final int wochentag;
  final int? ketteId;
  const WochenregelZeile({required this.wochentag, this.ketteId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['wochentag'] = Variable<int>(wochentag);
    if (!nullToAbsent || ketteId != null) {
      map['kette_id'] = Variable<int>(ketteId);
    }
    return map;
  }

  WochenregelCompanion toCompanion(bool nullToAbsent) {
    return WochenregelCompanion(
      wochentag: Value(wochentag),
      ketteId: ketteId == null && nullToAbsent
          ? const Value.absent()
          : Value(ketteId),
    );
  }

  factory WochenregelZeile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WochenregelZeile(
      wochentag: serializer.fromJson<int>(json['wochentag']),
      ketteId: serializer.fromJson<int?>(json['ketteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'wochentag': serializer.toJson<int>(wochentag),
      'ketteId': serializer.toJson<int?>(ketteId),
    };
  }

  WochenregelZeile copyWith({
    int? wochentag,
    Value<int?> ketteId = const Value.absent(),
  }) => WochenregelZeile(
    wochentag: wochentag ?? this.wochentag,
    ketteId: ketteId.present ? ketteId.value : this.ketteId,
  );
  WochenregelZeile copyWithCompanion(WochenregelCompanion data) {
    return WochenregelZeile(
      wochentag: data.wochentag.present ? data.wochentag.value : this.wochentag,
      ketteId: data.ketteId.present ? data.ketteId.value : this.ketteId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WochenregelZeile(')
          ..write('wochentag: $wochentag, ')
          ..write('ketteId: $ketteId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(wochentag, ketteId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WochenregelZeile &&
          other.wochentag == this.wochentag &&
          other.ketteId == this.ketteId);
}

class WochenregelCompanion extends UpdateCompanion<WochenregelZeile> {
  final Value<int> wochentag;
  final Value<int?> ketteId;
  const WochenregelCompanion({
    this.wochentag = const Value.absent(),
    this.ketteId = const Value.absent(),
  });
  WochenregelCompanion.insert({
    this.wochentag = const Value.absent(),
    this.ketteId = const Value.absent(),
  });
  static Insertable<WochenregelZeile> custom({
    Expression<int>? wochentag,
    Expression<int>? ketteId,
  }) {
    return RawValuesInsertable({
      if (wochentag != null) 'wochentag': wochentag,
      if (ketteId != null) 'kette_id': ketteId,
    });
  }

  WochenregelCompanion copyWith({Value<int>? wochentag, Value<int?>? ketteId}) {
    return WochenregelCompanion(
      wochentag: wochentag ?? this.wochentag,
      ketteId: ketteId ?? this.ketteId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (wochentag.present) {
      map['wochentag'] = Variable<int>(wochentag.value);
    }
    if (ketteId.present) {
      map['kette_id'] = Variable<int>(ketteId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WochenregelCompanion(')
          ..write('wochentag: $wochentag, ')
          ..write('ketteId: $ketteId')
          ..write(')'))
        .toString();
  }
}

class $TagesausnahmenTable extends Tagesausnahmen
    with TableInfo<$TagesausnahmenTable, TagesausnahmeZeile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagesausnahmenTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
    'tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ketteIdMeta = const VerificationMeta(
    'ketteId',
  );
  @override
  late final GeneratedColumn<int> ketteId = GeneratedColumn<int>(
    'kette_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [tag, ketteId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tagesausnahmen';
  @override
  VerificationContext validateIntegrity(
    Insertable<TagesausnahmeZeile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    if (data.containsKey('kette_id')) {
      context.handle(
        _ketteIdMeta,
        ketteId.isAcceptableOrUnknown(data['kette_id']!, _ketteIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tag};
  @override
  TagesausnahmeZeile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagesausnahmeZeile(
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      )!,
      ketteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kette_id'],
      ),
    );
  }

  @override
  $TagesausnahmenTable createAlias(String alias) {
    return $TagesausnahmenTable(attachedDatabase, alias);
  }
}

class TagesausnahmeZeile extends DataClass
    implements Insertable<TagesausnahmeZeile> {
  final String tag;
  final int? ketteId;
  const TagesausnahmeZeile({required this.tag, this.ketteId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tag'] = Variable<String>(tag);
    if (!nullToAbsent || ketteId != null) {
      map['kette_id'] = Variable<int>(ketteId);
    }
    return map;
  }

  TagesausnahmenCompanion toCompanion(bool nullToAbsent) {
    return TagesausnahmenCompanion(
      tag: Value(tag),
      ketteId: ketteId == null && nullToAbsent
          ? const Value.absent()
          : Value(ketteId),
    );
  }

  factory TagesausnahmeZeile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagesausnahmeZeile(
      tag: serializer.fromJson<String>(json['tag']),
      ketteId: serializer.fromJson<int?>(json['ketteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tag': serializer.toJson<String>(tag),
      'ketteId': serializer.toJson<int?>(ketteId),
    };
  }

  TagesausnahmeZeile copyWith({
    String? tag,
    Value<int?> ketteId = const Value.absent(),
  }) => TagesausnahmeZeile(
    tag: tag ?? this.tag,
    ketteId: ketteId.present ? ketteId.value : this.ketteId,
  );
  TagesausnahmeZeile copyWithCompanion(TagesausnahmenCompanion data) {
    return TagesausnahmeZeile(
      tag: data.tag.present ? data.tag.value : this.tag,
      ketteId: data.ketteId.present ? data.ketteId.value : this.ketteId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagesausnahmeZeile(')
          ..write('tag: $tag, ')
          ..write('ketteId: $ketteId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tag, ketteId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagesausnahmeZeile &&
          other.tag == this.tag &&
          other.ketteId == this.ketteId);
}

class TagesausnahmenCompanion extends UpdateCompanion<TagesausnahmeZeile> {
  final Value<String> tag;
  final Value<int?> ketteId;
  final Value<int> rowid;
  const TagesausnahmenCompanion({
    this.tag = const Value.absent(),
    this.ketteId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagesausnahmenCompanion.insert({
    required String tag,
    this.ketteId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : tag = Value(tag);
  static Insertable<TagesausnahmeZeile> custom({
    Expression<String>? tag,
    Expression<int>? ketteId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tag != null) 'tag': tag,
      if (ketteId != null) 'kette_id': ketteId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagesausnahmenCompanion copyWith({
    Value<String>? tag,
    Value<int?>? ketteId,
    Value<int>? rowid,
  }) {
    return TagesausnahmenCompanion(
      tag: tag ?? this.tag,
      ketteId: ketteId ?? this.ketteId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (ketteId.present) {
      map['kette_id'] = Variable<int>(ketteId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagesausnahmenCompanion(')
          ..write('tag: $tag, ')
          ..write('ketteId: $ketteId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessungenTable extends Messungen
    with TableInfo<$MessungenTable, MessungZeile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessungenTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ereignisIdMeta = const VerificationMeta(
    'ereignisId',
  );
  @override
  late final GeneratedColumn<int> ereignisId = GeneratedColumn<int>(
    'ereignis_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMeta = const VerificationMeta('start');
  @override
  late final GeneratedColumn<int> start = GeneratedColumn<int>(
    'start',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stoppMeta = const VerificationMeta('stopp');
  @override
  late final GeneratedColumn<int> stopp = GeneratedColumn<int>(
    'stopp',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
    'tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ketteNameMeta = const VerificationMeta(
    'ketteName',
  );
  @override
  late final GeneratedColumn<String> ketteName = GeneratedColumn<String>(
    'kette_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schrittPositionMeta = const VerificationMeta(
    'schrittPosition',
  );
  @override
  late final GeneratedColumn<int> schrittPosition = GeneratedColumn<int>(
    'schritt_position',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ereignisId,
    start,
    stopp,
    tag,
    ketteName,
    schrittPosition,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messungen';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessungZeile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ereignis_id')) {
      context.handle(
        _ereignisIdMeta,
        ereignisId.isAcceptableOrUnknown(data['ereignis_id']!, _ereignisIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ereignisIdMeta);
    }
    if (data.containsKey('start')) {
      context.handle(
        _startMeta,
        start.isAcceptableOrUnknown(data['start']!, _startMeta),
      );
    } else if (isInserting) {
      context.missing(_startMeta);
    }
    if (data.containsKey('stopp')) {
      context.handle(
        _stoppMeta,
        stopp.isAcceptableOrUnknown(data['stopp']!, _stoppMeta),
      );
    }
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    if (data.containsKey('kette_name')) {
      context.handle(
        _ketteNameMeta,
        ketteName.isAcceptableOrUnknown(data['kette_name']!, _ketteNameMeta),
      );
    }
    if (data.containsKey('schritt_position')) {
      context.handle(
        _schrittPositionMeta,
        schrittPosition.isAcceptableOrUnknown(
          data['schritt_position']!,
          _schrittPositionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessungZeile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessungZeile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ereignisId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ereignis_id'],
      )!,
      start: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start'],
      )!,
      stopp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stopp'],
      ),
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      )!,
      ketteName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kette_name'],
      ),
      schrittPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schritt_position'],
      ),
    );
  }

  @override
  $MessungenTable createAlias(String alias) {
    return $MessungenTable(attachedDatabase, alias);
  }
}

class MessungZeile extends DataClass implements Insertable<MessungZeile> {
  final int id;
  final int ereignisId;

  /// UTC-Millisekunden.
  final int start;
  final int? stopp;
  final String tag;
  final String? ketteName;
  final int? schrittPosition;
  const MessungZeile({
    required this.id,
    required this.ereignisId,
    required this.start,
    this.stopp,
    required this.tag,
    this.ketteName,
    this.schrittPosition,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ereignis_id'] = Variable<int>(ereignisId);
    map['start'] = Variable<int>(start);
    if (!nullToAbsent || stopp != null) {
      map['stopp'] = Variable<int>(stopp);
    }
    map['tag'] = Variable<String>(tag);
    if (!nullToAbsent || ketteName != null) {
      map['kette_name'] = Variable<String>(ketteName);
    }
    if (!nullToAbsent || schrittPosition != null) {
      map['schritt_position'] = Variable<int>(schrittPosition);
    }
    return map;
  }

  MessungenCompanion toCompanion(bool nullToAbsent) {
    return MessungenCompanion(
      id: Value(id),
      ereignisId: Value(ereignisId),
      start: Value(start),
      stopp: stopp == null && nullToAbsent
          ? const Value.absent()
          : Value(stopp),
      tag: Value(tag),
      ketteName: ketteName == null && nullToAbsent
          ? const Value.absent()
          : Value(ketteName),
      schrittPosition: schrittPosition == null && nullToAbsent
          ? const Value.absent()
          : Value(schrittPosition),
    );
  }

  factory MessungZeile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessungZeile(
      id: serializer.fromJson<int>(json['id']),
      ereignisId: serializer.fromJson<int>(json['ereignisId']),
      start: serializer.fromJson<int>(json['start']),
      stopp: serializer.fromJson<int?>(json['stopp']),
      tag: serializer.fromJson<String>(json['tag']),
      ketteName: serializer.fromJson<String?>(json['ketteName']),
      schrittPosition: serializer.fromJson<int?>(json['schrittPosition']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ereignisId': serializer.toJson<int>(ereignisId),
      'start': serializer.toJson<int>(start),
      'stopp': serializer.toJson<int?>(stopp),
      'tag': serializer.toJson<String>(tag),
      'ketteName': serializer.toJson<String?>(ketteName),
      'schrittPosition': serializer.toJson<int?>(schrittPosition),
    };
  }

  MessungZeile copyWith({
    int? id,
    int? ereignisId,
    int? start,
    Value<int?> stopp = const Value.absent(),
    String? tag,
    Value<String?> ketteName = const Value.absent(),
    Value<int?> schrittPosition = const Value.absent(),
  }) => MessungZeile(
    id: id ?? this.id,
    ereignisId: ereignisId ?? this.ereignisId,
    start: start ?? this.start,
    stopp: stopp.present ? stopp.value : this.stopp,
    tag: tag ?? this.tag,
    ketteName: ketteName.present ? ketteName.value : this.ketteName,
    schrittPosition: schrittPosition.present
        ? schrittPosition.value
        : this.schrittPosition,
  );
  MessungZeile copyWithCompanion(MessungenCompanion data) {
    return MessungZeile(
      id: data.id.present ? data.id.value : this.id,
      ereignisId: data.ereignisId.present
          ? data.ereignisId.value
          : this.ereignisId,
      start: data.start.present ? data.start.value : this.start,
      stopp: data.stopp.present ? data.stopp.value : this.stopp,
      tag: data.tag.present ? data.tag.value : this.tag,
      ketteName: data.ketteName.present ? data.ketteName.value : this.ketteName,
      schrittPosition: data.schrittPosition.present
          ? data.schrittPosition.value
          : this.schrittPosition,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessungZeile(')
          ..write('id: $id, ')
          ..write('ereignisId: $ereignisId, ')
          ..write('start: $start, ')
          ..write('stopp: $stopp, ')
          ..write('tag: $tag, ')
          ..write('ketteName: $ketteName, ')
          ..write('schrittPosition: $schrittPosition')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ereignisId,
    start,
    stopp,
    tag,
    ketteName,
    schrittPosition,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessungZeile &&
          other.id == this.id &&
          other.ereignisId == this.ereignisId &&
          other.start == this.start &&
          other.stopp == this.stopp &&
          other.tag == this.tag &&
          other.ketteName == this.ketteName &&
          other.schrittPosition == this.schrittPosition);
}

class MessungenCompanion extends UpdateCompanion<MessungZeile> {
  final Value<int> id;
  final Value<int> ereignisId;
  final Value<int> start;
  final Value<int?> stopp;
  final Value<String> tag;
  final Value<String?> ketteName;
  final Value<int?> schrittPosition;
  const MessungenCompanion({
    this.id = const Value.absent(),
    this.ereignisId = const Value.absent(),
    this.start = const Value.absent(),
    this.stopp = const Value.absent(),
    this.tag = const Value.absent(),
    this.ketteName = const Value.absent(),
    this.schrittPosition = const Value.absent(),
  });
  MessungenCompanion.insert({
    this.id = const Value.absent(),
    required int ereignisId,
    required int start,
    this.stopp = const Value.absent(),
    required String tag,
    this.ketteName = const Value.absent(),
    this.schrittPosition = const Value.absent(),
  }) : ereignisId = Value(ereignisId),
       start = Value(start),
       tag = Value(tag);
  static Insertable<MessungZeile> custom({
    Expression<int>? id,
    Expression<int>? ereignisId,
    Expression<int>? start,
    Expression<int>? stopp,
    Expression<String>? tag,
    Expression<String>? ketteName,
    Expression<int>? schrittPosition,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ereignisId != null) 'ereignis_id': ereignisId,
      if (start != null) 'start': start,
      if (stopp != null) 'stopp': stopp,
      if (tag != null) 'tag': tag,
      if (ketteName != null) 'kette_name': ketteName,
      if (schrittPosition != null) 'schritt_position': schrittPosition,
    });
  }

  MessungenCompanion copyWith({
    Value<int>? id,
    Value<int>? ereignisId,
    Value<int>? start,
    Value<int?>? stopp,
    Value<String>? tag,
    Value<String?>? ketteName,
    Value<int?>? schrittPosition,
  }) {
    return MessungenCompanion(
      id: id ?? this.id,
      ereignisId: ereignisId ?? this.ereignisId,
      start: start ?? this.start,
      stopp: stopp ?? this.stopp,
      tag: tag ?? this.tag,
      ketteName: ketteName ?? this.ketteName,
      schrittPosition: schrittPosition ?? this.schrittPosition,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ereignisId.present) {
      map['ereignis_id'] = Variable<int>(ereignisId.value);
    }
    if (start.present) {
      map['start'] = Variable<int>(start.value);
    }
    if (stopp.present) {
      map['stopp'] = Variable<int>(stopp.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (ketteName.present) {
      map['kette_name'] = Variable<String>(ketteName.value);
    }
    if (schrittPosition.present) {
      map['schritt_position'] = Variable<int>(schrittPosition.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessungenCompanion(')
          ..write('id: $id, ')
          ..write('ereignisId: $ereignisId, ')
          ..write('start: $start, ')
          ..write('stopp: $stopp, ')
          ..write('tag: $tag, ')
          ..write('ketteName: $ketteName, ')
          ..write('schrittPosition: $schrittPosition')
          ..write(')'))
        .toString();
  }
}

class $TageslaeufeTable extends Tageslaeufe
    with TableInfo<$TageslaeufeTable, TageslaufZeile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TageslaeufeTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
    'tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ketteIdMeta = const VerificationMeta(
    'ketteId',
  );
  @override
  late final GeneratedColumn<int> ketteId = GeneratedColumn<int>(
    'kette_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ketteNameMeta = const VerificationMeta(
    'ketteName',
  );
  @override
  late final GeneratedColumn<String> ketteName = GeneratedColumn<String>(
    'kette_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schritteMeta = const VerificationMeta(
    'schritte',
  );
  @override
  late final GeneratedColumn<String> schritte = GeneratedColumn<String>(
    'schritte',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _naechsterMeta = const VerificationMeta(
    'naechster',
  );
  @override
  late final GeneratedColumn<int> naechster = GeneratedColumn<int>(
    'naechster',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    tag,
    ketteId,
    ketteName,
    schritte,
    naechster,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tageslaeufe';
  @override
  VerificationContext validateIntegrity(
    Insertable<TageslaufZeile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    if (data.containsKey('kette_id')) {
      context.handle(
        _ketteIdMeta,
        ketteId.isAcceptableOrUnknown(data['kette_id']!, _ketteIdMeta),
      );
    }
    if (data.containsKey('kette_name')) {
      context.handle(
        _ketteNameMeta,
        ketteName.isAcceptableOrUnknown(data['kette_name']!, _ketteNameMeta),
      );
    } else if (isInserting) {
      context.missing(_ketteNameMeta);
    }
    if (data.containsKey('schritte')) {
      context.handle(
        _schritteMeta,
        schritte.isAcceptableOrUnknown(data['schritte']!, _schritteMeta),
      );
    } else if (isInserting) {
      context.missing(_schritteMeta);
    }
    if (data.containsKey('naechster')) {
      context.handle(
        _naechsterMeta,
        naechster.isAcceptableOrUnknown(data['naechster']!, _naechsterMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tag};
  @override
  TageslaufZeile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TageslaufZeile(
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      )!,
      ketteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kette_id'],
      ),
      ketteName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kette_name'],
      )!,
      schritte: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schritte'],
      )!,
      naechster: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}naechster'],
      ),
    );
  }

  @override
  $TageslaeufeTable createAlias(String alias) {
    return $TageslaeufeTable(attachedDatabase, alias);
  }
}

class TageslaufZeile extends DataClass implements Insertable<TageslaufZeile> {
  final String tag;
  final int? ketteId;
  final String ketteName;

  /// JSON-Liste von `ereignis_id`.
  final String schritte;
  final int? naechster;
  const TageslaufZeile({
    required this.tag,
    this.ketteId,
    required this.ketteName,
    required this.schritte,
    this.naechster,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tag'] = Variable<String>(tag);
    if (!nullToAbsent || ketteId != null) {
      map['kette_id'] = Variable<int>(ketteId);
    }
    map['kette_name'] = Variable<String>(ketteName);
    map['schritte'] = Variable<String>(schritte);
    if (!nullToAbsent || naechster != null) {
      map['naechster'] = Variable<int>(naechster);
    }
    return map;
  }

  TageslaeufeCompanion toCompanion(bool nullToAbsent) {
    return TageslaeufeCompanion(
      tag: Value(tag),
      ketteId: ketteId == null && nullToAbsent
          ? const Value.absent()
          : Value(ketteId),
      ketteName: Value(ketteName),
      schritte: Value(schritte),
      naechster: naechster == null && nullToAbsent
          ? const Value.absent()
          : Value(naechster),
    );
  }

  factory TageslaufZeile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TageslaufZeile(
      tag: serializer.fromJson<String>(json['tag']),
      ketteId: serializer.fromJson<int?>(json['ketteId']),
      ketteName: serializer.fromJson<String>(json['ketteName']),
      schritte: serializer.fromJson<String>(json['schritte']),
      naechster: serializer.fromJson<int?>(json['naechster']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tag': serializer.toJson<String>(tag),
      'ketteId': serializer.toJson<int?>(ketteId),
      'ketteName': serializer.toJson<String>(ketteName),
      'schritte': serializer.toJson<String>(schritte),
      'naechster': serializer.toJson<int?>(naechster),
    };
  }

  TageslaufZeile copyWith({
    String? tag,
    Value<int?> ketteId = const Value.absent(),
    String? ketteName,
    String? schritte,
    Value<int?> naechster = const Value.absent(),
  }) => TageslaufZeile(
    tag: tag ?? this.tag,
    ketteId: ketteId.present ? ketteId.value : this.ketteId,
    ketteName: ketteName ?? this.ketteName,
    schritte: schritte ?? this.schritte,
    naechster: naechster.present ? naechster.value : this.naechster,
  );
  TageslaufZeile copyWithCompanion(TageslaeufeCompanion data) {
    return TageslaufZeile(
      tag: data.tag.present ? data.tag.value : this.tag,
      ketteId: data.ketteId.present ? data.ketteId.value : this.ketteId,
      ketteName: data.ketteName.present ? data.ketteName.value : this.ketteName,
      schritte: data.schritte.present ? data.schritte.value : this.schritte,
      naechster: data.naechster.present ? data.naechster.value : this.naechster,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TageslaufZeile(')
          ..write('tag: $tag, ')
          ..write('ketteId: $ketteId, ')
          ..write('ketteName: $ketteName, ')
          ..write('schritte: $schritte, ')
          ..write('naechster: $naechster')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tag, ketteId, ketteName, schritte, naechster);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TageslaufZeile &&
          other.tag == this.tag &&
          other.ketteId == this.ketteId &&
          other.ketteName == this.ketteName &&
          other.schritte == this.schritte &&
          other.naechster == this.naechster);
}

class TageslaeufeCompanion extends UpdateCompanion<TageslaufZeile> {
  final Value<String> tag;
  final Value<int?> ketteId;
  final Value<String> ketteName;
  final Value<String> schritte;
  final Value<int?> naechster;
  final Value<int> rowid;
  const TageslaeufeCompanion({
    this.tag = const Value.absent(),
    this.ketteId = const Value.absent(),
    this.ketteName = const Value.absent(),
    this.schritte = const Value.absent(),
    this.naechster = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TageslaeufeCompanion.insert({
    required String tag,
    this.ketteId = const Value.absent(),
    required String ketteName,
    required String schritte,
    this.naechster = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : tag = Value(tag),
       ketteName = Value(ketteName),
       schritte = Value(schritte);
  static Insertable<TageslaufZeile> custom({
    Expression<String>? tag,
    Expression<int>? ketteId,
    Expression<String>? ketteName,
    Expression<String>? schritte,
    Expression<int>? naechster,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tag != null) 'tag': tag,
      if (ketteId != null) 'kette_id': ketteId,
      if (ketteName != null) 'kette_name': ketteName,
      if (schritte != null) 'schritte': schritte,
      if (naechster != null) 'naechster': naechster,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TageslaeufeCompanion copyWith({
    Value<String>? tag,
    Value<int?>? ketteId,
    Value<String>? ketteName,
    Value<String>? schritte,
    Value<int?>? naechster,
    Value<int>? rowid,
  }) {
    return TageslaeufeCompanion(
      tag: tag ?? this.tag,
      ketteId: ketteId ?? this.ketteId,
      ketteName: ketteName ?? this.ketteName,
      schritte: schritte ?? this.schritte,
      naechster: naechster ?? this.naechster,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (ketteId.present) {
      map['kette_id'] = Variable<int>(ketteId.value);
    }
    if (ketteName.present) {
      map['kette_name'] = Variable<String>(ketteName.value);
    }
    if (schritte.present) {
      map['schritte'] = Variable<String>(schritte.value);
    }
    if (naechster.present) {
      map['naechster'] = Variable<int>(naechster.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TageslaeufeCompanion(')
          ..write('tag: $tag, ')
          ..write('ketteId: $ketteId, ')
          ..write('ketteName: $ketteName, ')
          ..write('schritte: $schritte, ')
          ..write('naechster: $naechster, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UebersprungenTable extends Uebersprungen
    with TableInfo<$UebersprungenTable, UebersprungenZeile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UebersprungenTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
    'tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [tag, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'uebersprungen';
  @override
  VerificationContext validateIntegrity(
    Insertable<UebersprungenZeile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tag, position};
  @override
  UebersprungenZeile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UebersprungenZeile(
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $UebersprungenTable createAlias(String alias) {
    return $UebersprungenTable(attachedDatabase, alias);
  }
}

class UebersprungenZeile extends DataClass
    implements Insertable<UebersprungenZeile> {
  final String tag;
  final int position;
  const UebersprungenZeile({required this.tag, required this.position});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tag'] = Variable<String>(tag);
    map['position'] = Variable<int>(position);
    return map;
  }

  UebersprungenCompanion toCompanion(bool nullToAbsent) {
    return UebersprungenCompanion(tag: Value(tag), position: Value(position));
  }

  factory UebersprungenZeile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UebersprungenZeile(
      tag: serializer.fromJson<String>(json['tag']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tag': serializer.toJson<String>(tag),
      'position': serializer.toJson<int>(position),
    };
  }

  UebersprungenZeile copyWith({String? tag, int? position}) =>
      UebersprungenZeile(
        tag: tag ?? this.tag,
        position: position ?? this.position,
      );
  UebersprungenZeile copyWithCompanion(UebersprungenCompanion data) {
    return UebersprungenZeile(
      tag: data.tag.present ? data.tag.value : this.tag,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UebersprungenZeile(')
          ..write('tag: $tag, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tag, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UebersprungenZeile &&
          other.tag == this.tag &&
          other.position == this.position);
}

class UebersprungenCompanion extends UpdateCompanion<UebersprungenZeile> {
  final Value<String> tag;
  final Value<int> position;
  final Value<int> rowid;
  const UebersprungenCompanion({
    this.tag = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UebersprungenCompanion.insert({
    required String tag,
    required int position,
    this.rowid = const Value.absent(),
  }) : tag = Value(tag),
       position = Value(position);
  static Insertable<UebersprungenZeile> custom({
    Expression<String>? tag,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tag != null) 'tag': tag,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UebersprungenCompanion copyWith({
    Value<String>? tag,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return UebersprungenCompanion(
      tag: tag ?? this.tag,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UebersprungenCompanion(')
          ..write('tag: $tag, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EinstellungenTable extends Einstellungen
    with TableInfo<$EinstellungenTable, EinstellungZeile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EinstellungenTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _schluesselMeta = const VerificationMeta(
    'schluessel',
  );
  @override
  late final GeneratedColumn<String> schluessel = GeneratedColumn<String>(
    'schluessel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wertMeta = const VerificationMeta('wert');
  @override
  late final GeneratedColumn<String> wert = GeneratedColumn<String>(
    'wert',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [schluessel, wert];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'einstellungen';
  @override
  VerificationContext validateIntegrity(
    Insertable<EinstellungZeile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('schluessel')) {
      context.handle(
        _schluesselMeta,
        schluessel.isAcceptableOrUnknown(data['schluessel']!, _schluesselMeta),
      );
    } else if (isInserting) {
      context.missing(_schluesselMeta);
    }
    if (data.containsKey('wert')) {
      context.handle(
        _wertMeta,
        wert.isAcceptableOrUnknown(data['wert']!, _wertMeta),
      );
    } else if (isInserting) {
      context.missing(_wertMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {schluessel};
  @override
  EinstellungZeile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EinstellungZeile(
      schluessel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schluessel'],
      )!,
      wert: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wert'],
      )!,
    );
  }

  @override
  $EinstellungenTable createAlias(String alias) {
    return $EinstellungenTable(attachedDatabase, alias);
  }
}

class EinstellungZeile extends DataClass
    implements Insertable<EinstellungZeile> {
  final String schluessel;
  final String wert;
  const EinstellungZeile({required this.schluessel, required this.wert});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['schluessel'] = Variable<String>(schluessel);
    map['wert'] = Variable<String>(wert);
    return map;
  }

  EinstellungenCompanion toCompanion(bool nullToAbsent) {
    return EinstellungenCompanion(
      schluessel: Value(schluessel),
      wert: Value(wert),
    );
  }

  factory EinstellungZeile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EinstellungZeile(
      schluessel: serializer.fromJson<String>(json['schluessel']),
      wert: serializer.fromJson<String>(json['wert']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'schluessel': serializer.toJson<String>(schluessel),
      'wert': serializer.toJson<String>(wert),
    };
  }

  EinstellungZeile copyWith({String? schluessel, String? wert}) =>
      EinstellungZeile(
        schluessel: schluessel ?? this.schluessel,
        wert: wert ?? this.wert,
      );
  EinstellungZeile copyWithCompanion(EinstellungenCompanion data) {
    return EinstellungZeile(
      schluessel: data.schluessel.present
          ? data.schluessel.value
          : this.schluessel,
      wert: data.wert.present ? data.wert.value : this.wert,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EinstellungZeile(')
          ..write('schluessel: $schluessel, ')
          ..write('wert: $wert')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(schluessel, wert);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EinstellungZeile &&
          other.schluessel == this.schluessel &&
          other.wert == this.wert);
}

class EinstellungenCompanion extends UpdateCompanion<EinstellungZeile> {
  final Value<String> schluessel;
  final Value<String> wert;
  final Value<int> rowid;
  const EinstellungenCompanion({
    this.schluessel = const Value.absent(),
    this.wert = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EinstellungenCompanion.insert({
    required String schluessel,
    required String wert,
    this.rowid = const Value.absent(),
  }) : schluessel = Value(schluessel),
       wert = Value(wert);
  static Insertable<EinstellungZeile> custom({
    Expression<String>? schluessel,
    Expression<String>? wert,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (schluessel != null) 'schluessel': schluessel,
      if (wert != null) 'wert': wert,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EinstellungenCompanion copyWith({
    Value<String>? schluessel,
    Value<String>? wert,
    Value<int>? rowid,
  }) {
    return EinstellungenCompanion(
      schluessel: schluessel ?? this.schluessel,
      wert: wert ?? this.wert,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (schluessel.present) {
      map['schluessel'] = Variable<String>(schluessel.value);
    }
    if (wert.present) {
      map['wert'] = Variable<String>(wert.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EinstellungenCompanion(')
          ..write('schluessel: $schluessel, ')
          ..write('wert: $wert, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$StoppDatenbank extends GeneratedDatabase {
  _$StoppDatenbank(QueryExecutor e) : super(e);
  $StoppDatenbankManager get managers => $StoppDatenbankManager(this);
  late final $EreignisseTable ereignisse = $EreignisseTable(this);
  late final $KettenTable ketten = $KettenTable(this);
  late final $SchritteTable schritte = $SchritteTable(this);
  late final $WochenregelTable wochenregel = $WochenregelTable(this);
  late final $TagesausnahmenTable tagesausnahmen = $TagesausnahmenTable(this);
  late final $MessungenTable messungen = $MessungenTable(this);
  late final $TageslaeufeTable tageslaeufe = $TageslaeufeTable(this);
  late final $UebersprungenTable uebersprungen = $UebersprungenTable(this);
  late final $EinstellungenTable einstellungen = $EinstellungenTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    ereignisse,
    ketten,
    schritte,
    wochenregel,
    tagesausnahmen,
    messungen,
    tageslaeufe,
    uebersprungen,
    einstellungen,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'ketten',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('schritte', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$EreignisseTableCreateCompanionBuilder = EreignisseCompanion Function({
  Value<int> id,
  required String name,
  Value<bool> archiviert,
});
typedef $$EreignisseTableUpdateCompanionBuilder = EreignisseCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<bool> archiviert,
});

final class $$EreignisseTableReferences
    extends BaseReferences<_$StoppDatenbank, $EreignisseTable, EreignisZeile> {
  $$EreignisseTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SchritteTable, List<SchrittZeile>>
  _schritteRefsTable(_$StoppDatenbank db) => MultiTypedResultKey.fromTable(
    db.schritte,
    aliasName: 'ereignisse__id__schritte__ereignis_id',
  );

  $$SchritteTableProcessedTableManager get schritteRefs {
    final manager = $$SchritteTableTableManager(
      $_db,
      $_db.schritte,
    ).filter((f) => f.ereignisId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_schritteRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EreignisseTableFilterComposer
    extends Composer<_$StoppDatenbank, $EreignisseTable> {
  $$EreignisseTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archiviert => $composableBuilder(
    column: $table.archiviert,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> schritteRefs(
    Expression<bool> Function($$SchritteTableFilterComposer f) f,
  ) {
    final $$SchritteTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.schritte,
      getReferencedColumn: (t) => t.ereignisId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchritteTableFilterComposer(
            $db: $db,
            $table: $db.schritte,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EreignisseTableOrderingComposer
    extends Composer<_$StoppDatenbank, $EreignisseTable> {
  $$EreignisseTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archiviert => $composableBuilder(
    column: $table.archiviert,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EreignisseTableAnnotationComposer
    extends Composer<_$StoppDatenbank, $EreignisseTable> {
  $$EreignisseTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get archiviert => $composableBuilder(
    column: $table.archiviert,
    builder: (column) => column,
  );

  Expression<T> schritteRefs<T extends Object>(
    Expression<T> Function($$SchritteTableAnnotationComposer a) f,
  ) {
    final $$SchritteTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.schritte,
      getReferencedColumn: (t) => t.ereignisId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchritteTableAnnotationComposer(
            $db: $db,
            $table: $db.schritte,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EreignisseTableTableManager
    extends
        RootTableManager<
          _$StoppDatenbank,
          $EreignisseTable,
          EreignisZeile,
          $$EreignisseTableFilterComposer,
          $$EreignisseTableOrderingComposer,
          $$EreignisseTableAnnotationComposer,
          $$EreignisseTableCreateCompanionBuilder,
          $$EreignisseTableUpdateCompanionBuilder,
          (EreignisZeile, $$EreignisseTableReferences),
          EreignisZeile,
          PrefetchHooks Function({bool schritteRefs})
        > {
  $$EreignisseTableTableManager(_$StoppDatenbank db, $EreignisseTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EreignisseTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EreignisseTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EreignisseTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<bool> archiviert = const Value.absent(),
          }) => EreignisseCompanion(id: id, name: name, archiviert: archiviert),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<bool> archiviert = const Value.absent(),
              }) => EreignisseCompanion.insert(
                id: id,
                name: name,
                archiviert: archiviert,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EreignisseTable, EreignisZeile>(table),
                  $$EreignisseTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({schritteRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (schritteRefs) db.schritte],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (schritteRefs)
                    await $_getPrefetchedDataByColumns<
                      EreignisZeile,
                      $EreignisseTable,
                      SchrittZeile,
                      $SchritteTable
                    >(
                      currentTable: table,
                      referencedTable: $$EreignisseTableReferences
                          ._schritteRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$EreignisseTableReferences(
                            db,
                            table,
                            p0,
                          ).schritteRefs,
                      currentColumn: 'id',
                      referencedColumn: 'ereignis_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$EreignisseTableProcessedTableManager =
    ProcessedTableManager<
      _$StoppDatenbank,
      $EreignisseTable,
      EreignisZeile,
      $$EreignisseTableFilterComposer,
      $$EreignisseTableOrderingComposer,
      $$EreignisseTableAnnotationComposer,
      $$EreignisseTableCreateCompanionBuilder,
      $$EreignisseTableUpdateCompanionBuilder,
      (EreignisZeile, $$EreignisseTableReferences),
      EreignisZeile,
      PrefetchHooks Function({bool schritteRefs})
    >;
typedef $$KettenTableCreateCompanionBuilder = KettenCompanion Function({
  Value<int> id,
  required String name,
  required int farbe,
  required int sortierung,
});
typedef $$KettenTableUpdateCompanionBuilder = KettenCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> farbe,
  Value<int> sortierung,
});

final class $$KettenTableReferences
    extends BaseReferences<_$StoppDatenbank, $KettenTable, KetteZeile> {
  $$KettenTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SchritteTable, List<SchrittZeile>>
  _schritteRefsTable(_$StoppDatenbank db) => MultiTypedResultKey.fromTable(
    db.schritte,
    aliasName: 'ketten__id__schritte__kette_id',
  );

  $$SchritteTableProcessedTableManager get schritteRefs {
    final manager = $$SchritteTableTableManager(
      $_db,
      $_db.schritte,
    ).filter((f) => f.ketteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_schritteRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$KettenTableFilterComposer
    extends Composer<_$StoppDatenbank, $KettenTable> {
  $$KettenTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get farbe => $composableBuilder(
    column: $table.farbe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortierung => $composableBuilder(
    column: $table.sortierung,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> schritteRefs(
    Expression<bool> Function($$SchritteTableFilterComposer f) f,
  ) {
    final $$SchritteTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.schritte,
      getReferencedColumn: (t) => t.ketteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchritteTableFilterComposer(
            $db: $db,
            $table: $db.schritte,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$KettenTableOrderingComposer
    extends Composer<_$StoppDatenbank, $KettenTable> {
  $$KettenTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get farbe => $composableBuilder(
    column: $table.farbe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortierung => $composableBuilder(
    column: $table.sortierung,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KettenTableAnnotationComposer
    extends Composer<_$StoppDatenbank, $KettenTable> {
  $$KettenTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get farbe =>
      $composableBuilder(column: $table.farbe, builder: (column) => column);

  GeneratedColumn<int> get sortierung => $composableBuilder(
    column: $table.sortierung,
    builder: (column) => column,
  );

  Expression<T> schritteRefs<T extends Object>(
    Expression<T> Function($$SchritteTableAnnotationComposer a) f,
  ) {
    final $$SchritteTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.schritte,
      getReferencedColumn: (t) => t.ketteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchritteTableAnnotationComposer(
            $db: $db,
            $table: $db.schritte,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$KettenTableTableManager
    extends
        RootTableManager<
          _$StoppDatenbank,
          $KettenTable,
          KetteZeile,
          $$KettenTableFilterComposer,
          $$KettenTableOrderingComposer,
          $$KettenTableAnnotationComposer,
          $$KettenTableCreateCompanionBuilder,
          $$KettenTableUpdateCompanionBuilder,
          (KetteZeile, $$KettenTableReferences),
          KetteZeile,
          PrefetchHooks Function({bool schritteRefs})
        > {
  $$KettenTableTableManager(_$StoppDatenbank db, $KettenTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KettenTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KettenTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KettenTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> farbe = const Value.absent(),
                Value<int> sortierung = const Value.absent(),
              }) => KettenCompanion(
                id: id,
                name: name,
                farbe: farbe,
                sortierung: sortierung,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int farbe,
                required int sortierung,
              }) => KettenCompanion.insert(
                id: id,
                name: name,
                farbe: farbe,
                sortierung: sortierung,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KettenTable, KetteZeile>(table),
                  $$KettenTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({schritteRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (schritteRefs) db.schritte],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (schritteRefs)
                    await $_getPrefetchedDataByColumns<
                      KetteZeile,
                      $KettenTable,
                      SchrittZeile,
                      $SchritteTable
                    >(
                      currentTable: table,
                      referencedTable: $$KettenTableReferences
                          ._schritteRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$KettenTableReferences(db, table, p0).schritteRefs,
                      currentColumn: 'id',
                      referencedColumn: 'kette_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$KettenTableProcessedTableManager =
    ProcessedTableManager<
      _$StoppDatenbank,
      $KettenTable,
      KetteZeile,
      $$KettenTableFilterComposer,
      $$KettenTableOrderingComposer,
      $$KettenTableAnnotationComposer,
      $$KettenTableCreateCompanionBuilder,
      $$KettenTableUpdateCompanionBuilder,
      (KetteZeile, $$KettenTableReferences),
      KetteZeile,
      PrefetchHooks Function({bool schritteRefs})
    >;
typedef $$SchritteTableCreateCompanionBuilder = SchritteCompanion Function({
  Value<int> id,
  required int ketteId,
  required int position,
  required int ereignisId,
});
typedef $$SchritteTableUpdateCompanionBuilder = SchritteCompanion Function({
  Value<int> id,
  Value<int> ketteId,
  Value<int> position,
  Value<int> ereignisId,
});

final class $$SchritteTableReferences
    extends BaseReferences<_$StoppDatenbank, $SchritteTable, SchrittZeile> {
  $$SchritteTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $KettenTable _ketteIdTable(_$StoppDatenbank db) =>
      db.ketten.createAlias('schritte__kette_id__ketten__id');

  $$KettenTableProcessedTableManager get ketteId {
    final $_column = $_itemColumn<int>('kette_id')!;

    final manager = $$KettenTableTableManager(
      $_db,
      $_db.ketten,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ketteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EreignisseTable _ereignisIdTable(_$StoppDatenbank db) =>
      db.ereignisse.createAlias('schritte__ereignis_id__ereignisse__id');

  $$EreignisseTableProcessedTableManager get ereignisId {
    final $_column = $_itemColumn<int>('ereignis_id')!;

    final manager = $$EreignisseTableTableManager(
      $_db,
      $_db.ereignisse,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ereignisIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SchritteTableFilterComposer
    extends Composer<_$StoppDatenbank, $SchritteTable> {
  $$SchritteTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$KettenTableFilterComposer get ketteId {
    final $$KettenTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ketteId,
      referencedTable: $db.ketten,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KettenTableFilterComposer(
            $db: $db,
            $table: $db.ketten,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EreignisseTableFilterComposer get ereignisId {
    final $$EreignisseTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ereignisId,
      referencedTable: $db.ereignisse,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EreignisseTableFilterComposer(
            $db: $db,
            $table: $db.ereignisse,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SchritteTableOrderingComposer
    extends Composer<_$StoppDatenbank, $SchritteTable> {
  $$SchritteTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$KettenTableOrderingComposer get ketteId {
    final $$KettenTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ketteId,
      referencedTable: $db.ketten,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KettenTableOrderingComposer(
            $db: $db,
            $table: $db.ketten,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EreignisseTableOrderingComposer get ereignisId {
    final $$EreignisseTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ereignisId,
      referencedTable: $db.ereignisse,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EreignisseTableOrderingComposer(
            $db: $db,
            $table: $db.ereignisse,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SchritteTableAnnotationComposer
    extends Composer<_$StoppDatenbank, $SchritteTable> {
  $$SchritteTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$KettenTableAnnotationComposer get ketteId {
    final $$KettenTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ketteId,
      referencedTable: $db.ketten,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KettenTableAnnotationComposer(
            $db: $db,
            $table: $db.ketten,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EreignisseTableAnnotationComposer get ereignisId {
    final $$EreignisseTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ereignisId,
      referencedTable: $db.ereignisse,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EreignisseTableAnnotationComposer(
            $db: $db,
            $table: $db.ereignisse,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SchritteTableTableManager
    extends
        RootTableManager<
          _$StoppDatenbank,
          $SchritteTable,
          SchrittZeile,
          $$SchritteTableFilterComposer,
          $$SchritteTableOrderingComposer,
          $$SchritteTableAnnotationComposer,
          $$SchritteTableCreateCompanionBuilder,
          $$SchritteTableUpdateCompanionBuilder,
          (SchrittZeile, $$SchritteTableReferences),
          SchrittZeile,
          PrefetchHooks Function({bool ketteId, bool ereignisId})
        > {
  $$SchritteTableTableManager(_$StoppDatenbank db, $SchritteTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchritteTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchritteTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchritteTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> ketteId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> ereignisId = const Value.absent(),
              }) => SchritteCompanion(
                id: id,
                ketteId: ketteId,
                position: position,
                ereignisId: ereignisId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int ketteId,
                required int position,
                required int ereignisId,
              }) => SchritteCompanion.insert(
                id: id,
                ketteId: ketteId,
                position: position,
                ereignisId: ereignisId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SchritteTable, SchrittZeile>(table),
                  $$SchritteTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ketteId = false, ereignisId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ketteId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.ketteId,
                        referencedTable: $$SchritteTableReferences
                            ._ketteIdTable(db),
                        referencedColumn: $$SchritteTableReferences
                            ._ketteIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (ereignisId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.ereignisId,
                        referencedTable: $$SchritteTableReferences
                            ._ereignisIdTable(db),
                        referencedColumn: $$SchritteTableReferences
                            ._ereignisIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SchritteTableProcessedTableManager =
    ProcessedTableManager<
      _$StoppDatenbank,
      $SchritteTable,
      SchrittZeile,
      $$SchritteTableFilterComposer,
      $$SchritteTableOrderingComposer,
      $$SchritteTableAnnotationComposer,
      $$SchritteTableCreateCompanionBuilder,
      $$SchritteTableUpdateCompanionBuilder,
      (SchrittZeile, $$SchritteTableReferences),
      SchrittZeile,
      PrefetchHooks Function({bool ketteId, bool ereignisId})
    >;
typedef $$WochenregelTableCreateCompanionBuilder =
    WochenregelCompanion Function({Value<int> wochentag, Value<int?> ketteId});
typedef $$WochenregelTableUpdateCompanionBuilder =
    WochenregelCompanion Function({Value<int> wochentag, Value<int?> ketteId});

class $$WochenregelTableFilterComposer
    extends Composer<_$StoppDatenbank, $WochenregelTable> {
  $$WochenregelTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get wochentag => $composableBuilder(
    column: $table.wochentag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ketteId => $composableBuilder(
    column: $table.ketteId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WochenregelTableOrderingComposer
    extends Composer<_$StoppDatenbank, $WochenregelTable> {
  $$WochenregelTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get wochentag => $composableBuilder(
    column: $table.wochentag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ketteId => $composableBuilder(
    column: $table.ketteId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WochenregelTableAnnotationComposer
    extends Composer<_$StoppDatenbank, $WochenregelTable> {
  $$WochenregelTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get wochentag =>
      $composableBuilder(column: $table.wochentag, builder: (column) => column);

  GeneratedColumn<int> get ketteId =>
      $composableBuilder(column: $table.ketteId, builder: (column) => column);
}

class $$WochenregelTableTableManager
    extends
        RootTableManager<
          _$StoppDatenbank,
          $WochenregelTable,
          WochenregelZeile,
          $$WochenregelTableFilterComposer,
          $$WochenregelTableOrderingComposer,
          $$WochenregelTableAnnotationComposer,
          $$WochenregelTableCreateCompanionBuilder,
          $$WochenregelTableUpdateCompanionBuilder,
          (
            WochenregelZeile,
            BaseReferences<
              _$StoppDatenbank,
              $WochenregelTable,
              WochenregelZeile
            >,
          ),
          WochenregelZeile,
          PrefetchHooks Function()
        > {
  $$WochenregelTableTableManager(_$StoppDatenbank db, $WochenregelTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WochenregelTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WochenregelTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WochenregelTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> wochentag = const Value.absent(),
            Value<int?> ketteId = const Value.absent(),
          }) => WochenregelCompanion(wochentag: wochentag, ketteId: ketteId),
          createCompanionCallback:
              ({
                Value<int> wochentag = const Value.absent(),
                Value<int?> ketteId = const Value.absent(),
              }) => WochenregelCompanion.insert(
                wochentag: wochentag,
                ketteId: ketteId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WochenregelTable, WochenregelZeile>(table),
                  BaseReferences<
                    _$StoppDatenbank,
                    $WochenregelTable,
                    WochenregelZeile
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WochenregelTableProcessedTableManager =
    ProcessedTableManager<
      _$StoppDatenbank,
      $WochenregelTable,
      WochenregelZeile,
      $$WochenregelTableFilterComposer,
      $$WochenregelTableOrderingComposer,
      $$WochenregelTableAnnotationComposer,
      $$WochenregelTableCreateCompanionBuilder,
      $$WochenregelTableUpdateCompanionBuilder,
      (
        WochenregelZeile,
        BaseReferences<_$StoppDatenbank, $WochenregelTable, WochenregelZeile>,
      ),
      WochenregelZeile,
      PrefetchHooks Function()
    >;
typedef $$TagesausnahmenTableCreateCompanionBuilder =
    TagesausnahmenCompanion Function({
      required String tag,
      Value<int?> ketteId,
      Value<int> rowid,
    });
typedef $$TagesausnahmenTableUpdateCompanionBuilder =
    TagesausnahmenCompanion Function({
      Value<String> tag,
      Value<int?> ketteId,
      Value<int> rowid,
    });

class $$TagesausnahmenTableFilterComposer
    extends Composer<_$StoppDatenbank, $TagesausnahmenTable> {
  $$TagesausnahmenTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ketteId => $composableBuilder(
    column: $table.ketteId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TagesausnahmenTableOrderingComposer
    extends Composer<_$StoppDatenbank, $TagesausnahmenTable> {
  $$TagesausnahmenTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ketteId => $composableBuilder(
    column: $table.ketteId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagesausnahmenTableAnnotationComposer
    extends Composer<_$StoppDatenbank, $TagesausnahmenTable> {
  $$TagesausnahmenTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  GeneratedColumn<int> get ketteId =>
      $composableBuilder(column: $table.ketteId, builder: (column) => column);
}

class $$TagesausnahmenTableTableManager
    extends
        RootTableManager<
          _$StoppDatenbank,
          $TagesausnahmenTable,
          TagesausnahmeZeile,
          $$TagesausnahmenTableFilterComposer,
          $$TagesausnahmenTableOrderingComposer,
          $$TagesausnahmenTableAnnotationComposer,
          $$TagesausnahmenTableCreateCompanionBuilder,
          $$TagesausnahmenTableUpdateCompanionBuilder,
          (
            TagesausnahmeZeile,
            BaseReferences<
              _$StoppDatenbank,
              $TagesausnahmenTable,
              TagesausnahmeZeile
            >,
          ),
          TagesausnahmeZeile,
          PrefetchHooks Function()
        > {
  $$TagesausnahmenTableTableManager(
    _$StoppDatenbank db,
    $TagesausnahmenTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagesausnahmenTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagesausnahmenTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagesausnahmenTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> tag = const Value.absent(),
                Value<int?> ketteId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagesausnahmenCompanion(
                tag: tag,
                ketteId: ketteId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tag,
                Value<int?> ketteId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagesausnahmenCompanion.insert(
                tag: tag,
                ketteId: ketteId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TagesausnahmenTable, TagesausnahmeZeile>(table),
                  BaseReferences<
                    _$StoppDatenbank,
                    $TagesausnahmenTable,
                    TagesausnahmeZeile
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TagesausnahmenTableProcessedTableManager =
    ProcessedTableManager<
      _$StoppDatenbank,
      $TagesausnahmenTable,
      TagesausnahmeZeile,
      $$TagesausnahmenTableFilterComposer,
      $$TagesausnahmenTableOrderingComposer,
      $$TagesausnahmenTableAnnotationComposer,
      $$TagesausnahmenTableCreateCompanionBuilder,
      $$TagesausnahmenTableUpdateCompanionBuilder,
      (
        TagesausnahmeZeile,
        BaseReferences<
          _$StoppDatenbank,
          $TagesausnahmenTable,
          TagesausnahmeZeile
        >,
      ),
      TagesausnahmeZeile,
      PrefetchHooks Function()
    >;
typedef $$MessungenTableCreateCompanionBuilder = MessungenCompanion Function({
  Value<int> id,
  required int ereignisId,
  required int start,
  Value<int?> stopp,
  required String tag,
  Value<String?> ketteName,
  Value<int?> schrittPosition,
});
typedef $$MessungenTableUpdateCompanionBuilder = MessungenCompanion Function({
  Value<int> id,
  Value<int> ereignisId,
  Value<int> start,
  Value<int?> stopp,
  Value<String> tag,
  Value<String?> ketteName,
  Value<int?> schrittPosition,
});

class $$MessungenTableFilterComposer
    extends Composer<_$StoppDatenbank, $MessungenTable> {
  $$MessungenTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ereignisId => $composableBuilder(
    column: $table.ereignisId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get start => $composableBuilder(
    column: $table.start,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stopp => $composableBuilder(
    column: $table.stopp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ketteName => $composableBuilder(
    column: $table.ketteName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schrittPosition => $composableBuilder(
    column: $table.schrittPosition,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessungenTableOrderingComposer
    extends Composer<_$StoppDatenbank, $MessungenTable> {
  $$MessungenTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ereignisId => $composableBuilder(
    column: $table.ereignisId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get start => $composableBuilder(
    column: $table.start,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stopp => $composableBuilder(
    column: $table.stopp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ketteName => $composableBuilder(
    column: $table.ketteName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schrittPosition => $composableBuilder(
    column: $table.schrittPosition,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessungenTableAnnotationComposer
    extends Composer<_$StoppDatenbank, $MessungenTable> {
  $$MessungenTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ereignisId => $composableBuilder(
    column: $table.ereignisId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get start =>
      $composableBuilder(column: $table.start, builder: (column) => column);

  GeneratedColumn<int> get stopp =>
      $composableBuilder(column: $table.stopp, builder: (column) => column);

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  GeneratedColumn<String> get ketteName =>
      $composableBuilder(column: $table.ketteName, builder: (column) => column);

  GeneratedColumn<int> get schrittPosition => $composableBuilder(
    column: $table.schrittPosition,
    builder: (column) => column,
  );
}

class $$MessungenTableTableManager
    extends
        RootTableManager<
          _$StoppDatenbank,
          $MessungenTable,
          MessungZeile,
          $$MessungenTableFilterComposer,
          $$MessungenTableOrderingComposer,
          $$MessungenTableAnnotationComposer,
          $$MessungenTableCreateCompanionBuilder,
          $$MessungenTableUpdateCompanionBuilder,
          (
            MessungZeile,
            BaseReferences<_$StoppDatenbank, $MessungenTable, MessungZeile>,
          ),
          MessungZeile,
          PrefetchHooks Function()
        > {
  $$MessungenTableTableManager(_$StoppDatenbank db, $MessungenTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessungenTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessungenTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessungenTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> ereignisId = const Value.absent(),
                Value<int> start = const Value.absent(),
                Value<int?> stopp = const Value.absent(),
                Value<String> tag = const Value.absent(),
                Value<String?> ketteName = const Value.absent(),
                Value<int?> schrittPosition = const Value.absent(),
              }) => MessungenCompanion(
                id: id,
                ereignisId: ereignisId,
                start: start,
                stopp: stopp,
                tag: tag,
                ketteName: ketteName,
                schrittPosition: schrittPosition,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int ereignisId,
                required int start,
                Value<int?> stopp = const Value.absent(),
                required String tag,
                Value<String?> ketteName = const Value.absent(),
                Value<int?> schrittPosition = const Value.absent(),
              }) => MessungenCompanion.insert(
                id: id,
                ereignisId: ereignisId,
                start: start,
                stopp: stopp,
                tag: tag,
                ketteName: ketteName,
                schrittPosition: schrittPosition,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MessungenTable, MessungZeile>(table),
                  BaseReferences<
                    _$StoppDatenbank,
                    $MessungenTable,
                    MessungZeile
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessungenTableProcessedTableManager =
    ProcessedTableManager<
      _$StoppDatenbank,
      $MessungenTable,
      MessungZeile,
      $$MessungenTableFilterComposer,
      $$MessungenTableOrderingComposer,
      $$MessungenTableAnnotationComposer,
      $$MessungenTableCreateCompanionBuilder,
      $$MessungenTableUpdateCompanionBuilder,
      (
        MessungZeile,
        BaseReferences<_$StoppDatenbank, $MessungenTable, MessungZeile>,
      ),
      MessungZeile,
      PrefetchHooks Function()
    >;
typedef $$TageslaeufeTableCreateCompanionBuilder =
    TageslaeufeCompanion Function({
      required String tag,
      Value<int?> ketteId,
      required String ketteName,
      required String schritte,
      Value<int?> naechster,
      Value<int> rowid,
    });
typedef $$TageslaeufeTableUpdateCompanionBuilder =
    TageslaeufeCompanion Function({
      Value<String> tag,
      Value<int?> ketteId,
      Value<String> ketteName,
      Value<String> schritte,
      Value<int?> naechster,
      Value<int> rowid,
    });

class $$TageslaeufeTableFilterComposer
    extends Composer<_$StoppDatenbank, $TageslaeufeTable> {
  $$TageslaeufeTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ketteId => $composableBuilder(
    column: $table.ketteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ketteName => $composableBuilder(
    column: $table.ketteName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schritte => $composableBuilder(
    column: $table.schritte,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get naechster => $composableBuilder(
    column: $table.naechster,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TageslaeufeTableOrderingComposer
    extends Composer<_$StoppDatenbank, $TageslaeufeTable> {
  $$TageslaeufeTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ketteId => $composableBuilder(
    column: $table.ketteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ketteName => $composableBuilder(
    column: $table.ketteName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schritte => $composableBuilder(
    column: $table.schritte,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get naechster => $composableBuilder(
    column: $table.naechster,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TageslaeufeTableAnnotationComposer
    extends Composer<_$StoppDatenbank, $TageslaeufeTable> {
  $$TageslaeufeTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  GeneratedColumn<int> get ketteId =>
      $composableBuilder(column: $table.ketteId, builder: (column) => column);

  GeneratedColumn<String> get ketteName =>
      $composableBuilder(column: $table.ketteName, builder: (column) => column);

  GeneratedColumn<String> get schritte =>
      $composableBuilder(column: $table.schritte, builder: (column) => column);

  GeneratedColumn<int> get naechster =>
      $composableBuilder(column: $table.naechster, builder: (column) => column);
}

class $$TageslaeufeTableTableManager
    extends
        RootTableManager<
          _$StoppDatenbank,
          $TageslaeufeTable,
          TageslaufZeile,
          $$TageslaeufeTableFilterComposer,
          $$TageslaeufeTableOrderingComposer,
          $$TageslaeufeTableAnnotationComposer,
          $$TageslaeufeTableCreateCompanionBuilder,
          $$TageslaeufeTableUpdateCompanionBuilder,
          (
            TageslaufZeile,
            BaseReferences<_$StoppDatenbank, $TageslaeufeTable, TageslaufZeile>,
          ),
          TageslaufZeile,
          PrefetchHooks Function()
        > {
  $$TageslaeufeTableTableManager(_$StoppDatenbank db, $TageslaeufeTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TageslaeufeTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TageslaeufeTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TageslaeufeTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> tag = const Value.absent(),
                Value<int?> ketteId = const Value.absent(),
                Value<String> ketteName = const Value.absent(),
                Value<String> schritte = const Value.absent(),
                Value<int?> naechster = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TageslaeufeCompanion(
                tag: tag,
                ketteId: ketteId,
                ketteName: ketteName,
                schritte: schritte,
                naechster: naechster,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tag,
                Value<int?> ketteId = const Value.absent(),
                required String ketteName,
                required String schritte,
                Value<int?> naechster = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TageslaeufeCompanion.insert(
                tag: tag,
                ketteId: ketteId,
                ketteName: ketteName,
                schritte: schritte,
                naechster: naechster,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TageslaeufeTable, TageslaufZeile>(table),
                  BaseReferences<
                    _$StoppDatenbank,
                    $TageslaeufeTable,
                    TageslaufZeile
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TageslaeufeTableProcessedTableManager =
    ProcessedTableManager<
      _$StoppDatenbank,
      $TageslaeufeTable,
      TageslaufZeile,
      $$TageslaeufeTableFilterComposer,
      $$TageslaeufeTableOrderingComposer,
      $$TageslaeufeTableAnnotationComposer,
      $$TageslaeufeTableCreateCompanionBuilder,
      $$TageslaeufeTableUpdateCompanionBuilder,
      (
        TageslaufZeile,
        BaseReferences<_$StoppDatenbank, $TageslaeufeTable, TageslaufZeile>,
      ),
      TageslaufZeile,
      PrefetchHooks Function()
    >;
typedef $$UebersprungenTableCreateCompanionBuilder =
    UebersprungenCompanion Function({
      required String tag,
      required int position,
      Value<int> rowid,
    });
typedef $$UebersprungenTableUpdateCompanionBuilder =
    UebersprungenCompanion Function({
      Value<String> tag,
      Value<int> position,
      Value<int> rowid,
    });

class $$UebersprungenTableFilterComposer
    extends Composer<_$StoppDatenbank, $UebersprungenTable> {
  $$UebersprungenTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UebersprungenTableOrderingComposer
    extends Composer<_$StoppDatenbank, $UebersprungenTable> {
  $$UebersprungenTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UebersprungenTableAnnotationComposer
    extends Composer<_$StoppDatenbank, $UebersprungenTable> {
  $$UebersprungenTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$UebersprungenTableTableManager
    extends
        RootTableManager<
          _$StoppDatenbank,
          $UebersprungenTable,
          UebersprungenZeile,
          $$UebersprungenTableFilterComposer,
          $$UebersprungenTableOrderingComposer,
          $$UebersprungenTableAnnotationComposer,
          $$UebersprungenTableCreateCompanionBuilder,
          $$UebersprungenTableUpdateCompanionBuilder,
          (
            UebersprungenZeile,
            BaseReferences<
              _$StoppDatenbank,
              $UebersprungenTable,
              UebersprungenZeile
            >,
          ),
          UebersprungenZeile,
          PrefetchHooks Function()
        > {
  $$UebersprungenTableTableManager(
    _$StoppDatenbank db,
    $UebersprungenTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UebersprungenTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UebersprungenTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UebersprungenTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> tag = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UebersprungenCompanion(
                tag: tag,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tag,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => UebersprungenCompanion.insert(
                tag: tag,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UebersprungenTable, UebersprungenZeile>(table),
                  BaseReferences<
                    _$StoppDatenbank,
                    $UebersprungenTable,
                    UebersprungenZeile
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UebersprungenTableProcessedTableManager =
    ProcessedTableManager<
      _$StoppDatenbank,
      $UebersprungenTable,
      UebersprungenZeile,
      $$UebersprungenTableFilterComposer,
      $$UebersprungenTableOrderingComposer,
      $$UebersprungenTableAnnotationComposer,
      $$UebersprungenTableCreateCompanionBuilder,
      $$UebersprungenTableUpdateCompanionBuilder,
      (
        UebersprungenZeile,
        BaseReferences<
          _$StoppDatenbank,
          $UebersprungenTable,
          UebersprungenZeile
        >,
      ),
      UebersprungenZeile,
      PrefetchHooks Function()
    >;
typedef $$EinstellungenTableCreateCompanionBuilder =
    EinstellungenCompanion Function({
      required String schluessel,
      required String wert,
      Value<int> rowid,
    });
typedef $$EinstellungenTableUpdateCompanionBuilder =
    EinstellungenCompanion Function({
      Value<String> schluessel,
      Value<String> wert,
      Value<int> rowid,
    });

class $$EinstellungenTableFilterComposer
    extends Composer<_$StoppDatenbank, $EinstellungenTable> {
  $$EinstellungenTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get schluessel => $composableBuilder(
    column: $table.schluessel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wert => $composableBuilder(
    column: $table.wert,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EinstellungenTableOrderingComposer
    extends Composer<_$StoppDatenbank, $EinstellungenTable> {
  $$EinstellungenTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get schluessel => $composableBuilder(
    column: $table.schluessel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wert => $composableBuilder(
    column: $table.wert,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EinstellungenTableAnnotationComposer
    extends Composer<_$StoppDatenbank, $EinstellungenTable> {
  $$EinstellungenTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get schluessel => $composableBuilder(
    column: $table.schluessel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get wert =>
      $composableBuilder(column: $table.wert, builder: (column) => column);
}

class $$EinstellungenTableTableManager
    extends
        RootTableManager<
          _$StoppDatenbank,
          $EinstellungenTable,
          EinstellungZeile,
          $$EinstellungenTableFilterComposer,
          $$EinstellungenTableOrderingComposer,
          $$EinstellungenTableAnnotationComposer,
          $$EinstellungenTableCreateCompanionBuilder,
          $$EinstellungenTableUpdateCompanionBuilder,
          (
            EinstellungZeile,
            BaseReferences<
              _$StoppDatenbank,
              $EinstellungenTable,
              EinstellungZeile
            >,
          ),
          EinstellungZeile,
          PrefetchHooks Function()
        > {
  $$EinstellungenTableTableManager(
    _$StoppDatenbank db,
    $EinstellungenTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EinstellungenTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EinstellungenTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EinstellungenTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> schluessel = const Value.absent(),
                Value<String> wert = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EinstellungenCompanion(
                schluessel: schluessel,
                wert: wert,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String schluessel,
                required String wert,
                Value<int> rowid = const Value.absent(),
              }) => EinstellungenCompanion.insert(
                schluessel: schluessel,
                wert: wert,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EinstellungenTable, EinstellungZeile>(table),
                  BaseReferences<
                    _$StoppDatenbank,
                    $EinstellungenTable,
                    EinstellungZeile
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EinstellungenTableProcessedTableManager =
    ProcessedTableManager<
      _$StoppDatenbank,
      $EinstellungenTable,
      EinstellungZeile,
      $$EinstellungenTableFilterComposer,
      $$EinstellungenTableOrderingComposer,
      $$EinstellungenTableAnnotationComposer,
      $$EinstellungenTableCreateCompanionBuilder,
      $$EinstellungenTableUpdateCompanionBuilder,
      (
        EinstellungZeile,
        BaseReferences<_$StoppDatenbank, $EinstellungenTable, EinstellungZeile>,
      ),
      EinstellungZeile,
      PrefetchHooks Function()
    >;

class $StoppDatenbankManager {
  final _$StoppDatenbank _db;
  $StoppDatenbankManager(this._db);
  $$EreignisseTableTableManager get ereignisse =>
      $$EreignisseTableTableManager(_db, _db.ereignisse);
  $$KettenTableTableManager get ketten =>
      $$KettenTableTableManager(_db, _db.ketten);
  $$SchritteTableTableManager get schritte =>
      $$SchritteTableTableManager(_db, _db.schritte);
  $$WochenregelTableTableManager get wochenregel =>
      $$WochenregelTableTableManager(_db, _db.wochenregel);
  $$TagesausnahmenTableTableManager get tagesausnahmen =>
      $$TagesausnahmenTableTableManager(_db, _db.tagesausnahmen);
  $$MessungenTableTableManager get messungen =>
      $$MessungenTableTableManager(_db, _db.messungen);
  $$TageslaeufeTableTableManager get tageslaeufe =>
      $$TageslaeufeTableTableManager(_db, _db.tageslaeufe);
  $$UebersprungenTableTableManager get uebersprungen =>
      $$UebersprungenTableTableManager(_db, _db.uebersprungen);
  $$EinstellungenTableTableManager get einstellungen =>
      $$EinstellungenTableTableManager(_db, _db.einstellungen);
}
