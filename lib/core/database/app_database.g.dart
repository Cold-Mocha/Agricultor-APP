// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalProfilesTable extends LocalProfiles
    with TableInfo<$LocalProfilesTable, LocalProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailDisplayMeta = const VerificationMeta(
    'emailDisplay',
  );
  @override
  late final GeneratedColumn<String> emailDisplay = GeneratedColumn<String>(
    'email_display',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('es_CL'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    emailDisplay,
    locale,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('email_display')) {
      context.handle(
        _emailDisplayMeta,
        emailDisplay.isAcceptableOrUnknown(
          data['email_display']!,
          _emailDisplayMeta,
        ),
      );
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      emailDisplay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email_display'],
      ),
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalProfilesTable createAlias(String alias) {
    return $LocalProfilesTable(attachedDatabase, alias);
  }
}

class LocalProfile extends DataClass implements Insertable<LocalProfile> {
  final String id;
  final String displayName;
  final String? emailDisplay;
  final String locale;
  final DateTime updatedAt;
  const LocalProfile({
    required this.id,
    required this.displayName,
    this.emailDisplay,
    required this.locale,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || emailDisplay != null) {
      map['email_display'] = Variable<String>(emailDisplay);
    }
    map['locale'] = Variable<String>(locale);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalProfilesCompanion toCompanion(bool nullToAbsent) {
    return LocalProfilesCompanion(
      id: Value(id),
      displayName: Value(displayName),
      emailDisplay: emailDisplay == null && nullToAbsent
          ? const Value.absent()
          : Value(emailDisplay),
      locale: Value(locale),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalProfile(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      emailDisplay: serializer.fromJson<String?>(json['emailDisplay']),
      locale: serializer.fromJson<String>(json['locale']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'emailDisplay': serializer.toJson<String?>(emailDisplay),
      'locale': serializer.toJson<String>(locale),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalProfile copyWith({
    String? id,
    String? displayName,
    Value<String?> emailDisplay = const Value.absent(),
    String? locale,
    DateTime? updatedAt,
  }) => LocalProfile(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    emailDisplay: emailDisplay.present ? emailDisplay.value : this.emailDisplay,
    locale: locale ?? this.locale,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalProfile copyWithCompanion(LocalProfilesCompanion data) {
    return LocalProfile(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      emailDisplay: data.emailDisplay.present
          ? data.emailDisplay.value
          : this.emailDisplay,
      locale: data.locale.present ? data.locale.value : this.locale,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalProfile(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('emailDisplay: $emailDisplay, ')
          ..write('locale: $locale, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, displayName, emailDisplay, locale, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalProfile &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.emailDisplay == this.emailDisplay &&
          other.locale == this.locale &&
          other.updatedAt == this.updatedAt);
}

class LocalProfilesCompanion extends UpdateCompanion<LocalProfile> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<String?> emailDisplay;
  final Value<String> locale;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalProfilesCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.emailDisplay = const Value.absent(),
    this.locale = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalProfilesCompanion.insert({
    required String id,
    required String displayName,
    this.emailDisplay = const Value.absent(),
    this.locale = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayName = Value(displayName),
       updatedAt = Value(updatedAt);
  static Insertable<LocalProfile> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<String>? emailDisplay,
    Expression<String>? locale,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (emailDisplay != null) 'email_display': emailDisplay,
      if (locale != null) 'locale': locale,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? displayName,
    Value<String?>? emailDisplay,
    Value<String>? locale,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalProfilesCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      emailDisplay: emailDisplay ?? this.emailDisplay,
      locale: locale ?? this.locale,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (emailDisplay.present) {
      map['email_display'] = Variable<String>(emailDisplay.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalProfilesCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('emailDisplay: $emailDisplay, ')
          ..write('locale: $locale, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppPreferencesTable extends AppPreferences
    with TableInfo<$AppPreferencesTable, AppPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [ownerId, key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerId, key};
  @override
  AppPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppPreference(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppPreferencesTable createAlias(String alias) {
    return $AppPreferencesTable(attachedDatabase, alias);
  }
}

class AppPreference extends DataClass implements Insertable<AppPreference> {
  final String ownerId;
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppPreference({
    required this.ownerId,
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppPreferencesCompanion toCompanion(bool nullToAbsent) {
    return AppPreferencesCompanion(
      ownerId: Value(ownerId),
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppPreference(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppPreference copyWith({
    String? ownerId,
    String? key,
    String? value,
    DateTime? updatedAt,
  }) => AppPreference(
    ownerId: ownerId ?? this.ownerId,
    key: key ?? this.key,
    value: value ?? this.value,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppPreference copyWithCompanion(AppPreferencesCompanion data) {
    return AppPreference(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppPreference(')
          ..write('ownerId: $ownerId, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(ownerId, key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppPreference &&
          other.ownerId == this.ownerId &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppPreferencesCompanion extends UpdateCompanion<AppPreference> {
  final Value<String> ownerId;
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppPreferencesCompanion({
    this.ownerId = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppPreferencesCompanion.insert({
    required String ownerId,
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<AppPreference> custom({
    Expression<String>? ownerId,
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppPreferencesCompanion copyWith({
    Value<String>? ownerId,
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppPreferencesCompanion(
      ownerId: ownerId ?? this.ownerId,
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppPreferencesCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, SyncOutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _operationIdMeta = const VerificationMeta(
    'operationId',
  );
  @override
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
    'operation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aggregateTypeMeta = const VerificationMeta(
    'aggregateType',
  );
  @override
  late final GeneratedColumn<String> aggregateType = GeneratedColumn<String>(
    'aggregate_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aggregateIdMeta = const VerificationMeta(
    'aggregateId',
  );
  @override
  late final GeneratedColumn<String> aggregateId = GeneratedColumn<String>(
    'aggregate_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mutationKindMeta = const VerificationMeta(
    'mutationKind',
  );
  @override
  late final GeneratedColumn<String> mutationKind = GeneratedColumn<String>(
    'mutation_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseVersionMeta = const VerificationMeta(
    'baseVersion',
  );
  @override
  late final GeneratedColumn<int> baseVersion = GeneratedColumn<int>(
    'base_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dependencyOperationIdMeta =
      const VerificationMeta('dependencyOperationId');
  @override
  late final GeneratedColumn<String> dependencyOperationId =
      GeneratedColumn<String>(
        'dependency_operation_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorCodeMeta = const VerificationMeta(
    'lastErrorCode',
  );
  @override
  late final GeneratedColumn<String> lastErrorCode = GeneratedColumn<String>(
    'last_error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    operationId,
    ownerId,
    aggregateType,
    aggregateId,
    mutationKind,
    baseVersion,
    payloadJson,
    dependencyOperationId,
    state,
    attemptCount,
    nextAttemptAt,
    lastErrorCode,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('operation_id')) {
      context.handle(
        _operationIdMeta,
        operationId.isAcceptableOrUnknown(
          data['operation_id']!,
          _operationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('aggregate_type')) {
      context.handle(
        _aggregateTypeMeta,
        aggregateType.isAcceptableOrUnknown(
          data['aggregate_type']!,
          _aggregateTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aggregateTypeMeta);
    }
    if (data.containsKey('aggregate_id')) {
      context.handle(
        _aggregateIdMeta,
        aggregateId.isAcceptableOrUnknown(
          data['aggregate_id']!,
          _aggregateIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aggregateIdMeta);
    }
    if (data.containsKey('mutation_kind')) {
      context.handle(
        _mutationKindMeta,
        mutationKind.isAcceptableOrUnknown(
          data['mutation_kind']!,
          _mutationKindMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mutationKindMeta);
    }
    if (data.containsKey('base_version')) {
      context.handle(
        _baseVersionMeta,
        baseVersion.isAcceptableOrUnknown(
          data['base_version']!,
          _baseVersionMeta,
        ),
      );
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('dependency_operation_id')) {
      context.handle(
        _dependencyOperationIdMeta,
        dependencyOperationId.isAcceptableOrUnknown(
          data['dependency_operation_id']!,
          _dependencyOperationIdMeta,
        ),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error_code')) {
      context.handle(
        _lastErrorCodeMeta,
        lastErrorCode.isAcceptableOrUnknown(
          data['last_error_code']!,
          _lastErrorCodeMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {operationId};
  @override
  SyncOutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxData(
      operationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      aggregateType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aggregate_type'],
      )!,
      aggregateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aggregate_id'],
      )!,
      mutationKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mutation_kind'],
      )!,
      baseVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_version'],
      ),
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      dependencyOperationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dependency_operation_id'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
      lastErrorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_code'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }
}

class SyncOutboxData extends DataClass implements Insertable<SyncOutboxData> {
  final String operationId;
  final String ownerId;
  final String aggregateType;
  final String aggregateId;
  final String mutationKind;
  final int? baseVersion;
  final String payloadJson;
  final String? dependencyOperationId;
  final String state;
  final int attemptCount;
  final DateTime? nextAttemptAt;
  final String? lastErrorCode;
  final DateTime createdAt;
  const SyncOutboxData({
    required this.operationId,
    required this.ownerId,
    required this.aggregateType,
    required this.aggregateId,
    required this.mutationKind,
    this.baseVersion,
    required this.payloadJson,
    this.dependencyOperationId,
    required this.state,
    required this.attemptCount,
    this.nextAttemptAt,
    this.lastErrorCode,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['operation_id'] = Variable<String>(operationId);
    map['owner_id'] = Variable<String>(ownerId);
    map['aggregate_type'] = Variable<String>(aggregateType);
    map['aggregate_id'] = Variable<String>(aggregateId);
    map['mutation_kind'] = Variable<String>(mutationKind);
    if (!nullToAbsent || baseVersion != null) {
      map['base_version'] = Variable<int>(baseVersion);
    }
    map['payload_json'] = Variable<String>(payloadJson);
    if (!nullToAbsent || dependencyOperationId != null) {
      map['dependency_operation_id'] = Variable<String>(dependencyOperationId);
    }
    map['state'] = Variable<String>(state);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    if (!nullToAbsent || lastErrorCode != null) {
      map['last_error_code'] = Variable<String>(lastErrorCode);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      operationId: Value(operationId),
      ownerId: Value(ownerId),
      aggregateType: Value(aggregateType),
      aggregateId: Value(aggregateId),
      mutationKind: Value(mutationKind),
      baseVersion: baseVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(baseVersion),
      payloadJson: Value(payloadJson),
      dependencyOperationId: dependencyOperationId == null && nullToAbsent
          ? const Value.absent()
          : Value(dependencyOperationId),
      state: Value(state),
      attemptCount: Value(attemptCount),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      lastErrorCode: lastErrorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorCode),
      createdAt: Value(createdAt),
    );
  }

  factory SyncOutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxData(
      operationId: serializer.fromJson<String>(json['operationId']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      aggregateType: serializer.fromJson<String>(json['aggregateType']),
      aggregateId: serializer.fromJson<String>(json['aggregateId']),
      mutationKind: serializer.fromJson<String>(json['mutationKind']),
      baseVersion: serializer.fromJson<int?>(json['baseVersion']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      dependencyOperationId: serializer.fromJson<String?>(
        json['dependencyOperationId'],
      ),
      state: serializer.fromJson<String>(json['state']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      lastErrorCode: serializer.fromJson<String?>(json['lastErrorCode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'operationId': serializer.toJson<String>(operationId),
      'ownerId': serializer.toJson<String>(ownerId),
      'aggregateType': serializer.toJson<String>(aggregateType),
      'aggregateId': serializer.toJson<String>(aggregateId),
      'mutationKind': serializer.toJson<String>(mutationKind),
      'baseVersion': serializer.toJson<int?>(baseVersion),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'dependencyOperationId': serializer.toJson<String?>(
        dependencyOperationId,
      ),
      'state': serializer.toJson<String>(state),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'lastErrorCode': serializer.toJson<String?>(lastErrorCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncOutboxData copyWith({
    String? operationId,
    String? ownerId,
    String? aggregateType,
    String? aggregateId,
    String? mutationKind,
    Value<int?> baseVersion = const Value.absent(),
    String? payloadJson,
    Value<String?> dependencyOperationId = const Value.absent(),
    String? state,
    int? attemptCount,
    Value<DateTime?> nextAttemptAt = const Value.absent(),
    Value<String?> lastErrorCode = const Value.absent(),
    DateTime? createdAt,
  }) => SyncOutboxData(
    operationId: operationId ?? this.operationId,
    ownerId: ownerId ?? this.ownerId,
    aggregateType: aggregateType ?? this.aggregateType,
    aggregateId: aggregateId ?? this.aggregateId,
    mutationKind: mutationKind ?? this.mutationKind,
    baseVersion: baseVersion.present ? baseVersion.value : this.baseVersion,
    payloadJson: payloadJson ?? this.payloadJson,
    dependencyOperationId: dependencyOperationId.present
        ? dependencyOperationId.value
        : this.dependencyOperationId,
    state: state ?? this.state,
    attemptCount: attemptCount ?? this.attemptCount,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    lastErrorCode: lastErrorCode.present
        ? lastErrorCode.value
        : this.lastErrorCode,
    createdAt: createdAt ?? this.createdAt,
  );
  SyncOutboxData copyWithCompanion(SyncOutboxCompanion data) {
    return SyncOutboxData(
      operationId: data.operationId.present
          ? data.operationId.value
          : this.operationId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      aggregateType: data.aggregateType.present
          ? data.aggregateType.value
          : this.aggregateType,
      aggregateId: data.aggregateId.present
          ? data.aggregateId.value
          : this.aggregateId,
      mutationKind: data.mutationKind.present
          ? data.mutationKind.value
          : this.mutationKind,
      baseVersion: data.baseVersion.present
          ? data.baseVersion.value
          : this.baseVersion,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      dependencyOperationId: data.dependencyOperationId.present
          ? data.dependencyOperationId.value
          : this.dependencyOperationId,
      state: data.state.present ? data.state.value : this.state,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      lastErrorCode: data.lastErrorCode.present
          ? data.lastErrorCode.value
          : this.lastErrorCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxData(')
          ..write('operationId: $operationId, ')
          ..write('ownerId: $ownerId, ')
          ..write('aggregateType: $aggregateType, ')
          ..write('aggregateId: $aggregateId, ')
          ..write('mutationKind: $mutationKind, ')
          ..write('baseVersion: $baseVersion, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('dependencyOperationId: $dependencyOperationId, ')
          ..write('state: $state, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    operationId,
    ownerId,
    aggregateType,
    aggregateId,
    mutationKind,
    baseVersion,
    payloadJson,
    dependencyOperationId,
    state,
    attemptCount,
    nextAttemptAt,
    lastErrorCode,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxData &&
          other.operationId == this.operationId &&
          other.ownerId == this.ownerId &&
          other.aggregateType == this.aggregateType &&
          other.aggregateId == this.aggregateId &&
          other.mutationKind == this.mutationKind &&
          other.baseVersion == this.baseVersion &&
          other.payloadJson == this.payloadJson &&
          other.dependencyOperationId == this.dependencyOperationId &&
          other.state == this.state &&
          other.attemptCount == this.attemptCount &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.lastErrorCode == this.lastErrorCode &&
          other.createdAt == this.createdAt);
}

class SyncOutboxCompanion extends UpdateCompanion<SyncOutboxData> {
  final Value<String> operationId;
  final Value<String> ownerId;
  final Value<String> aggregateType;
  final Value<String> aggregateId;
  final Value<String> mutationKind;
  final Value<int?> baseVersion;
  final Value<String> payloadJson;
  final Value<String?> dependencyOperationId;
  final Value<String> state;
  final Value<int> attemptCount;
  final Value<DateTime?> nextAttemptAt;
  final Value<String?> lastErrorCode;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SyncOutboxCompanion({
    this.operationId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.aggregateType = const Value.absent(),
    this.aggregateId = const Value.absent(),
    this.mutationKind = const Value.absent(),
    this.baseVersion = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.dependencyOperationId = const Value.absent(),
    this.state = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    required String operationId,
    required String ownerId,
    required String aggregateType,
    required String aggregateId,
    required String mutationKind,
    this.baseVersion = const Value.absent(),
    required String payloadJson,
    this.dependencyOperationId = const Value.absent(),
    this.state = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : operationId = Value(operationId),
       ownerId = Value(ownerId),
       aggregateType = Value(aggregateType),
       aggregateId = Value(aggregateId),
       mutationKind = Value(mutationKind),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<SyncOutboxData> custom({
    Expression<String>? operationId,
    Expression<String>? ownerId,
    Expression<String>? aggregateType,
    Expression<String>? aggregateId,
    Expression<String>? mutationKind,
    Expression<int>? baseVersion,
    Expression<String>? payloadJson,
    Expression<String>? dependencyOperationId,
    Expression<String>? state,
    Expression<int>? attemptCount,
    Expression<DateTime>? nextAttemptAt,
    Expression<String>? lastErrorCode,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (operationId != null) 'operation_id': operationId,
      if (ownerId != null) 'owner_id': ownerId,
      if (aggregateType != null) 'aggregate_type': aggregateType,
      if (aggregateId != null) 'aggregate_id': aggregateId,
      if (mutationKind != null) 'mutation_kind': mutationKind,
      if (baseVersion != null) 'base_version': baseVersion,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (dependencyOperationId != null)
        'dependency_operation_id': dependencyOperationId,
      if (state != null) 'state': state,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (lastErrorCode != null) 'last_error_code': lastErrorCode,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOutboxCompanion copyWith({
    Value<String>? operationId,
    Value<String>? ownerId,
    Value<String>? aggregateType,
    Value<String>? aggregateId,
    Value<String>? mutationKind,
    Value<int?>? baseVersion,
    Value<String>? payloadJson,
    Value<String?>? dependencyOperationId,
    Value<String>? state,
    Value<int>? attemptCount,
    Value<DateTime?>? nextAttemptAt,
    Value<String?>? lastErrorCode,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SyncOutboxCompanion(
      operationId: operationId ?? this.operationId,
      ownerId: ownerId ?? this.ownerId,
      aggregateType: aggregateType ?? this.aggregateType,
      aggregateId: aggregateId ?? this.aggregateId,
      mutationKind: mutationKind ?? this.mutationKind,
      baseVersion: baseVersion ?? this.baseVersion,
      payloadJson: payloadJson ?? this.payloadJson,
      dependencyOperationId:
          dependencyOperationId ?? this.dependencyOperationId,
      state: state ?? this.state,
      attemptCount: attemptCount ?? this.attemptCount,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (aggregateType.present) {
      map['aggregate_type'] = Variable<String>(aggregateType.value);
    }
    if (aggregateId.present) {
      map['aggregate_id'] = Variable<String>(aggregateId.value);
    }
    if (mutationKind.present) {
      map['mutation_kind'] = Variable<String>(mutationKind.value);
    }
    if (baseVersion.present) {
      map['base_version'] = Variable<int>(baseVersion.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (dependencyOperationId.present) {
      map['dependency_operation_id'] = Variable<String>(
        dependencyOperationId.value,
      );
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (lastErrorCode.present) {
      map['last_error_code'] = Variable<String>(lastErrorCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('operationId: $operationId, ')
          ..write('ownerId: $ownerId, ')
          ..write('aggregateType: $aggregateType, ')
          ..write('aggregateId: $aggregateId, ')
          ..write('mutationKind: $mutationKind, ')
          ..write('baseVersion: $baseVersion, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('dependencyOperationId: $dependencyOperationId, ')
          ..write('state: $state, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTable extends SyncCursors
    with TableInfo<$SyncCursorsTable, SyncCursor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _streamMeta = const VerificationMeta('stream');
  @override
  late final GeneratedColumn<String> stream = GeneratedColumn<String>(
    'stream',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastChangeSeqMeta = const VerificationMeta(
    'lastChangeSeq',
  );
  @override
  late final GeneratedColumn<int> lastChangeSeq = GeneratedColumn<int>(
    'last_change_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ownerId,
    stream,
    lastChangeSeq,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncCursor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('stream')) {
      context.handle(
        _streamMeta,
        stream.isAcceptableOrUnknown(data['stream']!, _streamMeta),
      );
    } else if (isInserting) {
      context.missing(_streamMeta);
    }
    if (data.containsKey('last_change_seq')) {
      context.handle(
        _lastChangeSeqMeta,
        lastChangeSeq.isAcceptableOrUnknown(
          data['last_change_seq']!,
          _lastChangeSeqMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerId, stream};
  @override
  SyncCursor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursor(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      stream: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stream'],
      )!,
      lastChangeSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_change_seq'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SyncCursorsTable createAlias(String alias) {
    return $SyncCursorsTable(attachedDatabase, alias);
  }
}

class SyncCursor extends DataClass implements Insertable<SyncCursor> {
  final String ownerId;
  final String stream;
  final int lastChangeSeq;
  final DateTime updatedAt;
  const SyncCursor({
    required this.ownerId,
    required this.stream,
    required this.lastChangeSeq,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    map['stream'] = Variable<String>(stream);
    map['last_change_seq'] = Variable<int>(lastChangeSeq);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsCompanion(
      ownerId: Value(ownerId),
      stream: Value(stream),
      lastChangeSeq: Value(lastChangeSeq),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncCursor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursor(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      stream: serializer.fromJson<String>(json['stream']),
      lastChangeSeq: serializer.fromJson<int>(json['lastChangeSeq']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'stream': serializer.toJson<String>(stream),
      'lastChangeSeq': serializer.toJson<int>(lastChangeSeq),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncCursor copyWith({
    String? ownerId,
    String? stream,
    int? lastChangeSeq,
    DateTime? updatedAt,
  }) => SyncCursor(
    ownerId: ownerId ?? this.ownerId,
    stream: stream ?? this.stream,
    lastChangeSeq: lastChangeSeq ?? this.lastChangeSeq,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SyncCursor copyWithCompanion(SyncCursorsCompanion data) {
    return SyncCursor(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      stream: data.stream.present ? data.stream.value : this.stream,
      lastChangeSeq: data.lastChangeSeq.present
          ? data.lastChangeSeq.value
          : this.lastChangeSeq,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursor(')
          ..write('ownerId: $ownerId, ')
          ..write('stream: $stream, ')
          ..write('lastChangeSeq: $lastChangeSeq, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(ownerId, stream, lastChangeSeq, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursor &&
          other.ownerId == this.ownerId &&
          other.stream == this.stream &&
          other.lastChangeSeq == this.lastChangeSeq &&
          other.updatedAt == this.updatedAt);
}

class SyncCursorsCompanion extends UpdateCompanion<SyncCursor> {
  final Value<String> ownerId;
  final Value<String> stream;
  final Value<int> lastChangeSeq;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SyncCursorsCompanion({
    this.ownerId = const Value.absent(),
    this.stream = const Value.absent(),
    this.lastChangeSeq = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorsCompanion.insert({
    required String ownerId,
    required String stream,
    this.lastChangeSeq = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       stream = Value(stream),
       updatedAt = Value(updatedAt);
  static Insertable<SyncCursor> custom({
    Expression<String>? ownerId,
    Expression<String>? stream,
    Expression<int>? lastChangeSeq,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (stream != null) 'stream': stream,
      if (lastChangeSeq != null) 'last_change_seq': lastChangeSeq,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorsCompanion copyWith({
    Value<String>? ownerId,
    Value<String>? stream,
    Value<int>? lastChangeSeq,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SyncCursorsCompanion(
      ownerId: ownerId ?? this.ownerId,
      stream: stream ?? this.stream,
      lastChangeSeq: lastChangeSeq ?? this.lastChangeSeq,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (stream.present) {
      map['stream'] = Variable<String>(stream.value);
    }
    if (lastChangeSeq.present) {
      map['last_change_seq'] = Variable<int>(lastChangeSeq.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('stream: $stream, ')
          ..write('lastChangeSeq: $lastChangeSeq, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncConflictsTable extends SyncConflicts
    with TableInfo<$SyncConflictsTable, SyncConflict> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncConflictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _conflictIdMeta = const VerificationMeta(
    'conflictId',
  );
  @override
  late final GeneratedColumn<String> conflictId = GeneratedColumn<String>(
    'conflict_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aggregateTypeMeta = const VerificationMeta(
    'aggregateType',
  );
  @override
  late final GeneratedColumn<String> aggregateType = GeneratedColumn<String>(
    'aggregate_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aggregateIdMeta = const VerificationMeta(
    'aggregateId',
  );
  @override
  late final GeneratedColumn<String> aggregateId = GeneratedColumn<String>(
    'aggregate_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localJsonMeta = const VerificationMeta(
    'localJson',
  );
  @override
  late final GeneratedColumn<String> localJson = GeneratedColumn<String>(
    'local_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteJsonMeta = const VerificationMeta(
    'remoteJson',
  );
  @override
  late final GeneratedColumn<String> remoteJson = GeneratedColumn<String>(
    'remote_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detectedAtMeta = const VerificationMeta(
    'detectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> detectedAt = GeneratedColumn<DateTime>(
    'detected_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    conflictId,
    ownerId,
    aggregateType,
    aggregateId,
    localJson,
    remoteJson,
    detectedAt,
    resolvedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncConflict> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('conflict_id')) {
      context.handle(
        _conflictIdMeta,
        conflictId.isAcceptableOrUnknown(data['conflict_id']!, _conflictIdMeta),
      );
    } else if (isInserting) {
      context.missing(_conflictIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('aggregate_type')) {
      context.handle(
        _aggregateTypeMeta,
        aggregateType.isAcceptableOrUnknown(
          data['aggregate_type']!,
          _aggregateTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aggregateTypeMeta);
    }
    if (data.containsKey('aggregate_id')) {
      context.handle(
        _aggregateIdMeta,
        aggregateId.isAcceptableOrUnknown(
          data['aggregate_id']!,
          _aggregateIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aggregateIdMeta);
    }
    if (data.containsKey('local_json')) {
      context.handle(
        _localJsonMeta,
        localJson.isAcceptableOrUnknown(data['local_json']!, _localJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_localJsonMeta);
    }
    if (data.containsKey('remote_json')) {
      context.handle(
        _remoteJsonMeta,
        remoteJson.isAcceptableOrUnknown(data['remote_json']!, _remoteJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteJsonMeta);
    }
    if (data.containsKey('detected_at')) {
      context.handle(
        _detectedAtMeta,
        detectedAt.isAcceptableOrUnknown(data['detected_at']!, _detectedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_detectedAtMeta);
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {conflictId};
  @override
  SyncConflict map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncConflict(
      conflictId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conflict_id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      aggregateType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aggregate_type'],
      )!,
      aggregateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aggregate_id'],
      )!,
      localJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_json'],
      )!,
      remoteJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_json'],
      )!,
      detectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}detected_at'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
    );
  }

  @override
  $SyncConflictsTable createAlias(String alias) {
    return $SyncConflictsTable(attachedDatabase, alias);
  }
}

class SyncConflict extends DataClass implements Insertable<SyncConflict> {
  final String conflictId;
  final String ownerId;
  final String aggregateType;
  final String aggregateId;
  final String localJson;
  final String remoteJson;
  final DateTime detectedAt;
  final DateTime? resolvedAt;
  const SyncConflict({
    required this.conflictId,
    required this.ownerId,
    required this.aggregateType,
    required this.aggregateId,
    required this.localJson,
    required this.remoteJson,
    required this.detectedAt,
    this.resolvedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['conflict_id'] = Variable<String>(conflictId);
    map['owner_id'] = Variable<String>(ownerId);
    map['aggregate_type'] = Variable<String>(aggregateType);
    map['aggregate_id'] = Variable<String>(aggregateId);
    map['local_json'] = Variable<String>(localJson);
    map['remote_json'] = Variable<String>(remoteJson);
    map['detected_at'] = Variable<DateTime>(detectedAt);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    return map;
  }

  SyncConflictsCompanion toCompanion(bool nullToAbsent) {
    return SyncConflictsCompanion(
      conflictId: Value(conflictId),
      ownerId: Value(ownerId),
      aggregateType: Value(aggregateType),
      aggregateId: Value(aggregateId),
      localJson: Value(localJson),
      remoteJson: Value(remoteJson),
      detectedAt: Value(detectedAt),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
    );
  }

  factory SyncConflict.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncConflict(
      conflictId: serializer.fromJson<String>(json['conflictId']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      aggregateType: serializer.fromJson<String>(json['aggregateType']),
      aggregateId: serializer.fromJson<String>(json['aggregateId']),
      localJson: serializer.fromJson<String>(json['localJson']),
      remoteJson: serializer.fromJson<String>(json['remoteJson']),
      detectedAt: serializer.fromJson<DateTime>(json['detectedAt']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'conflictId': serializer.toJson<String>(conflictId),
      'ownerId': serializer.toJson<String>(ownerId),
      'aggregateType': serializer.toJson<String>(aggregateType),
      'aggregateId': serializer.toJson<String>(aggregateId),
      'localJson': serializer.toJson<String>(localJson),
      'remoteJson': serializer.toJson<String>(remoteJson),
      'detectedAt': serializer.toJson<DateTime>(detectedAt),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
    };
  }

  SyncConflict copyWith({
    String? conflictId,
    String? ownerId,
    String? aggregateType,
    String? aggregateId,
    String? localJson,
    String? remoteJson,
    DateTime? detectedAt,
    Value<DateTime?> resolvedAt = const Value.absent(),
  }) => SyncConflict(
    conflictId: conflictId ?? this.conflictId,
    ownerId: ownerId ?? this.ownerId,
    aggregateType: aggregateType ?? this.aggregateType,
    aggregateId: aggregateId ?? this.aggregateId,
    localJson: localJson ?? this.localJson,
    remoteJson: remoteJson ?? this.remoteJson,
    detectedAt: detectedAt ?? this.detectedAt,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
  );
  SyncConflict copyWithCompanion(SyncConflictsCompanion data) {
    return SyncConflict(
      conflictId: data.conflictId.present
          ? data.conflictId.value
          : this.conflictId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      aggregateType: data.aggregateType.present
          ? data.aggregateType.value
          : this.aggregateType,
      aggregateId: data.aggregateId.present
          ? data.aggregateId.value
          : this.aggregateId,
      localJson: data.localJson.present ? data.localJson.value : this.localJson,
      remoteJson: data.remoteJson.present
          ? data.remoteJson.value
          : this.remoteJson,
      detectedAt: data.detectedAt.present
          ? data.detectedAt.value
          : this.detectedAt,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflict(')
          ..write('conflictId: $conflictId, ')
          ..write('ownerId: $ownerId, ')
          ..write('aggregateType: $aggregateType, ')
          ..write('aggregateId: $aggregateId, ')
          ..write('localJson: $localJson, ')
          ..write('remoteJson: $remoteJson, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    conflictId,
    ownerId,
    aggregateType,
    aggregateId,
    localJson,
    remoteJson,
    detectedAt,
    resolvedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncConflict &&
          other.conflictId == this.conflictId &&
          other.ownerId == this.ownerId &&
          other.aggregateType == this.aggregateType &&
          other.aggregateId == this.aggregateId &&
          other.localJson == this.localJson &&
          other.remoteJson == this.remoteJson &&
          other.detectedAt == this.detectedAt &&
          other.resolvedAt == this.resolvedAt);
}

class SyncConflictsCompanion extends UpdateCompanion<SyncConflict> {
  final Value<String> conflictId;
  final Value<String> ownerId;
  final Value<String> aggregateType;
  final Value<String> aggregateId;
  final Value<String> localJson;
  final Value<String> remoteJson;
  final Value<DateTime> detectedAt;
  final Value<DateTime?> resolvedAt;
  final Value<int> rowid;
  const SyncConflictsCompanion({
    this.conflictId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.aggregateType = const Value.absent(),
    this.aggregateId = const Value.absent(),
    this.localJson = const Value.absent(),
    this.remoteJson = const Value.absent(),
    this.detectedAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncConflictsCompanion.insert({
    required String conflictId,
    required String ownerId,
    required String aggregateType,
    required String aggregateId,
    required String localJson,
    required String remoteJson,
    required DateTime detectedAt,
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : conflictId = Value(conflictId),
       ownerId = Value(ownerId),
       aggregateType = Value(aggregateType),
       aggregateId = Value(aggregateId),
       localJson = Value(localJson),
       remoteJson = Value(remoteJson),
       detectedAt = Value(detectedAt);
  static Insertable<SyncConflict> custom({
    Expression<String>? conflictId,
    Expression<String>? ownerId,
    Expression<String>? aggregateType,
    Expression<String>? aggregateId,
    Expression<String>? localJson,
    Expression<String>? remoteJson,
    Expression<DateTime>? detectedAt,
    Expression<DateTime>? resolvedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (conflictId != null) 'conflict_id': conflictId,
      if (ownerId != null) 'owner_id': ownerId,
      if (aggregateType != null) 'aggregate_type': aggregateType,
      if (aggregateId != null) 'aggregate_id': aggregateId,
      if (localJson != null) 'local_json': localJson,
      if (remoteJson != null) 'remote_json': remoteJson,
      if (detectedAt != null) 'detected_at': detectedAt,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncConflictsCompanion copyWith({
    Value<String>? conflictId,
    Value<String>? ownerId,
    Value<String>? aggregateType,
    Value<String>? aggregateId,
    Value<String>? localJson,
    Value<String>? remoteJson,
    Value<DateTime>? detectedAt,
    Value<DateTime?>? resolvedAt,
    Value<int>? rowid,
  }) {
    return SyncConflictsCompanion(
      conflictId: conflictId ?? this.conflictId,
      ownerId: ownerId ?? this.ownerId,
      aggregateType: aggregateType ?? this.aggregateType,
      aggregateId: aggregateId ?? this.aggregateId,
      localJson: localJson ?? this.localJson,
      remoteJson: remoteJson ?? this.remoteJson,
      detectedAt: detectedAt ?? this.detectedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (conflictId.present) {
      map['conflict_id'] = Variable<String>(conflictId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (aggregateType.present) {
      map['aggregate_type'] = Variable<String>(aggregateType.value);
    }
    if (aggregateId.present) {
      map['aggregate_id'] = Variable<String>(aggregateId.value);
    }
    if (localJson.present) {
      map['local_json'] = Variable<String>(localJson.value);
    }
    if (remoteJson.present) {
      map['remote_json'] = Variable<String>(remoteJson.value);
    }
    if (detectedAt.present) {
      map['detected_at'] = Variable<DateTime>(detectedAt.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictsCompanion(')
          ..write('conflictId: $conflictId, ')
          ..write('ownerId: $ownerId, ')
          ..write('aggregateType: $aggregateType, ')
          ..write('aggregateId: $aggregateId, ')
          ..write('localJson: $localJson, ')
          ..write('remoteJson: $remoteJson, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FormDraftsTable extends FormDrafts
    with TableInfo<$FormDraftsTable, FormDraft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FormDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _draftKeyMeta = const VerificationMeta(
    'draftKey',
  );
  @override
  late final GeneratedColumn<String> draftKey = GeneratedColumn<String>(
    'draft_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ownerId,
    draftKey,
    payloadJson,
    schemaVersion,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'form_drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<FormDraft> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('draft_key')) {
      context.handle(
        _draftKeyMeta,
        draftKey.isAcceptableOrUnknown(data['draft_key']!, _draftKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_draftKeyMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerId, draftKey};
  @override
  FormDraft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FormDraft(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      draftKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}draft_key'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FormDraftsTable createAlias(String alias) {
    return $FormDraftsTable(attachedDatabase, alias);
  }
}

class FormDraft extends DataClass implements Insertable<FormDraft> {
  final String ownerId;
  final String draftKey;
  final String payloadJson;
  final int schemaVersion;
  final DateTime updatedAt;
  const FormDraft({
    required this.ownerId,
    required this.draftKey,
    required this.payloadJson,
    required this.schemaVersion,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    map['draft_key'] = Variable<String>(draftKey);
    map['payload_json'] = Variable<String>(payloadJson);
    map['schema_version'] = Variable<int>(schemaVersion);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FormDraftsCompanion toCompanion(bool nullToAbsent) {
    return FormDraftsCompanion(
      ownerId: Value(ownerId),
      draftKey: Value(draftKey),
      payloadJson: Value(payloadJson),
      schemaVersion: Value(schemaVersion),
      updatedAt: Value(updatedAt),
    );
  }

  factory FormDraft.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FormDraft(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      draftKey: serializer.fromJson<String>(json['draftKey']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'draftKey': serializer.toJson<String>(draftKey),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FormDraft copyWith({
    String? ownerId,
    String? draftKey,
    String? payloadJson,
    int? schemaVersion,
    DateTime? updatedAt,
  }) => FormDraft(
    ownerId: ownerId ?? this.ownerId,
    draftKey: draftKey ?? this.draftKey,
    payloadJson: payloadJson ?? this.payloadJson,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FormDraft copyWithCompanion(FormDraftsCompanion data) {
    return FormDraft(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      draftKey: data.draftKey.present ? data.draftKey.value : this.draftKey,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FormDraft(')
          ..write('ownerId: $ownerId, ')
          ..write('draftKey: $draftKey, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(ownerId, draftKey, payloadJson, schemaVersion, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FormDraft &&
          other.ownerId == this.ownerId &&
          other.draftKey == this.draftKey &&
          other.payloadJson == this.payloadJson &&
          other.schemaVersion == this.schemaVersion &&
          other.updatedAt == this.updatedAt);
}

class FormDraftsCompanion extends UpdateCompanion<FormDraft> {
  final Value<String> ownerId;
  final Value<String> draftKey;
  final Value<String> payloadJson;
  final Value<int> schemaVersion;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FormDraftsCompanion({
    this.ownerId = const Value.absent(),
    this.draftKey = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FormDraftsCompanion.insert({
    required String ownerId,
    required String draftKey,
    required String payloadJson,
    this.schemaVersion = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       draftKey = Value(draftKey),
       payloadJson = Value(payloadJson),
       updatedAt = Value(updatedAt);
  static Insertable<FormDraft> custom({
    Expression<String>? ownerId,
    Expression<String>? draftKey,
    Expression<String>? payloadJson,
    Expression<int>? schemaVersion,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (draftKey != null) 'draft_key': draftKey,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FormDraftsCompanion copyWith({
    Value<String>? ownerId,
    Value<String>? draftKey,
    Value<String>? payloadJson,
    Value<int>? schemaVersion,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return FormDraftsCompanion(
      ownerId: ownerId ?? this.ownerId,
      draftKey: draftKey ?? this.draftKey,
      payloadJson: payloadJson ?? this.payloadJson,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (draftKey.present) {
      map['draft_key'] = Variable<String>(draftKey.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FormDraftsCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('draftKey: $draftKey, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ParcelsTable extends Parcels with TableInfo<$ParcelsTable, Parcel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParcelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localityMeta = const VerificationMeta(
    'locality',
  );
  @override
  late final GeneratedColumn<String> locality = GeneratedColumn<String>(
    'locality',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _polygonJsonMeta = const VerificationMeta(
    'polygonJson',
  );
  @override
  late final GeneratedColumn<String> polygonJson = GeneratedColumn<String>(
    'polygon_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _areaSquareMetersMeta = const VerificationMeta(
    'areaSquareMeters',
  );
  @override
  late final GeneratedColumn<double> areaSquareMeters = GeneratedColumn<double>(
    'area_square_meters',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    name,
    locality,
    polygonJson,
    areaSquareMeters,
    isActive,
    isArchived,
    version,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parcels';
  @override
  VerificationContext validateIntegrity(
    Insertable<Parcel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('locality')) {
      context.handle(
        _localityMeta,
        locality.isAcceptableOrUnknown(data['locality']!, _localityMeta),
      );
    }
    if (data.containsKey('polygon_json')) {
      context.handle(
        _polygonJsonMeta,
        polygonJson.isAcceptableOrUnknown(
          data['polygon_json']!,
          _polygonJsonMeta,
        ),
      );
    }
    if (data.containsKey('area_square_meters')) {
      context.handle(
        _areaSquareMetersMeta,
        areaSquareMeters.isAcceptableOrUnknown(
          data['area_square_meters']!,
          _areaSquareMetersMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Parcel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Parcel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      locality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locality'],
      ),
      polygonJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}polygon_json'],
      ),
      areaSquareMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}area_square_meters'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $ParcelsTable createAlias(String alias) {
    return $ParcelsTable(attachedDatabase, alias);
  }
}

class Parcel extends DataClass implements Insertable<Parcel> {
  final String id;
  final String ownerId;
  final String name;
  final String? locality;
  final String? polygonJson;
  final double? areaSquareMeters;
  final bool isActive;
  final bool isArchived;
  final int version;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Parcel({
    required this.id,
    required this.ownerId,
    required this.name,
    this.locality,
    this.polygonJson,
    this.areaSquareMeters,
    required this.isActive,
    required this.isArchived,
    required this.version,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || locality != null) {
      map['locality'] = Variable<String>(locality);
    }
    if (!nullToAbsent || polygonJson != null) {
      map['polygon_json'] = Variable<String>(polygonJson);
    }
    if (!nullToAbsent || areaSquareMeters != null) {
      map['area_square_meters'] = Variable<double>(areaSquareMeters);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['is_archived'] = Variable<bool>(isArchived);
    map['version'] = Variable<int>(version);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ParcelsCompanion toCompanion(bool nullToAbsent) {
    return ParcelsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      name: Value(name),
      locality: locality == null && nullToAbsent
          ? const Value.absent()
          : Value(locality),
      polygonJson: polygonJson == null && nullToAbsent
          ? const Value.absent()
          : Value(polygonJson),
      areaSquareMeters: areaSquareMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(areaSquareMeters),
      isActive: Value(isActive),
      isArchived: Value(isArchived),
      version: Value(version),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Parcel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Parcel(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      name: serializer.fromJson<String>(json['name']),
      locality: serializer.fromJson<String?>(json['locality']),
      polygonJson: serializer.fromJson<String?>(json['polygonJson']),
      areaSquareMeters: serializer.fromJson<double?>(json['areaSquareMeters']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      version: serializer.fromJson<int>(json['version']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'name': serializer.toJson<String>(name),
      'locality': serializer.toJson<String?>(locality),
      'polygonJson': serializer.toJson<String?>(polygonJson),
      'areaSquareMeters': serializer.toJson<double?>(areaSquareMeters),
      'isActive': serializer.toJson<bool>(isActive),
      'isArchived': serializer.toJson<bool>(isArchived),
      'version': serializer.toJson<int>(version),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Parcel copyWith({
    String? id,
    String? ownerId,
    String? name,
    Value<String?> locality = const Value.absent(),
    Value<String?> polygonJson = const Value.absent(),
    Value<double?> areaSquareMeters = const Value.absent(),
    bool? isActive,
    bool? isArchived,
    int? version,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Parcel(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    name: name ?? this.name,
    locality: locality.present ? locality.value : this.locality,
    polygonJson: polygonJson.present ? polygonJson.value : this.polygonJson,
    areaSquareMeters: areaSquareMeters.present
        ? areaSquareMeters.value
        : this.areaSquareMeters,
    isActive: isActive ?? this.isActive,
    isArchived: isArchived ?? this.isArchived,
    version: version ?? this.version,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Parcel copyWithCompanion(ParcelsCompanion data) {
    return Parcel(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      name: data.name.present ? data.name.value : this.name,
      locality: data.locality.present ? data.locality.value : this.locality,
      polygonJson: data.polygonJson.present
          ? data.polygonJson.value
          : this.polygonJson,
      areaSquareMeters: data.areaSquareMeters.present
          ? data.areaSquareMeters.value
          : this.areaSquareMeters,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      version: data.version.present ? data.version.value : this.version,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Parcel(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('locality: $locality, ')
          ..write('polygonJson: $polygonJson, ')
          ..write('areaSquareMeters: $areaSquareMeters, ')
          ..write('isActive: $isActive, ')
          ..write('isArchived: $isArchived, ')
          ..write('version: $version, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    name,
    locality,
    polygonJson,
    areaSquareMeters,
    isActive,
    isArchived,
    version,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Parcel &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.name == this.name &&
          other.locality == this.locality &&
          other.polygonJson == this.polygonJson &&
          other.areaSquareMeters == this.areaSquareMeters &&
          other.isActive == this.isActive &&
          other.isArchived == this.isArchived &&
          other.version == this.version &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class ParcelsCompanion extends UpdateCompanion<Parcel> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> name;
  final Value<String?> locality;
  final Value<String?> polygonJson;
  final Value<double?> areaSquareMeters;
  final Value<bool> isActive;
  final Value<bool> isArchived;
  final Value<int> version;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const ParcelsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.name = const Value.absent(),
    this.locality = const Value.absent(),
    this.polygonJson = const Value.absent(),
    this.areaSquareMeters = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.version = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ParcelsCompanion.insert({
    required String id,
    required String ownerId,
    required String name,
    this.locality = const Value.absent(),
    this.polygonJson = const Value.absent(),
    this.areaSquareMeters = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.version = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       name = Value(name),
       updatedAt = Value(updatedAt);
  static Insertable<Parcel> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? name,
    Expression<String>? locality,
    Expression<String>? polygonJson,
    Expression<double>? areaSquareMeters,
    Expression<bool>? isActive,
    Expression<bool>? isArchived,
    Expression<int>? version,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (name != null) 'name': name,
      if (locality != null) 'locality': locality,
      if (polygonJson != null) 'polygon_json': polygonJson,
      if (areaSquareMeters != null) 'area_square_meters': areaSquareMeters,
      if (isActive != null) 'is_active': isActive,
      if (isArchived != null) 'is_archived': isArchived,
      if (version != null) 'version': version,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ParcelsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? name,
    Value<String?>? locality,
    Value<String?>? polygonJson,
    Value<double?>? areaSquareMeters,
    Value<bool>? isActive,
    Value<bool>? isArchived,
    Value<int>? version,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return ParcelsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      locality: locality ?? this.locality,
      polygonJson: polygonJson ?? this.polygonJson,
      areaSquareMeters: areaSquareMeters ?? this.areaSquareMeters,
      isActive: isActive ?? this.isActive,
      isArchived: isArchived ?? this.isArchived,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (locality.present) {
      map['locality'] = Variable<String>(locality.value);
    }
    if (polygonJson.present) {
      map['polygon_json'] = Variable<String>(polygonJson.value);
    }
    if (areaSquareMeters.present) {
      map['area_square_meters'] = Variable<double>(areaSquareMeters.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ParcelsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('locality: $locality, ')
          ..write('polygonJson: $polygonJson, ')
          ..write('areaSquareMeters: $areaSquareMeters, ')
          ..write('isActive: $isActive, ')
          ..write('isArchived: $isArchived, ')
          ..write('version: $version, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SectorsTable extends Sectors with TableInfo<$SectorsTable, Sector> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SectorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parcelIdMeta = const VerificationMeta(
    'parcelId',
  );
  @override
  late final GeneratedColumn<String> parcelId = GeneratedColumn<String>(
    'parcel_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES parcels (id)',
    ),
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (number > 0)',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('crop'),
  );
  static const VerificationMeta _polygonJsonMeta = const VerificationMeta(
    'polygonJson',
  );
  @override
  late final GeneratedColumn<String> polygonJson = GeneratedColumn<String>(
    'polygon_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _areaSquareMetersMeta = const VerificationMeta(
    'areaSquareMeters',
  );
  @override
  late final GeneratedColumn<double> areaSquareMeters = GeneratedColumn<double>(
    'area_square_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (area_square_meters > 0)',
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    parcelId,
    number,
    name,
    kind,
    polygonJson,
    areaSquareMeters,
    version,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sectors';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sector> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('parcel_id')) {
      context.handle(
        _parcelIdMeta,
        parcelId.isAcceptableOrUnknown(data['parcel_id']!, _parcelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_parcelIdMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('polygon_json')) {
      context.handle(
        _polygonJsonMeta,
        polygonJson.isAcceptableOrUnknown(
          data['polygon_json']!,
          _polygonJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_polygonJsonMeta);
    }
    if (data.containsKey('area_square_meters')) {
      context.handle(
        _areaSquareMetersMeta,
        areaSquareMeters.isAcceptableOrUnknown(
          data['area_square_meters']!,
          _areaSquareMetersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_areaSquareMetersMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {parcelId, number},
  ];
  @override
  Sector map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sector(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      parcelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parcel_id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      polygonJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}polygon_json'],
      )!,
      areaSquareMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}area_square_meters'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $SectorsTable createAlias(String alias) {
    return $SectorsTable(attachedDatabase, alias);
  }
}

class Sector extends DataClass implements Insertable<Sector> {
  final String id;
  final String ownerId;
  final String parcelId;
  final int number;
  final String name;
  final String kind;
  final String polygonJson;
  final double areaSquareMeters;
  final int version;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Sector({
    required this.id,
    required this.ownerId,
    required this.parcelId,
    required this.number,
    required this.name,
    required this.kind,
    required this.polygonJson,
    required this.areaSquareMeters,
    required this.version,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['parcel_id'] = Variable<String>(parcelId);
    map['number'] = Variable<int>(number);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['polygon_json'] = Variable<String>(polygonJson);
    map['area_square_meters'] = Variable<double>(areaSquareMeters);
    map['version'] = Variable<int>(version);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  SectorsCompanion toCompanion(bool nullToAbsent) {
    return SectorsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      parcelId: Value(parcelId),
      number: Value(number),
      name: Value(name),
      kind: Value(kind),
      polygonJson: Value(polygonJson),
      areaSquareMeters: Value(areaSquareMeters),
      version: Value(version),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Sector.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sector(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      parcelId: serializer.fromJson<String>(json['parcelId']),
      number: serializer.fromJson<int>(json['number']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      polygonJson: serializer.fromJson<String>(json['polygonJson']),
      areaSquareMeters: serializer.fromJson<double>(json['areaSquareMeters']),
      version: serializer.fromJson<int>(json['version']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'parcelId': serializer.toJson<String>(parcelId),
      'number': serializer.toJson<int>(number),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'polygonJson': serializer.toJson<String>(polygonJson),
      'areaSquareMeters': serializer.toJson<double>(areaSquareMeters),
      'version': serializer.toJson<int>(version),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Sector copyWith({
    String? id,
    String? ownerId,
    String? parcelId,
    int? number,
    String? name,
    String? kind,
    String? polygonJson,
    double? areaSquareMeters,
    int? version,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Sector(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    parcelId: parcelId ?? this.parcelId,
    number: number ?? this.number,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    polygonJson: polygonJson ?? this.polygonJson,
    areaSquareMeters: areaSquareMeters ?? this.areaSquareMeters,
    version: version ?? this.version,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Sector copyWithCompanion(SectorsCompanion data) {
    return Sector(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      parcelId: data.parcelId.present ? data.parcelId.value : this.parcelId,
      number: data.number.present ? data.number.value : this.number,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      polygonJson: data.polygonJson.present
          ? data.polygonJson.value
          : this.polygonJson,
      areaSquareMeters: data.areaSquareMeters.present
          ? data.areaSquareMeters.value
          : this.areaSquareMeters,
      version: data.version.present ? data.version.value : this.version,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sector(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('parcelId: $parcelId, ')
          ..write('number: $number, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('polygonJson: $polygonJson, ')
          ..write('areaSquareMeters: $areaSquareMeters, ')
          ..write('version: $version, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    parcelId,
    number,
    name,
    kind,
    polygonJson,
    areaSquareMeters,
    version,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sector &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.parcelId == this.parcelId &&
          other.number == this.number &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.polygonJson == this.polygonJson &&
          other.areaSquareMeters == this.areaSquareMeters &&
          other.version == this.version &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class SectorsCompanion extends UpdateCompanion<Sector> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> parcelId;
  final Value<int> number;
  final Value<String> name;
  final Value<String> kind;
  final Value<String> polygonJson;
  final Value<double> areaSquareMeters;
  final Value<int> version;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const SectorsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.parcelId = const Value.absent(),
    this.number = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.polygonJson = const Value.absent(),
    this.areaSquareMeters = const Value.absent(),
    this.version = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SectorsCompanion.insert({
    required String id,
    required String ownerId,
    required String parcelId,
    required int number,
    required String name,
    this.kind = const Value.absent(),
    required String polygonJson,
    required double areaSquareMeters,
    this.version = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       parcelId = Value(parcelId),
       number = Value(number),
       name = Value(name),
       polygonJson = Value(polygonJson),
       areaSquareMeters = Value(areaSquareMeters),
       updatedAt = Value(updatedAt);
  static Insertable<Sector> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? parcelId,
    Expression<int>? number,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? polygonJson,
    Expression<double>? areaSquareMeters,
    Expression<int>? version,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (parcelId != null) 'parcel_id': parcelId,
      if (number != null) 'number': number,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (polygonJson != null) 'polygon_json': polygonJson,
      if (areaSquareMeters != null) 'area_square_meters': areaSquareMeters,
      if (version != null) 'version': version,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SectorsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? parcelId,
    Value<int>? number,
    Value<String>? name,
    Value<String>? kind,
    Value<String>? polygonJson,
    Value<double>? areaSquareMeters,
    Value<int>? version,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return SectorsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      parcelId: parcelId ?? this.parcelId,
      number: number ?? this.number,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      polygonJson: polygonJson ?? this.polygonJson,
      areaSquareMeters: areaSquareMeters ?? this.areaSquareMeters,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (parcelId.present) {
      map['parcel_id'] = Variable<String>(parcelId.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (polygonJson.present) {
      map['polygon_json'] = Variable<String>(polygonJson.value);
    }
    if (areaSquareMeters.present) {
      map['area_square_meters'] = Variable<double>(areaSquareMeters.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SectorsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('parcelId: $parcelId, ')
          ..write('number: $number, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('polygonJson: $polygonJson, ')
          ..write('areaSquareMeters: $areaSquareMeters, ')
          ..write('version: $version, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OfficialCropsTable extends OfficialCrops
    with TableInfo<$OfficialCropsTable, OfficialCrop> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfficialCropsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commonNameMeta = const VerificationMeta(
    'commonName',
  );
  @override
  late final GeneratedColumn<String> commonName = GeneratedColumn<String>(
    'common_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scientificNameMeta = const VerificationMeta(
    'scientificName',
  );
  @override
  late final GeneratedColumn<String> scientificName = GeneratedColumn<String>(
    'scientific_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorTokenMeta = const VerificationMeta(
    'colorToken',
  );
  @override
  late final GeneratedColumn<String> colorToken = GeneratedColumn<String>(
    'color_token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconAssetMeta = const VerificationMeta(
    'iconAsset',
  );
  @override
  late final GeneratedColumn<String> iconAsset = GeneratedColumn<String>(
    'icon_asset',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _catalogVersionMeta = const VerificationMeta(
    'catalogVersion',
  );
  @override
  late final GeneratedColumn<int> catalogVersion = GeneratedColumn<int>(
    'catalog_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    commonName,
    scientificName,
    category,
    colorToken,
    iconAsset,
    catalogVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'official_crops';
  @override
  VerificationContext validateIntegrity(
    Insertable<OfficialCrop> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('common_name')) {
      context.handle(
        _commonNameMeta,
        commonName.isAcceptableOrUnknown(data['common_name']!, _commonNameMeta),
      );
    } else if (isInserting) {
      context.missing(_commonNameMeta);
    }
    if (data.containsKey('scientific_name')) {
      context.handle(
        _scientificNameMeta,
        scientificName.isAcceptableOrUnknown(
          data['scientific_name']!,
          _scientificNameMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('color_token')) {
      context.handle(
        _colorTokenMeta,
        colorToken.isAcceptableOrUnknown(data['color_token']!, _colorTokenMeta),
      );
    } else if (isInserting) {
      context.missing(_colorTokenMeta);
    }
    if (data.containsKey('icon_asset')) {
      context.handle(
        _iconAssetMeta,
        iconAsset.isAcceptableOrUnknown(data['icon_asset']!, _iconAssetMeta),
      );
    } else if (isInserting) {
      context.missing(_iconAssetMeta);
    }
    if (data.containsKey('catalog_version')) {
      context.handle(
        _catalogVersionMeta,
        catalogVersion.isAcceptableOrUnknown(
          data['catalog_version']!,
          _catalogVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfficialCrop map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfficialCrop(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      commonName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}common_name'],
      )!,
      scientificName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scientific_name'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      colorToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_token'],
      )!,
      iconAsset: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_asset'],
      )!,
      catalogVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}catalog_version'],
      )!,
    );
  }

  @override
  $OfficialCropsTable createAlias(String alias) {
    return $OfficialCropsTable(attachedDatabase, alias);
  }
}

class OfficialCrop extends DataClass implements Insertable<OfficialCrop> {
  final String id;
  final String commonName;
  final String? scientificName;
  final String category;
  final String colorToken;
  final String iconAsset;
  final int catalogVersion;
  const OfficialCrop({
    required this.id,
    required this.commonName,
    this.scientificName,
    required this.category,
    required this.colorToken,
    required this.iconAsset,
    required this.catalogVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['common_name'] = Variable<String>(commonName);
    if (!nullToAbsent || scientificName != null) {
      map['scientific_name'] = Variable<String>(scientificName);
    }
    map['category'] = Variable<String>(category);
    map['color_token'] = Variable<String>(colorToken);
    map['icon_asset'] = Variable<String>(iconAsset);
    map['catalog_version'] = Variable<int>(catalogVersion);
    return map;
  }

  OfficialCropsCompanion toCompanion(bool nullToAbsent) {
    return OfficialCropsCompanion(
      id: Value(id),
      commonName: Value(commonName),
      scientificName: scientificName == null && nullToAbsent
          ? const Value.absent()
          : Value(scientificName),
      category: Value(category),
      colorToken: Value(colorToken),
      iconAsset: Value(iconAsset),
      catalogVersion: Value(catalogVersion),
    );
  }

  factory OfficialCrop.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfficialCrop(
      id: serializer.fromJson<String>(json['id']),
      commonName: serializer.fromJson<String>(json['commonName']),
      scientificName: serializer.fromJson<String?>(json['scientificName']),
      category: serializer.fromJson<String>(json['category']),
      colorToken: serializer.fromJson<String>(json['colorToken']),
      iconAsset: serializer.fromJson<String>(json['iconAsset']),
      catalogVersion: serializer.fromJson<int>(json['catalogVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'commonName': serializer.toJson<String>(commonName),
      'scientificName': serializer.toJson<String?>(scientificName),
      'category': serializer.toJson<String>(category),
      'colorToken': serializer.toJson<String>(colorToken),
      'iconAsset': serializer.toJson<String>(iconAsset),
      'catalogVersion': serializer.toJson<int>(catalogVersion),
    };
  }

  OfficialCrop copyWith({
    String? id,
    String? commonName,
    Value<String?> scientificName = const Value.absent(),
    String? category,
    String? colorToken,
    String? iconAsset,
    int? catalogVersion,
  }) => OfficialCrop(
    id: id ?? this.id,
    commonName: commonName ?? this.commonName,
    scientificName: scientificName.present
        ? scientificName.value
        : this.scientificName,
    category: category ?? this.category,
    colorToken: colorToken ?? this.colorToken,
    iconAsset: iconAsset ?? this.iconAsset,
    catalogVersion: catalogVersion ?? this.catalogVersion,
  );
  OfficialCrop copyWithCompanion(OfficialCropsCompanion data) {
    return OfficialCrop(
      id: data.id.present ? data.id.value : this.id,
      commonName: data.commonName.present
          ? data.commonName.value
          : this.commonName,
      scientificName: data.scientificName.present
          ? data.scientificName.value
          : this.scientificName,
      category: data.category.present ? data.category.value : this.category,
      colorToken: data.colorToken.present
          ? data.colorToken.value
          : this.colorToken,
      iconAsset: data.iconAsset.present ? data.iconAsset.value : this.iconAsset,
      catalogVersion: data.catalogVersion.present
          ? data.catalogVersion.value
          : this.catalogVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfficialCrop(')
          ..write('id: $id, ')
          ..write('commonName: $commonName, ')
          ..write('scientificName: $scientificName, ')
          ..write('category: $category, ')
          ..write('colorToken: $colorToken, ')
          ..write('iconAsset: $iconAsset, ')
          ..write('catalogVersion: $catalogVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    commonName,
    scientificName,
    category,
    colorToken,
    iconAsset,
    catalogVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfficialCrop &&
          other.id == this.id &&
          other.commonName == this.commonName &&
          other.scientificName == this.scientificName &&
          other.category == this.category &&
          other.colorToken == this.colorToken &&
          other.iconAsset == this.iconAsset &&
          other.catalogVersion == this.catalogVersion);
}

class OfficialCropsCompanion extends UpdateCompanion<OfficialCrop> {
  final Value<String> id;
  final Value<String> commonName;
  final Value<String?> scientificName;
  final Value<String> category;
  final Value<String> colorToken;
  final Value<String> iconAsset;
  final Value<int> catalogVersion;
  final Value<int> rowid;
  const OfficialCropsCompanion({
    this.id = const Value.absent(),
    this.commonName = const Value.absent(),
    this.scientificName = const Value.absent(),
    this.category = const Value.absent(),
    this.colorToken = const Value.absent(),
    this.iconAsset = const Value.absent(),
    this.catalogVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OfficialCropsCompanion.insert({
    required String id,
    required String commonName,
    this.scientificName = const Value.absent(),
    required String category,
    required String colorToken,
    required String iconAsset,
    this.catalogVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       commonName = Value(commonName),
       category = Value(category),
       colorToken = Value(colorToken),
       iconAsset = Value(iconAsset);
  static Insertable<OfficialCrop> custom({
    Expression<String>? id,
    Expression<String>? commonName,
    Expression<String>? scientificName,
    Expression<String>? category,
    Expression<String>? colorToken,
    Expression<String>? iconAsset,
    Expression<int>? catalogVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (commonName != null) 'common_name': commonName,
      if (scientificName != null) 'scientific_name': scientificName,
      if (category != null) 'category': category,
      if (colorToken != null) 'color_token': colorToken,
      if (iconAsset != null) 'icon_asset': iconAsset,
      if (catalogVersion != null) 'catalog_version': catalogVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OfficialCropsCompanion copyWith({
    Value<String>? id,
    Value<String>? commonName,
    Value<String?>? scientificName,
    Value<String>? category,
    Value<String>? colorToken,
    Value<String>? iconAsset,
    Value<int>? catalogVersion,
    Value<int>? rowid,
  }) {
    return OfficialCropsCompanion(
      id: id ?? this.id,
      commonName: commonName ?? this.commonName,
      scientificName: scientificName ?? this.scientificName,
      category: category ?? this.category,
      colorToken: colorToken ?? this.colorToken,
      iconAsset: iconAsset ?? this.iconAsset,
      catalogVersion: catalogVersion ?? this.catalogVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (commonName.present) {
      map['common_name'] = Variable<String>(commonName.value);
    }
    if (scientificName.present) {
      map['scientific_name'] = Variable<String>(scientificName.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (colorToken.present) {
      map['color_token'] = Variable<String>(colorToken.value);
    }
    if (iconAsset.present) {
      map['icon_asset'] = Variable<String>(iconAsset.value);
    }
    if (catalogVersion.present) {
      map['catalog_version'] = Variable<int>(catalogVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfficialCropsCompanion(')
          ..write('id: $id, ')
          ..write('commonName: $commonName, ')
          ..write('scientificName: $scientificName, ')
          ..write('category: $category, ')
          ..write('colorToken: $colorToken, ')
          ..write('iconAsset: $iconAsset, ')
          ..write('catalogVersion: $catalogVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomCropsTable extends CustomCrops
    with TableInfo<$CustomCropsTable, CustomCrop> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomCropsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, ownerId, name, notes, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_crops';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomCrop> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomCrop map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomCrop(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CustomCropsTable createAlias(String alias) {
    return $CustomCropsTable(attachedDatabase, alias);
  }
}

class CustomCrop extends DataClass implements Insertable<CustomCrop> {
  final String id;
  final String ownerId;
  final String name;
  final String? notes;
  final DateTime updatedAt;
  const CustomCrop({
    required this.id,
    required this.ownerId,
    required this.name,
    this.notes,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CustomCropsCompanion toCompanion(bool nullToAbsent) {
    return CustomCropsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      name: Value(name),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      updatedAt: Value(updatedAt),
    );
  }

  factory CustomCrop.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomCrop(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      name: serializer.fromJson<String>(json['name']),
      notes: serializer.fromJson<String?>(json['notes']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'name': serializer.toJson<String>(name),
      'notes': serializer.toJson<String?>(notes),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CustomCrop copyWith({
    String? id,
    String? ownerId,
    String? name,
    Value<String?> notes = const Value.absent(),
    DateTime? updatedAt,
  }) => CustomCrop(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    name: name ?? this.name,
    notes: notes.present ? notes.value : this.notes,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CustomCrop copyWithCompanion(CustomCropsCompanion data) {
    return CustomCrop(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      name: data.name.present ? data.name.value : this.name,
      notes: data.notes.present ? data.notes.value : this.notes,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomCrop(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ownerId, name, notes, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomCrop &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.name == this.name &&
          other.notes == this.notes &&
          other.updatedAt == this.updatedAt);
}

class CustomCropsCompanion extends UpdateCompanion<CustomCrop> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> name;
  final Value<String?> notes;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CustomCropsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.name = const Value.absent(),
    this.notes = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomCropsCompanion.insert({
    required String id,
    required String ownerId,
    required String name,
    this.notes = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       name = Value(name),
       updatedAt = Value(updatedAt);
  static Insertable<CustomCrop> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? name,
    Expression<String>? notes,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (name != null) 'name': name,
      if (notes != null) 'notes': notes,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomCropsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? name,
    Value<String?>? notes,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CustomCropsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomCropsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CropSeasonsTable extends CropSeasons
    with TableInfo<$CropSeasonsTable, CropSeason> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CropSeasonsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectorIdMeta = const VerificationMeta(
    'sectorId',
  );
  @override
  late final GeneratedColumn<String> sectorId = GeneratedColumn<String>(
    'sector_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sectors (id)',
    ),
  );
  static const VerificationMeta _cropIdMeta = const VerificationMeta('cropId');
  @override
  late final GeneratedColumn<String> cropId = GeneratedColumn<String>(
    'crop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCustomCropMeta = const VerificationMeta(
    'isCustomCrop',
  );
  @override
  late final GeneratedColumn<bool> isCustomCrop = GeneratedColumn<bool>(
    'is_custom_crop',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom_crop" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('planned'),
  );
  static const VerificationMeta _startsOnMeta = const VerificationMeta(
    'startsOn',
  );
  @override
  late final GeneratedColumn<DateTime> startsOn = GeneratedColumn<DateTime>(
    'starts_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endsOnMeta = const VerificationMeta('endsOn');
  @override
  late final GeneratedColumn<DateTime> endsOn = GeneratedColumn<DateTime>(
    'ends_on',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    sectorId,
    cropId,
    isCustomCrop,
    status,
    startsOn,
    endsOn,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'crop_seasons';
  @override
  VerificationContext validateIntegrity(
    Insertable<CropSeason> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('sector_id')) {
      context.handle(
        _sectorIdMeta,
        sectorId.isAcceptableOrUnknown(data['sector_id']!, _sectorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectorIdMeta);
    }
    if (data.containsKey('crop_id')) {
      context.handle(
        _cropIdMeta,
        cropId.isAcceptableOrUnknown(data['crop_id']!, _cropIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cropIdMeta);
    }
    if (data.containsKey('is_custom_crop')) {
      context.handle(
        _isCustomCropMeta,
        isCustomCrop.isAcceptableOrUnknown(
          data['is_custom_crop']!,
          _isCustomCropMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('starts_on')) {
      context.handle(
        _startsOnMeta,
        startsOn.isAcceptableOrUnknown(data['starts_on']!, _startsOnMeta),
      );
    } else if (isInserting) {
      context.missing(_startsOnMeta);
    }
    if (data.containsKey('ends_on')) {
      context.handle(
        _endsOnMeta,
        endsOn.isAcceptableOrUnknown(data['ends_on']!, _endsOnMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CropSeason map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CropSeason(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      sectorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sector_id'],
      )!,
      cropId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}crop_id'],
      )!,
      isCustomCrop: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom_crop'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}starts_on'],
      )!,
      endsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ends_on'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CropSeasonsTable createAlias(String alias) {
    return $CropSeasonsTable(attachedDatabase, alias);
  }
}

class CropSeason extends DataClass implements Insertable<CropSeason> {
  final String id;
  final String ownerId;
  final String sectorId;
  final String cropId;
  final bool isCustomCrop;
  final String status;
  final DateTime startsOn;
  final DateTime? endsOn;
  final DateTime updatedAt;
  const CropSeason({
    required this.id,
    required this.ownerId,
    required this.sectorId,
    required this.cropId,
    required this.isCustomCrop,
    required this.status,
    required this.startsOn,
    this.endsOn,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['sector_id'] = Variable<String>(sectorId);
    map['crop_id'] = Variable<String>(cropId);
    map['is_custom_crop'] = Variable<bool>(isCustomCrop);
    map['status'] = Variable<String>(status);
    map['starts_on'] = Variable<DateTime>(startsOn);
    if (!nullToAbsent || endsOn != null) {
      map['ends_on'] = Variable<DateTime>(endsOn);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CropSeasonsCompanion toCompanion(bool nullToAbsent) {
    return CropSeasonsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      sectorId: Value(sectorId),
      cropId: Value(cropId),
      isCustomCrop: Value(isCustomCrop),
      status: Value(status),
      startsOn: Value(startsOn),
      endsOn: endsOn == null && nullToAbsent
          ? const Value.absent()
          : Value(endsOn),
      updatedAt: Value(updatedAt),
    );
  }

  factory CropSeason.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CropSeason(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      sectorId: serializer.fromJson<String>(json['sectorId']),
      cropId: serializer.fromJson<String>(json['cropId']),
      isCustomCrop: serializer.fromJson<bool>(json['isCustomCrop']),
      status: serializer.fromJson<String>(json['status']),
      startsOn: serializer.fromJson<DateTime>(json['startsOn']),
      endsOn: serializer.fromJson<DateTime?>(json['endsOn']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'sectorId': serializer.toJson<String>(sectorId),
      'cropId': serializer.toJson<String>(cropId),
      'isCustomCrop': serializer.toJson<bool>(isCustomCrop),
      'status': serializer.toJson<String>(status),
      'startsOn': serializer.toJson<DateTime>(startsOn),
      'endsOn': serializer.toJson<DateTime?>(endsOn),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CropSeason copyWith({
    String? id,
    String? ownerId,
    String? sectorId,
    String? cropId,
    bool? isCustomCrop,
    String? status,
    DateTime? startsOn,
    Value<DateTime?> endsOn = const Value.absent(),
    DateTime? updatedAt,
  }) => CropSeason(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    sectorId: sectorId ?? this.sectorId,
    cropId: cropId ?? this.cropId,
    isCustomCrop: isCustomCrop ?? this.isCustomCrop,
    status: status ?? this.status,
    startsOn: startsOn ?? this.startsOn,
    endsOn: endsOn.present ? endsOn.value : this.endsOn,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CropSeason copyWithCompanion(CropSeasonsCompanion data) {
    return CropSeason(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      sectorId: data.sectorId.present ? data.sectorId.value : this.sectorId,
      cropId: data.cropId.present ? data.cropId.value : this.cropId,
      isCustomCrop: data.isCustomCrop.present
          ? data.isCustomCrop.value
          : this.isCustomCrop,
      status: data.status.present ? data.status.value : this.status,
      startsOn: data.startsOn.present ? data.startsOn.value : this.startsOn,
      endsOn: data.endsOn.present ? data.endsOn.value : this.endsOn,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CropSeason(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('sectorId: $sectorId, ')
          ..write('cropId: $cropId, ')
          ..write('isCustomCrop: $isCustomCrop, ')
          ..write('status: $status, ')
          ..write('startsOn: $startsOn, ')
          ..write('endsOn: $endsOn, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    sectorId,
    cropId,
    isCustomCrop,
    status,
    startsOn,
    endsOn,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CropSeason &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.sectorId == this.sectorId &&
          other.cropId == this.cropId &&
          other.isCustomCrop == this.isCustomCrop &&
          other.status == this.status &&
          other.startsOn == this.startsOn &&
          other.endsOn == this.endsOn &&
          other.updatedAt == this.updatedAt);
}

class CropSeasonsCompanion extends UpdateCompanion<CropSeason> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> sectorId;
  final Value<String> cropId;
  final Value<bool> isCustomCrop;
  final Value<String> status;
  final Value<DateTime> startsOn;
  final Value<DateTime?> endsOn;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CropSeasonsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.sectorId = const Value.absent(),
    this.cropId = const Value.absent(),
    this.isCustomCrop = const Value.absent(),
    this.status = const Value.absent(),
    this.startsOn = const Value.absent(),
    this.endsOn = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CropSeasonsCompanion.insert({
    required String id,
    required String ownerId,
    required String sectorId,
    required String cropId,
    this.isCustomCrop = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime startsOn,
    this.endsOn = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       sectorId = Value(sectorId),
       cropId = Value(cropId),
       startsOn = Value(startsOn),
       updatedAt = Value(updatedAt);
  static Insertable<CropSeason> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? sectorId,
    Expression<String>? cropId,
    Expression<bool>? isCustomCrop,
    Expression<String>? status,
    Expression<DateTime>? startsOn,
    Expression<DateTime>? endsOn,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (sectorId != null) 'sector_id': sectorId,
      if (cropId != null) 'crop_id': cropId,
      if (isCustomCrop != null) 'is_custom_crop': isCustomCrop,
      if (status != null) 'status': status,
      if (startsOn != null) 'starts_on': startsOn,
      if (endsOn != null) 'ends_on': endsOn,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CropSeasonsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? sectorId,
    Value<String>? cropId,
    Value<bool>? isCustomCrop,
    Value<String>? status,
    Value<DateTime>? startsOn,
    Value<DateTime?>? endsOn,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CropSeasonsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      sectorId: sectorId ?? this.sectorId,
      cropId: cropId ?? this.cropId,
      isCustomCrop: isCustomCrop ?? this.isCustomCrop,
      status: status ?? this.status,
      startsOn: startsOn ?? this.startsOn,
      endsOn: endsOn ?? this.endsOn,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (sectorId.present) {
      map['sector_id'] = Variable<String>(sectorId.value);
    }
    if (cropId.present) {
      map['crop_id'] = Variable<String>(cropId.value);
    }
    if (isCustomCrop.present) {
      map['is_custom_crop'] = Variable<bool>(isCustomCrop.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startsOn.present) {
      map['starts_on'] = Variable<DateTime>(startsOn.value);
    }
    if (endsOn.present) {
      map['ends_on'] = Variable<DateTime>(endsOn.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CropSeasonsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('sectorId: $sectorId, ')
          ..write('cropId: $cropId, ')
          ..write('isCustomCrop: $isCustomCrop, ')
          ..write('status: $status, ')
          ..write('startsOn: $startsOn, ')
          ..write('endsOn: $endsOn, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LaborsTable extends Labors with TableInfo<$LaborsTable, Labor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LaborsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parcelIdMeta = const VerificationMeta(
    'parcelId',
  );
  @override
  late final GeneratedColumn<String> parcelId = GeneratedColumn<String>(
    'parcel_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectorIdMeta = const VerificationMeta(
    'sectorId',
  );
  @override
  late final GeneratedColumn<String> sectorId = GeneratedColumn<String>(
    'sector_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sectors (id)',
    ),
  );
  static const VerificationMeta _seasonIdMeta = const VerificationMeta(
    'seasonId',
  );
  @override
  late final GeneratedColumn<String> seasonId = GeneratedColumn<String>(
    'season_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customNameMeta = const VerificationMeta(
    'customName',
  );
  @override
  late final GeneratedColumn<String> customName = GeneratedColumn<String>(
    'custom_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _detailsJsonMeta = const VerificationMeta(
    'detailsJson',
  );
  @override
  late final GeneratedColumn<String> detailsJson = GeneratedColumn<String>(
    'details_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    parcelId,
    sectorId,
    seasonId,
    type,
    customName,
    detailsJson,
    notes,
    occurredAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'labors';
  @override
  VerificationContext validateIntegrity(
    Insertable<Labor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('parcel_id')) {
      context.handle(
        _parcelIdMeta,
        parcelId.isAcceptableOrUnknown(data['parcel_id']!, _parcelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_parcelIdMeta);
    }
    if (data.containsKey('sector_id')) {
      context.handle(
        _sectorIdMeta,
        sectorId.isAcceptableOrUnknown(data['sector_id']!, _sectorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectorIdMeta);
    }
    if (data.containsKey('season_id')) {
      context.handle(
        _seasonIdMeta,
        seasonId.isAcceptableOrUnknown(data['season_id']!, _seasonIdMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('custom_name')) {
      context.handle(
        _customNameMeta,
        customName.isAcceptableOrUnknown(data['custom_name']!, _customNameMeta),
      );
    }
    if (data.containsKey('details_json')) {
      context.handle(
        _detailsJsonMeta,
        detailsJson.isAcceptableOrUnknown(
          data['details_json']!,
          _detailsJsonMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Labor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Labor(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      parcelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parcel_id'],
      )!,
      sectorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sector_id'],
      )!,
      seasonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}season_id'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      customName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_name'],
      ),
      detailsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details_json'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LaborsTable createAlias(String alias) {
    return $LaborsTable(attachedDatabase, alias);
  }
}

class Labor extends DataClass implements Insertable<Labor> {
  final String id;
  final String ownerId;
  final String parcelId;
  final String sectorId;
  final String? seasonId;
  final String type;
  final String? customName;
  final String detailsJson;
  final String? notes;
  final DateTime occurredAt;
  final DateTime updatedAt;
  const Labor({
    required this.id,
    required this.ownerId,
    required this.parcelId,
    required this.sectorId,
    this.seasonId,
    required this.type,
    this.customName,
    required this.detailsJson,
    this.notes,
    required this.occurredAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['parcel_id'] = Variable<String>(parcelId);
    map['sector_id'] = Variable<String>(sectorId);
    if (!nullToAbsent || seasonId != null) {
      map['season_id'] = Variable<String>(seasonId);
    }
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || customName != null) {
      map['custom_name'] = Variable<String>(customName);
    }
    map['details_json'] = Variable<String>(detailsJson);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LaborsCompanion toCompanion(bool nullToAbsent) {
    return LaborsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      parcelId: Value(parcelId),
      sectorId: Value(sectorId),
      seasonId: seasonId == null && nullToAbsent
          ? const Value.absent()
          : Value(seasonId),
      type: Value(type),
      customName: customName == null && nullToAbsent
          ? const Value.absent()
          : Value(customName),
      detailsJson: Value(detailsJson),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      occurredAt: Value(occurredAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Labor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Labor(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      parcelId: serializer.fromJson<String>(json['parcelId']),
      sectorId: serializer.fromJson<String>(json['sectorId']),
      seasonId: serializer.fromJson<String?>(json['seasonId']),
      type: serializer.fromJson<String>(json['type']),
      customName: serializer.fromJson<String?>(json['customName']),
      detailsJson: serializer.fromJson<String>(json['detailsJson']),
      notes: serializer.fromJson<String?>(json['notes']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'parcelId': serializer.toJson<String>(parcelId),
      'sectorId': serializer.toJson<String>(sectorId),
      'seasonId': serializer.toJson<String?>(seasonId),
      'type': serializer.toJson<String>(type),
      'customName': serializer.toJson<String?>(customName),
      'detailsJson': serializer.toJson<String>(detailsJson),
      'notes': serializer.toJson<String?>(notes),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Labor copyWith({
    String? id,
    String? ownerId,
    String? parcelId,
    String? sectorId,
    Value<String?> seasonId = const Value.absent(),
    String? type,
    Value<String?> customName = const Value.absent(),
    String? detailsJson,
    Value<String?> notes = const Value.absent(),
    DateTime? occurredAt,
    DateTime? updatedAt,
  }) => Labor(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    parcelId: parcelId ?? this.parcelId,
    sectorId: sectorId ?? this.sectorId,
    seasonId: seasonId.present ? seasonId.value : this.seasonId,
    type: type ?? this.type,
    customName: customName.present ? customName.value : this.customName,
    detailsJson: detailsJson ?? this.detailsJson,
    notes: notes.present ? notes.value : this.notes,
    occurredAt: occurredAt ?? this.occurredAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Labor copyWithCompanion(LaborsCompanion data) {
    return Labor(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      parcelId: data.parcelId.present ? data.parcelId.value : this.parcelId,
      sectorId: data.sectorId.present ? data.sectorId.value : this.sectorId,
      seasonId: data.seasonId.present ? data.seasonId.value : this.seasonId,
      type: data.type.present ? data.type.value : this.type,
      customName: data.customName.present
          ? data.customName.value
          : this.customName,
      detailsJson: data.detailsJson.present
          ? data.detailsJson.value
          : this.detailsJson,
      notes: data.notes.present ? data.notes.value : this.notes,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Labor(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('parcelId: $parcelId, ')
          ..write('sectorId: $sectorId, ')
          ..write('seasonId: $seasonId, ')
          ..write('type: $type, ')
          ..write('customName: $customName, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('notes: $notes, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    parcelId,
    sectorId,
    seasonId,
    type,
    customName,
    detailsJson,
    notes,
    occurredAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Labor &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.parcelId == this.parcelId &&
          other.sectorId == this.sectorId &&
          other.seasonId == this.seasonId &&
          other.type == this.type &&
          other.customName == this.customName &&
          other.detailsJson == this.detailsJson &&
          other.notes == this.notes &&
          other.occurredAt == this.occurredAt &&
          other.updatedAt == this.updatedAt);
}

class LaborsCompanion extends UpdateCompanion<Labor> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> parcelId;
  final Value<String> sectorId;
  final Value<String?> seasonId;
  final Value<String> type;
  final Value<String?> customName;
  final Value<String> detailsJson;
  final Value<String?> notes;
  final Value<DateTime> occurredAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LaborsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.parcelId = const Value.absent(),
    this.sectorId = const Value.absent(),
    this.seasonId = const Value.absent(),
    this.type = const Value.absent(),
    this.customName = const Value.absent(),
    this.detailsJson = const Value.absent(),
    this.notes = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LaborsCompanion.insert({
    required String id,
    required String ownerId,
    required String parcelId,
    required String sectorId,
    this.seasonId = const Value.absent(),
    required String type,
    this.customName = const Value.absent(),
    this.detailsJson = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime occurredAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       parcelId = Value(parcelId),
       sectorId = Value(sectorId),
       type = Value(type),
       occurredAt = Value(occurredAt),
       updatedAt = Value(updatedAt);
  static Insertable<Labor> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? parcelId,
    Expression<String>? sectorId,
    Expression<String>? seasonId,
    Expression<String>? type,
    Expression<String>? customName,
    Expression<String>? detailsJson,
    Expression<String>? notes,
    Expression<DateTime>? occurredAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (parcelId != null) 'parcel_id': parcelId,
      if (sectorId != null) 'sector_id': sectorId,
      if (seasonId != null) 'season_id': seasonId,
      if (type != null) 'type': type,
      if (customName != null) 'custom_name': customName,
      if (detailsJson != null) 'details_json': detailsJson,
      if (notes != null) 'notes': notes,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LaborsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? parcelId,
    Value<String>? sectorId,
    Value<String?>? seasonId,
    Value<String>? type,
    Value<String?>? customName,
    Value<String>? detailsJson,
    Value<String?>? notes,
    Value<DateTime>? occurredAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LaborsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      parcelId: parcelId ?? this.parcelId,
      sectorId: sectorId ?? this.sectorId,
      seasonId: seasonId ?? this.seasonId,
      type: type ?? this.type,
      customName: customName ?? this.customName,
      detailsJson: detailsJson ?? this.detailsJson,
      notes: notes ?? this.notes,
      occurredAt: occurredAt ?? this.occurredAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (parcelId.present) {
      map['parcel_id'] = Variable<String>(parcelId.value);
    }
    if (sectorId.present) {
      map['sector_id'] = Variable<String>(sectorId.value);
    }
    if (seasonId.present) {
      map['season_id'] = Variable<String>(seasonId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (customName.present) {
      map['custom_name'] = Variable<String>(customName.value);
    }
    if (detailsJson.present) {
      map['details_json'] = Variable<String>(detailsJson.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LaborsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('parcelId: $parcelId, ')
          ..write('sectorId: $sectorId, ')
          ..write('seasonId: $seasonId, ')
          ..write('type: $type, ')
          ..write('customName: $customName, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('notes: $notes, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SoilMeasurementsTable extends SoilMeasurements
    with TableInfo<$SoilMeasurementsTable, SoilMeasurement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SoilMeasurementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectorIdMeta = const VerificationMeta(
    'sectorId',
  );
  @override
  late final GeneratedColumn<String> sectorId = GeneratedColumn<String>(
    'sector_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sectors (id)',
    ),
  );
  static const VerificationMeta _moisturePercentMeta = const VerificationMeta(
    'moisturePercent',
  );
  @override
  late final GeneratedColumn<double> moisturePercent = GeneratedColumn<double>(
    'moisture_percent',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phMeta = const VerificationMeta('ph');
  @override
  late final GeneratedColumn<double> ph = GeneratedColumn<double>(
    'ph',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _temperatureCelsiusMeta =
      const VerificationMeta('temperatureCelsius');
  @override
  late final GeneratedColumn<double> temperatureCelsius =
      GeneratedColumn<double>(
        'temperature_celsius',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _conductivityMeta = const VerificationMeta(
    'conductivity',
  );
  @override
  late final GeneratedColumn<double> conductivity = GeneratedColumn<double>(
    'conductivity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nitrogenMeta = const VerificationMeta(
    'nitrogen',
  );
  @override
  late final GeneratedColumn<double> nitrogen = GeneratedColumn<double>(
    'nitrogen',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phosphorusMeta = const VerificationMeta(
    'phosphorus',
  );
  @override
  late final GeneratedColumn<double> phosphorus = GeneratedColumn<double>(
    'phosphorus',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _potassiumMeta = const VerificationMeta(
    'potassium',
  );
  @override
  late final GeneratedColumn<double> potassium = GeneratedColumn<double>(
    'potassium',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _measuredAtMeta = const VerificationMeta(
    'measuredAt',
  );
  @override
  late final GeneratedColumn<DateTime> measuredAt = GeneratedColumn<DateTime>(
    'measured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    sectorId,
    moisturePercent,
    ph,
    temperatureCelsius,
    conductivity,
    nitrogen,
    phosphorus,
    potassium,
    notes,
    measuredAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'soil_measurements';
  @override
  VerificationContext validateIntegrity(
    Insertable<SoilMeasurement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('sector_id')) {
      context.handle(
        _sectorIdMeta,
        sectorId.isAcceptableOrUnknown(data['sector_id']!, _sectorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectorIdMeta);
    }
    if (data.containsKey('moisture_percent')) {
      context.handle(
        _moisturePercentMeta,
        moisturePercent.isAcceptableOrUnknown(
          data['moisture_percent']!,
          _moisturePercentMeta,
        ),
      );
    }
    if (data.containsKey('ph')) {
      context.handle(_phMeta, ph.isAcceptableOrUnknown(data['ph']!, _phMeta));
    }
    if (data.containsKey('temperature_celsius')) {
      context.handle(
        _temperatureCelsiusMeta,
        temperatureCelsius.isAcceptableOrUnknown(
          data['temperature_celsius']!,
          _temperatureCelsiusMeta,
        ),
      );
    }
    if (data.containsKey('conductivity')) {
      context.handle(
        _conductivityMeta,
        conductivity.isAcceptableOrUnknown(
          data['conductivity']!,
          _conductivityMeta,
        ),
      );
    }
    if (data.containsKey('nitrogen')) {
      context.handle(
        _nitrogenMeta,
        nitrogen.isAcceptableOrUnknown(data['nitrogen']!, _nitrogenMeta),
      );
    }
    if (data.containsKey('phosphorus')) {
      context.handle(
        _phosphorusMeta,
        phosphorus.isAcceptableOrUnknown(data['phosphorus']!, _phosphorusMeta),
      );
    }
    if (data.containsKey('potassium')) {
      context.handle(
        _potassiumMeta,
        potassium.isAcceptableOrUnknown(data['potassium']!, _potassiumMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('measured_at')) {
      context.handle(
        _measuredAtMeta,
        measuredAt.isAcceptableOrUnknown(data['measured_at']!, _measuredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_measuredAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SoilMeasurement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SoilMeasurement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      sectorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sector_id'],
      )!,
      moisturePercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}moisture_percent'],
      ),
      ph: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ph'],
      ),
      temperatureCelsius: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temperature_celsius'],
      ),
      conductivity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}conductivity'],
      ),
      nitrogen: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}nitrogen'],
      ),
      phosphorus: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}phosphorus'],
      ),
      potassium: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}potassium'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      measuredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}measured_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SoilMeasurementsTable createAlias(String alias) {
    return $SoilMeasurementsTable(attachedDatabase, alias);
  }
}

class SoilMeasurement extends DataClass implements Insertable<SoilMeasurement> {
  final String id;
  final String ownerId;
  final String sectorId;
  final double? moisturePercent;
  final double? ph;
  final double? temperatureCelsius;
  final double? conductivity;
  final double? nitrogen;
  final double? phosphorus;
  final double? potassium;
  final String? notes;
  final DateTime measuredAt;
  final DateTime updatedAt;
  const SoilMeasurement({
    required this.id,
    required this.ownerId,
    required this.sectorId,
    this.moisturePercent,
    this.ph,
    this.temperatureCelsius,
    this.conductivity,
    this.nitrogen,
    this.phosphorus,
    this.potassium,
    this.notes,
    required this.measuredAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['sector_id'] = Variable<String>(sectorId);
    if (!nullToAbsent || moisturePercent != null) {
      map['moisture_percent'] = Variable<double>(moisturePercent);
    }
    if (!nullToAbsent || ph != null) {
      map['ph'] = Variable<double>(ph);
    }
    if (!nullToAbsent || temperatureCelsius != null) {
      map['temperature_celsius'] = Variable<double>(temperatureCelsius);
    }
    if (!nullToAbsent || conductivity != null) {
      map['conductivity'] = Variable<double>(conductivity);
    }
    if (!nullToAbsent || nitrogen != null) {
      map['nitrogen'] = Variable<double>(nitrogen);
    }
    if (!nullToAbsent || phosphorus != null) {
      map['phosphorus'] = Variable<double>(phosphorus);
    }
    if (!nullToAbsent || potassium != null) {
      map['potassium'] = Variable<double>(potassium);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['measured_at'] = Variable<DateTime>(measuredAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SoilMeasurementsCompanion toCompanion(bool nullToAbsent) {
    return SoilMeasurementsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      sectorId: Value(sectorId),
      moisturePercent: moisturePercent == null && nullToAbsent
          ? const Value.absent()
          : Value(moisturePercent),
      ph: ph == null && nullToAbsent ? const Value.absent() : Value(ph),
      temperatureCelsius: temperatureCelsius == null && nullToAbsent
          ? const Value.absent()
          : Value(temperatureCelsius),
      conductivity: conductivity == null && nullToAbsent
          ? const Value.absent()
          : Value(conductivity),
      nitrogen: nitrogen == null && nullToAbsent
          ? const Value.absent()
          : Value(nitrogen),
      phosphorus: phosphorus == null && nullToAbsent
          ? const Value.absent()
          : Value(phosphorus),
      potassium: potassium == null && nullToAbsent
          ? const Value.absent()
          : Value(potassium),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      measuredAt: Value(measuredAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SoilMeasurement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SoilMeasurement(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      sectorId: serializer.fromJson<String>(json['sectorId']),
      moisturePercent: serializer.fromJson<double?>(json['moisturePercent']),
      ph: serializer.fromJson<double?>(json['ph']),
      temperatureCelsius: serializer.fromJson<double?>(
        json['temperatureCelsius'],
      ),
      conductivity: serializer.fromJson<double?>(json['conductivity']),
      nitrogen: serializer.fromJson<double?>(json['nitrogen']),
      phosphorus: serializer.fromJson<double?>(json['phosphorus']),
      potassium: serializer.fromJson<double?>(json['potassium']),
      notes: serializer.fromJson<String?>(json['notes']),
      measuredAt: serializer.fromJson<DateTime>(json['measuredAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'sectorId': serializer.toJson<String>(sectorId),
      'moisturePercent': serializer.toJson<double?>(moisturePercent),
      'ph': serializer.toJson<double?>(ph),
      'temperatureCelsius': serializer.toJson<double?>(temperatureCelsius),
      'conductivity': serializer.toJson<double?>(conductivity),
      'nitrogen': serializer.toJson<double?>(nitrogen),
      'phosphorus': serializer.toJson<double?>(phosphorus),
      'potassium': serializer.toJson<double?>(potassium),
      'notes': serializer.toJson<String?>(notes),
      'measuredAt': serializer.toJson<DateTime>(measuredAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SoilMeasurement copyWith({
    String? id,
    String? ownerId,
    String? sectorId,
    Value<double?> moisturePercent = const Value.absent(),
    Value<double?> ph = const Value.absent(),
    Value<double?> temperatureCelsius = const Value.absent(),
    Value<double?> conductivity = const Value.absent(),
    Value<double?> nitrogen = const Value.absent(),
    Value<double?> phosphorus = const Value.absent(),
    Value<double?> potassium = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? measuredAt,
    DateTime? updatedAt,
  }) => SoilMeasurement(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    sectorId: sectorId ?? this.sectorId,
    moisturePercent: moisturePercent.present
        ? moisturePercent.value
        : this.moisturePercent,
    ph: ph.present ? ph.value : this.ph,
    temperatureCelsius: temperatureCelsius.present
        ? temperatureCelsius.value
        : this.temperatureCelsius,
    conductivity: conductivity.present ? conductivity.value : this.conductivity,
    nitrogen: nitrogen.present ? nitrogen.value : this.nitrogen,
    phosphorus: phosphorus.present ? phosphorus.value : this.phosphorus,
    potassium: potassium.present ? potassium.value : this.potassium,
    notes: notes.present ? notes.value : this.notes,
    measuredAt: measuredAt ?? this.measuredAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SoilMeasurement copyWithCompanion(SoilMeasurementsCompanion data) {
    return SoilMeasurement(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      sectorId: data.sectorId.present ? data.sectorId.value : this.sectorId,
      moisturePercent: data.moisturePercent.present
          ? data.moisturePercent.value
          : this.moisturePercent,
      ph: data.ph.present ? data.ph.value : this.ph,
      temperatureCelsius: data.temperatureCelsius.present
          ? data.temperatureCelsius.value
          : this.temperatureCelsius,
      conductivity: data.conductivity.present
          ? data.conductivity.value
          : this.conductivity,
      nitrogen: data.nitrogen.present ? data.nitrogen.value : this.nitrogen,
      phosphorus: data.phosphorus.present
          ? data.phosphorus.value
          : this.phosphorus,
      potassium: data.potassium.present ? data.potassium.value : this.potassium,
      notes: data.notes.present ? data.notes.value : this.notes,
      measuredAt: data.measuredAt.present
          ? data.measuredAt.value
          : this.measuredAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SoilMeasurement(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('sectorId: $sectorId, ')
          ..write('moisturePercent: $moisturePercent, ')
          ..write('ph: $ph, ')
          ..write('temperatureCelsius: $temperatureCelsius, ')
          ..write('conductivity: $conductivity, ')
          ..write('nitrogen: $nitrogen, ')
          ..write('phosphorus: $phosphorus, ')
          ..write('potassium: $potassium, ')
          ..write('notes: $notes, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    sectorId,
    moisturePercent,
    ph,
    temperatureCelsius,
    conductivity,
    nitrogen,
    phosphorus,
    potassium,
    notes,
    measuredAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SoilMeasurement &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.sectorId == this.sectorId &&
          other.moisturePercent == this.moisturePercent &&
          other.ph == this.ph &&
          other.temperatureCelsius == this.temperatureCelsius &&
          other.conductivity == this.conductivity &&
          other.nitrogen == this.nitrogen &&
          other.phosphorus == this.phosphorus &&
          other.potassium == this.potassium &&
          other.notes == this.notes &&
          other.measuredAt == this.measuredAt &&
          other.updatedAt == this.updatedAt);
}

class SoilMeasurementsCompanion extends UpdateCompanion<SoilMeasurement> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> sectorId;
  final Value<double?> moisturePercent;
  final Value<double?> ph;
  final Value<double?> temperatureCelsius;
  final Value<double?> conductivity;
  final Value<double?> nitrogen;
  final Value<double?> phosphorus;
  final Value<double?> potassium;
  final Value<String?> notes;
  final Value<DateTime> measuredAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SoilMeasurementsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.sectorId = const Value.absent(),
    this.moisturePercent = const Value.absent(),
    this.ph = const Value.absent(),
    this.temperatureCelsius = const Value.absent(),
    this.conductivity = const Value.absent(),
    this.nitrogen = const Value.absent(),
    this.phosphorus = const Value.absent(),
    this.potassium = const Value.absent(),
    this.notes = const Value.absent(),
    this.measuredAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SoilMeasurementsCompanion.insert({
    required String id,
    required String ownerId,
    required String sectorId,
    this.moisturePercent = const Value.absent(),
    this.ph = const Value.absent(),
    this.temperatureCelsius = const Value.absent(),
    this.conductivity = const Value.absent(),
    this.nitrogen = const Value.absent(),
    this.phosphorus = const Value.absent(),
    this.potassium = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime measuredAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       sectorId = Value(sectorId),
       measuredAt = Value(measuredAt),
       updatedAt = Value(updatedAt);
  static Insertable<SoilMeasurement> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? sectorId,
    Expression<double>? moisturePercent,
    Expression<double>? ph,
    Expression<double>? temperatureCelsius,
    Expression<double>? conductivity,
    Expression<double>? nitrogen,
    Expression<double>? phosphorus,
    Expression<double>? potassium,
    Expression<String>? notes,
    Expression<DateTime>? measuredAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (sectorId != null) 'sector_id': sectorId,
      if (moisturePercent != null) 'moisture_percent': moisturePercent,
      if (ph != null) 'ph': ph,
      if (temperatureCelsius != null) 'temperature_celsius': temperatureCelsius,
      if (conductivity != null) 'conductivity': conductivity,
      if (nitrogen != null) 'nitrogen': nitrogen,
      if (phosphorus != null) 'phosphorus': phosphorus,
      if (potassium != null) 'potassium': potassium,
      if (notes != null) 'notes': notes,
      if (measuredAt != null) 'measured_at': measuredAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SoilMeasurementsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? sectorId,
    Value<double?>? moisturePercent,
    Value<double?>? ph,
    Value<double?>? temperatureCelsius,
    Value<double?>? conductivity,
    Value<double?>? nitrogen,
    Value<double?>? phosphorus,
    Value<double?>? potassium,
    Value<String?>? notes,
    Value<DateTime>? measuredAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SoilMeasurementsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      sectorId: sectorId ?? this.sectorId,
      moisturePercent: moisturePercent ?? this.moisturePercent,
      ph: ph ?? this.ph,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
      conductivity: conductivity ?? this.conductivity,
      nitrogen: nitrogen ?? this.nitrogen,
      phosphorus: phosphorus ?? this.phosphorus,
      potassium: potassium ?? this.potassium,
      notes: notes ?? this.notes,
      measuredAt: measuredAt ?? this.measuredAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (sectorId.present) {
      map['sector_id'] = Variable<String>(sectorId.value);
    }
    if (moisturePercent.present) {
      map['moisture_percent'] = Variable<double>(moisturePercent.value);
    }
    if (ph.present) {
      map['ph'] = Variable<double>(ph.value);
    }
    if (temperatureCelsius.present) {
      map['temperature_celsius'] = Variable<double>(temperatureCelsius.value);
    }
    if (conductivity.present) {
      map['conductivity'] = Variable<double>(conductivity.value);
    }
    if (nitrogen.present) {
      map['nitrogen'] = Variable<double>(nitrogen.value);
    }
    if (phosphorus.present) {
      map['phosphorus'] = Variable<double>(phosphorus.value);
    }
    if (potassium.present) {
      map['potassium'] = Variable<double>(potassium.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (measuredAt.present) {
      map['measured_at'] = Variable<DateTime>(measuredAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SoilMeasurementsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('sectorId: $sectorId, ')
          ..write('moisturePercent: $moisturePercent, ')
          ..write('ph: $ph, ')
          ..write('temperatureCelsius: $temperatureCelsius, ')
          ..write('conductivity: $conductivity, ')
          ..write('nitrogen: $nitrogen, ')
          ..write('phosphorus: $phosphorus, ')
          ..write('potassium: $potassium, ')
          ..write('notes: $notes, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IrrigationRecordsTable extends IrrigationRecords
    with TableInfo<$IrrigationRecordsTable, IrrigationRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IrrigationRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectorIdMeta = const VerificationMeta(
    'sectorId',
  );
  @override
  late final GeneratedColumn<String> sectorId = GeneratedColumn<String>(
    'sector_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sectors (id)',
    ),
  );
  static const VerificationMeta _irrigationTypeMeta = const VerificationMeta(
    'irrigationType',
  );
  @override
  late final GeneratedColumn<String> irrigationType = GeneratedColumn<String>(
    'irrigation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _soilTypeCodeMeta = const VerificationMeta(
    'soilTypeCode',
  );
  @override
  late final GeneratedColumn<String> soilTypeCode = GeneratedColumn<String>(
    'soil_type_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _flowLitersPerHourMeta = const VerificationMeta(
    'flowLitersPerHour',
  );
  @override
  late final GeneratedColumn<double> flowLitersPerHour =
      GeneratedColumn<double>(
        'flow_liters_per_hour',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estimatedLitersMeta = const VerificationMeta(
    'estimatedLiters',
  );
  @override
  late final GeneratedColumn<double> estimatedLiters = GeneratedColumn<double>(
    'estimated_liters',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _irrigatedAtMeta = const VerificationMeta(
    'irrigatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> irrigatedAt = GeneratedColumn<DateTime>(
    'irrigated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    sectorId,
    irrigationType,
    soilTypeCode,
    flowLitersPerHour,
    durationMinutes,
    estimatedLiters,
    irrigatedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'irrigation_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<IrrigationRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('sector_id')) {
      context.handle(
        _sectorIdMeta,
        sectorId.isAcceptableOrUnknown(data['sector_id']!, _sectorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectorIdMeta);
    }
    if (data.containsKey('irrigation_type')) {
      context.handle(
        _irrigationTypeMeta,
        irrigationType.isAcceptableOrUnknown(
          data['irrigation_type']!,
          _irrigationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_irrigationTypeMeta);
    }
    if (data.containsKey('soil_type_code')) {
      context.handle(
        _soilTypeCodeMeta,
        soilTypeCode.isAcceptableOrUnknown(
          data['soil_type_code']!,
          _soilTypeCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_soilTypeCodeMeta);
    }
    if (data.containsKey('flow_liters_per_hour')) {
      context.handle(
        _flowLitersPerHourMeta,
        flowLitersPerHour.isAcceptableOrUnknown(
          data['flow_liters_per_hour']!,
          _flowLitersPerHourMeta,
        ),
      );
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('estimated_liters')) {
      context.handle(
        _estimatedLitersMeta,
        estimatedLiters.isAcceptableOrUnknown(
          data['estimated_liters']!,
          _estimatedLitersMeta,
        ),
      );
    }
    if (data.containsKey('irrigated_at')) {
      context.handle(
        _irrigatedAtMeta,
        irrigatedAt.isAcceptableOrUnknown(
          data['irrigated_at']!,
          _irrigatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_irrigatedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IrrigationRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IrrigationRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      sectorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sector_id'],
      )!,
      irrigationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}irrigation_type'],
      )!,
      soilTypeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}soil_type_code'],
      )!,
      flowLitersPerHour: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}flow_liters_per_hour'],
      ),
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      ),
      estimatedLiters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}estimated_liters'],
      ),
      irrigatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}irrigated_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $IrrigationRecordsTable createAlias(String alias) {
    return $IrrigationRecordsTable(attachedDatabase, alias);
  }
}

class IrrigationRecord extends DataClass
    implements Insertable<IrrigationRecord> {
  final String id;
  final String ownerId;
  final String sectorId;
  final String irrigationType;
  final String soilTypeCode;
  final double? flowLitersPerHour;
  final int? durationMinutes;
  final double? estimatedLiters;
  final DateTime irrigatedAt;
  final DateTime updatedAt;
  const IrrigationRecord({
    required this.id,
    required this.ownerId,
    required this.sectorId,
    required this.irrigationType,
    required this.soilTypeCode,
    this.flowLitersPerHour,
    this.durationMinutes,
    this.estimatedLiters,
    required this.irrigatedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['sector_id'] = Variable<String>(sectorId);
    map['irrigation_type'] = Variable<String>(irrigationType);
    map['soil_type_code'] = Variable<String>(soilTypeCode);
    if (!nullToAbsent || flowLitersPerHour != null) {
      map['flow_liters_per_hour'] = Variable<double>(flowLitersPerHour);
    }
    if (!nullToAbsent || durationMinutes != null) {
      map['duration_minutes'] = Variable<int>(durationMinutes);
    }
    if (!nullToAbsent || estimatedLiters != null) {
      map['estimated_liters'] = Variable<double>(estimatedLiters);
    }
    map['irrigated_at'] = Variable<DateTime>(irrigatedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  IrrigationRecordsCompanion toCompanion(bool nullToAbsent) {
    return IrrigationRecordsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      sectorId: Value(sectorId),
      irrigationType: Value(irrigationType),
      soilTypeCode: Value(soilTypeCode),
      flowLitersPerHour: flowLitersPerHour == null && nullToAbsent
          ? const Value.absent()
          : Value(flowLitersPerHour),
      durationMinutes: durationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMinutes),
      estimatedLiters: estimatedLiters == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedLiters),
      irrigatedAt: Value(irrigatedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory IrrigationRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IrrigationRecord(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      sectorId: serializer.fromJson<String>(json['sectorId']),
      irrigationType: serializer.fromJson<String>(json['irrigationType']),
      soilTypeCode: serializer.fromJson<String>(json['soilTypeCode']),
      flowLitersPerHour: serializer.fromJson<double?>(
        json['flowLitersPerHour'],
      ),
      durationMinutes: serializer.fromJson<int?>(json['durationMinutes']),
      estimatedLiters: serializer.fromJson<double?>(json['estimatedLiters']),
      irrigatedAt: serializer.fromJson<DateTime>(json['irrigatedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'sectorId': serializer.toJson<String>(sectorId),
      'irrigationType': serializer.toJson<String>(irrigationType),
      'soilTypeCode': serializer.toJson<String>(soilTypeCode),
      'flowLitersPerHour': serializer.toJson<double?>(flowLitersPerHour),
      'durationMinutes': serializer.toJson<int?>(durationMinutes),
      'estimatedLiters': serializer.toJson<double?>(estimatedLiters),
      'irrigatedAt': serializer.toJson<DateTime>(irrigatedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  IrrigationRecord copyWith({
    String? id,
    String? ownerId,
    String? sectorId,
    String? irrigationType,
    String? soilTypeCode,
    Value<double?> flowLitersPerHour = const Value.absent(),
    Value<int?> durationMinutes = const Value.absent(),
    Value<double?> estimatedLiters = const Value.absent(),
    DateTime? irrigatedAt,
    DateTime? updatedAt,
  }) => IrrigationRecord(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    sectorId: sectorId ?? this.sectorId,
    irrigationType: irrigationType ?? this.irrigationType,
    soilTypeCode: soilTypeCode ?? this.soilTypeCode,
    flowLitersPerHour: flowLitersPerHour.present
        ? flowLitersPerHour.value
        : this.flowLitersPerHour,
    durationMinutes: durationMinutes.present
        ? durationMinutes.value
        : this.durationMinutes,
    estimatedLiters: estimatedLiters.present
        ? estimatedLiters.value
        : this.estimatedLiters,
    irrigatedAt: irrigatedAt ?? this.irrigatedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  IrrigationRecord copyWithCompanion(IrrigationRecordsCompanion data) {
    return IrrigationRecord(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      sectorId: data.sectorId.present ? data.sectorId.value : this.sectorId,
      irrigationType: data.irrigationType.present
          ? data.irrigationType.value
          : this.irrigationType,
      soilTypeCode: data.soilTypeCode.present
          ? data.soilTypeCode.value
          : this.soilTypeCode,
      flowLitersPerHour: data.flowLitersPerHour.present
          ? data.flowLitersPerHour.value
          : this.flowLitersPerHour,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      estimatedLiters: data.estimatedLiters.present
          ? data.estimatedLiters.value
          : this.estimatedLiters,
      irrigatedAt: data.irrigatedAt.present
          ? data.irrigatedAt.value
          : this.irrigatedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IrrigationRecord(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('sectorId: $sectorId, ')
          ..write('irrigationType: $irrigationType, ')
          ..write('soilTypeCode: $soilTypeCode, ')
          ..write('flowLitersPerHour: $flowLitersPerHour, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('estimatedLiters: $estimatedLiters, ')
          ..write('irrigatedAt: $irrigatedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    sectorId,
    irrigationType,
    soilTypeCode,
    flowLitersPerHour,
    durationMinutes,
    estimatedLiters,
    irrigatedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IrrigationRecord &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.sectorId == this.sectorId &&
          other.irrigationType == this.irrigationType &&
          other.soilTypeCode == this.soilTypeCode &&
          other.flowLitersPerHour == this.flowLitersPerHour &&
          other.durationMinutes == this.durationMinutes &&
          other.estimatedLiters == this.estimatedLiters &&
          other.irrigatedAt == this.irrigatedAt &&
          other.updatedAt == this.updatedAt);
}

class IrrigationRecordsCompanion extends UpdateCompanion<IrrigationRecord> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> sectorId;
  final Value<String> irrigationType;
  final Value<String> soilTypeCode;
  final Value<double?> flowLitersPerHour;
  final Value<int?> durationMinutes;
  final Value<double?> estimatedLiters;
  final Value<DateTime> irrigatedAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const IrrigationRecordsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.sectorId = const Value.absent(),
    this.irrigationType = const Value.absent(),
    this.soilTypeCode = const Value.absent(),
    this.flowLitersPerHour = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.estimatedLiters = const Value.absent(),
    this.irrigatedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IrrigationRecordsCompanion.insert({
    required String id,
    required String ownerId,
    required String sectorId,
    required String irrigationType,
    required String soilTypeCode,
    this.flowLitersPerHour = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.estimatedLiters = const Value.absent(),
    required DateTime irrigatedAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       sectorId = Value(sectorId),
       irrigationType = Value(irrigationType),
       soilTypeCode = Value(soilTypeCode),
       irrigatedAt = Value(irrigatedAt),
       updatedAt = Value(updatedAt);
  static Insertable<IrrigationRecord> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? sectorId,
    Expression<String>? irrigationType,
    Expression<String>? soilTypeCode,
    Expression<double>? flowLitersPerHour,
    Expression<int>? durationMinutes,
    Expression<double>? estimatedLiters,
    Expression<DateTime>? irrigatedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (sectorId != null) 'sector_id': sectorId,
      if (irrigationType != null) 'irrigation_type': irrigationType,
      if (soilTypeCode != null) 'soil_type_code': soilTypeCode,
      if (flowLitersPerHour != null) 'flow_liters_per_hour': flowLitersPerHour,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (estimatedLiters != null) 'estimated_liters': estimatedLiters,
      if (irrigatedAt != null) 'irrigated_at': irrigatedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IrrigationRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? sectorId,
    Value<String>? irrigationType,
    Value<String>? soilTypeCode,
    Value<double?>? flowLitersPerHour,
    Value<int?>? durationMinutes,
    Value<double?>? estimatedLiters,
    Value<DateTime>? irrigatedAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return IrrigationRecordsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      sectorId: sectorId ?? this.sectorId,
      irrigationType: irrigationType ?? this.irrigationType,
      soilTypeCode: soilTypeCode ?? this.soilTypeCode,
      flowLitersPerHour: flowLitersPerHour ?? this.flowLitersPerHour,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      estimatedLiters: estimatedLiters ?? this.estimatedLiters,
      irrigatedAt: irrigatedAt ?? this.irrigatedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (sectorId.present) {
      map['sector_id'] = Variable<String>(sectorId.value);
    }
    if (irrigationType.present) {
      map['irrigation_type'] = Variable<String>(irrigationType.value);
    }
    if (soilTypeCode.present) {
      map['soil_type_code'] = Variable<String>(soilTypeCode.value);
    }
    if (flowLitersPerHour.present) {
      map['flow_liters_per_hour'] = Variable<double>(flowLitersPerHour.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (estimatedLiters.present) {
      map['estimated_liters'] = Variable<double>(estimatedLiters.value);
    }
    if (irrigatedAt.present) {
      map['irrigated_at'] = Variable<DateTime>(irrigatedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IrrigationRecordsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('sectorId: $sectorId, ')
          ..write('irrigationType: $irrigationType, ')
          ..write('soilTypeCode: $soilTypeCode, ')
          ..write('flowLitersPerHour: $flowLitersPerHour, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('estimatedLiters: $estimatedLiters, ')
          ..write('irrigatedAt: $irrigatedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CropIrrigationRulesTable extends CropIrrigationRules
    with TableInfo<$CropIrrigationRulesTable, CropIrrigationRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CropIrrigationRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cropIdMeta = const VerificationMeta('cropId');
  @override
  late final GeneratedColumn<String> cropId = GeneratedColumn<String>(
    'crop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _soilTypeCodeMeta = const VerificationMeta(
    'soilTypeCode',
  );
  @override
  late final GeneratedColumn<String> soilTypeCode = GeneratedColumn<String>(
    'soil_type_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _soilMultiplierPermilleMeta =
      const VerificationMeta('soilMultiplierPermille');
  @override
  late final GeneratedColumn<int> soilMultiplierPermille = GeneratedColumn<int>(
    'soil_multiplier_permille',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _efficiencyPermilleMeta =
      const VerificationMeta('efficiencyPermille');
  @override
  late final GeneratedColumn<int> efficiencyPermille = GeneratedColumn<int>(
    'efficiency_permille',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minimumDurationMinutesMeta =
      const VerificationMeta('minimumDurationMinutes');
  @override
  late final GeneratedColumn<int> minimumDurationMinutes = GeneratedColumn<int>(
    'minimum_duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maximumDurationMinutesMeta =
      const VerificationMeta('maximumDurationMinutes');
  @override
  late final GeneratedColumn<int> maximumDurationMinutes = GeneratedColumn<int>(
    'maximum_duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceTitleMeta = const VerificationMeta(
    'sourceTitle',
  );
  @override
  late final GeneratedColumn<String> sourceTitle = GeneratedColumn<String>(
    'source_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceReferenceMeta = const VerificationMeta(
    'sourceReference',
  );
  @override
  late final GeneratedColumn<String> sourceReference = GeneratedColumn<String>(
    'source_reference',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _approvedAtMeta = const VerificationMeta(
    'approvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> approvedAt = GeneratedColumn<DateTime>(
    'approved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cropId,
    soilTypeCode,
    version,
    soilMultiplierPermille,
    efficiencyPermille,
    minimumDurationMinutes,
    maximumDurationMinutes,
    sourceTitle,
    sourceReference,
    approvedAt,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'crop_irrigation_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<CropIrrigationRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('crop_id')) {
      context.handle(
        _cropIdMeta,
        cropId.isAcceptableOrUnknown(data['crop_id']!, _cropIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cropIdMeta);
    }
    if (data.containsKey('soil_type_code')) {
      context.handle(
        _soilTypeCodeMeta,
        soilTypeCode.isAcceptableOrUnknown(
          data['soil_type_code']!,
          _soilTypeCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_soilTypeCodeMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('soil_multiplier_permille')) {
      context.handle(
        _soilMultiplierPermilleMeta,
        soilMultiplierPermille.isAcceptableOrUnknown(
          data['soil_multiplier_permille']!,
          _soilMultiplierPermilleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_soilMultiplierPermilleMeta);
    }
    if (data.containsKey('efficiency_permille')) {
      context.handle(
        _efficiencyPermilleMeta,
        efficiencyPermille.isAcceptableOrUnknown(
          data['efficiency_permille']!,
          _efficiencyPermilleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_efficiencyPermilleMeta);
    }
    if (data.containsKey('minimum_duration_minutes')) {
      context.handle(
        _minimumDurationMinutesMeta,
        minimumDurationMinutes.isAcceptableOrUnknown(
          data['minimum_duration_minutes']!,
          _minimumDurationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_minimumDurationMinutesMeta);
    }
    if (data.containsKey('maximum_duration_minutes')) {
      context.handle(
        _maximumDurationMinutesMeta,
        maximumDurationMinutes.isAcceptableOrUnknown(
          data['maximum_duration_minutes']!,
          _maximumDurationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_maximumDurationMinutesMeta);
    }
    if (data.containsKey('source_title')) {
      context.handle(
        _sourceTitleMeta,
        sourceTitle.isAcceptableOrUnknown(
          data['source_title']!,
          _sourceTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceTitleMeta);
    }
    if (data.containsKey('source_reference')) {
      context.handle(
        _sourceReferenceMeta,
        sourceReference.isAcceptableOrUnknown(
          data['source_reference']!,
          _sourceReferenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceReferenceMeta);
    }
    if (data.containsKey('approved_at')) {
      context.handle(
        _approvedAtMeta,
        approvedAt.isAcceptableOrUnknown(data['approved_at']!, _approvedAtMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CropIrrigationRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CropIrrigationRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cropId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}crop_id'],
      )!,
      soilTypeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}soil_type_code'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      soilMultiplierPermille: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}soil_multiplier_permille'],
      )!,
      efficiencyPermille: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}efficiency_permille'],
      )!,
      minimumDurationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minimum_duration_minutes'],
      )!,
      maximumDurationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}maximum_duration_minutes'],
      )!,
      sourceTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_title'],
      )!,
      sourceReference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_reference'],
      )!,
      approvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}approved_at'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $CropIrrigationRulesTable createAlias(String alias) {
    return $CropIrrigationRulesTable(attachedDatabase, alias);
  }
}

class CropIrrigationRule extends DataClass
    implements Insertable<CropIrrigationRule> {
  final String id;
  final String cropId;
  final String soilTypeCode;
  final int version;
  final int soilMultiplierPermille;
  final int efficiencyPermille;
  final int minimumDurationMinutes;
  final int maximumDurationMinutes;
  final String sourceTitle;
  final String sourceReference;
  final DateTime? approvedAt;
  final bool isActive;
  const CropIrrigationRule({
    required this.id,
    required this.cropId,
    required this.soilTypeCode,
    required this.version,
    required this.soilMultiplierPermille,
    required this.efficiencyPermille,
    required this.minimumDurationMinutes,
    required this.maximumDurationMinutes,
    required this.sourceTitle,
    required this.sourceReference,
    this.approvedAt,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['crop_id'] = Variable<String>(cropId);
    map['soil_type_code'] = Variable<String>(soilTypeCode);
    map['version'] = Variable<int>(version);
    map['soil_multiplier_permille'] = Variable<int>(soilMultiplierPermille);
    map['efficiency_permille'] = Variable<int>(efficiencyPermille);
    map['minimum_duration_minutes'] = Variable<int>(minimumDurationMinutes);
    map['maximum_duration_minutes'] = Variable<int>(maximumDurationMinutes);
    map['source_title'] = Variable<String>(sourceTitle);
    map['source_reference'] = Variable<String>(sourceReference);
    if (!nullToAbsent || approvedAt != null) {
      map['approved_at'] = Variable<DateTime>(approvedAt);
    }
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  CropIrrigationRulesCompanion toCompanion(bool nullToAbsent) {
    return CropIrrigationRulesCompanion(
      id: Value(id),
      cropId: Value(cropId),
      soilTypeCode: Value(soilTypeCode),
      version: Value(version),
      soilMultiplierPermille: Value(soilMultiplierPermille),
      efficiencyPermille: Value(efficiencyPermille),
      minimumDurationMinutes: Value(minimumDurationMinutes),
      maximumDurationMinutes: Value(maximumDurationMinutes),
      sourceTitle: Value(sourceTitle),
      sourceReference: Value(sourceReference),
      approvedAt: approvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(approvedAt),
      isActive: Value(isActive),
    );
  }

  factory CropIrrigationRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CropIrrigationRule(
      id: serializer.fromJson<String>(json['id']),
      cropId: serializer.fromJson<String>(json['cropId']),
      soilTypeCode: serializer.fromJson<String>(json['soilTypeCode']),
      version: serializer.fromJson<int>(json['version']),
      soilMultiplierPermille: serializer.fromJson<int>(
        json['soilMultiplierPermille'],
      ),
      efficiencyPermille: serializer.fromJson<int>(json['efficiencyPermille']),
      minimumDurationMinutes: serializer.fromJson<int>(
        json['minimumDurationMinutes'],
      ),
      maximumDurationMinutes: serializer.fromJson<int>(
        json['maximumDurationMinutes'],
      ),
      sourceTitle: serializer.fromJson<String>(json['sourceTitle']),
      sourceReference: serializer.fromJson<String>(json['sourceReference']),
      approvedAt: serializer.fromJson<DateTime?>(json['approvedAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cropId': serializer.toJson<String>(cropId),
      'soilTypeCode': serializer.toJson<String>(soilTypeCode),
      'version': serializer.toJson<int>(version),
      'soilMultiplierPermille': serializer.toJson<int>(soilMultiplierPermille),
      'efficiencyPermille': serializer.toJson<int>(efficiencyPermille),
      'minimumDurationMinutes': serializer.toJson<int>(minimumDurationMinutes),
      'maximumDurationMinutes': serializer.toJson<int>(maximumDurationMinutes),
      'sourceTitle': serializer.toJson<String>(sourceTitle),
      'sourceReference': serializer.toJson<String>(sourceReference),
      'approvedAt': serializer.toJson<DateTime?>(approvedAt),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  CropIrrigationRule copyWith({
    String? id,
    String? cropId,
    String? soilTypeCode,
    int? version,
    int? soilMultiplierPermille,
    int? efficiencyPermille,
    int? minimumDurationMinutes,
    int? maximumDurationMinutes,
    String? sourceTitle,
    String? sourceReference,
    Value<DateTime?> approvedAt = const Value.absent(),
    bool? isActive,
  }) => CropIrrigationRule(
    id: id ?? this.id,
    cropId: cropId ?? this.cropId,
    soilTypeCode: soilTypeCode ?? this.soilTypeCode,
    version: version ?? this.version,
    soilMultiplierPermille:
        soilMultiplierPermille ?? this.soilMultiplierPermille,
    efficiencyPermille: efficiencyPermille ?? this.efficiencyPermille,
    minimumDurationMinutes:
        minimumDurationMinutes ?? this.minimumDurationMinutes,
    maximumDurationMinutes:
        maximumDurationMinutes ?? this.maximumDurationMinutes,
    sourceTitle: sourceTitle ?? this.sourceTitle,
    sourceReference: sourceReference ?? this.sourceReference,
    approvedAt: approvedAt.present ? approvedAt.value : this.approvedAt,
    isActive: isActive ?? this.isActive,
  );
  CropIrrigationRule copyWithCompanion(CropIrrigationRulesCompanion data) {
    return CropIrrigationRule(
      id: data.id.present ? data.id.value : this.id,
      cropId: data.cropId.present ? data.cropId.value : this.cropId,
      soilTypeCode: data.soilTypeCode.present
          ? data.soilTypeCode.value
          : this.soilTypeCode,
      version: data.version.present ? data.version.value : this.version,
      soilMultiplierPermille: data.soilMultiplierPermille.present
          ? data.soilMultiplierPermille.value
          : this.soilMultiplierPermille,
      efficiencyPermille: data.efficiencyPermille.present
          ? data.efficiencyPermille.value
          : this.efficiencyPermille,
      minimumDurationMinutes: data.minimumDurationMinutes.present
          ? data.minimumDurationMinutes.value
          : this.minimumDurationMinutes,
      maximumDurationMinutes: data.maximumDurationMinutes.present
          ? data.maximumDurationMinutes.value
          : this.maximumDurationMinutes,
      sourceTitle: data.sourceTitle.present
          ? data.sourceTitle.value
          : this.sourceTitle,
      sourceReference: data.sourceReference.present
          ? data.sourceReference.value
          : this.sourceReference,
      approvedAt: data.approvedAt.present
          ? data.approvedAt.value
          : this.approvedAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CropIrrigationRule(')
          ..write('id: $id, ')
          ..write('cropId: $cropId, ')
          ..write('soilTypeCode: $soilTypeCode, ')
          ..write('version: $version, ')
          ..write('soilMultiplierPermille: $soilMultiplierPermille, ')
          ..write('efficiencyPermille: $efficiencyPermille, ')
          ..write('minimumDurationMinutes: $minimumDurationMinutes, ')
          ..write('maximumDurationMinutes: $maximumDurationMinutes, ')
          ..write('sourceTitle: $sourceTitle, ')
          ..write('sourceReference: $sourceReference, ')
          ..write('approvedAt: $approvedAt, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cropId,
    soilTypeCode,
    version,
    soilMultiplierPermille,
    efficiencyPermille,
    minimumDurationMinutes,
    maximumDurationMinutes,
    sourceTitle,
    sourceReference,
    approvedAt,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CropIrrigationRule &&
          other.id == this.id &&
          other.cropId == this.cropId &&
          other.soilTypeCode == this.soilTypeCode &&
          other.version == this.version &&
          other.soilMultiplierPermille == this.soilMultiplierPermille &&
          other.efficiencyPermille == this.efficiencyPermille &&
          other.minimumDurationMinutes == this.minimumDurationMinutes &&
          other.maximumDurationMinutes == this.maximumDurationMinutes &&
          other.sourceTitle == this.sourceTitle &&
          other.sourceReference == this.sourceReference &&
          other.approvedAt == this.approvedAt &&
          other.isActive == this.isActive);
}

class CropIrrigationRulesCompanion extends UpdateCompanion<CropIrrigationRule> {
  final Value<String> id;
  final Value<String> cropId;
  final Value<String> soilTypeCode;
  final Value<int> version;
  final Value<int> soilMultiplierPermille;
  final Value<int> efficiencyPermille;
  final Value<int> minimumDurationMinutes;
  final Value<int> maximumDurationMinutes;
  final Value<String> sourceTitle;
  final Value<String> sourceReference;
  final Value<DateTime?> approvedAt;
  final Value<bool> isActive;
  final Value<int> rowid;
  const CropIrrigationRulesCompanion({
    this.id = const Value.absent(),
    this.cropId = const Value.absent(),
    this.soilTypeCode = const Value.absent(),
    this.version = const Value.absent(),
    this.soilMultiplierPermille = const Value.absent(),
    this.efficiencyPermille = const Value.absent(),
    this.minimumDurationMinutes = const Value.absent(),
    this.maximumDurationMinutes = const Value.absent(),
    this.sourceTitle = const Value.absent(),
    this.sourceReference = const Value.absent(),
    this.approvedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CropIrrigationRulesCompanion.insert({
    required String id,
    required String cropId,
    required String soilTypeCode,
    required int version,
    required int soilMultiplierPermille,
    required int efficiencyPermille,
    required int minimumDurationMinutes,
    required int maximumDurationMinutes,
    required String sourceTitle,
    required String sourceReference,
    this.approvedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cropId = Value(cropId),
       soilTypeCode = Value(soilTypeCode),
       version = Value(version),
       soilMultiplierPermille = Value(soilMultiplierPermille),
       efficiencyPermille = Value(efficiencyPermille),
       minimumDurationMinutes = Value(minimumDurationMinutes),
       maximumDurationMinutes = Value(maximumDurationMinutes),
       sourceTitle = Value(sourceTitle),
       sourceReference = Value(sourceReference);
  static Insertable<CropIrrigationRule> custom({
    Expression<String>? id,
    Expression<String>? cropId,
    Expression<String>? soilTypeCode,
    Expression<int>? version,
    Expression<int>? soilMultiplierPermille,
    Expression<int>? efficiencyPermille,
    Expression<int>? minimumDurationMinutes,
    Expression<int>? maximumDurationMinutes,
    Expression<String>? sourceTitle,
    Expression<String>? sourceReference,
    Expression<DateTime>? approvedAt,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cropId != null) 'crop_id': cropId,
      if (soilTypeCode != null) 'soil_type_code': soilTypeCode,
      if (version != null) 'version': version,
      if (soilMultiplierPermille != null)
        'soil_multiplier_permille': soilMultiplierPermille,
      if (efficiencyPermille != null) 'efficiency_permille': efficiencyPermille,
      if (minimumDurationMinutes != null)
        'minimum_duration_minutes': minimumDurationMinutes,
      if (maximumDurationMinutes != null)
        'maximum_duration_minutes': maximumDurationMinutes,
      if (sourceTitle != null) 'source_title': sourceTitle,
      if (sourceReference != null) 'source_reference': sourceReference,
      if (approvedAt != null) 'approved_at': approvedAt,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CropIrrigationRulesCompanion copyWith({
    Value<String>? id,
    Value<String>? cropId,
    Value<String>? soilTypeCode,
    Value<int>? version,
    Value<int>? soilMultiplierPermille,
    Value<int>? efficiencyPermille,
    Value<int>? minimumDurationMinutes,
    Value<int>? maximumDurationMinutes,
    Value<String>? sourceTitle,
    Value<String>? sourceReference,
    Value<DateTime?>? approvedAt,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return CropIrrigationRulesCompanion(
      id: id ?? this.id,
      cropId: cropId ?? this.cropId,
      soilTypeCode: soilTypeCode ?? this.soilTypeCode,
      version: version ?? this.version,
      soilMultiplierPermille:
          soilMultiplierPermille ?? this.soilMultiplierPermille,
      efficiencyPermille: efficiencyPermille ?? this.efficiencyPermille,
      minimumDurationMinutes:
          minimumDurationMinutes ?? this.minimumDurationMinutes,
      maximumDurationMinutes:
          maximumDurationMinutes ?? this.maximumDurationMinutes,
      sourceTitle: sourceTitle ?? this.sourceTitle,
      sourceReference: sourceReference ?? this.sourceReference,
      approvedAt: approvedAt ?? this.approvedAt,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cropId.present) {
      map['crop_id'] = Variable<String>(cropId.value);
    }
    if (soilTypeCode.present) {
      map['soil_type_code'] = Variable<String>(soilTypeCode.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (soilMultiplierPermille.present) {
      map['soil_multiplier_permille'] = Variable<int>(
        soilMultiplierPermille.value,
      );
    }
    if (efficiencyPermille.present) {
      map['efficiency_permille'] = Variable<int>(efficiencyPermille.value);
    }
    if (minimumDurationMinutes.present) {
      map['minimum_duration_minutes'] = Variable<int>(
        minimumDurationMinutes.value,
      );
    }
    if (maximumDurationMinutes.present) {
      map['maximum_duration_minutes'] = Variable<int>(
        maximumDurationMinutes.value,
      );
    }
    if (sourceTitle.present) {
      map['source_title'] = Variable<String>(sourceTitle.value);
    }
    if (sourceReference.present) {
      map['source_reference'] = Variable<String>(sourceReference.value);
    }
    if (approvedAt.present) {
      map['approved_at'] = Variable<DateTime>(approvedAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CropIrrigationRulesCompanion(')
          ..write('id: $id, ')
          ..write('cropId: $cropId, ')
          ..write('soilTypeCode: $soilTypeCode, ')
          ..write('version: $version, ')
          ..write('soilMultiplierPermille: $soilMultiplierPermille, ')
          ..write('efficiencyPermille: $efficiencyPermille, ')
          ..write('minimumDurationMinutes: $minimumDurationMinutes, ')
          ..write('maximumDurationMinutes: $maximumDurationMinutes, ')
          ..write('sourceTitle: $sourceTitle, ')
          ..write('sourceReference: $sourceReference, ')
          ..write('approvedAt: $approvedAt, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IrrigationEstimatesTable extends IrrigationEstimates
    with TableInfo<$IrrigationEstimatesTable, IrrigationEstimate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IrrigationEstimatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectorIdMeta = const VerificationMeta(
    'sectorId',
  );
  @override
  late final GeneratedColumn<String> sectorId = GeneratedColumn<String>(
    'sector_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ruleIdMeta = const VerificationMeta('ruleId');
  @override
  late final GeneratedColumn<String> ruleId = GeneratedColumn<String>(
    'rule_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ruleVersionMeta = const VerificationMeta(
    'ruleVersion',
  );
  @override
  late final GeneratedColumn<int> ruleVersion = GeneratedColumn<int>(
    'rule_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _soilTypeCodeMeta = const VerificationMeta(
    'soilTypeCode',
  );
  @override
  late final GeneratedColumn<String> soilTypeCode = GeneratedColumn<String>(
    'soil_type_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inputsJsonMeta = const VerificationMeta(
    'inputsJson',
  );
  @override
  late final GeneratedColumn<String> inputsJson = GeneratedColumn<String>(
    'inputs_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estimatedLitersMilliMeta =
      const VerificationMeta('estimatedLitersMilli');
  @override
  late final GeneratedColumn<int> estimatedLitersMilli = GeneratedColumn<int>(
    'estimated_liters_milli',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recommendedMinutesMeta =
      const VerificationMeta('recommendedMinutes');
  @override
  late final GeneratedColumn<int> recommendedMinutes = GeneratedColumn<int>(
    'recommended_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _warningsJsonMeta = const VerificationMeta(
    'warningsJson',
  );
  @override
  late final GeneratedColumn<String> warningsJson = GeneratedColumn<String>(
    'warnings_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    sectorId,
    ruleId,
    ruleVersion,
    soilTypeCode,
    inputsJson,
    estimatedLitersMilli,
    recommendedMinutes,
    warningsJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'irrigation_estimates';
  @override
  VerificationContext validateIntegrity(
    Insertable<IrrigationEstimate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('sector_id')) {
      context.handle(
        _sectorIdMeta,
        sectorId.isAcceptableOrUnknown(data['sector_id']!, _sectorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectorIdMeta);
    }
    if (data.containsKey('rule_id')) {
      context.handle(
        _ruleIdMeta,
        ruleId.isAcceptableOrUnknown(data['rule_id']!, _ruleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleIdMeta);
    }
    if (data.containsKey('rule_version')) {
      context.handle(
        _ruleVersionMeta,
        ruleVersion.isAcceptableOrUnknown(
          data['rule_version']!,
          _ruleVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ruleVersionMeta);
    }
    if (data.containsKey('soil_type_code')) {
      context.handle(
        _soilTypeCodeMeta,
        soilTypeCode.isAcceptableOrUnknown(
          data['soil_type_code']!,
          _soilTypeCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_soilTypeCodeMeta);
    }
    if (data.containsKey('inputs_json')) {
      context.handle(
        _inputsJsonMeta,
        inputsJson.isAcceptableOrUnknown(data['inputs_json']!, _inputsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_inputsJsonMeta);
    }
    if (data.containsKey('estimated_liters_milli')) {
      context.handle(
        _estimatedLitersMilliMeta,
        estimatedLitersMilli.isAcceptableOrUnknown(
          data['estimated_liters_milli']!,
          _estimatedLitersMilliMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_estimatedLitersMilliMeta);
    }
    if (data.containsKey('recommended_minutes')) {
      context.handle(
        _recommendedMinutesMeta,
        recommendedMinutes.isAcceptableOrUnknown(
          data['recommended_minutes']!,
          _recommendedMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recommendedMinutesMeta);
    }
    if (data.containsKey('warnings_json')) {
      context.handle(
        _warningsJsonMeta,
        warningsJson.isAcceptableOrUnknown(
          data['warnings_json']!,
          _warningsJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IrrigationEstimate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IrrigationEstimate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      sectorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sector_id'],
      )!,
      ruleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_id'],
      )!,
      ruleVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rule_version'],
      )!,
      soilTypeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}soil_type_code'],
      )!,
      inputsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}inputs_json'],
      )!,
      estimatedLitersMilli: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_liters_milli'],
      )!,
      recommendedMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recommended_minutes'],
      )!,
      warningsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}warnings_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $IrrigationEstimatesTable createAlias(String alias) {
    return $IrrigationEstimatesTable(attachedDatabase, alias);
  }
}

class IrrigationEstimate extends DataClass
    implements Insertable<IrrigationEstimate> {
  final String id;
  final String ownerId;
  final String sectorId;
  final String ruleId;
  final int ruleVersion;
  final String soilTypeCode;
  final String inputsJson;
  final int estimatedLitersMilli;
  final int recommendedMinutes;
  final String warningsJson;
  final DateTime createdAt;
  const IrrigationEstimate({
    required this.id,
    required this.ownerId,
    required this.sectorId,
    required this.ruleId,
    required this.ruleVersion,
    required this.soilTypeCode,
    required this.inputsJson,
    required this.estimatedLitersMilli,
    required this.recommendedMinutes,
    required this.warningsJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['sector_id'] = Variable<String>(sectorId);
    map['rule_id'] = Variable<String>(ruleId);
    map['rule_version'] = Variable<int>(ruleVersion);
    map['soil_type_code'] = Variable<String>(soilTypeCode);
    map['inputs_json'] = Variable<String>(inputsJson);
    map['estimated_liters_milli'] = Variable<int>(estimatedLitersMilli);
    map['recommended_minutes'] = Variable<int>(recommendedMinutes);
    map['warnings_json'] = Variable<String>(warningsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  IrrigationEstimatesCompanion toCompanion(bool nullToAbsent) {
    return IrrigationEstimatesCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      sectorId: Value(sectorId),
      ruleId: Value(ruleId),
      ruleVersion: Value(ruleVersion),
      soilTypeCode: Value(soilTypeCode),
      inputsJson: Value(inputsJson),
      estimatedLitersMilli: Value(estimatedLitersMilli),
      recommendedMinutes: Value(recommendedMinutes),
      warningsJson: Value(warningsJson),
      createdAt: Value(createdAt),
    );
  }

  factory IrrigationEstimate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IrrigationEstimate(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      sectorId: serializer.fromJson<String>(json['sectorId']),
      ruleId: serializer.fromJson<String>(json['ruleId']),
      ruleVersion: serializer.fromJson<int>(json['ruleVersion']),
      soilTypeCode: serializer.fromJson<String>(json['soilTypeCode']),
      inputsJson: serializer.fromJson<String>(json['inputsJson']),
      estimatedLitersMilli: serializer.fromJson<int>(
        json['estimatedLitersMilli'],
      ),
      recommendedMinutes: serializer.fromJson<int>(json['recommendedMinutes']),
      warningsJson: serializer.fromJson<String>(json['warningsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'sectorId': serializer.toJson<String>(sectorId),
      'ruleId': serializer.toJson<String>(ruleId),
      'ruleVersion': serializer.toJson<int>(ruleVersion),
      'soilTypeCode': serializer.toJson<String>(soilTypeCode),
      'inputsJson': serializer.toJson<String>(inputsJson),
      'estimatedLitersMilli': serializer.toJson<int>(estimatedLitersMilli),
      'recommendedMinutes': serializer.toJson<int>(recommendedMinutes),
      'warningsJson': serializer.toJson<String>(warningsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  IrrigationEstimate copyWith({
    String? id,
    String? ownerId,
    String? sectorId,
    String? ruleId,
    int? ruleVersion,
    String? soilTypeCode,
    String? inputsJson,
    int? estimatedLitersMilli,
    int? recommendedMinutes,
    String? warningsJson,
    DateTime? createdAt,
  }) => IrrigationEstimate(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    sectorId: sectorId ?? this.sectorId,
    ruleId: ruleId ?? this.ruleId,
    ruleVersion: ruleVersion ?? this.ruleVersion,
    soilTypeCode: soilTypeCode ?? this.soilTypeCode,
    inputsJson: inputsJson ?? this.inputsJson,
    estimatedLitersMilli: estimatedLitersMilli ?? this.estimatedLitersMilli,
    recommendedMinutes: recommendedMinutes ?? this.recommendedMinutes,
    warningsJson: warningsJson ?? this.warningsJson,
    createdAt: createdAt ?? this.createdAt,
  );
  IrrigationEstimate copyWithCompanion(IrrigationEstimatesCompanion data) {
    return IrrigationEstimate(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      sectorId: data.sectorId.present ? data.sectorId.value : this.sectorId,
      ruleId: data.ruleId.present ? data.ruleId.value : this.ruleId,
      ruleVersion: data.ruleVersion.present
          ? data.ruleVersion.value
          : this.ruleVersion,
      soilTypeCode: data.soilTypeCode.present
          ? data.soilTypeCode.value
          : this.soilTypeCode,
      inputsJson: data.inputsJson.present
          ? data.inputsJson.value
          : this.inputsJson,
      estimatedLitersMilli: data.estimatedLitersMilli.present
          ? data.estimatedLitersMilli.value
          : this.estimatedLitersMilli,
      recommendedMinutes: data.recommendedMinutes.present
          ? data.recommendedMinutes.value
          : this.recommendedMinutes,
      warningsJson: data.warningsJson.present
          ? data.warningsJson.value
          : this.warningsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IrrigationEstimate(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('sectorId: $sectorId, ')
          ..write('ruleId: $ruleId, ')
          ..write('ruleVersion: $ruleVersion, ')
          ..write('soilTypeCode: $soilTypeCode, ')
          ..write('inputsJson: $inputsJson, ')
          ..write('estimatedLitersMilli: $estimatedLitersMilli, ')
          ..write('recommendedMinutes: $recommendedMinutes, ')
          ..write('warningsJson: $warningsJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    sectorId,
    ruleId,
    ruleVersion,
    soilTypeCode,
    inputsJson,
    estimatedLitersMilli,
    recommendedMinutes,
    warningsJson,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IrrigationEstimate &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.sectorId == this.sectorId &&
          other.ruleId == this.ruleId &&
          other.ruleVersion == this.ruleVersion &&
          other.soilTypeCode == this.soilTypeCode &&
          other.inputsJson == this.inputsJson &&
          other.estimatedLitersMilli == this.estimatedLitersMilli &&
          other.recommendedMinutes == this.recommendedMinutes &&
          other.warningsJson == this.warningsJson &&
          other.createdAt == this.createdAt);
}

class IrrigationEstimatesCompanion extends UpdateCompanion<IrrigationEstimate> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> sectorId;
  final Value<String> ruleId;
  final Value<int> ruleVersion;
  final Value<String> soilTypeCode;
  final Value<String> inputsJson;
  final Value<int> estimatedLitersMilli;
  final Value<int> recommendedMinutes;
  final Value<String> warningsJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const IrrigationEstimatesCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.sectorId = const Value.absent(),
    this.ruleId = const Value.absent(),
    this.ruleVersion = const Value.absent(),
    this.soilTypeCode = const Value.absent(),
    this.inputsJson = const Value.absent(),
    this.estimatedLitersMilli = const Value.absent(),
    this.recommendedMinutes = const Value.absent(),
    this.warningsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IrrigationEstimatesCompanion.insert({
    required String id,
    required String ownerId,
    required String sectorId,
    required String ruleId,
    required int ruleVersion,
    required String soilTypeCode,
    required String inputsJson,
    required int estimatedLitersMilli,
    required int recommendedMinutes,
    this.warningsJson = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       sectorId = Value(sectorId),
       ruleId = Value(ruleId),
       ruleVersion = Value(ruleVersion),
       soilTypeCode = Value(soilTypeCode),
       inputsJson = Value(inputsJson),
       estimatedLitersMilli = Value(estimatedLitersMilli),
       recommendedMinutes = Value(recommendedMinutes),
       createdAt = Value(createdAt);
  static Insertable<IrrigationEstimate> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? sectorId,
    Expression<String>? ruleId,
    Expression<int>? ruleVersion,
    Expression<String>? soilTypeCode,
    Expression<String>? inputsJson,
    Expression<int>? estimatedLitersMilli,
    Expression<int>? recommendedMinutes,
    Expression<String>? warningsJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (sectorId != null) 'sector_id': sectorId,
      if (ruleId != null) 'rule_id': ruleId,
      if (ruleVersion != null) 'rule_version': ruleVersion,
      if (soilTypeCode != null) 'soil_type_code': soilTypeCode,
      if (inputsJson != null) 'inputs_json': inputsJson,
      if (estimatedLitersMilli != null)
        'estimated_liters_milli': estimatedLitersMilli,
      if (recommendedMinutes != null) 'recommended_minutes': recommendedMinutes,
      if (warningsJson != null) 'warnings_json': warningsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IrrigationEstimatesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? sectorId,
    Value<String>? ruleId,
    Value<int>? ruleVersion,
    Value<String>? soilTypeCode,
    Value<String>? inputsJson,
    Value<int>? estimatedLitersMilli,
    Value<int>? recommendedMinutes,
    Value<String>? warningsJson,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return IrrigationEstimatesCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      sectorId: sectorId ?? this.sectorId,
      ruleId: ruleId ?? this.ruleId,
      ruleVersion: ruleVersion ?? this.ruleVersion,
      soilTypeCode: soilTypeCode ?? this.soilTypeCode,
      inputsJson: inputsJson ?? this.inputsJson,
      estimatedLitersMilli: estimatedLitersMilli ?? this.estimatedLitersMilli,
      recommendedMinutes: recommendedMinutes ?? this.recommendedMinutes,
      warningsJson: warningsJson ?? this.warningsJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (sectorId.present) {
      map['sector_id'] = Variable<String>(sectorId.value);
    }
    if (ruleId.present) {
      map['rule_id'] = Variable<String>(ruleId.value);
    }
    if (ruleVersion.present) {
      map['rule_version'] = Variable<int>(ruleVersion.value);
    }
    if (soilTypeCode.present) {
      map['soil_type_code'] = Variable<String>(soilTypeCode.value);
    }
    if (inputsJson.present) {
      map['inputs_json'] = Variable<String>(inputsJson.value);
    }
    if (estimatedLitersMilli.present) {
      map['estimated_liters_milli'] = Variable<int>(estimatedLitersMilli.value);
    }
    if (recommendedMinutes.present) {
      map['recommended_minutes'] = Variable<int>(recommendedMinutes.value);
    }
    if (warningsJson.present) {
      map['warnings_json'] = Variable<String>(warningsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IrrigationEstimatesCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('sectorId: $sectorId, ')
          ..write('ruleId: $ruleId, ')
          ..write('ruleVersion: $ruleVersion, ')
          ..write('soilTypeCode: $soilTypeCode, ')
          ..write('inputsJson: $inputsJson, ')
          ..write('estimatedLitersMilli: $estimatedLitersMilli, ')
          ..write('recommendedMinutes: $recommendedMinutes, ')
          ..write('warningsJson: $warningsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductionRecordsTable extends ProductionRecords
    with TableInfo<$ProductionRecordsTable, ProductionRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductionRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parcelIdMeta = const VerificationMeta(
    'parcelId',
  );
  @override
  late final GeneratedColumn<String> parcelId = GeneratedColumn<String>(
    'parcel_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectorIdMeta = const VerificationMeta(
    'sectorId',
  );
  @override
  late final GeneratedColumn<String> sectorId = GeneratedColumn<String>(
    'sector_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sectors (id)',
    ),
  );
  static const VerificationMeta _seasonIdMeta = const VerificationMeta(
    'seasonId',
  );
  @override
  late final GeneratedColumn<String> seasonId = GeneratedColumn<String>(
    'season_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cropIdMeta = const VerificationMeta('cropId');
  @override
  late final GeneratedColumn<String> cropId = GeneratedColumn<String>(
    'crop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qualityNotesMeta = const VerificationMeta(
    'qualityNotes',
  );
  @override
  late final GeneratedColumn<String> qualityNotes = GeneratedColumn<String>(
    'quality_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _harvestedAtMeta = const VerificationMeta(
    'harvestedAt',
  );
  @override
  late final GeneratedColumn<DateTime> harvestedAt = GeneratedColumn<DateTime>(
    'harvested_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    parcelId,
    sectorId,
    seasonId,
    cropId,
    quantity,
    unit,
    qualityNotes,
    harvestedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'production_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductionRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('parcel_id')) {
      context.handle(
        _parcelIdMeta,
        parcelId.isAcceptableOrUnknown(data['parcel_id']!, _parcelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_parcelIdMeta);
    }
    if (data.containsKey('sector_id')) {
      context.handle(
        _sectorIdMeta,
        sectorId.isAcceptableOrUnknown(data['sector_id']!, _sectorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectorIdMeta);
    }
    if (data.containsKey('season_id')) {
      context.handle(
        _seasonIdMeta,
        seasonId.isAcceptableOrUnknown(data['season_id']!, _seasonIdMeta),
      );
    }
    if (data.containsKey('crop_id')) {
      context.handle(
        _cropIdMeta,
        cropId.isAcceptableOrUnknown(data['crop_id']!, _cropIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cropIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('quality_notes')) {
      context.handle(
        _qualityNotesMeta,
        qualityNotes.isAcceptableOrUnknown(
          data['quality_notes']!,
          _qualityNotesMeta,
        ),
      );
    }
    if (data.containsKey('harvested_at')) {
      context.handle(
        _harvestedAtMeta,
        harvestedAt.isAcceptableOrUnknown(
          data['harvested_at']!,
          _harvestedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_harvestedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductionRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductionRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      parcelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parcel_id'],
      )!,
      sectorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sector_id'],
      )!,
      seasonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}season_id'],
      ),
      cropId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}crop_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      qualityNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quality_notes'],
      ),
      harvestedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}harvested_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProductionRecordsTable createAlias(String alias) {
    return $ProductionRecordsTable(attachedDatabase, alias);
  }
}

class ProductionRecord extends DataClass
    implements Insertable<ProductionRecord> {
  final String id;
  final String ownerId;
  final String parcelId;
  final String sectorId;
  final String? seasonId;
  final String cropId;
  final double quantity;
  final String unit;
  final String? qualityNotes;
  final DateTime harvestedAt;
  final DateTime updatedAt;
  const ProductionRecord({
    required this.id,
    required this.ownerId,
    required this.parcelId,
    required this.sectorId,
    this.seasonId,
    required this.cropId,
    required this.quantity,
    required this.unit,
    this.qualityNotes,
    required this.harvestedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['parcel_id'] = Variable<String>(parcelId);
    map['sector_id'] = Variable<String>(sectorId);
    if (!nullToAbsent || seasonId != null) {
      map['season_id'] = Variable<String>(seasonId);
    }
    map['crop_id'] = Variable<String>(cropId);
    map['quantity'] = Variable<double>(quantity);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || qualityNotes != null) {
      map['quality_notes'] = Variable<String>(qualityNotes);
    }
    map['harvested_at'] = Variable<DateTime>(harvestedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProductionRecordsCompanion toCompanion(bool nullToAbsent) {
    return ProductionRecordsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      parcelId: Value(parcelId),
      sectorId: Value(sectorId),
      seasonId: seasonId == null && nullToAbsent
          ? const Value.absent()
          : Value(seasonId),
      cropId: Value(cropId),
      quantity: Value(quantity),
      unit: Value(unit),
      qualityNotes: qualityNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(qualityNotes),
      harvestedAt: Value(harvestedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProductionRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductionRecord(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      parcelId: serializer.fromJson<String>(json['parcelId']),
      sectorId: serializer.fromJson<String>(json['sectorId']),
      seasonId: serializer.fromJson<String?>(json['seasonId']),
      cropId: serializer.fromJson<String>(json['cropId']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      qualityNotes: serializer.fromJson<String?>(json['qualityNotes']),
      harvestedAt: serializer.fromJson<DateTime>(json['harvestedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'parcelId': serializer.toJson<String>(parcelId),
      'sectorId': serializer.toJson<String>(sectorId),
      'seasonId': serializer.toJson<String?>(seasonId),
      'cropId': serializer.toJson<String>(cropId),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(unit),
      'qualityNotes': serializer.toJson<String?>(qualityNotes),
      'harvestedAt': serializer.toJson<DateTime>(harvestedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProductionRecord copyWith({
    String? id,
    String? ownerId,
    String? parcelId,
    String? sectorId,
    Value<String?> seasonId = const Value.absent(),
    String? cropId,
    double? quantity,
    String? unit,
    Value<String?> qualityNotes = const Value.absent(),
    DateTime? harvestedAt,
    DateTime? updatedAt,
  }) => ProductionRecord(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    parcelId: parcelId ?? this.parcelId,
    sectorId: sectorId ?? this.sectorId,
    seasonId: seasonId.present ? seasonId.value : this.seasonId,
    cropId: cropId ?? this.cropId,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    qualityNotes: qualityNotes.present ? qualityNotes.value : this.qualityNotes,
    harvestedAt: harvestedAt ?? this.harvestedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ProductionRecord copyWithCompanion(ProductionRecordsCompanion data) {
    return ProductionRecord(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      parcelId: data.parcelId.present ? data.parcelId.value : this.parcelId,
      sectorId: data.sectorId.present ? data.sectorId.value : this.sectorId,
      seasonId: data.seasonId.present ? data.seasonId.value : this.seasonId,
      cropId: data.cropId.present ? data.cropId.value : this.cropId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      qualityNotes: data.qualityNotes.present
          ? data.qualityNotes.value
          : this.qualityNotes,
      harvestedAt: data.harvestedAt.present
          ? data.harvestedAt.value
          : this.harvestedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductionRecord(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('parcelId: $parcelId, ')
          ..write('sectorId: $sectorId, ')
          ..write('seasonId: $seasonId, ')
          ..write('cropId: $cropId, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('qualityNotes: $qualityNotes, ')
          ..write('harvestedAt: $harvestedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    parcelId,
    sectorId,
    seasonId,
    cropId,
    quantity,
    unit,
    qualityNotes,
    harvestedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductionRecord &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.parcelId == this.parcelId &&
          other.sectorId == this.sectorId &&
          other.seasonId == this.seasonId &&
          other.cropId == this.cropId &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.qualityNotes == this.qualityNotes &&
          other.harvestedAt == this.harvestedAt &&
          other.updatedAt == this.updatedAt);
}

class ProductionRecordsCompanion extends UpdateCompanion<ProductionRecord> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> parcelId;
  final Value<String> sectorId;
  final Value<String?> seasonId;
  final Value<String> cropId;
  final Value<double> quantity;
  final Value<String> unit;
  final Value<String?> qualityNotes;
  final Value<DateTime> harvestedAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProductionRecordsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.parcelId = const Value.absent(),
    this.sectorId = const Value.absent(),
    this.seasonId = const Value.absent(),
    this.cropId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.qualityNotes = const Value.absent(),
    this.harvestedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductionRecordsCompanion.insert({
    required String id,
    required String ownerId,
    required String parcelId,
    required String sectorId,
    this.seasonId = const Value.absent(),
    required String cropId,
    required double quantity,
    required String unit,
    this.qualityNotes = const Value.absent(),
    required DateTime harvestedAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       parcelId = Value(parcelId),
       sectorId = Value(sectorId),
       cropId = Value(cropId),
       quantity = Value(quantity),
       unit = Value(unit),
       harvestedAt = Value(harvestedAt),
       updatedAt = Value(updatedAt);
  static Insertable<ProductionRecord> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? parcelId,
    Expression<String>? sectorId,
    Expression<String>? seasonId,
    Expression<String>? cropId,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<String>? qualityNotes,
    Expression<DateTime>? harvestedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (parcelId != null) 'parcel_id': parcelId,
      if (sectorId != null) 'sector_id': sectorId,
      if (seasonId != null) 'season_id': seasonId,
      if (cropId != null) 'crop_id': cropId,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (qualityNotes != null) 'quality_notes': qualityNotes,
      if (harvestedAt != null) 'harvested_at': harvestedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductionRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? parcelId,
    Value<String>? sectorId,
    Value<String?>? seasonId,
    Value<String>? cropId,
    Value<double>? quantity,
    Value<String>? unit,
    Value<String?>? qualityNotes,
    Value<DateTime>? harvestedAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProductionRecordsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      parcelId: parcelId ?? this.parcelId,
      sectorId: sectorId ?? this.sectorId,
      seasonId: seasonId ?? this.seasonId,
      cropId: cropId ?? this.cropId,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      qualityNotes: qualityNotes ?? this.qualityNotes,
      harvestedAt: harvestedAt ?? this.harvestedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (parcelId.present) {
      map['parcel_id'] = Variable<String>(parcelId.value);
    }
    if (sectorId.present) {
      map['sector_id'] = Variable<String>(sectorId.value);
    }
    if (seasonId.present) {
      map['season_id'] = Variable<String>(seasonId.value);
    }
    if (cropId.present) {
      map['crop_id'] = Variable<String>(cropId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (qualityNotes.present) {
      map['quality_notes'] = Variable<String>(qualityNotes.value);
    }
    if (harvestedAt.present) {
      map['harvested_at'] = Variable<DateTime>(harvestedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductionRecordsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('parcelId: $parcelId, ')
          ..write('sectorId: $sectorId, ')
          ..write('seasonId: $seasonId, ')
          ..write('cropId: $cropId, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('qualityNotes: $qualityNotes, ')
          ..write('harvestedAt: $harvestedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhotoAttachmentsTable extends PhotoAttachments
    with TableInfo<$PhotoAttachmentsTable, PhotoAttachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotoAttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aggregateTypeMeta = const VerificationMeta(
    'aggregateType',
  );
  @override
  late final GeneratedColumn<String> aggregateType = GeneratedColumn<String>(
    'aggregate_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aggregateIdMeta = const VerificationMeta(
    'aggregateId',
  );
  @override
  late final GeneratedColumn<String> aggregateId = GeneratedColumn<String>(
    'aggregate_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remotePathMeta = const VerificationMeta(
    'remotePath',
  );
  @override
  late final GeneratedColumn<String> remotePath = GeneratedColumn<String>(
    'remote_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uploadStateMeta = const VerificationMeta(
    'uploadState',
  );
  @override
  late final GeneratedColumn<String> uploadState = GeneratedColumn<String>(
    'upload_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    aggregateType,
    aggregateId,
    localPath,
    contentHash,
    mimeType,
    remotePath,
    uploadState,
    capturedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photo_attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<PhotoAttachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('aggregate_type')) {
      context.handle(
        _aggregateTypeMeta,
        aggregateType.isAcceptableOrUnknown(
          data['aggregate_type']!,
          _aggregateTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aggregateTypeMeta);
    }
    if (data.containsKey('aggregate_id')) {
      context.handle(
        _aggregateIdMeta,
        aggregateId.isAcceptableOrUnknown(
          data['aggregate_id']!,
          _aggregateIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aggregateIdMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentHashMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('remote_path')) {
      context.handle(
        _remotePathMeta,
        remotePath.isAcceptableOrUnknown(data['remote_path']!, _remotePathMeta),
      );
    }
    if (data.containsKey('upload_state')) {
      context.handle(
        _uploadStateMeta,
        uploadState.isAcceptableOrUnknown(
          data['upload_state']!,
          _uploadStateMeta,
        ),
      );
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {ownerId, contentHash},
  ];
  @override
  PhotoAttachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhotoAttachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      aggregateType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aggregate_type'],
      )!,
      aggregateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aggregate_id'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      remotePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_path'],
      ),
      uploadState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upload_state'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
    );
  }

  @override
  $PhotoAttachmentsTable createAlias(String alias) {
    return $PhotoAttachmentsTable(attachedDatabase, alias);
  }
}

class PhotoAttachment extends DataClass implements Insertable<PhotoAttachment> {
  final String id;
  final String ownerId;
  final String aggregateType;
  final String aggregateId;
  final String localPath;
  final String contentHash;
  final String mimeType;
  final String? remotePath;
  final String uploadState;
  final DateTime capturedAt;
  const PhotoAttachment({
    required this.id,
    required this.ownerId,
    required this.aggregateType,
    required this.aggregateId,
    required this.localPath,
    required this.contentHash,
    required this.mimeType,
    this.remotePath,
    required this.uploadState,
    required this.capturedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['aggregate_type'] = Variable<String>(aggregateType);
    map['aggregate_id'] = Variable<String>(aggregateId);
    map['local_path'] = Variable<String>(localPath);
    map['content_hash'] = Variable<String>(contentHash);
    map['mime_type'] = Variable<String>(mimeType);
    if (!nullToAbsent || remotePath != null) {
      map['remote_path'] = Variable<String>(remotePath);
    }
    map['upload_state'] = Variable<String>(uploadState);
    map['captured_at'] = Variable<DateTime>(capturedAt);
    return map;
  }

  PhotoAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return PhotoAttachmentsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      aggregateType: Value(aggregateType),
      aggregateId: Value(aggregateId),
      localPath: Value(localPath),
      contentHash: Value(contentHash),
      mimeType: Value(mimeType),
      remotePath: remotePath == null && nullToAbsent
          ? const Value.absent()
          : Value(remotePath),
      uploadState: Value(uploadState),
      capturedAt: Value(capturedAt),
    );
  }

  factory PhotoAttachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhotoAttachment(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      aggregateType: serializer.fromJson<String>(json['aggregateType']),
      aggregateId: serializer.fromJson<String>(json['aggregateId']),
      localPath: serializer.fromJson<String>(json['localPath']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      remotePath: serializer.fromJson<String?>(json['remotePath']),
      uploadState: serializer.fromJson<String>(json['uploadState']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'aggregateType': serializer.toJson<String>(aggregateType),
      'aggregateId': serializer.toJson<String>(aggregateId),
      'localPath': serializer.toJson<String>(localPath),
      'contentHash': serializer.toJson<String>(contentHash),
      'mimeType': serializer.toJson<String>(mimeType),
      'remotePath': serializer.toJson<String?>(remotePath),
      'uploadState': serializer.toJson<String>(uploadState),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
    };
  }

  PhotoAttachment copyWith({
    String? id,
    String? ownerId,
    String? aggregateType,
    String? aggregateId,
    String? localPath,
    String? contentHash,
    String? mimeType,
    Value<String?> remotePath = const Value.absent(),
    String? uploadState,
    DateTime? capturedAt,
  }) => PhotoAttachment(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    aggregateType: aggregateType ?? this.aggregateType,
    aggregateId: aggregateId ?? this.aggregateId,
    localPath: localPath ?? this.localPath,
    contentHash: contentHash ?? this.contentHash,
    mimeType: mimeType ?? this.mimeType,
    remotePath: remotePath.present ? remotePath.value : this.remotePath,
    uploadState: uploadState ?? this.uploadState,
    capturedAt: capturedAt ?? this.capturedAt,
  );
  PhotoAttachment copyWithCompanion(PhotoAttachmentsCompanion data) {
    return PhotoAttachment(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      aggregateType: data.aggregateType.present
          ? data.aggregateType.value
          : this.aggregateType,
      aggregateId: data.aggregateId.present
          ? data.aggregateId.value
          : this.aggregateId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      remotePath: data.remotePath.present
          ? data.remotePath.value
          : this.remotePath,
      uploadState: data.uploadState.present
          ? data.uploadState.value
          : this.uploadState,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhotoAttachment(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('aggregateType: $aggregateType, ')
          ..write('aggregateId: $aggregateId, ')
          ..write('localPath: $localPath, ')
          ..write('contentHash: $contentHash, ')
          ..write('mimeType: $mimeType, ')
          ..write('remotePath: $remotePath, ')
          ..write('uploadState: $uploadState, ')
          ..write('capturedAt: $capturedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    aggregateType,
    aggregateId,
    localPath,
    contentHash,
    mimeType,
    remotePath,
    uploadState,
    capturedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhotoAttachment &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.aggregateType == this.aggregateType &&
          other.aggregateId == this.aggregateId &&
          other.localPath == this.localPath &&
          other.contentHash == this.contentHash &&
          other.mimeType == this.mimeType &&
          other.remotePath == this.remotePath &&
          other.uploadState == this.uploadState &&
          other.capturedAt == this.capturedAt);
}

class PhotoAttachmentsCompanion extends UpdateCompanion<PhotoAttachment> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> aggregateType;
  final Value<String> aggregateId;
  final Value<String> localPath;
  final Value<String> contentHash;
  final Value<String> mimeType;
  final Value<String?> remotePath;
  final Value<String> uploadState;
  final Value<DateTime> capturedAt;
  final Value<int> rowid;
  const PhotoAttachmentsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.aggregateType = const Value.absent(),
    this.aggregateId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.remotePath = const Value.absent(),
    this.uploadState = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhotoAttachmentsCompanion.insert({
    required String id,
    required String ownerId,
    required String aggregateType,
    required String aggregateId,
    required String localPath,
    required String contentHash,
    required String mimeType,
    this.remotePath = const Value.absent(),
    this.uploadState = const Value.absent(),
    required DateTime capturedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       aggregateType = Value(aggregateType),
       aggregateId = Value(aggregateId),
       localPath = Value(localPath),
       contentHash = Value(contentHash),
       mimeType = Value(mimeType),
       capturedAt = Value(capturedAt);
  static Insertable<PhotoAttachment> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? aggregateType,
    Expression<String>? aggregateId,
    Expression<String>? localPath,
    Expression<String>? contentHash,
    Expression<String>? mimeType,
    Expression<String>? remotePath,
    Expression<String>? uploadState,
    Expression<DateTime>? capturedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (aggregateType != null) 'aggregate_type': aggregateType,
      if (aggregateId != null) 'aggregate_id': aggregateId,
      if (localPath != null) 'local_path': localPath,
      if (contentHash != null) 'content_hash': contentHash,
      if (mimeType != null) 'mime_type': mimeType,
      if (remotePath != null) 'remote_path': remotePath,
      if (uploadState != null) 'upload_state': uploadState,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhotoAttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? aggregateType,
    Value<String>? aggregateId,
    Value<String>? localPath,
    Value<String>? contentHash,
    Value<String>? mimeType,
    Value<String?>? remotePath,
    Value<String>? uploadState,
    Value<DateTime>? capturedAt,
    Value<int>? rowid,
  }) {
    return PhotoAttachmentsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      aggregateType: aggregateType ?? this.aggregateType,
      aggregateId: aggregateId ?? this.aggregateId,
      localPath: localPath ?? this.localPath,
      contentHash: contentHash ?? this.contentHash,
      mimeType: mimeType ?? this.mimeType,
      remotePath: remotePath ?? this.remotePath,
      uploadState: uploadState ?? this.uploadState,
      capturedAt: capturedAt ?? this.capturedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (aggregateType.present) {
      map['aggregate_type'] = Variable<String>(aggregateType.value);
    }
    if (aggregateId.present) {
      map['aggregate_id'] = Variable<String>(aggregateId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (remotePath.present) {
      map['remote_path'] = Variable<String>(remotePath.value);
    }
    if (uploadState.present) {
      map['upload_state'] = Variable<String>(uploadState.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotoAttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('aggregateType: $aggregateType, ')
          ..write('aggregateId: $aggregateId, ')
          ..write('localPath: $localPath, ')
          ..write('contentHash: $contentHash, ')
          ..write('mimeType: $mimeType, ')
          ..write('remotePath: $remotePath, ')
          ..write('uploadState: $uploadState, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectorIdMeta = const VerificationMeta(
    'sectorId',
  );
  @override
  late final GeneratedColumn<String> sectorId = GeneratedColumn<String>(
    'sector_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    sectorId,
    title,
    notes,
    scheduledAt,
    isCompleted,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('sector_id')) {
      context.handle(
        _sectorIdMeta,
        sectorId.isAcceptableOrUnknown(data['sector_id']!, _sectorIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      sectorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sector_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final String id;
  final String ownerId;
  final String? sectorId;
  final String title;
  final String? notes;
  final DateTime scheduledAt;
  final bool isCompleted;
  final DateTime updatedAt;
  const Reminder({
    required this.id,
    required this.ownerId,
    this.sectorId,
    required this.title,
    this.notes,
    required this.scheduledAt,
    required this.isCompleted,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    if (!nullToAbsent || sectorId != null) {
      map['sector_id'] = Variable<String>(sectorId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      sectorId: sectorId == null && nullToAbsent
          ? const Value.absent()
          : Value(sectorId),
      title: Value(title),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      scheduledAt: Value(scheduledAt),
      isCompleted: Value(isCompleted),
      updatedAt: Value(updatedAt),
    );
  }

  factory Reminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      sectorId: serializer.fromJson<String?>(json['sectorId']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String?>(json['notes']),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'sectorId': serializer.toJson<String?>(sectorId),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String?>(notes),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Reminder copyWith({
    String? id,
    String? ownerId,
    Value<String?> sectorId = const Value.absent(),
    String? title,
    Value<String?> notes = const Value.absent(),
    DateTime? scheduledAt,
    bool? isCompleted,
    DateTime? updatedAt,
  }) => Reminder(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    sectorId: sectorId.present ? sectorId.value : this.sectorId,
    title: title ?? this.title,
    notes: notes.present ? notes.value : this.notes,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    isCompleted: isCompleted ?? this.isCompleted,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Reminder copyWithCompanion(RemindersCompanion data) {
    return Reminder(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      sectorId: data.sectorId.present ? data.sectorId.value : this.sectorId,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('sectorId: $sectorId, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    sectorId,
    title,
    notes,
    scheduledAt,
    isCompleted,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.sectorId == this.sectorId &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.scheduledAt == this.scheduledAt &&
          other.isCompleted == this.isCompleted &&
          other.updatedAt == this.updatedAt);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String?> sectorId;
  final Value<String> title;
  final Value<String?> notes;
  final Value<DateTime> scheduledAt;
  final Value<bool> isCompleted;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.sectorId = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersCompanion.insert({
    required String id,
    required String ownerId,
    this.sectorId = const Value.absent(),
    required String title,
    this.notes = const Value.absent(),
    required DateTime scheduledAt,
    this.isCompleted = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       title = Value(title),
       scheduledAt = Value(scheduledAt),
       updatedAt = Value(updatedAt);
  static Insertable<Reminder> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? sectorId,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<DateTime>? scheduledAt,
    Expression<bool>? isCompleted,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (sectorId != null) 'sector_id': sectorId,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String?>? sectorId,
    Value<String>? title,
    Value<String?>? notes,
    Value<DateTime>? scheduledAt,
    Value<bool>? isCompleted,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      sectorId: sectorId ?? this.sectorId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isCompleted: isCompleted ?? this.isCompleted,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (sectorId.present) {
      map['sector_id'] = Variable<String>(sectorId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('sectorId: $sectorId, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeviceInstallationsTable extends DeviceInstallations
    with TableInfo<$DeviceInstallationsTable, DeviceInstallation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceInstallationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fcmTokenMeta = const VerificationMeta(
    'fcmToken',
  );
  @override
  late final GeneratedColumn<String> fcmToken = GeneratedColumn<String>(
    'fcm_token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('android'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    fcmToken,
    platform,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_installations';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceInstallation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('fcm_token')) {
      context.handle(
        _fcmTokenMeta,
        fcmToken.isAcceptableOrUnknown(data['fcm_token']!, _fcmTokenMeta),
      );
    } else if (isInserting) {
      context.missing(_fcmTokenMeta);
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeviceInstallation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceInstallation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      fcmToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fcm_token'],
      )!,
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DeviceInstallationsTable createAlias(String alias) {
    return $DeviceInstallationsTable(attachedDatabase, alias);
  }
}

class DeviceInstallation extends DataClass
    implements Insertable<DeviceInstallation> {
  final String id;
  final String ownerId;
  final String fcmToken;
  final String platform;
  final DateTime updatedAt;
  const DeviceInstallation({
    required this.id,
    required this.ownerId,
    required this.fcmToken,
    required this.platform,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['fcm_token'] = Variable<String>(fcmToken);
    map['platform'] = Variable<String>(platform);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DeviceInstallationsCompanion toCompanion(bool nullToAbsent) {
    return DeviceInstallationsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      fcmToken: Value(fcmToken),
      platform: Value(platform),
      updatedAt: Value(updatedAt),
    );
  }

  factory DeviceInstallation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceInstallation(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      fcmToken: serializer.fromJson<String>(json['fcmToken']),
      platform: serializer.fromJson<String>(json['platform']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'fcmToken': serializer.toJson<String>(fcmToken),
      'platform': serializer.toJson<String>(platform),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DeviceInstallation copyWith({
    String? id,
    String? ownerId,
    String? fcmToken,
    String? platform,
    DateTime? updatedAt,
  }) => DeviceInstallation(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    fcmToken: fcmToken ?? this.fcmToken,
    platform: platform ?? this.platform,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DeviceInstallation copyWithCompanion(DeviceInstallationsCompanion data) {
    return DeviceInstallation(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      fcmToken: data.fcmToken.present ? data.fcmToken.value : this.fcmToken,
      platform: data.platform.present ? data.platform.value : this.platform,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceInstallation(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('fcmToken: $fcmToken, ')
          ..write('platform: $platform, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ownerId, fcmToken, platform, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceInstallation &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.fcmToken == this.fcmToken &&
          other.platform == this.platform &&
          other.updatedAt == this.updatedAt);
}

class DeviceInstallationsCompanion extends UpdateCompanion<DeviceInstallation> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> fcmToken;
  final Value<String> platform;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DeviceInstallationsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.fcmToken = const Value.absent(),
    this.platform = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeviceInstallationsCompanion.insert({
    required String id,
    required String ownerId,
    required String fcmToken,
    this.platform = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       fcmToken = Value(fcmToken),
       updatedAt = Value(updatedAt);
  static Insertable<DeviceInstallation> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? fcmToken,
    Expression<String>? platform,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (fcmToken != null) 'fcm_token': fcmToken,
      if (platform != null) 'platform': platform,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeviceInstallationsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? fcmToken,
    Value<String>? platform,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DeviceInstallationsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      fcmToken: fcmToken ?? this.fcmToken,
      platform: platform ?? this.platform,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (fcmToken.present) {
      map['fcm_token'] = Variable<String>(fcmToken.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceInstallationsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('fcmToken: $fcmToken, ')
          ..write('platform: $platform, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ApiaryInspectionsTable extends ApiaryInspections
    with TableInfo<$ApiaryInspectionsTable, ApiaryInspection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ApiaryInspectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectorIdMeta = const VerificationMeta(
    'sectorId',
  );
  @override
  late final GeneratedColumn<String> sectorId = GeneratedColumn<String>(
    'sector_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskTypeMeta = const VerificationMeta(
    'taskType',
  );
  @override
  late final GeneratedColumn<String> taskType = GeneratedColumn<String>(
    'task_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _beekeeperNameMeta = const VerificationMeta(
    'beekeeperName',
  );
  @override
  late final GeneratedColumn<String> beekeeperName = GeneratedColumn<String>(
    'beekeeper_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hiveCountMeta = const VerificationMeta(
    'hiveCount',
  );
  @override
  late final GeneratedColumn<int> hiveCount = GeneratedColumn<int>(
    'hive_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _queenStatusMeta = const VerificationMeta(
    'queenStatus',
  );
  @override
  late final GeneratedColumn<String> queenStatus = GeneratedColumn<String>(
    'queen_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _broodStatusMeta = const VerificationMeta(
    'broodStatus',
  );
  @override
  late final GeneratedColumn<String> broodStatus = GeneratedColumn<String>(
    'brood_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feedingStatusMeta = const VerificationMeta(
    'feedingStatus',
  );
  @override
  late final GeneratedColumn<String> feedingStatus = GeneratedColumn<String>(
    'feeding_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _healthNotesMeta = const VerificationMeta(
    'healthNotes',
  );
  @override
  late final GeneratedColumn<String> healthNotes = GeneratedColumn<String>(
    'health_notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pestNotesMeta = const VerificationMeta(
    'pestNotes',
  );
  @override
  late final GeneratedColumn<String> pestNotes = GeneratedColumn<String>(
    'pest_notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _superInstalledMeta = const VerificationMeta(
    'superInstalled',
  );
  @override
  late final GeneratedColumn<bool> superInstalled = GeneratedColumn<bool>(
    'super_installed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("super_installed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _observationsMeta = const VerificationMeta(
    'observations',
  );
  @override
  late final GeneratedColumn<String> observations = GeneratedColumn<String>(
    'observations',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inspectedAtMeta = const VerificationMeta(
    'inspectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> inspectedAt = GeneratedColumn<DateTime>(
    'inspected_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    sectorId,
    taskType,
    beekeeperName,
    hiveCount,
    queenStatus,
    broodStatus,
    feedingStatus,
    healthNotes,
    pestNotes,
    superInstalled,
    observations,
    inspectedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'apiary_inspections';
  @override
  VerificationContext validateIntegrity(
    Insertable<ApiaryInspection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('sector_id')) {
      context.handle(
        _sectorIdMeta,
        sectorId.isAcceptableOrUnknown(data['sector_id']!, _sectorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectorIdMeta);
    }
    if (data.containsKey('task_type')) {
      context.handle(
        _taskTypeMeta,
        taskType.isAcceptableOrUnknown(data['task_type']!, _taskTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_taskTypeMeta);
    }
    if (data.containsKey('beekeeper_name')) {
      context.handle(
        _beekeeperNameMeta,
        beekeeperName.isAcceptableOrUnknown(
          data['beekeeper_name']!,
          _beekeeperNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_beekeeperNameMeta);
    }
    if (data.containsKey('hive_count')) {
      context.handle(
        _hiveCountMeta,
        hiveCount.isAcceptableOrUnknown(data['hive_count']!, _hiveCountMeta),
      );
    } else if (isInserting) {
      context.missing(_hiveCountMeta);
    }
    if (data.containsKey('queen_status')) {
      context.handle(
        _queenStatusMeta,
        queenStatus.isAcceptableOrUnknown(
          data['queen_status']!,
          _queenStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_queenStatusMeta);
    }
    if (data.containsKey('brood_status')) {
      context.handle(
        _broodStatusMeta,
        broodStatus.isAcceptableOrUnknown(
          data['brood_status']!,
          _broodStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_broodStatusMeta);
    }
    if (data.containsKey('feeding_status')) {
      context.handle(
        _feedingStatusMeta,
        feedingStatus.isAcceptableOrUnknown(
          data['feeding_status']!,
          _feedingStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_feedingStatusMeta);
    }
    if (data.containsKey('health_notes')) {
      context.handle(
        _healthNotesMeta,
        healthNotes.isAcceptableOrUnknown(
          data['health_notes']!,
          _healthNotesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_healthNotesMeta);
    }
    if (data.containsKey('pest_notes')) {
      context.handle(
        _pestNotesMeta,
        pestNotes.isAcceptableOrUnknown(data['pest_notes']!, _pestNotesMeta),
      );
    } else if (isInserting) {
      context.missing(_pestNotesMeta);
    }
    if (data.containsKey('super_installed')) {
      context.handle(
        _superInstalledMeta,
        superInstalled.isAcceptableOrUnknown(
          data['super_installed']!,
          _superInstalledMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_superInstalledMeta);
    }
    if (data.containsKey('observations')) {
      context.handle(
        _observationsMeta,
        observations.isAcceptableOrUnknown(
          data['observations']!,
          _observationsMeta,
        ),
      );
    }
    if (data.containsKey('inspected_at')) {
      context.handle(
        _inspectedAtMeta,
        inspectedAt.isAcceptableOrUnknown(
          data['inspected_at']!,
          _inspectedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_inspectedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ApiaryInspection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ApiaryInspection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      sectorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sector_id'],
      )!,
      taskType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_type'],
      )!,
      beekeeperName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}beekeeper_name'],
      )!,
      hiveCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hive_count'],
      )!,
      queenStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}queen_status'],
      )!,
      broodStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brood_status'],
      )!,
      feedingStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feeding_status'],
      )!,
      healthNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}health_notes'],
      )!,
      pestNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pest_notes'],
      )!,
      superInstalled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}super_installed'],
      )!,
      observations: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observations'],
      ),
      inspectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}inspected_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ApiaryInspectionsTable createAlias(String alias) {
    return $ApiaryInspectionsTable(attachedDatabase, alias);
  }
}

class ApiaryInspection extends DataClass
    implements Insertable<ApiaryInspection> {
  final String id;
  final String ownerId;
  final String sectorId;
  final String taskType;
  final String beekeeperName;
  final int hiveCount;
  final String queenStatus;
  final String broodStatus;
  final String feedingStatus;
  final String healthNotes;
  final String pestNotes;
  final bool superInstalled;
  final String? observations;
  final DateTime inspectedAt;
  final DateTime updatedAt;
  const ApiaryInspection({
    required this.id,
    required this.ownerId,
    required this.sectorId,
    required this.taskType,
    required this.beekeeperName,
    required this.hiveCount,
    required this.queenStatus,
    required this.broodStatus,
    required this.feedingStatus,
    required this.healthNotes,
    required this.pestNotes,
    required this.superInstalled,
    this.observations,
    required this.inspectedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['sector_id'] = Variable<String>(sectorId);
    map['task_type'] = Variable<String>(taskType);
    map['beekeeper_name'] = Variable<String>(beekeeperName);
    map['hive_count'] = Variable<int>(hiveCount);
    map['queen_status'] = Variable<String>(queenStatus);
    map['brood_status'] = Variable<String>(broodStatus);
    map['feeding_status'] = Variable<String>(feedingStatus);
    map['health_notes'] = Variable<String>(healthNotes);
    map['pest_notes'] = Variable<String>(pestNotes);
    map['super_installed'] = Variable<bool>(superInstalled);
    if (!nullToAbsent || observations != null) {
      map['observations'] = Variable<String>(observations);
    }
    map['inspected_at'] = Variable<DateTime>(inspectedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ApiaryInspectionsCompanion toCompanion(bool nullToAbsent) {
    return ApiaryInspectionsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      sectorId: Value(sectorId),
      taskType: Value(taskType),
      beekeeperName: Value(beekeeperName),
      hiveCount: Value(hiveCount),
      queenStatus: Value(queenStatus),
      broodStatus: Value(broodStatus),
      feedingStatus: Value(feedingStatus),
      healthNotes: Value(healthNotes),
      pestNotes: Value(pestNotes),
      superInstalled: Value(superInstalled),
      observations: observations == null && nullToAbsent
          ? const Value.absent()
          : Value(observations),
      inspectedAt: Value(inspectedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ApiaryInspection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ApiaryInspection(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      sectorId: serializer.fromJson<String>(json['sectorId']),
      taskType: serializer.fromJson<String>(json['taskType']),
      beekeeperName: serializer.fromJson<String>(json['beekeeperName']),
      hiveCount: serializer.fromJson<int>(json['hiveCount']),
      queenStatus: serializer.fromJson<String>(json['queenStatus']),
      broodStatus: serializer.fromJson<String>(json['broodStatus']),
      feedingStatus: serializer.fromJson<String>(json['feedingStatus']),
      healthNotes: serializer.fromJson<String>(json['healthNotes']),
      pestNotes: serializer.fromJson<String>(json['pestNotes']),
      superInstalled: serializer.fromJson<bool>(json['superInstalled']),
      observations: serializer.fromJson<String?>(json['observations']),
      inspectedAt: serializer.fromJson<DateTime>(json['inspectedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'sectorId': serializer.toJson<String>(sectorId),
      'taskType': serializer.toJson<String>(taskType),
      'beekeeperName': serializer.toJson<String>(beekeeperName),
      'hiveCount': serializer.toJson<int>(hiveCount),
      'queenStatus': serializer.toJson<String>(queenStatus),
      'broodStatus': serializer.toJson<String>(broodStatus),
      'feedingStatus': serializer.toJson<String>(feedingStatus),
      'healthNotes': serializer.toJson<String>(healthNotes),
      'pestNotes': serializer.toJson<String>(pestNotes),
      'superInstalled': serializer.toJson<bool>(superInstalled),
      'observations': serializer.toJson<String?>(observations),
      'inspectedAt': serializer.toJson<DateTime>(inspectedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ApiaryInspection copyWith({
    String? id,
    String? ownerId,
    String? sectorId,
    String? taskType,
    String? beekeeperName,
    int? hiveCount,
    String? queenStatus,
    String? broodStatus,
    String? feedingStatus,
    String? healthNotes,
    String? pestNotes,
    bool? superInstalled,
    Value<String?> observations = const Value.absent(),
    DateTime? inspectedAt,
    DateTime? updatedAt,
  }) => ApiaryInspection(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    sectorId: sectorId ?? this.sectorId,
    taskType: taskType ?? this.taskType,
    beekeeperName: beekeeperName ?? this.beekeeperName,
    hiveCount: hiveCount ?? this.hiveCount,
    queenStatus: queenStatus ?? this.queenStatus,
    broodStatus: broodStatus ?? this.broodStatus,
    feedingStatus: feedingStatus ?? this.feedingStatus,
    healthNotes: healthNotes ?? this.healthNotes,
    pestNotes: pestNotes ?? this.pestNotes,
    superInstalled: superInstalled ?? this.superInstalled,
    observations: observations.present ? observations.value : this.observations,
    inspectedAt: inspectedAt ?? this.inspectedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ApiaryInspection copyWithCompanion(ApiaryInspectionsCompanion data) {
    return ApiaryInspection(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      sectorId: data.sectorId.present ? data.sectorId.value : this.sectorId,
      taskType: data.taskType.present ? data.taskType.value : this.taskType,
      beekeeperName: data.beekeeperName.present
          ? data.beekeeperName.value
          : this.beekeeperName,
      hiveCount: data.hiveCount.present ? data.hiveCount.value : this.hiveCount,
      queenStatus: data.queenStatus.present
          ? data.queenStatus.value
          : this.queenStatus,
      broodStatus: data.broodStatus.present
          ? data.broodStatus.value
          : this.broodStatus,
      feedingStatus: data.feedingStatus.present
          ? data.feedingStatus.value
          : this.feedingStatus,
      healthNotes: data.healthNotes.present
          ? data.healthNotes.value
          : this.healthNotes,
      pestNotes: data.pestNotes.present ? data.pestNotes.value : this.pestNotes,
      superInstalled: data.superInstalled.present
          ? data.superInstalled.value
          : this.superInstalled,
      observations: data.observations.present
          ? data.observations.value
          : this.observations,
      inspectedAt: data.inspectedAt.present
          ? data.inspectedAt.value
          : this.inspectedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ApiaryInspection(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('sectorId: $sectorId, ')
          ..write('taskType: $taskType, ')
          ..write('beekeeperName: $beekeeperName, ')
          ..write('hiveCount: $hiveCount, ')
          ..write('queenStatus: $queenStatus, ')
          ..write('broodStatus: $broodStatus, ')
          ..write('feedingStatus: $feedingStatus, ')
          ..write('healthNotes: $healthNotes, ')
          ..write('pestNotes: $pestNotes, ')
          ..write('superInstalled: $superInstalled, ')
          ..write('observations: $observations, ')
          ..write('inspectedAt: $inspectedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    sectorId,
    taskType,
    beekeeperName,
    hiveCount,
    queenStatus,
    broodStatus,
    feedingStatus,
    healthNotes,
    pestNotes,
    superInstalled,
    observations,
    inspectedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ApiaryInspection &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.sectorId == this.sectorId &&
          other.taskType == this.taskType &&
          other.beekeeperName == this.beekeeperName &&
          other.hiveCount == this.hiveCount &&
          other.queenStatus == this.queenStatus &&
          other.broodStatus == this.broodStatus &&
          other.feedingStatus == this.feedingStatus &&
          other.healthNotes == this.healthNotes &&
          other.pestNotes == this.pestNotes &&
          other.superInstalled == this.superInstalled &&
          other.observations == this.observations &&
          other.inspectedAt == this.inspectedAt &&
          other.updatedAt == this.updatedAt);
}

class ApiaryInspectionsCompanion extends UpdateCompanion<ApiaryInspection> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> sectorId;
  final Value<String> taskType;
  final Value<String> beekeeperName;
  final Value<int> hiveCount;
  final Value<String> queenStatus;
  final Value<String> broodStatus;
  final Value<String> feedingStatus;
  final Value<String> healthNotes;
  final Value<String> pestNotes;
  final Value<bool> superInstalled;
  final Value<String?> observations;
  final Value<DateTime> inspectedAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ApiaryInspectionsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.sectorId = const Value.absent(),
    this.taskType = const Value.absent(),
    this.beekeeperName = const Value.absent(),
    this.hiveCount = const Value.absent(),
    this.queenStatus = const Value.absent(),
    this.broodStatus = const Value.absent(),
    this.feedingStatus = const Value.absent(),
    this.healthNotes = const Value.absent(),
    this.pestNotes = const Value.absent(),
    this.superInstalled = const Value.absent(),
    this.observations = const Value.absent(),
    this.inspectedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ApiaryInspectionsCompanion.insert({
    required String id,
    required String ownerId,
    required String sectorId,
    required String taskType,
    required String beekeeperName,
    required int hiveCount,
    required String queenStatus,
    required String broodStatus,
    required String feedingStatus,
    required String healthNotes,
    required String pestNotes,
    required bool superInstalled,
    this.observations = const Value.absent(),
    required DateTime inspectedAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       sectorId = Value(sectorId),
       taskType = Value(taskType),
       beekeeperName = Value(beekeeperName),
       hiveCount = Value(hiveCount),
       queenStatus = Value(queenStatus),
       broodStatus = Value(broodStatus),
       feedingStatus = Value(feedingStatus),
       healthNotes = Value(healthNotes),
       pestNotes = Value(pestNotes),
       superInstalled = Value(superInstalled),
       inspectedAt = Value(inspectedAt),
       updatedAt = Value(updatedAt);
  static Insertable<ApiaryInspection> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? sectorId,
    Expression<String>? taskType,
    Expression<String>? beekeeperName,
    Expression<int>? hiveCount,
    Expression<String>? queenStatus,
    Expression<String>? broodStatus,
    Expression<String>? feedingStatus,
    Expression<String>? healthNotes,
    Expression<String>? pestNotes,
    Expression<bool>? superInstalled,
    Expression<String>? observations,
    Expression<DateTime>? inspectedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (sectorId != null) 'sector_id': sectorId,
      if (taskType != null) 'task_type': taskType,
      if (beekeeperName != null) 'beekeeper_name': beekeeperName,
      if (hiveCount != null) 'hive_count': hiveCount,
      if (queenStatus != null) 'queen_status': queenStatus,
      if (broodStatus != null) 'brood_status': broodStatus,
      if (feedingStatus != null) 'feeding_status': feedingStatus,
      if (healthNotes != null) 'health_notes': healthNotes,
      if (pestNotes != null) 'pest_notes': pestNotes,
      if (superInstalled != null) 'super_installed': superInstalled,
      if (observations != null) 'observations': observations,
      if (inspectedAt != null) 'inspected_at': inspectedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ApiaryInspectionsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? sectorId,
    Value<String>? taskType,
    Value<String>? beekeeperName,
    Value<int>? hiveCount,
    Value<String>? queenStatus,
    Value<String>? broodStatus,
    Value<String>? feedingStatus,
    Value<String>? healthNotes,
    Value<String>? pestNotes,
    Value<bool>? superInstalled,
    Value<String?>? observations,
    Value<DateTime>? inspectedAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ApiaryInspectionsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      sectorId: sectorId ?? this.sectorId,
      taskType: taskType ?? this.taskType,
      beekeeperName: beekeeperName ?? this.beekeeperName,
      hiveCount: hiveCount ?? this.hiveCount,
      queenStatus: queenStatus ?? this.queenStatus,
      broodStatus: broodStatus ?? this.broodStatus,
      feedingStatus: feedingStatus ?? this.feedingStatus,
      healthNotes: healthNotes ?? this.healthNotes,
      pestNotes: pestNotes ?? this.pestNotes,
      superInstalled: superInstalled ?? this.superInstalled,
      observations: observations ?? this.observations,
      inspectedAt: inspectedAt ?? this.inspectedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (sectorId.present) {
      map['sector_id'] = Variable<String>(sectorId.value);
    }
    if (taskType.present) {
      map['task_type'] = Variable<String>(taskType.value);
    }
    if (beekeeperName.present) {
      map['beekeeper_name'] = Variable<String>(beekeeperName.value);
    }
    if (hiveCount.present) {
      map['hive_count'] = Variable<int>(hiveCount.value);
    }
    if (queenStatus.present) {
      map['queen_status'] = Variable<String>(queenStatus.value);
    }
    if (broodStatus.present) {
      map['brood_status'] = Variable<String>(broodStatus.value);
    }
    if (feedingStatus.present) {
      map['feeding_status'] = Variable<String>(feedingStatus.value);
    }
    if (healthNotes.present) {
      map['health_notes'] = Variable<String>(healthNotes.value);
    }
    if (pestNotes.present) {
      map['pest_notes'] = Variable<String>(pestNotes.value);
    }
    if (superInstalled.present) {
      map['super_installed'] = Variable<bool>(superInstalled.value);
    }
    if (observations.present) {
      map['observations'] = Variable<String>(observations.value);
    }
    if (inspectedAt.present) {
      map['inspected_at'] = Variable<DateTime>(inspectedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ApiaryInspectionsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('sectorId: $sectorId, ')
          ..write('taskType: $taskType, ')
          ..write('beekeeperName: $beekeeperName, ')
          ..write('hiveCount: $hiveCount, ')
          ..write('queenStatus: $queenStatus, ')
          ..write('broodStatus: $broodStatus, ')
          ..write('feedingStatus: $feedingStatus, ')
          ..write('healthNotes: $healthNotes, ')
          ..write('pestNotes: $pestNotes, ')
          ..write('superInstalled: $superInstalled, ')
          ..write('observations: $observations, ')
          ..write('inspectedAt: $inspectedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WeatherCacheTable extends WeatherCache
    with TableInfo<$WeatherCacheTable, WeatherCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeatherCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localityMeta = const VerificationMeta(
    'locality',
  );
  @override
  late final GeneratedColumn<String> locality = GeneratedColumn<String>(
    'locality',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    locality,
    payloadJson,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weather_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeatherCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('locality')) {
      context.handle(
        _localityMeta,
        locality.isAcceptableOrUnknown(data['locality']!, _localityMeta),
      );
    } else if (isInserting) {
      context.missing(_localityMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeatherCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeatherCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      locality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locality'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $WeatherCacheTable createAlias(String alias) {
    return $WeatherCacheTable(attachedDatabase, alias);
  }
}

class WeatherCacheData extends DataClass
    implements Insertable<WeatherCacheData> {
  final String id;
  final String ownerId;
  final String locality;
  final String payloadJson;
  final DateTime fetchedAt;
  const WeatherCacheData({
    required this.id,
    required this.ownerId,
    required this.locality,
    required this.payloadJson,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['locality'] = Variable<String>(locality);
    map['payload_json'] = Variable<String>(payloadJson);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  WeatherCacheCompanion toCompanion(bool nullToAbsent) {
    return WeatherCacheCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      locality: Value(locality),
      payloadJson: Value(payloadJson),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory WeatherCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeatherCacheData(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      locality: serializer.fromJson<String>(json['locality']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'locality': serializer.toJson<String>(locality),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  WeatherCacheData copyWith({
    String? id,
    String? ownerId,
    String? locality,
    String? payloadJson,
    DateTime? fetchedAt,
  }) => WeatherCacheData(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    locality: locality ?? this.locality,
    payloadJson: payloadJson ?? this.payloadJson,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  WeatherCacheData copyWithCompanion(WeatherCacheCompanion data) {
    return WeatherCacheData(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      locality: data.locality.present ? data.locality.value : this.locality,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeatherCacheData(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('locality: $locality, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, ownerId, locality, payloadJson, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeatherCacheData &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.locality == this.locality &&
          other.payloadJson == this.payloadJson &&
          other.fetchedAt == this.fetchedAt);
}

class WeatherCacheCompanion extends UpdateCompanion<WeatherCacheData> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> locality;
  final Value<String> payloadJson;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const WeatherCacheCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.locality = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeatherCacheCompanion.insert({
    required String id,
    required String ownerId,
    required String locality,
    required String payloadJson,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       locality = Value(locality),
       payloadJson = Value(payloadJson),
       fetchedAt = Value(fetchedAt);
  static Insertable<WeatherCacheData> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? locality,
    Expression<String>? payloadJson,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (locality != null) 'locality': locality,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeatherCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? locality,
    Value<String>? payloadJson,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return WeatherCacheCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      locality: locality ?? this.locality,
      payloadJson: payloadJson ?? this.payloadJson,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (locality.present) {
      map['locality'] = Variable<String>(locality.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeatherCacheCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('locality: $locality, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiMessagesTable extends AiMessages
    with TableInfo<$AiMessagesTable, AiMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, ownerId, role, content, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AiMessagesTable createAlias(String alias) {
    return $AiMessagesTable(attachedDatabase, alias);
  }
}

class AiMessage extends DataClass implements Insertable<AiMessage> {
  final String id;
  final String ownerId;
  final String role;
  final String content;
  final DateTime createdAt;
  const AiMessage({
    required this.id,
    required this.ownerId,
    required this.role,
    required this.content,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AiMessagesCompanion toCompanion(bool nullToAbsent) {
    return AiMessagesCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      role: Value(role),
      content: Value(content),
      createdAt: Value(createdAt),
    );
  }

  factory AiMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiMessage(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AiMessage copyWith({
    String? id,
    String? ownerId,
    String? role,
    String? content,
    DateTime? createdAt,
  }) => AiMessage(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    role: role ?? this.role,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
  );
  AiMessage copyWithCompanion(AiMessagesCompanion data) {
    return AiMessage(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiMessage(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ownerId, role, content, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiMessage &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.role == this.role &&
          other.content == this.content &&
          other.createdAt == this.createdAt);
}

class AiMessagesCompanion extends UpdateCompanion<AiMessage> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> role;
  final Value<String> content;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AiMessagesCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiMessagesCompanion.insert({
    required String id,
    required String ownerId,
    required String role,
    required String content,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       role = Value(role),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<AiMessage> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiMessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? role,
    Value<String>? content,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AiMessagesCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiMessagesCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExportSnapshotsTable extends ExportSnapshots
    with TableInfo<$ExportSnapshotsTable, ExportSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExportSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manifestJsonMeta = const VerificationMeta(
    'manifestJson',
  );
  @override
  late final GeneratedColumn<String> manifestJson = GeneratedColumn<String>(
    'manifest_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    status,
    manifestJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'export_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExportSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('manifest_json')) {
      context.handle(
        _manifestJsonMeta,
        manifestJson.isAcceptableOrUnknown(
          data['manifest_json']!,
          _manifestJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_manifestJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExportSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExportSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      manifestJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manifest_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ExportSnapshotsTable createAlias(String alias) {
    return $ExportSnapshotsTable(attachedDatabase, alias);
  }
}

class ExportSnapshot extends DataClass implements Insertable<ExportSnapshot> {
  final String id;
  final String ownerId;
  final String status;
  final String manifestJson;
  final DateTime createdAt;
  const ExportSnapshot({
    required this.id,
    required this.ownerId,
    required this.status,
    required this.manifestJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['status'] = Variable<String>(status);
    map['manifest_json'] = Variable<String>(manifestJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ExportSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return ExportSnapshotsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      status: Value(status),
      manifestJson: Value(manifestJson),
      createdAt: Value(createdAt),
    );
  }

  factory ExportSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExportSnapshot(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      status: serializer.fromJson<String>(json['status']),
      manifestJson: serializer.fromJson<String>(json['manifestJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'status': serializer.toJson<String>(status),
      'manifestJson': serializer.toJson<String>(manifestJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ExportSnapshot copyWith({
    String? id,
    String? ownerId,
    String? status,
    String? manifestJson,
    DateTime? createdAt,
  }) => ExportSnapshot(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    status: status ?? this.status,
    manifestJson: manifestJson ?? this.manifestJson,
    createdAt: createdAt ?? this.createdAt,
  );
  ExportSnapshot copyWithCompanion(ExportSnapshotsCompanion data) {
    return ExportSnapshot(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      status: data.status.present ? data.status.value : this.status,
      manifestJson: data.manifestJson.present
          ? data.manifestJson.value
          : this.manifestJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExportSnapshot(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('status: $status, ')
          ..write('manifestJson: $manifestJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ownerId, status, manifestJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExportSnapshot &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.status == this.status &&
          other.manifestJson == this.manifestJson &&
          other.createdAt == this.createdAt);
}

class ExportSnapshotsCompanion extends UpdateCompanion<ExportSnapshot> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> status;
  final Value<String> manifestJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ExportSnapshotsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.status = const Value.absent(),
    this.manifestJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExportSnapshotsCompanion.insert({
    required String id,
    required String ownerId,
    required String status,
    required String manifestJson,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       status = Value(status),
       manifestJson = Value(manifestJson),
       createdAt = Value(createdAt);
  static Insertable<ExportSnapshot> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? status,
    Expression<String>? manifestJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (status != null) 'status': status,
      if (manifestJson != null) 'manifest_json': manifestJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExportSnapshotsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? status,
    Value<String>? manifestJson,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ExportSnapshotsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      status: status ?? this.status,
      manifestJson: manifestJson ?? this.manifestJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (manifestJson.present) {
      map['manifest_json'] = Variable<String>(manifestJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExportSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('status: $status, ')
          ..write('manifestJson: $manifestJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalProfilesTable localProfiles = $LocalProfilesTable(this);
  late final $AppPreferencesTable appPreferences = $AppPreferencesTable(this);
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  late final $SyncCursorsTable syncCursors = $SyncCursorsTable(this);
  late final $SyncConflictsTable syncConflicts = $SyncConflictsTable(this);
  late final $FormDraftsTable formDrafts = $FormDraftsTable(this);
  late final $ParcelsTable parcels = $ParcelsTable(this);
  late final $SectorsTable sectors = $SectorsTable(this);
  late final $OfficialCropsTable officialCrops = $OfficialCropsTable(this);
  late final $CustomCropsTable customCrops = $CustomCropsTable(this);
  late final $CropSeasonsTable cropSeasons = $CropSeasonsTable(this);
  late final $LaborsTable labors = $LaborsTable(this);
  late final $SoilMeasurementsTable soilMeasurements = $SoilMeasurementsTable(
    this,
  );
  late final $IrrigationRecordsTable irrigationRecords =
      $IrrigationRecordsTable(this);
  late final $CropIrrigationRulesTable cropIrrigationRules =
      $CropIrrigationRulesTable(this);
  late final $IrrigationEstimatesTable irrigationEstimates =
      $IrrigationEstimatesTable(this);
  late final $ProductionRecordsTable productionRecords =
      $ProductionRecordsTable(this);
  late final $PhotoAttachmentsTable photoAttachments = $PhotoAttachmentsTable(
    this,
  );
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $DeviceInstallationsTable deviceInstallations =
      $DeviceInstallationsTable(this);
  late final $ApiaryInspectionsTable apiaryInspections =
      $ApiaryInspectionsTable(this);
  late final $WeatherCacheTable weatherCache = $WeatherCacheTable(this);
  late final $AiMessagesTable aiMessages = $AiMessagesTable(this);
  late final $ExportSnapshotsTable exportSnapshots = $ExportSnapshotsTable(
    this,
  );
  late final SyncOutboxDao syncOutboxDao = SyncOutboxDao(this as AppDatabase);
  late final SyncCursorDao syncCursorDao = SyncCursorDao(this as AppDatabase);
  late final ConflictDao conflictDao = ConflictDao(this as AppDatabase);
  late final FormDraftDao formDraftDao = FormDraftDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localProfiles,
    appPreferences,
    syncOutbox,
    syncCursors,
    syncConflicts,
    formDrafts,
    parcels,
    sectors,
    officialCrops,
    customCrops,
    cropSeasons,
    labors,
    soilMeasurements,
    irrigationRecords,
    cropIrrigationRules,
    irrigationEstimates,
    productionRecords,
    photoAttachments,
    reminders,
    deviceInstallations,
    apiaryInspections,
    weatherCache,
    aiMessages,
    exportSnapshots,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$LocalProfilesTableCreateCompanionBuilder =
    LocalProfilesCompanion Function({
      required String id,
      required String displayName,
      Value<String?> emailDisplay,
      Value<String> locale,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalProfilesTableUpdateCompanionBuilder =
    LocalProfilesCompanion Function({
      Value<String> id,
      Value<String> displayName,
      Value<String?> emailDisplay,
      Value<String> locale,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalProfilesTable> {
  $$LocalProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emailDisplay => $composableBuilder(
    column: $table.emailDisplay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalProfilesTable> {
  $$LocalProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emailDisplay => $composableBuilder(
    column: $table.emailDisplay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalProfilesTable> {
  $$LocalProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get emailDisplay => $composableBuilder(
    column: $table.emailDisplay,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalProfilesTable,
          LocalProfile,
          $$LocalProfilesTableFilterComposer,
          $$LocalProfilesTableOrderingComposer,
          $$LocalProfilesTableAnnotationComposer,
          $$LocalProfilesTableCreateCompanionBuilder,
          $$LocalProfilesTableUpdateCompanionBuilder,
          (
            LocalProfile,
            BaseReferences<_$AppDatabase, $LocalProfilesTable, LocalProfile>,
          ),
          LocalProfile,
          PrefetchHooks Function()
        > {
  $$LocalProfilesTableTableManager(_$AppDatabase db, $LocalProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> emailDisplay = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalProfilesCompanion(
                id: id,
                displayName: displayName,
                emailDisplay: emailDisplay,
                locale: locale,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String displayName,
                Value<String?> emailDisplay = const Value.absent(),
                Value<String> locale = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalProfilesCompanion.insert(
                id: id,
                displayName: displayName,
                emailDisplay: emailDisplay,
                locale: locale,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalProfilesTable,
      LocalProfile,
      $$LocalProfilesTableFilterComposer,
      $$LocalProfilesTableOrderingComposer,
      $$LocalProfilesTableAnnotationComposer,
      $$LocalProfilesTableCreateCompanionBuilder,
      $$LocalProfilesTableUpdateCompanionBuilder,
      (
        LocalProfile,
        BaseReferences<_$AppDatabase, $LocalProfilesTable, LocalProfile>,
      ),
      LocalProfile,
      PrefetchHooks Function()
    >;
typedef $$AppPreferencesTableCreateCompanionBuilder =
    AppPreferencesCompanion Function({
      required String ownerId,
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppPreferencesTableUpdateCompanionBuilder =
    AppPreferencesCompanion Function({
      Value<String> ownerId,
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppPreferencesTable,
          AppPreference,
          $$AppPreferencesTableFilterComposer,
          $$AppPreferencesTableOrderingComposer,
          $$AppPreferencesTableAnnotationComposer,
          $$AppPreferencesTableCreateCompanionBuilder,
          $$AppPreferencesTableUpdateCompanionBuilder,
          (
            AppPreference,
            BaseReferences<_$AppDatabase, $AppPreferencesTable, AppPreference>,
          ),
          AppPreference,
          PrefetchHooks Function()
        > {
  $$AppPreferencesTableTableManager(
    _$AppDatabase db,
    $AppPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppPreferencesCompanion(
                ownerId: ownerId,
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppPreferencesCompanion.insert(
                ownerId: ownerId,
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppPreferencesTable,
      AppPreference,
      $$AppPreferencesTableFilterComposer,
      $$AppPreferencesTableOrderingComposer,
      $$AppPreferencesTableAnnotationComposer,
      $$AppPreferencesTableCreateCompanionBuilder,
      $$AppPreferencesTableUpdateCompanionBuilder,
      (
        AppPreference,
        BaseReferences<_$AppDatabase, $AppPreferencesTable, AppPreference>,
      ),
      AppPreference,
      PrefetchHooks Function()
    >;
typedef $$SyncOutboxTableCreateCompanionBuilder = SyncOutboxCompanion Function({
  required String operationId,
  required String ownerId,
  required String aggregateType,
  required String aggregateId,
  required String mutationKind,
  Value<int?> baseVersion,
  required String payloadJson,
  Value<String?> dependencyOperationId,
  Value<String> state,
  Value<int> attemptCount,
  Value<DateTime?> nextAttemptAt,
  Value<String?> lastErrorCode,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$SyncOutboxTableUpdateCompanionBuilder = SyncOutboxCompanion Function({
  Value<String> operationId,
  Value<String> ownerId,
  Value<String> aggregateType,
  Value<String> aggregateId,
  Value<String> mutationKind,
  Value<int?> baseVersion,
  Value<String> payloadJson,
  Value<String?> dependencyOperationId,
  Value<String> state,
  Value<int> attemptCount,
  Value<DateTime?> nextAttemptAt,
  Value<String?> lastErrorCode,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$SyncOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aggregateType => $composableBuilder(
    column: $table.aggregateType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aggregateId => $composableBuilder(
    column: $table.aggregateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mutationKind => $composableBuilder(
    column: $table.mutationKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseVersion => $composableBuilder(
    column: $table.baseVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dependencyOperationId => $composableBuilder(
    column: $table.dependencyOperationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aggregateType => $composableBuilder(
    column: $table.aggregateType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aggregateId => $composableBuilder(
    column: $table.aggregateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mutationKind => $composableBuilder(
    column: $table.mutationKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseVersion => $composableBuilder(
    column: $table.baseVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dependencyOperationId => $composableBuilder(
    column: $table.dependencyOperationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get aggregateType => $composableBuilder(
    column: $table.aggregateType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aggregateId => $composableBuilder(
    column: $table.aggregateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mutationKind => $composableBuilder(
    column: $table.mutationKind,
    builder: (column) => column,
  );

  GeneratedColumn<int> get baseVersion => $composableBuilder(
    column: $table.baseVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dependencyOperationId => $composableBuilder(
    column: $table.dependencyOperationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncOutboxTable,
          SyncOutboxData,
          $$SyncOutboxTableFilterComposer,
          $$SyncOutboxTableOrderingComposer,
          $$SyncOutboxTableAnnotationComposer,
          $$SyncOutboxTableCreateCompanionBuilder,
          $$SyncOutboxTableUpdateCompanionBuilder,
          (
            SyncOutboxData,
            BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxData>,
          ),
          SyncOutboxData,
          PrefetchHooks Function()
        > {
  $$SyncOutboxTableTableManager(_$AppDatabase db, $SyncOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> operationId = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> aggregateType = const Value.absent(),
                Value<String> aggregateId = const Value.absent(),
                Value<String> mutationKind = const Value.absent(),
                Value<int?> baseVersion = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String?> dependencyOperationId = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion(
                operationId: operationId,
                ownerId: ownerId,
                aggregateType: aggregateType,
                aggregateId: aggregateId,
                mutationKind: mutationKind,
                baseVersion: baseVersion,
                payloadJson: payloadJson,
                dependencyOperationId: dependencyOperationId,
                state: state,
                attemptCount: attemptCount,
                nextAttemptAt: nextAttemptAt,
                lastErrorCode: lastErrorCode,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String operationId,
                required String ownerId,
                required String aggregateType,
                required String aggregateId,
                required String mutationKind,
                Value<int?> baseVersion = const Value.absent(),
                required String payloadJson,
                Value<String?> dependencyOperationId = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion.insert(
                operationId: operationId,
                ownerId: ownerId,
                aggregateType: aggregateType,
                aggregateId: aggregateId,
                mutationKind: mutationKind,
                baseVersion: baseVersion,
                payloadJson: payloadJson,
                dependencyOperationId: dependencyOperationId,
                state: state,
                attemptCount: attemptCount,
                nextAttemptAt: nextAttemptAt,
                lastErrorCode: lastErrorCode,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncOutboxTable,
      SyncOutboxData,
      $$SyncOutboxTableFilterComposer,
      $$SyncOutboxTableOrderingComposer,
      $$SyncOutboxTableAnnotationComposer,
      $$SyncOutboxTableCreateCompanionBuilder,
      $$SyncOutboxTableUpdateCompanionBuilder,
      (
        SyncOutboxData,
        BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxData>,
      ),
      SyncOutboxData,
      PrefetchHooks Function()
    >;
typedef $$SyncCursorsTableCreateCompanionBuilder =
    SyncCursorsCompanion Function({
      required String ownerId,
      required String stream,
      Value<int> lastChangeSeq,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SyncCursorsTableUpdateCompanionBuilder =
    SyncCursorsCompanion Function({
      Value<String> ownerId,
      Value<String> stream,
      Value<int> lastChangeSeq,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SyncCursorsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stream => $composableBuilder(
    column: $table.stream,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastChangeSeq => $composableBuilder(
    column: $table.lastChangeSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncCursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stream => $composableBuilder(
    column: $table.stream,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastChangeSeq => $composableBuilder(
    column: $table.lastChangeSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncCursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get stream =>
      $composableBuilder(column: $table.stream, builder: (column) => column);

  GeneratedColumn<int> get lastChangeSeq => $composableBuilder(
    column: $table.lastChangeSeq,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncCursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncCursorsTable,
          SyncCursor,
          $$SyncCursorsTableFilterComposer,
          $$SyncCursorsTableOrderingComposer,
          $$SyncCursorsTableAnnotationComposer,
          $$SyncCursorsTableCreateCompanionBuilder,
          $$SyncCursorsTableUpdateCompanionBuilder,
          (
            SyncCursor,
            BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>,
          ),
          SyncCursor,
          PrefetchHooks Function()
        > {
  $$SyncCursorsTableTableManager(_$AppDatabase db, $SyncCursorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<String> stream = const Value.absent(),
                Value<int> lastChangeSeq = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion(
                ownerId: ownerId,
                stream: stream,
                lastChangeSeq: lastChangeSeq,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                required String stream,
                Value<int> lastChangeSeq = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion.insert(
                ownerId: ownerId,
                stream: stream,
                lastChangeSeq: lastChangeSeq,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncCursorsTable,
      SyncCursor,
      $$SyncCursorsTableFilterComposer,
      $$SyncCursorsTableOrderingComposer,
      $$SyncCursorsTableAnnotationComposer,
      $$SyncCursorsTableCreateCompanionBuilder,
      $$SyncCursorsTableUpdateCompanionBuilder,
      (
        SyncCursor,
        BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>,
      ),
      SyncCursor,
      PrefetchHooks Function()
    >;
typedef $$SyncConflictsTableCreateCompanionBuilder =
    SyncConflictsCompanion Function({
      required String conflictId,
      required String ownerId,
      required String aggregateType,
      required String aggregateId,
      required String localJson,
      required String remoteJson,
      required DateTime detectedAt,
      Value<DateTime?> resolvedAt,
      Value<int> rowid,
    });
typedef $$SyncConflictsTableUpdateCompanionBuilder =
    SyncConflictsCompanion Function({
      Value<String> conflictId,
      Value<String> ownerId,
      Value<String> aggregateType,
      Value<String> aggregateId,
      Value<String> localJson,
      Value<String> remoteJson,
      Value<DateTime> detectedAt,
      Value<DateTime?> resolvedAt,
      Value<int> rowid,
    });

class $$SyncConflictsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get conflictId => $composableBuilder(
    column: $table.conflictId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aggregateType => $composableBuilder(
    column: $table.aggregateType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aggregateId => $composableBuilder(
    column: $table.aggregateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localJson => $composableBuilder(
    column: $table.localJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteJson => $composableBuilder(
    column: $table.remoteJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncConflictsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get conflictId => $composableBuilder(
    column: $table.conflictId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aggregateType => $composableBuilder(
    column: $table.aggregateType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aggregateId => $composableBuilder(
    column: $table.aggregateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localJson => $composableBuilder(
    column: $table.localJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteJson => $composableBuilder(
    column: $table.remoteJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncConflictsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get conflictId => $composableBuilder(
    column: $table.conflictId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get aggregateType => $composableBuilder(
    column: $table.aggregateType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aggregateId => $composableBuilder(
    column: $table.aggregateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localJson =>
      $composableBuilder(column: $table.localJson, builder: (column) => column);

  GeneratedColumn<String> get remoteJson => $composableBuilder(
    column: $table.remoteJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );
}

class $$SyncConflictsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncConflictsTable,
          SyncConflict,
          $$SyncConflictsTableFilterComposer,
          $$SyncConflictsTableOrderingComposer,
          $$SyncConflictsTableAnnotationComposer,
          $$SyncConflictsTableCreateCompanionBuilder,
          $$SyncConflictsTableUpdateCompanionBuilder,
          (
            SyncConflict,
            BaseReferences<_$AppDatabase, $SyncConflictsTable, SyncConflict>,
          ),
          SyncConflict,
          PrefetchHooks Function()
        > {
  $$SyncConflictsTableTableManager(_$AppDatabase db, $SyncConflictsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncConflictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncConflictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncConflictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> conflictId = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> aggregateType = const Value.absent(),
                Value<String> aggregateId = const Value.absent(),
                Value<String> localJson = const Value.absent(),
                Value<String> remoteJson = const Value.absent(),
                Value<DateTime> detectedAt = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion(
                conflictId: conflictId,
                ownerId: ownerId,
                aggregateType: aggregateType,
                aggregateId: aggregateId,
                localJson: localJson,
                remoteJson: remoteJson,
                detectedAt: detectedAt,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String conflictId,
                required String ownerId,
                required String aggregateType,
                required String aggregateId,
                required String localJson,
                required String remoteJson,
                required DateTime detectedAt,
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion.insert(
                conflictId: conflictId,
                ownerId: ownerId,
                aggregateType: aggregateType,
                aggregateId: aggregateId,
                localJson: localJson,
                remoteJson: remoteJson,
                detectedAt: detectedAt,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncConflictsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncConflictsTable,
      SyncConflict,
      $$SyncConflictsTableFilterComposer,
      $$SyncConflictsTableOrderingComposer,
      $$SyncConflictsTableAnnotationComposer,
      $$SyncConflictsTableCreateCompanionBuilder,
      $$SyncConflictsTableUpdateCompanionBuilder,
      (
        SyncConflict,
        BaseReferences<_$AppDatabase, $SyncConflictsTable, SyncConflict>,
      ),
      SyncConflict,
      PrefetchHooks Function()
    >;
typedef $$FormDraftsTableCreateCompanionBuilder = FormDraftsCompanion Function({
  required String ownerId,
  required String draftKey,
  required String payloadJson,
  Value<int> schemaVersion,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$FormDraftsTableUpdateCompanionBuilder = FormDraftsCompanion Function({
  Value<String> ownerId,
  Value<String> draftKey,
  Value<String> payloadJson,
  Value<int> schemaVersion,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$FormDraftsTableFilterComposer
    extends Composer<_$AppDatabase, $FormDraftsTable> {
  $$FormDraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get draftKey => $composableBuilder(
    column: $table.draftKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FormDraftsTableOrderingComposer
    extends Composer<_$AppDatabase, $FormDraftsTable> {
  $$FormDraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get draftKey => $composableBuilder(
    column: $table.draftKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FormDraftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FormDraftsTable> {
  $$FormDraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get draftKey =>
      $composableBuilder(column: $table.draftKey, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FormDraftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FormDraftsTable,
          FormDraft,
          $$FormDraftsTableFilterComposer,
          $$FormDraftsTableOrderingComposer,
          $$FormDraftsTableAnnotationComposer,
          $$FormDraftsTableCreateCompanionBuilder,
          $$FormDraftsTableUpdateCompanionBuilder,
          (
            FormDraft,
            BaseReferences<_$AppDatabase, $FormDraftsTable, FormDraft>,
          ),
          FormDraft,
          PrefetchHooks Function()
        > {
  $$FormDraftsTableTableManager(_$AppDatabase db, $FormDraftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FormDraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FormDraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FormDraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<String> draftKey = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FormDraftsCompanion(
                ownerId: ownerId,
                draftKey: draftKey,
                payloadJson: payloadJson,
                schemaVersion: schemaVersion,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                required String draftKey,
                required String payloadJson,
                Value<int> schemaVersion = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FormDraftsCompanion.insert(
                ownerId: ownerId,
                draftKey: draftKey,
                payloadJson: payloadJson,
                schemaVersion: schemaVersion,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FormDraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FormDraftsTable,
      FormDraft,
      $$FormDraftsTableFilterComposer,
      $$FormDraftsTableOrderingComposer,
      $$FormDraftsTableAnnotationComposer,
      $$FormDraftsTableCreateCompanionBuilder,
      $$FormDraftsTableUpdateCompanionBuilder,
      (FormDraft, BaseReferences<_$AppDatabase, $FormDraftsTable, FormDraft>),
      FormDraft,
      PrefetchHooks Function()
    >;
typedef $$ParcelsTableCreateCompanionBuilder = ParcelsCompanion Function({
  required String id,
  required String ownerId,
  required String name,
  Value<String?> locality,
  Value<String?> polygonJson,
  Value<double?> areaSquareMeters,
  Value<bool> isActive,
  Value<bool> isArchived,
  Value<int> version,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$ParcelsTableUpdateCompanionBuilder = ParcelsCompanion Function({
  Value<String> id,
  Value<String> ownerId,
  Value<String> name,
  Value<String?> locality,
  Value<String?> polygonJson,
  Value<double?> areaSquareMeters,
  Value<bool> isActive,
  Value<bool> isArchived,
  Value<int> version,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

final class $$ParcelsTableReferences
    extends BaseReferences<_$AppDatabase, $ParcelsTable, Parcel> {
  $$ParcelsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SectorsTable, List<Sector>> _sectorsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sectors,
    aliasName: 'parcels__id__sectors__parcel_id',
  );

  $$SectorsTableProcessedTableManager get sectorsRefs {
    final manager = $$SectorsTableTableManager(
      $_db,
      $_db.sectors,
    ).filter((f) => f.parcelId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sectorsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ParcelsTableFilterComposer
    extends Composer<_$AppDatabase, $ParcelsTable> {
  $$ParcelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locality => $composableBuilder(
    column: $table.locality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get polygonJson => $composableBuilder(
    column: $table.polygonJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get areaSquareMeters => $composableBuilder(
    column: $table.areaSquareMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sectorsRefs(
    Expression<bool> Function($$SectorsTableFilterComposer f) f,
  ) {
    final $$SectorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sectors,
      getReferencedColumn: (t) => t.parcelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectorsTableFilterComposer(
            $db: $db,
            $table: $db.sectors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ParcelsTableOrderingComposer
    extends Composer<_$AppDatabase, $ParcelsTable> {
  $$ParcelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locality => $composableBuilder(
    column: $table.locality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get polygonJson => $composableBuilder(
    column: $table.polygonJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get areaSquareMeters => $composableBuilder(
    column: $table.areaSquareMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ParcelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ParcelsTable> {
  $$ParcelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get locality =>
      $composableBuilder(column: $table.locality, builder: (column) => column);

  GeneratedColumn<String> get polygonJson => $composableBuilder(
    column: $table.polygonJson,
    builder: (column) => column,
  );

  GeneratedColumn<double> get areaSquareMeters => $composableBuilder(
    column: $table.areaSquareMeters,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> sectorsRefs<T extends Object>(
    Expression<T> Function($$SectorsTableAnnotationComposer a) f,
  ) {
    final $$SectorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sectors,
      getReferencedColumn: (t) => t.parcelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectorsTableAnnotationComposer(
            $db: $db,
            $table: $db.sectors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ParcelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ParcelsTable,
          Parcel,
          $$ParcelsTableFilterComposer,
          $$ParcelsTableOrderingComposer,
          $$ParcelsTableAnnotationComposer,
          $$ParcelsTableCreateCompanionBuilder,
          $$ParcelsTableUpdateCompanionBuilder,
          (Parcel, $$ParcelsTableReferences),
          Parcel,
          PrefetchHooks Function({bool sectorsRefs})
        > {
  $$ParcelsTableTableManager(_$AppDatabase db, $ParcelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ParcelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ParcelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ParcelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> locality = const Value.absent(),
                Value<String?> polygonJson = const Value.absent(),
                Value<double?> areaSquareMeters = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ParcelsCompanion(
                id: id,
                ownerId: ownerId,
                name: name,
                locality: locality,
                polygonJson: polygonJson,
                areaSquareMeters: areaSquareMeters,
                isActive: isActive,
                isArchived: isArchived,
                version: version,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String name,
                Value<String?> locality = const Value.absent(),
                Value<String?> polygonJson = const Value.absent(),
                Value<double?> areaSquareMeters = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> version = const Value.absent(),
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ParcelsCompanion.insert(
                id: id,
                ownerId: ownerId,
                name: name,
                locality: locality,
                polygonJson: polygonJson,
                areaSquareMeters: areaSquareMeters,
                isActive: isActive,
                isArchived: isArchived,
                version: version,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ParcelsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sectorsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (sectorsRefs) db.sectors],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sectorsRefs)
                    await $_getPrefetchedData<Parcel, $ParcelsTable, Sector>(
                      currentTable: table,
                      referencedTable: $$ParcelsTableReferences
                          ._sectorsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ParcelsTableReferences(db, table, p0).sectorsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.parcelId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ParcelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ParcelsTable,
      Parcel,
      $$ParcelsTableFilterComposer,
      $$ParcelsTableOrderingComposer,
      $$ParcelsTableAnnotationComposer,
      $$ParcelsTableCreateCompanionBuilder,
      $$ParcelsTableUpdateCompanionBuilder,
      (Parcel, $$ParcelsTableReferences),
      Parcel,
      PrefetchHooks Function({bool sectorsRefs})
    >;
typedef $$SectorsTableCreateCompanionBuilder = SectorsCompanion Function({
  required String id,
  required String ownerId,
  required String parcelId,
  required int number,
  required String name,
  Value<String> kind,
  required String polygonJson,
  required double areaSquareMeters,
  Value<int> version,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$SectorsTableUpdateCompanionBuilder = SectorsCompanion Function({
  Value<String> id,
  Value<String> ownerId,
  Value<String> parcelId,
  Value<int> number,
  Value<String> name,
  Value<String> kind,
  Value<String> polygonJson,
  Value<double> areaSquareMeters,
  Value<int> version,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

final class $$SectorsTableReferences
    extends BaseReferences<_$AppDatabase, $SectorsTable, Sector> {
  $$SectorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ParcelsTable _parcelIdTable(_$AppDatabase db) =>
      db.parcels.createAlias('sectors__parcel_id__parcels__id');

  $$ParcelsTableProcessedTableManager get parcelId {
    final $_column = $_itemColumn<String>('parcel_id')!;

    final manager = $$ParcelsTableTableManager(
      $_db,
      $_db.parcels,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parcelIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CropSeasonsTable, List<CropSeason>>
  _cropSeasonsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cropSeasons,
    aliasName: 'sectors__id__crop_seasons__sector_id',
  );

  $$CropSeasonsTableProcessedTableManager get cropSeasonsRefs {
    final manager = $$CropSeasonsTableTableManager(
      $_db,
      $_db.cropSeasons,
    ).filter((f) => f.sectorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cropSeasonsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LaborsTable, List<Labor>> _laborsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.labors,
    aliasName: 'sectors__id__labors__sector_id',
  );

  $$LaborsTableProcessedTableManager get laborsRefs {
    final manager = $$LaborsTableTableManager(
      $_db,
      $_db.labors,
    ).filter((f) => f.sectorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_laborsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SoilMeasurementsTable, List<SoilMeasurement>>
  _soilMeasurementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.soilMeasurements,
    aliasName: 'sectors__id__soil_measurements__sector_id',
  );

  $$SoilMeasurementsTableProcessedTableManager get soilMeasurementsRefs {
    final manager = $$SoilMeasurementsTableTableManager(
      $_db,
      $_db.soilMeasurements,
    ).filter((f) => f.sectorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _soilMeasurementsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$IrrigationRecordsTable, List<IrrigationRecord>>
  _irrigationRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.irrigationRecords,
        aliasName: 'sectors__id__irrigation_records__sector_id',
      );

  $$IrrigationRecordsTableProcessedTableManager get irrigationRecordsRefs {
    final manager = $$IrrigationRecordsTableTableManager(
      $_db,
      $_db.irrigationRecords,
    ).filter((f) => f.sectorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _irrigationRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ProductionRecordsTable, List<ProductionRecord>>
  _productionRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.productionRecords,
        aliasName: 'sectors__id__production_records__sector_id',
      );

  $$ProductionRecordsTableProcessedTableManager get productionRecordsRefs {
    final manager = $$ProductionRecordsTableTableManager(
      $_db,
      $_db.productionRecords,
    ).filter((f) => f.sectorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _productionRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SectorsTableFilterComposer
    extends Composer<_$AppDatabase, $SectorsTable> {
  $$SectorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get polygonJson => $composableBuilder(
    column: $table.polygonJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get areaSquareMeters => $composableBuilder(
    column: $table.areaSquareMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ParcelsTableFilterComposer get parcelId {
    final $$ParcelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parcelId,
      referencedTable: $db.parcels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParcelsTableFilterComposer(
            $db: $db,
            $table: $db.parcels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> cropSeasonsRefs(
    Expression<bool> Function($$CropSeasonsTableFilterComposer f) f,
  ) {
    final $$CropSeasonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cropSeasons,
      getReferencedColumn: (t) => t.sectorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CropSeasonsTableFilterComposer(
            $db: $db,
            $table: $db.cropSeasons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> laborsRefs(
    Expression<bool> Function($$LaborsTableFilterComposer f) f,
  ) {
    final $$LaborsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.labors,
      getReferencedColumn: (t) => t.sectorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LaborsTableFilterComposer(
            $db: $db,
            $table: $db.labors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> soilMeasurementsRefs(
    Expression<bool> Function($$SoilMeasurementsTableFilterComposer f) f,
  ) {
    final $$SoilMeasurementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.soilMeasurements,
      getReferencedColumn: (t) => t.sectorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SoilMeasurementsTableFilterComposer(
            $db: $db,
            $table: $db.soilMeasurements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> irrigationRecordsRefs(
    Expression<bool> Function($$IrrigationRecordsTableFilterComposer f) f,
  ) {
    final $$IrrigationRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.irrigationRecords,
      getReferencedColumn: (t) => t.sectorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IrrigationRecordsTableFilterComposer(
            $db: $db,
            $table: $db.irrigationRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> productionRecordsRefs(
    Expression<bool> Function($$ProductionRecordsTableFilterComposer f) f,
  ) {
    final $$ProductionRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.productionRecords,
      getReferencedColumn: (t) => t.sectorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductionRecordsTableFilterComposer(
            $db: $db,
            $table: $db.productionRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SectorsTableOrderingComposer
    extends Composer<_$AppDatabase, $SectorsTable> {
  $$SectorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get polygonJson => $composableBuilder(
    column: $table.polygonJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get areaSquareMeters => $composableBuilder(
    column: $table.areaSquareMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ParcelsTableOrderingComposer get parcelId {
    final $$ParcelsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parcelId,
      referencedTable: $db.parcels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParcelsTableOrderingComposer(
            $db: $db,
            $table: $db.parcels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SectorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SectorsTable> {
  $$SectorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get polygonJson => $composableBuilder(
    column: $table.polygonJson,
    builder: (column) => column,
  );

  GeneratedColumn<double> get areaSquareMeters => $composableBuilder(
    column: $table.areaSquareMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$ParcelsTableAnnotationComposer get parcelId {
    final $$ParcelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parcelId,
      referencedTable: $db.parcels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ParcelsTableAnnotationComposer(
            $db: $db,
            $table: $db.parcels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> cropSeasonsRefs<T extends Object>(
    Expression<T> Function($$CropSeasonsTableAnnotationComposer a) f,
  ) {
    final $$CropSeasonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cropSeasons,
      getReferencedColumn: (t) => t.sectorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CropSeasonsTableAnnotationComposer(
            $db: $db,
            $table: $db.cropSeasons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> laborsRefs<T extends Object>(
    Expression<T> Function($$LaborsTableAnnotationComposer a) f,
  ) {
    final $$LaborsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.labors,
      getReferencedColumn: (t) => t.sectorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LaborsTableAnnotationComposer(
            $db: $db,
            $table: $db.labors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> soilMeasurementsRefs<T extends Object>(
    Expression<T> Function($$SoilMeasurementsTableAnnotationComposer a) f,
  ) {
    final $$SoilMeasurementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.soilMeasurements,
      getReferencedColumn: (t) => t.sectorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SoilMeasurementsTableAnnotationComposer(
            $db: $db,
            $table: $db.soilMeasurements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> irrigationRecordsRefs<T extends Object>(
    Expression<T> Function($$IrrigationRecordsTableAnnotationComposer a) f,
  ) {
    final $$IrrigationRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.irrigationRecords,
          getReferencedColumn: (t) => t.sectorId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$IrrigationRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.irrigationRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> productionRecordsRefs<T extends Object>(
    Expression<T> Function($$ProductionRecordsTableAnnotationComposer a) f,
  ) {
    final $$ProductionRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.productionRecords,
          getReferencedColumn: (t) => t.sectorId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProductionRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.productionRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SectorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SectorsTable,
          Sector,
          $$SectorsTableFilterComposer,
          $$SectorsTableOrderingComposer,
          $$SectorsTableAnnotationComposer,
          $$SectorsTableCreateCompanionBuilder,
          $$SectorsTableUpdateCompanionBuilder,
          (Sector, $$SectorsTableReferences),
          Sector,
          PrefetchHooks Function({
            bool parcelId,
            bool cropSeasonsRefs,
            bool laborsRefs,
            bool soilMeasurementsRefs,
            bool irrigationRecordsRefs,
            bool productionRecordsRefs,
          })
        > {
  $$SectorsTableTableManager(_$AppDatabase db, $SectorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SectorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SectorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SectorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> parcelId = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> polygonJson = const Value.absent(),
                Value<double> areaSquareMeters = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SectorsCompanion(
                id: id,
                ownerId: ownerId,
                parcelId: parcelId,
                number: number,
                name: name,
                kind: kind,
                polygonJson: polygonJson,
                areaSquareMeters: areaSquareMeters,
                version: version,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String parcelId,
                required int number,
                required String name,
                Value<String> kind = const Value.absent(),
                required String polygonJson,
                required double areaSquareMeters,
                Value<int> version = const Value.absent(),
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SectorsCompanion.insert(
                id: id,
                ownerId: ownerId,
                parcelId: parcelId,
                number: number,
                name: name,
                kind: kind,
                polygonJson: polygonJson,
                areaSquareMeters: areaSquareMeters,
                version: version,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SectorsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                parcelId = false,
                cropSeasonsRefs = false,
                laborsRefs = false,
                soilMeasurementsRefs = false,
                irrigationRecordsRefs = false,
                productionRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (cropSeasonsRefs) db.cropSeasons,
                    if (laborsRefs) db.labors,
                    if (soilMeasurementsRefs) db.soilMeasurements,
                    if (irrigationRecordsRefs) db.irrigationRecords,
                    if (productionRecordsRefs) db.productionRecords,
                  ],
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
                        if (parcelId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.parcelId,
                            referencedTable: $$SectorsTableReferences
                                ._parcelIdTable(db),
                            referencedColumn: $$SectorsTableReferences
                                ._parcelIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (cropSeasonsRefs)
                        await $_getPrefetchedData<
                          Sector,
                          $SectorsTable,
                          CropSeason
                        >(
                          currentTable: table,
                          referencedTable: $$SectorsTableReferences
                              ._cropSeasonsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SectorsTableReferences(
                                db,
                                table,
                                p0,
                              ).cropSeasonsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sectorId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (laborsRefs)
                        await $_getPrefetchedData<Sector, $SectorsTable, Labor>(
                          currentTable: table,
                          referencedTable: $$SectorsTableReferences
                              ._laborsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SectorsTableReferences(
                                db,
                                table,
                                p0,
                              ).laborsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sectorId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (soilMeasurementsRefs)
                        await $_getPrefetchedData<
                          Sector,
                          $SectorsTable,
                          SoilMeasurement
                        >(
                          currentTable: table,
                          referencedTable: $$SectorsTableReferences
                              ._soilMeasurementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SectorsTableReferences(
                                db,
                                table,
                                p0,
                              ).soilMeasurementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sectorId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (irrigationRecordsRefs)
                        await $_getPrefetchedData<
                          Sector,
                          $SectorsTable,
                          IrrigationRecord
                        >(
                          currentTable: table,
                          referencedTable: $$SectorsTableReferences
                              ._irrigationRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SectorsTableReferences(
                                db,
                                table,
                                p0,
                              ).irrigationRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sectorId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (productionRecordsRefs)
                        await $_getPrefetchedData<
                          Sector,
                          $SectorsTable,
                          ProductionRecord
                        >(
                          currentTable: table,
                          referencedTable: $$SectorsTableReferences
                              ._productionRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SectorsTableReferences(
                                db,
                                table,
                                p0,
                              ).productionRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sectorId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SectorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SectorsTable,
      Sector,
      $$SectorsTableFilterComposer,
      $$SectorsTableOrderingComposer,
      $$SectorsTableAnnotationComposer,
      $$SectorsTableCreateCompanionBuilder,
      $$SectorsTableUpdateCompanionBuilder,
      (Sector, $$SectorsTableReferences),
      Sector,
      PrefetchHooks Function({
        bool parcelId,
        bool cropSeasonsRefs,
        bool laborsRefs,
        bool soilMeasurementsRefs,
        bool irrigationRecordsRefs,
        bool productionRecordsRefs,
      })
    >;
typedef $$OfficialCropsTableCreateCompanionBuilder =
    OfficialCropsCompanion Function({
      required String id,
      required String commonName,
      Value<String?> scientificName,
      required String category,
      required String colorToken,
      required String iconAsset,
      Value<int> catalogVersion,
      Value<int> rowid,
    });
typedef $$OfficialCropsTableUpdateCompanionBuilder =
    OfficialCropsCompanion Function({
      Value<String> id,
      Value<String> commonName,
      Value<String?> scientificName,
      Value<String> category,
      Value<String> colorToken,
      Value<String> iconAsset,
      Value<int> catalogVersion,
      Value<int> rowid,
    });

class $$OfficialCropsTableFilterComposer
    extends Composer<_$AppDatabase, $OfficialCropsTable> {
  $$OfficialCropsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commonName => $composableBuilder(
    column: $table.commonName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scientificName => $composableBuilder(
    column: $table.scientificName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorToken => $composableBuilder(
    column: $table.colorToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconAsset => $composableBuilder(
    column: $table.iconAsset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get catalogVersion => $composableBuilder(
    column: $table.catalogVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OfficialCropsTableOrderingComposer
    extends Composer<_$AppDatabase, $OfficialCropsTable> {
  $$OfficialCropsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commonName => $composableBuilder(
    column: $table.commonName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scientificName => $composableBuilder(
    column: $table.scientificName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorToken => $composableBuilder(
    column: $table.colorToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconAsset => $composableBuilder(
    column: $table.iconAsset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get catalogVersion => $composableBuilder(
    column: $table.catalogVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OfficialCropsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OfficialCropsTable> {
  $$OfficialCropsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get commonName => $composableBuilder(
    column: $table.commonName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scientificName => $composableBuilder(
    column: $table.scientificName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get colorToken => $composableBuilder(
    column: $table.colorToken,
    builder: (column) => column,
  );

  GeneratedColumn<String> get iconAsset =>
      $composableBuilder(column: $table.iconAsset, builder: (column) => column);

  GeneratedColumn<int> get catalogVersion => $composableBuilder(
    column: $table.catalogVersion,
    builder: (column) => column,
  );
}

class $$OfficialCropsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OfficialCropsTable,
          OfficialCrop,
          $$OfficialCropsTableFilterComposer,
          $$OfficialCropsTableOrderingComposer,
          $$OfficialCropsTableAnnotationComposer,
          $$OfficialCropsTableCreateCompanionBuilder,
          $$OfficialCropsTableUpdateCompanionBuilder,
          (
            OfficialCrop,
            BaseReferences<_$AppDatabase, $OfficialCropsTable, OfficialCrop>,
          ),
          OfficialCrop,
          PrefetchHooks Function()
        > {
  $$OfficialCropsTableTableManager(_$AppDatabase db, $OfficialCropsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfficialCropsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OfficialCropsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OfficialCropsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> commonName = const Value.absent(),
                Value<String?> scientificName = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> colorToken = const Value.absent(),
                Value<String> iconAsset = const Value.absent(),
                Value<int> catalogVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OfficialCropsCompanion(
                id: id,
                commonName: commonName,
                scientificName: scientificName,
                category: category,
                colorToken: colorToken,
                iconAsset: iconAsset,
                catalogVersion: catalogVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String commonName,
                Value<String?> scientificName = const Value.absent(),
                required String category,
                required String colorToken,
                required String iconAsset,
                Value<int> catalogVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OfficialCropsCompanion.insert(
                id: id,
                commonName: commonName,
                scientificName: scientificName,
                category: category,
                colorToken: colorToken,
                iconAsset: iconAsset,
                catalogVersion: catalogVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OfficialCropsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OfficialCropsTable,
      OfficialCrop,
      $$OfficialCropsTableFilterComposer,
      $$OfficialCropsTableOrderingComposer,
      $$OfficialCropsTableAnnotationComposer,
      $$OfficialCropsTableCreateCompanionBuilder,
      $$OfficialCropsTableUpdateCompanionBuilder,
      (
        OfficialCrop,
        BaseReferences<_$AppDatabase, $OfficialCropsTable, OfficialCrop>,
      ),
      OfficialCrop,
      PrefetchHooks Function()
    >;
typedef $$CustomCropsTableCreateCompanionBuilder =
    CustomCropsCompanion Function({
      required String id,
      required String ownerId,
      required String name,
      Value<String?> notes,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CustomCropsTableUpdateCompanionBuilder =
    CustomCropsCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> name,
      Value<String?> notes,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CustomCropsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomCropsTable> {
  $$CustomCropsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomCropsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomCropsTable> {
  $$CustomCropsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomCropsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomCropsTable> {
  $$CustomCropsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CustomCropsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomCropsTable,
          CustomCrop,
          $$CustomCropsTableFilterComposer,
          $$CustomCropsTableOrderingComposer,
          $$CustomCropsTableAnnotationComposer,
          $$CustomCropsTableCreateCompanionBuilder,
          $$CustomCropsTableUpdateCompanionBuilder,
          (
            CustomCrop,
            BaseReferences<_$AppDatabase, $CustomCropsTable, CustomCrop>,
          ),
          CustomCrop,
          PrefetchHooks Function()
        > {
  $$CustomCropsTableTableManager(_$AppDatabase db, $CustomCropsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomCropsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomCropsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomCropsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomCropsCompanion(
                id: id,
                ownerId: ownerId,
                name: name,
                notes: notes,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String name,
                Value<String?> notes = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CustomCropsCompanion.insert(
                id: id,
                ownerId: ownerId,
                name: name,
                notes: notes,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomCropsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomCropsTable,
      CustomCrop,
      $$CustomCropsTableFilterComposer,
      $$CustomCropsTableOrderingComposer,
      $$CustomCropsTableAnnotationComposer,
      $$CustomCropsTableCreateCompanionBuilder,
      $$CustomCropsTableUpdateCompanionBuilder,
      (
        CustomCrop,
        BaseReferences<_$AppDatabase, $CustomCropsTable, CustomCrop>,
      ),
      CustomCrop,
      PrefetchHooks Function()
    >;
typedef $$CropSeasonsTableCreateCompanionBuilder =
    CropSeasonsCompanion Function({
      required String id,
      required String ownerId,
      required String sectorId,
      required String cropId,
      Value<bool> isCustomCrop,
      Value<String> status,
      required DateTime startsOn,
      Value<DateTime?> endsOn,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CropSeasonsTableUpdateCompanionBuilder =
    CropSeasonsCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> sectorId,
      Value<String> cropId,
      Value<bool> isCustomCrop,
      Value<String> status,
      Value<DateTime> startsOn,
      Value<DateTime?> endsOn,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$CropSeasonsTableReferences
    extends BaseReferences<_$AppDatabase, $CropSeasonsTable, CropSeason> {
  $$CropSeasonsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SectorsTable _sectorIdTable(_$AppDatabase db) =>
      db.sectors.createAlias('crop_seasons__sector_id__sectors__id');

  $$SectorsTableProcessedTableManager get sectorId {
    final $_column = $_itemColumn<String>('sector_id')!;

    final manager = $$SectorsTableTableManager(
      $_db,
      $_db.sectors,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sectorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CropSeasonsTableFilterComposer
    extends Composer<_$AppDatabase, $CropSeasonsTable> {
  $$CropSeasonsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cropId => $composableBuilder(
    column: $table.cropId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustomCrop => $composableBuilder(
    column: $table.isCustomCrop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startsOn => $composableBuilder(
    column: $table.startsOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endsOn => $composableBuilder(
    column: $table.endsOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SectorsTableFilterComposer get sectorId {
    final $$SectorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectorId,
      referencedTable: $db.sectors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectorsTableFilterComposer(
            $db: $db,
            $table: $db.sectors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CropSeasonsTableOrderingComposer
    extends Composer<_$AppDatabase, $CropSeasonsTable> {
  $$CropSeasonsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cropId => $composableBuilder(
    column: $table.cropId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustomCrop => $composableBuilder(
    column: $table.isCustomCrop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startsOn => $composableBuilder(
    column: $table.startsOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endsOn => $composableBuilder(
    column: $table.endsOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SectorsTableOrderingComposer get sectorId {
    final $$SectorsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectorId,
      referencedTable: $db.sectors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectorsTableOrderingComposer(
            $db: $db,
            $table: $db.sectors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CropSeasonsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CropSeasonsTable> {
  $$CropSeasonsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get cropId =>
      $composableBuilder(column: $table.cropId, builder: (column) => column);

  GeneratedColumn<bool> get isCustomCrop => $composableBuilder(
    column: $table.isCustomCrop,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startsOn =>
      $composableBuilder(column: $table.startsOn, builder: (column) => column);

  GeneratedColumn<DateTime> get endsOn =>
      $composableBuilder(column: $table.endsOn, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$SectorsTableAnnotationComposer get sectorId {
    final $$SectorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectorId,
      referencedTable: $db.sectors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectorsTableAnnotationComposer(
            $db: $db,
            $table: $db.sectors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CropSeasonsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CropSeasonsTable,
          CropSeason,
          $$CropSeasonsTableFilterComposer,
          $$CropSeasonsTableOrderingComposer,
          $$CropSeasonsTableAnnotationComposer,
          $$CropSeasonsTableCreateCompanionBuilder,
          $$CropSeasonsTableUpdateCompanionBuilder,
          (CropSeason, $$CropSeasonsTableReferences),
          CropSeason,
          PrefetchHooks Function({bool sectorId})
        > {
  $$CropSeasonsTableTableManager(_$AppDatabase db, $CropSeasonsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CropSeasonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CropSeasonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CropSeasonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> sectorId = const Value.absent(),
                Value<String> cropId = const Value.absent(),
                Value<bool> isCustomCrop = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> startsOn = const Value.absent(),
                Value<DateTime?> endsOn = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CropSeasonsCompanion(
                id: id,
                ownerId: ownerId,
                sectorId: sectorId,
                cropId: cropId,
                isCustomCrop: isCustomCrop,
                status: status,
                startsOn: startsOn,
                endsOn: endsOn,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String sectorId,
                required String cropId,
                Value<bool> isCustomCrop = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime startsOn,
                Value<DateTime?> endsOn = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CropSeasonsCompanion.insert(
                id: id,
                ownerId: ownerId,
                sectorId: sectorId,
                cropId: cropId,
                isCustomCrop: isCustomCrop,
                status: status,
                startsOn: startsOn,
                endsOn: endsOn,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CropSeasonsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sectorId = false}) {
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
                    if (sectorId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sectorId,
                        referencedTable: $$CropSeasonsTableReferences
                            ._sectorIdTable(db),
                        referencedColumn: $$CropSeasonsTableReferences
                            ._sectorIdTable(db)
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

typedef $$CropSeasonsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CropSeasonsTable,
      CropSeason,
      $$CropSeasonsTableFilterComposer,
      $$CropSeasonsTableOrderingComposer,
      $$CropSeasonsTableAnnotationComposer,
      $$CropSeasonsTableCreateCompanionBuilder,
      $$CropSeasonsTableUpdateCompanionBuilder,
      (CropSeason, $$CropSeasonsTableReferences),
      CropSeason,
      PrefetchHooks Function({bool sectorId})
    >;
typedef $$LaborsTableCreateCompanionBuilder = LaborsCompanion Function({
  required String id,
  required String ownerId,
  required String parcelId,
  required String sectorId,
  Value<String?> seasonId,
  required String type,
  Value<String?> customName,
  Value<String> detailsJson,
  Value<String?> notes,
  required DateTime occurredAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$LaborsTableUpdateCompanionBuilder = LaborsCompanion Function({
  Value<String> id,
  Value<String> ownerId,
  Value<String> parcelId,
  Value<String> sectorId,
  Value<String?> seasonId,
  Value<String> type,
  Value<String?> customName,
  Value<String> detailsJson,
  Value<String?> notes,
  Value<DateTime> occurredAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$LaborsTableReferences
    extends BaseReferences<_$AppDatabase, $LaborsTable, Labor> {
  $$LaborsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SectorsTable _sectorIdTable(_$AppDatabase db) =>
      db.sectors.createAlias('labors__sector_id__sectors__id');

  $$SectorsTableProcessedTableManager get sectorId {
    final $_column = $_itemColumn<String>('sector_id')!;

    final manager = $$SectorsTableTableManager(
      $_db,
      $_db.sectors,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sectorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LaborsTableFilterComposer
    extends Composer<_$AppDatabase, $LaborsTable> {
  $$LaborsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parcelId => $composableBuilder(
    column: $table.parcelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seasonId => $composableBuilder(
    column: $table.seasonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SectorsTableFilterComposer get sectorId {
    final $$SectorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectorId,
      referencedTable: $db.sectors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectorsTableFilterComposer(
            $db: $db,
            $table: $db.sectors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LaborsTableOrderingComposer
    extends Composer<_$AppDatabase, $LaborsTable> {
  $$LaborsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parcelId => $composableBuilder(
    column: $table.parcelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seasonId => $composableBuilder(
    column: $table.seasonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SectorsTableOrderingComposer get sectorId {
    final $$SectorsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectorId,
      referencedTable: $db.sectors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectorsTableOrderingComposer(
            $db: $db,
            $table: $db.sectors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LaborsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LaborsTable> {
  $$LaborsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get parcelId =>
      $composableBuilder(column: $table.parcelId, builder: (column) => column);

  GeneratedColumn<String> get seasonId =>
      $composableBuilder(column: $table.seasonId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$SectorsTableAnnotationComposer get sectorId {
    final $$SectorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectorId,
      referencedTable: $db.sectors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectorsTableAnnotationComposer(
            $db: $db,
            $table: $db.sectors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LaborsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LaborsTable,
          Labor,
          $$LaborsTableFilterComposer,
          $$LaborsTableOrderingComposer,
          $$LaborsTableAnnotationComposer,
          $$LaborsTableCreateCompanionBuilder,
          $$LaborsTableUpdateCompanionBuilder,
          (Labor, $$LaborsTableReferences),
          Labor,
          PrefetchHooks Function({bool sectorId})
        > {
  $$LaborsTableTableManager(_$AppDatabase db, $LaborsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LaborsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LaborsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LaborsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> parcelId = const Value.absent(),
                Value<String> sectorId = const Value.absent(),
                Value<String?> seasonId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> customName = const Value.absent(),
                Value<String> detailsJson = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LaborsCompanion(
                id: id,
                ownerId: ownerId,
                parcelId: parcelId,
                sectorId: sectorId,
                seasonId: seasonId,
                type: type,
                customName: customName,
                detailsJson: detailsJson,
                notes: notes,
                occurredAt: occurredAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String parcelId,
                required String sectorId,
                Value<String?> seasonId = const Value.absent(),
                required String type,
                Value<String?> customName = const Value.absent(),
                Value<String> detailsJson = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime occurredAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LaborsCompanion.insert(
                id: id,
                ownerId: ownerId,
                parcelId: parcelId,
                sectorId: sectorId,
                seasonId: seasonId,
                type: type,
                customName: customName,
                detailsJson: detailsJson,
                notes: notes,
                occurredAt: occurredAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$LaborsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({sectorId = false}) {
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
                    if (sectorId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sectorId,
                        referencedTable: $$LaborsTableReferences._sectorIdTable(
                          db,
                        ),
                        referencedColumn: $$LaborsTableReferences
                            ._sectorIdTable(db)
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

typedef $$LaborsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LaborsTable,
      Labor,
      $$LaborsTableFilterComposer,
      $$LaborsTableOrderingComposer,
      $$LaborsTableAnnotationComposer,
      $$LaborsTableCreateCompanionBuilder,
      $$LaborsTableUpdateCompanionBuilder,
      (Labor, $$LaborsTableReferences),
      Labor,
      PrefetchHooks Function({bool sectorId})
    >;
typedef $$SoilMeasurementsTableCreateCompanionBuilder =
    SoilMeasurementsCompanion Function({
      required String id,
      required String ownerId,
      required String sectorId,
      Value<double?> moisturePercent,
      Value<double?> ph,
      Value<double?> temperatureCelsius,
      Value<double?> conductivity,
      Value<double?> nitrogen,
      Value<double?> phosphorus,
      Value<double?> potassium,
      Value<String?> notes,
      required DateTime measuredAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SoilMeasurementsTableUpdateCompanionBuilder =
    SoilMeasurementsCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> sectorId,
      Value<double?> moisturePercent,
      Value<double?> ph,
      Value<double?> temperatureCelsius,
      Value<double?> conductivity,
      Value<double?> nitrogen,
      Value<double?> phosphorus,
      Value<double?> potassium,
      Value<String?> notes,
      Value<DateTime> measuredAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$SoilMeasurementsTableReferences
    extends
        BaseReferences<_$AppDatabase, $SoilMeasurementsTable, SoilMeasurement> {
  $$SoilMeasurementsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SectorsTable _sectorIdTable(_$AppDatabase db) =>
      db.sectors.createAlias('soil_measurements__sector_id__sectors__id');

  $$SectorsTableProcessedTableManager get sectorId {
    final $_column = $_itemColumn<String>('sector_id')!;

    final manager = $$SectorsTableTableManager(
      $_db,
      $_db.sectors,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sectorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SoilMeasurementsTableFilterComposer
    extends Composer<_$AppDatabase, $SoilMeasurementsTable> {
  $$SoilMeasurementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get moisturePercent => $composableBuilder(
    column: $table.moisturePercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ph => $composableBuilder(
    column: $table.ph,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperatureCelsius => $composableBuilder(
    column: $table.temperatureCelsius,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get conductivity => $composableBuilder(
    column: $table.conductivity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get nitrogen => $composableBuilder(
    column: $table.nitrogen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get phosphorus => $composableBuilder(
    column: $table.phosphorus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get potassium => $composableBuilder(
    column: $table.potassium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SectorsTableFilterComposer get sectorId {
    final $$SectorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectorId,
      referencedTable: $db.sectors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectorsTableFilterComposer(
            $db: $db,
            $table: $db.sectors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SoilMeasurementsTableOrderingComposer
    extends Composer<_$AppDatabase, $SoilMeasurementsTable> {
  $$SoilMeasurementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get moisturePercent => $composableBuilder(
    column: $table.moisturePercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ph => $composableBuilder(
    column: $table.ph,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperatureCelsius => $composableBuilder(
    column: $table.temperatureCelsius,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get conductivity => $composableBuilder(
    column: $table.conductivity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get nitrogen => $composableBuilder(
    column: $table.nitrogen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get phosphorus => $composableBuilder(
    column: $table.phosphorus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get potassium => $composableBuilder(
    column: $table.potassium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SectorsTableOrderingComposer get sectorId {
    final $$SectorsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectorId,
      referencedTable: $db.sectors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectorsTableOrderingComposer(
            $db: $db,
            $table: $db.sectors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SoilMeasurementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SoilMeasurementsTable> {
  $$SoilMeasurementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<double> get moisturePercent => $composableBuilder(
    column: $table.moisturePercent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ph =>
      $composableBuilder(column: $table.ph, builder: (column) => column);

  GeneratedColumn<double> get temperatureCelsius => $composableBuilder(
    column: $table.temperatureCelsius,
    builder: (column) => column,
  );

  GeneratedColumn<double> get conductivity => $composableBuilder(
    column: $table.conductivity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get nitrogen =>
      $composableBuilder(column: $table.nitrogen, builder: (column) => column);

  GeneratedColumn<double> get phosphorus => $composableBuilder(
    column: $table.phosphorus,
    builder: (column) => column,
  );

  GeneratedColumn<double> get potassium =>
      $composableBuilder(column: $table.potassium, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$SectorsTableAnnotationComposer get sectorId {
    final $$SectorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectorId,
      referencedTable: $db.sectors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectorsTableAnnotationComposer(
            $db: $db,
            $table: $db.sectors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SoilMeasurementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SoilMeasurementsTable,
          SoilMeasurement,
          $$SoilMeasurementsTableFilterComposer,
          $$SoilMeasurementsTableOrderingComposer,
          $$SoilMeasurementsTableAnnotationComposer,
          $$SoilMeasurementsTableCreateCompanionBuilder,
          $$SoilMeasurementsTableUpdateCompanionBuilder,
          (SoilMeasurement, $$SoilMeasurementsTableReferences),
          SoilMeasurement,
          PrefetchHooks Function({bool sectorId})
        > {
  $$SoilMeasurementsTableTableManager(
    _$AppDatabase db,
    $SoilMeasurementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SoilMeasurementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SoilMeasurementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SoilMeasurementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> sectorId = const Value.absent(),
                Value<double?> moisturePercent = const Value.absent(),
                Value<double?> ph = const Value.absent(),
                Value<double?> temperatureCelsius = const Value.absent(),
                Value<double?> conductivity = const Value.absent(),
                Value<double?> nitrogen = const Value.absent(),
                Value<double?> phosphorus = const Value.absent(),
                Value<double?> potassium = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> measuredAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SoilMeasurementsCompanion(
                id: id,
                ownerId: ownerId,
                sectorId: sectorId,
                moisturePercent: moisturePercent,
                ph: ph,
                temperatureCelsius: temperatureCelsius,
                conductivity: conductivity,
                nitrogen: nitrogen,
                phosphorus: phosphorus,
                potassium: potassium,
                notes: notes,
                measuredAt: measuredAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String sectorId,
                Value<double?> moisturePercent = const Value.absent(),
                Value<double?> ph = const Value.absent(),
                Value<double?> temperatureCelsius = const Value.absent(),
                Value<double?> conductivity = const Value.absent(),
                Value<double?> nitrogen = const Value.absent(),
                Value<double?> phosphorus = const Value.absent(),
                Value<double?> potassium = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime measuredAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SoilMeasurementsCompanion.insert(
                id: id,
                ownerId: ownerId,
                sectorId: sectorId,
                moisturePercent: moisturePercent,
                ph: ph,
                temperatureCelsius: temperatureCelsius,
                conductivity: conductivity,
                nitrogen: nitrogen,
                phosphorus: phosphorus,
                potassium: potassium,
                notes: notes,
                measuredAt: measuredAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SoilMeasurementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sectorId = false}) {
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
                    if (sectorId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sectorId,
                        referencedTable: $$SoilMeasurementsTableReferences
                            ._sectorIdTable(db),
                        referencedColumn: $$SoilMeasurementsTableReferences
                            ._sectorIdTable(db)
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

typedef $$SoilMeasurementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SoilMeasurementsTable,
      SoilMeasurement,
      $$SoilMeasurementsTableFilterComposer,
      $$SoilMeasurementsTableOrderingComposer,
      $$SoilMeasurementsTableAnnotationComposer,
      $$SoilMeasurementsTableCreateCompanionBuilder,
      $$SoilMeasurementsTableUpdateCompanionBuilder,
      (SoilMeasurement, $$SoilMeasurementsTableReferences),
      SoilMeasurement,
      PrefetchHooks Function({bool sectorId})
    >;
typedef $$IrrigationRecordsTableCreateCompanionBuilder =
    IrrigationRecordsCompanion Function({
      required String id,
      required String ownerId,
      required String sectorId,
      required String irrigationType,
      required String soilTypeCode,
      Value<double?> flowLitersPerHour,
      Value<int?> durationMinutes,
      Value<double?> estimatedLiters,
      required DateTime irrigatedAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$IrrigationRecordsTableUpdateCompanionBuilder =
    IrrigationRecordsCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> sectorId,
      Value<String> irrigationType,
      Value<String> soilTypeCode,
      Value<double?> flowLitersPerHour,
      Value<int?> durationMinutes,
      Value<double?> estimatedLiters,
      Value<DateTime> irrigatedAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$IrrigationRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $IrrigationRecordsTable,
          IrrigationRecord
        > {
  $$IrrigationRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SectorsTable _sectorIdTable(_$AppDatabase db) =>
      db.sectors.createAlias('irrigation_records__sector_id__sectors__id');

  $$SectorsTableProcessedTableManager get sectorId {
    final $_column = $_itemColumn<String>('sector_id')!;

    final manager = $$SectorsTableTableManager(
      $_db,
      $_db.sectors,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sectorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$IrrigationRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $IrrigationRecordsTable> {
  $$IrrigationRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get irrigationType => $composableBuilder(
    column: $table.irrigationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get soilTypeCode => $composableBuilder(
    column: $table.soilTypeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get flowLitersPerHour => $composableBuilder(
    column: $table.flowLitersPerHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get estimatedLiters => $composableBuilder(
    column: $table.estimatedLiters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get irrigatedAt => $composableBuilder(
    column: $table.irrigatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SectorsTableFilterComposer get sectorId {
    final $$SectorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectorId,
      referencedTable: $db.sectors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectorsTableFilterComposer(
            $db: $db,
            $table: $db.sectors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IrrigationRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $IrrigationRecordsTable> {
  $$IrrigationRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get irrigationType => $composableBuilder(
    column: $table.irrigationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get soilTypeCode => $composableBuilder(
    column: $table.soilTypeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get flowLitersPerHour => $composableBuilder(
    column: $table.flowLitersPerHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get estimatedLiters => $composableBuilder(
    column: $table.estimatedLiters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get irrigatedAt => $composableBuilder(
    column: $table.irrigatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SectorsTableOrderingComposer get sectorId {
    final $$SectorsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectorId,
      referencedTable: $db.sectors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectorsTableOrderingComposer(
            $db: $db,
            $table: $db.sectors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IrrigationRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IrrigationRecordsTable> {
  $$IrrigationRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get irrigationType => $composableBuilder(
    column: $table.irrigationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get soilTypeCode => $composableBuilder(
    column: $table.soilTypeCode,
    builder: (column) => column,
  );

  GeneratedColumn<double> get flowLitersPerHour => $composableBuilder(
    column: $table.flowLitersPerHour,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get estimatedLiters => $composableBuilder(
    column: $table.estimatedLiters,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get irrigatedAt => $composableBuilder(
    column: $table.irrigatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$SectorsTableAnnotationComposer get sectorId {
    final $$SectorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectorId,
      referencedTable: $db.sectors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectorsTableAnnotationComposer(
            $db: $db,
            $table: $db.sectors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IrrigationRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IrrigationRecordsTable,
          IrrigationRecord,
          $$IrrigationRecordsTableFilterComposer,
          $$IrrigationRecordsTableOrderingComposer,
          $$IrrigationRecordsTableAnnotationComposer,
          $$IrrigationRecordsTableCreateCompanionBuilder,
          $$IrrigationRecordsTableUpdateCompanionBuilder,
          (IrrigationRecord, $$IrrigationRecordsTableReferences),
          IrrigationRecord,
          PrefetchHooks Function({bool sectorId})
        > {
  $$IrrigationRecordsTableTableManager(
    _$AppDatabase db,
    $IrrigationRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IrrigationRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IrrigationRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IrrigationRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> sectorId = const Value.absent(),
                Value<String> irrigationType = const Value.absent(),
                Value<String> soilTypeCode = const Value.absent(),
                Value<double?> flowLitersPerHour = const Value.absent(),
                Value<int?> durationMinutes = const Value.absent(),
                Value<double?> estimatedLiters = const Value.absent(),
                Value<DateTime> irrigatedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IrrigationRecordsCompanion(
                id: id,
                ownerId: ownerId,
                sectorId: sectorId,
                irrigationType: irrigationType,
                soilTypeCode: soilTypeCode,
                flowLitersPerHour: flowLitersPerHour,
                durationMinutes: durationMinutes,
                estimatedLiters: estimatedLiters,
                irrigatedAt: irrigatedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String sectorId,
                required String irrigationType,
                required String soilTypeCode,
                Value<double?> flowLitersPerHour = const Value.absent(),
                Value<int?> durationMinutes = const Value.absent(),
                Value<double?> estimatedLiters = const Value.absent(),
                required DateTime irrigatedAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => IrrigationRecordsCompanion.insert(
                id: id,
                ownerId: ownerId,
                sectorId: sectorId,
                irrigationType: irrigationType,
                soilTypeCode: soilTypeCode,
                flowLitersPerHour: flowLitersPerHour,
                durationMinutes: durationMinutes,
                estimatedLiters: estimatedLiters,
                irrigatedAt: irrigatedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IrrigationRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sectorId = false}) {
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
                    if (sectorId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sectorId,
                        referencedTable: $$IrrigationRecordsTableReferences
                            ._sectorIdTable(db),
                        referencedColumn: $$IrrigationRecordsTableReferences
                            ._sectorIdTable(db)
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

typedef $$IrrigationRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IrrigationRecordsTable,
      IrrigationRecord,
      $$IrrigationRecordsTableFilterComposer,
      $$IrrigationRecordsTableOrderingComposer,
      $$IrrigationRecordsTableAnnotationComposer,
      $$IrrigationRecordsTableCreateCompanionBuilder,
      $$IrrigationRecordsTableUpdateCompanionBuilder,
      (IrrigationRecord, $$IrrigationRecordsTableReferences),
      IrrigationRecord,
      PrefetchHooks Function({bool sectorId})
    >;
typedef $$CropIrrigationRulesTableCreateCompanionBuilder =
    CropIrrigationRulesCompanion Function({
      required String id,
      required String cropId,
      required String soilTypeCode,
      required int version,
      required int soilMultiplierPermille,
      required int efficiencyPermille,
      required int minimumDurationMinutes,
      required int maximumDurationMinutes,
      required String sourceTitle,
      required String sourceReference,
      Value<DateTime?> approvedAt,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$CropIrrigationRulesTableUpdateCompanionBuilder =
    CropIrrigationRulesCompanion Function({
      Value<String> id,
      Value<String> cropId,
      Value<String> soilTypeCode,
      Value<int> version,
      Value<int> soilMultiplierPermille,
      Value<int> efficiencyPermille,
      Value<int> minimumDurationMinutes,
      Value<int> maximumDurationMinutes,
      Value<String> sourceTitle,
      Value<String> sourceReference,
      Value<DateTime?> approvedAt,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$CropIrrigationRulesTableFilterComposer
    extends Composer<_$AppDatabase, $CropIrrigationRulesTable> {
  $$CropIrrigationRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cropId => $composableBuilder(
    column: $table.cropId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get soilTypeCode => $composableBuilder(
    column: $table.soilTypeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get soilMultiplierPermille => $composableBuilder(
    column: $table.soilMultiplierPermille,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get efficiencyPermille => $composableBuilder(
    column: $table.efficiencyPermille,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minimumDurationMinutes => $composableBuilder(
    column: $table.minimumDurationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maximumDurationMinutes => $composableBuilder(
    column: $table.maximumDurationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceTitle => $composableBuilder(
    column: $table.sourceTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceReference => $composableBuilder(
    column: $table.sourceReference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get approvedAt => $composableBuilder(
    column: $table.approvedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CropIrrigationRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $CropIrrigationRulesTable> {
  $$CropIrrigationRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cropId => $composableBuilder(
    column: $table.cropId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get soilTypeCode => $composableBuilder(
    column: $table.soilTypeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get soilMultiplierPermille => $composableBuilder(
    column: $table.soilMultiplierPermille,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get efficiencyPermille => $composableBuilder(
    column: $table.efficiencyPermille,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minimumDurationMinutes => $composableBuilder(
    column: $table.minimumDurationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maximumDurationMinutes => $composableBuilder(
    column: $table.maximumDurationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceTitle => $composableBuilder(
    column: $table.sourceTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceReference => $composableBuilder(
    column: $table.sourceReference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get approvedAt => $composableBuilder(
    column: $table.approvedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CropIrrigationRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CropIrrigationRulesTable> {
  $$CropIrrigationRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cropId =>
      $composableBuilder(column: $table.cropId, builder: (column) => column);

  GeneratedColumn<String> get soilTypeCode => $composableBuilder(
    column: $table.soilTypeCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get soilMultiplierPermille => $composableBuilder(
    column: $table.soilMultiplierPermille,
    builder: (column) => column,
  );

  GeneratedColumn<int> get efficiencyPermille => $composableBuilder(
    column: $table.efficiencyPermille,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minimumDurationMinutes => $composableBuilder(
    column: $table.minimumDurationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maximumDurationMinutes => $composableBuilder(
    column: $table.maximumDurationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceTitle => $composableBuilder(
    column: $table.sourceTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceReference => $composableBuilder(
    column: $table.sourceReference,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get approvedAt => $composableBuilder(
    column: $table.approvedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$CropIrrigationRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CropIrrigationRulesTable,
          CropIrrigationRule,
          $$CropIrrigationRulesTableFilterComposer,
          $$CropIrrigationRulesTableOrderingComposer,
          $$CropIrrigationRulesTableAnnotationComposer,
          $$CropIrrigationRulesTableCreateCompanionBuilder,
          $$CropIrrigationRulesTableUpdateCompanionBuilder,
          (
            CropIrrigationRule,
            BaseReferences<
              _$AppDatabase,
              $CropIrrigationRulesTable,
              CropIrrigationRule
            >,
          ),
          CropIrrigationRule,
          PrefetchHooks Function()
        > {
  $$CropIrrigationRulesTableTableManager(
    _$AppDatabase db,
    $CropIrrigationRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CropIrrigationRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CropIrrigationRulesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CropIrrigationRulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cropId = const Value.absent(),
                Value<String> soilTypeCode = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> soilMultiplierPermille = const Value.absent(),
                Value<int> efficiencyPermille = const Value.absent(),
                Value<int> minimumDurationMinutes = const Value.absent(),
                Value<int> maximumDurationMinutes = const Value.absent(),
                Value<String> sourceTitle = const Value.absent(),
                Value<String> sourceReference = const Value.absent(),
                Value<DateTime?> approvedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CropIrrigationRulesCompanion(
                id: id,
                cropId: cropId,
                soilTypeCode: soilTypeCode,
                version: version,
                soilMultiplierPermille: soilMultiplierPermille,
                efficiencyPermille: efficiencyPermille,
                minimumDurationMinutes: minimumDurationMinutes,
                maximumDurationMinutes: maximumDurationMinutes,
                sourceTitle: sourceTitle,
                sourceReference: sourceReference,
                approvedAt: approvedAt,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cropId,
                required String soilTypeCode,
                required int version,
                required int soilMultiplierPermille,
                required int efficiencyPermille,
                required int minimumDurationMinutes,
                required int maximumDurationMinutes,
                required String sourceTitle,
                required String sourceReference,
                Value<DateTime?> approvedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CropIrrigationRulesCompanion.insert(
                id: id,
                cropId: cropId,
                soilTypeCode: soilTypeCode,
                version: version,
                soilMultiplierPermille: soilMultiplierPermille,
                efficiencyPermille: efficiencyPermille,
                minimumDurationMinutes: minimumDurationMinutes,
                maximumDurationMinutes: maximumDurationMinutes,
                sourceTitle: sourceTitle,
                sourceReference: sourceReference,
                approvedAt: approvedAt,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CropIrrigationRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CropIrrigationRulesTable,
      CropIrrigationRule,
      $$CropIrrigationRulesTableFilterComposer,
      $$CropIrrigationRulesTableOrderingComposer,
      $$CropIrrigationRulesTableAnnotationComposer,
      $$CropIrrigationRulesTableCreateCompanionBuilder,
      $$CropIrrigationRulesTableUpdateCompanionBuilder,
      (
        CropIrrigationRule,
        BaseReferences<
          _$AppDatabase,
          $CropIrrigationRulesTable,
          CropIrrigationRule
        >,
      ),
      CropIrrigationRule,
      PrefetchHooks Function()
    >;
typedef $$IrrigationEstimatesTableCreateCompanionBuilder =
    IrrigationEstimatesCompanion Function({
      required String id,
      required String ownerId,
      required String sectorId,
      required String ruleId,
      required int ruleVersion,
      required String soilTypeCode,
      required String inputsJson,
      required int estimatedLitersMilli,
      required int recommendedMinutes,
      Value<String> warningsJson,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$IrrigationEstimatesTableUpdateCompanionBuilder =
    IrrigationEstimatesCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> sectorId,
      Value<String> ruleId,
      Value<int> ruleVersion,
      Value<String> soilTypeCode,
      Value<String> inputsJson,
      Value<int> estimatedLitersMilli,
      Value<int> recommendedMinutes,
      Value<String> warningsJson,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$IrrigationEstimatesTableFilterComposer
    extends Composer<_$AppDatabase, $IrrigationEstimatesTable> {
  $$IrrigationEstimatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sectorId => $composableBuilder(
    column: $table.sectorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleId => $composableBuilder(
    column: $table.ruleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get soilTypeCode => $composableBuilder(
    column: $table.soilTypeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inputsJson => $composableBuilder(
    column: $table.inputsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedLitersMilli => $composableBuilder(
    column: $table.estimatedLitersMilli,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recommendedMinutes => $composableBuilder(
    column: $table.recommendedMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get warningsJson => $composableBuilder(
    column: $table.warningsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IrrigationEstimatesTableOrderingComposer
    extends Composer<_$AppDatabase, $IrrigationEstimatesTable> {
  $$IrrigationEstimatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sectorId => $composableBuilder(
    column: $table.sectorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleId => $composableBuilder(
    column: $table.ruleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get soilTypeCode => $composableBuilder(
    column: $table.soilTypeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inputsJson => $composableBuilder(
    column: $table.inputsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedLitersMilli => $composableBuilder(
    column: $table.estimatedLitersMilli,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recommendedMinutes => $composableBuilder(
    column: $table.recommendedMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get warningsJson => $composableBuilder(
    column: $table.warningsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IrrigationEstimatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IrrigationEstimatesTable> {
  $$IrrigationEstimatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get sectorId =>
      $composableBuilder(column: $table.sectorId, builder: (column) => column);

  GeneratedColumn<String> get ruleId =>
      $composableBuilder(column: $table.ruleId, builder: (column) => column);

  GeneratedColumn<int> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get soilTypeCode => $composableBuilder(
    column: $table.soilTypeCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get inputsJson => $composableBuilder(
    column: $table.inputsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimatedLitersMilli => $composableBuilder(
    column: $table.estimatedLitersMilli,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recommendedMinutes => $composableBuilder(
    column: $table.recommendedMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get warningsJson => $composableBuilder(
    column: $table.warningsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$IrrigationEstimatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IrrigationEstimatesTable,
          IrrigationEstimate,
          $$IrrigationEstimatesTableFilterComposer,
          $$IrrigationEstimatesTableOrderingComposer,
          $$IrrigationEstimatesTableAnnotationComposer,
          $$IrrigationEstimatesTableCreateCompanionBuilder,
          $$IrrigationEstimatesTableUpdateCompanionBuilder,
          (
            IrrigationEstimate,
            BaseReferences<
              _$AppDatabase,
              $IrrigationEstimatesTable,
              IrrigationEstimate
            >,
          ),
          IrrigationEstimate,
          PrefetchHooks Function()
        > {
  $$IrrigationEstimatesTableTableManager(
    _$AppDatabase db,
    $IrrigationEstimatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IrrigationEstimatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IrrigationEstimatesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$IrrigationEstimatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> sectorId = const Value.absent(),
                Value<String> ruleId = const Value.absent(),
                Value<int> ruleVersion = const Value.absent(),
                Value<String> soilTypeCode = const Value.absent(),
                Value<String> inputsJson = const Value.absent(),
                Value<int> estimatedLitersMilli = const Value.absent(),
                Value<int> recommendedMinutes = const Value.absent(),
                Value<String> warningsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IrrigationEstimatesCompanion(
                id: id,
                ownerId: ownerId,
                sectorId: sectorId,
                ruleId: ruleId,
                ruleVersion: ruleVersion,
                soilTypeCode: soilTypeCode,
                inputsJson: inputsJson,
                estimatedLitersMilli: estimatedLitersMilli,
                recommendedMinutes: recommendedMinutes,
                warningsJson: warningsJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String sectorId,
                required String ruleId,
                required int ruleVersion,
                required String soilTypeCode,
                required String inputsJson,
                required int estimatedLitersMilli,
                required int recommendedMinutes,
                Value<String> warningsJson = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => IrrigationEstimatesCompanion.insert(
                id: id,
                ownerId: ownerId,
                sectorId: sectorId,
                ruleId: ruleId,
                ruleVersion: ruleVersion,
                soilTypeCode: soilTypeCode,
                inputsJson: inputsJson,
                estimatedLitersMilli: estimatedLitersMilli,
                recommendedMinutes: recommendedMinutes,
                warningsJson: warningsJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IrrigationEstimatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IrrigationEstimatesTable,
      IrrigationEstimate,
      $$IrrigationEstimatesTableFilterComposer,
      $$IrrigationEstimatesTableOrderingComposer,
      $$IrrigationEstimatesTableAnnotationComposer,
      $$IrrigationEstimatesTableCreateCompanionBuilder,
      $$IrrigationEstimatesTableUpdateCompanionBuilder,
      (
        IrrigationEstimate,
        BaseReferences<
          _$AppDatabase,
          $IrrigationEstimatesTable,
          IrrigationEstimate
        >,
      ),
      IrrigationEstimate,
      PrefetchHooks Function()
    >;
typedef $$ProductionRecordsTableCreateCompanionBuilder =
    ProductionRecordsCompanion Function({
      required String id,
      required String ownerId,
      required String parcelId,
      required String sectorId,
      Value<String?> seasonId,
      required String cropId,
      required double quantity,
      required String unit,
      Value<String?> qualityNotes,
      required DateTime harvestedAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ProductionRecordsTableUpdateCompanionBuilder =
    ProductionRecordsCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> parcelId,
      Value<String> sectorId,
      Value<String?> seasonId,
      Value<String> cropId,
      Value<double> quantity,
      Value<String> unit,
      Value<String?> qualityNotes,
      Value<DateTime> harvestedAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ProductionRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ProductionRecordsTable,
          ProductionRecord
        > {
  $$ProductionRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SectorsTable _sectorIdTable(_$AppDatabase db) =>
      db.sectors.createAlias('production_records__sector_id__sectors__id');

  $$SectorsTableProcessedTableManager get sectorId {
    final $_column = $_itemColumn<String>('sector_id')!;

    final manager = $$SectorsTableTableManager(
      $_db,
      $_db.sectors,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sectorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProductionRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductionRecordsTable> {
  $$ProductionRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parcelId => $composableBuilder(
    column: $table.parcelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seasonId => $composableBuilder(
    column: $table.seasonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cropId => $composableBuilder(
    column: $table.cropId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qualityNotes => $composableBuilder(
    column: $table.qualityNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get harvestedAt => $composableBuilder(
    column: $table.harvestedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SectorsTableFilterComposer get sectorId {
    final $$SectorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectorId,
      referencedTable: $db.sectors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectorsTableFilterComposer(
            $db: $db,
            $table: $db.sectors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductionRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductionRecordsTable> {
  $$ProductionRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parcelId => $composableBuilder(
    column: $table.parcelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seasonId => $composableBuilder(
    column: $table.seasonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cropId => $composableBuilder(
    column: $table.cropId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qualityNotes => $composableBuilder(
    column: $table.qualityNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get harvestedAt => $composableBuilder(
    column: $table.harvestedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SectorsTableOrderingComposer get sectorId {
    final $$SectorsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectorId,
      referencedTable: $db.sectors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectorsTableOrderingComposer(
            $db: $db,
            $table: $db.sectors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductionRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductionRecordsTable> {
  $$ProductionRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get parcelId =>
      $composableBuilder(column: $table.parcelId, builder: (column) => column);

  GeneratedColumn<String> get seasonId =>
      $composableBuilder(column: $table.seasonId, builder: (column) => column);

  GeneratedColumn<String> get cropId =>
      $composableBuilder(column: $table.cropId, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get qualityNotes => $composableBuilder(
    column: $table.qualityNotes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get harvestedAt => $composableBuilder(
    column: $table.harvestedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$SectorsTableAnnotationComposer get sectorId {
    final $$SectorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectorId,
      referencedTable: $db.sectors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectorsTableAnnotationComposer(
            $db: $db,
            $table: $db.sectors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductionRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductionRecordsTable,
          ProductionRecord,
          $$ProductionRecordsTableFilterComposer,
          $$ProductionRecordsTableOrderingComposer,
          $$ProductionRecordsTableAnnotationComposer,
          $$ProductionRecordsTableCreateCompanionBuilder,
          $$ProductionRecordsTableUpdateCompanionBuilder,
          (ProductionRecord, $$ProductionRecordsTableReferences),
          ProductionRecord,
          PrefetchHooks Function({bool sectorId})
        > {
  $$ProductionRecordsTableTableManager(
    _$AppDatabase db,
    $ProductionRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductionRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductionRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductionRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> parcelId = const Value.absent(),
                Value<String> sectorId = const Value.absent(),
                Value<String?> seasonId = const Value.absent(),
                Value<String> cropId = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String?> qualityNotes = const Value.absent(),
                Value<DateTime> harvestedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductionRecordsCompanion(
                id: id,
                ownerId: ownerId,
                parcelId: parcelId,
                sectorId: sectorId,
                seasonId: seasonId,
                cropId: cropId,
                quantity: quantity,
                unit: unit,
                qualityNotes: qualityNotes,
                harvestedAt: harvestedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String parcelId,
                required String sectorId,
                Value<String?> seasonId = const Value.absent(),
                required String cropId,
                required double quantity,
                required String unit,
                Value<String?> qualityNotes = const Value.absent(),
                required DateTime harvestedAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ProductionRecordsCompanion.insert(
                id: id,
                ownerId: ownerId,
                parcelId: parcelId,
                sectorId: sectorId,
                seasonId: seasonId,
                cropId: cropId,
                quantity: quantity,
                unit: unit,
                qualityNotes: qualityNotes,
                harvestedAt: harvestedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProductionRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sectorId = false}) {
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
                    if (sectorId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sectorId,
                        referencedTable: $$ProductionRecordsTableReferences
                            ._sectorIdTable(db),
                        referencedColumn: $$ProductionRecordsTableReferences
                            ._sectorIdTable(db)
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

typedef $$ProductionRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductionRecordsTable,
      ProductionRecord,
      $$ProductionRecordsTableFilterComposer,
      $$ProductionRecordsTableOrderingComposer,
      $$ProductionRecordsTableAnnotationComposer,
      $$ProductionRecordsTableCreateCompanionBuilder,
      $$ProductionRecordsTableUpdateCompanionBuilder,
      (ProductionRecord, $$ProductionRecordsTableReferences),
      ProductionRecord,
      PrefetchHooks Function({bool sectorId})
    >;
typedef $$PhotoAttachmentsTableCreateCompanionBuilder =
    PhotoAttachmentsCompanion Function({
      required String id,
      required String ownerId,
      required String aggregateType,
      required String aggregateId,
      required String localPath,
      required String contentHash,
      required String mimeType,
      Value<String?> remotePath,
      Value<String> uploadState,
      required DateTime capturedAt,
      Value<int> rowid,
    });
typedef $$PhotoAttachmentsTableUpdateCompanionBuilder =
    PhotoAttachmentsCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> aggregateType,
      Value<String> aggregateId,
      Value<String> localPath,
      Value<String> contentHash,
      Value<String> mimeType,
      Value<String?> remotePath,
      Value<String> uploadState,
      Value<DateTime> capturedAt,
      Value<int> rowid,
    });

class $$PhotoAttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $PhotoAttachmentsTable> {
  $$PhotoAttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aggregateType => $composableBuilder(
    column: $table.aggregateType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aggregateId => $composableBuilder(
    column: $table.aggregateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remotePath => $composableBuilder(
    column: $table.remotePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uploadState => $composableBuilder(
    column: $table.uploadState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PhotoAttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PhotoAttachmentsTable> {
  $$PhotoAttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aggregateType => $composableBuilder(
    column: $table.aggregateType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aggregateId => $composableBuilder(
    column: $table.aggregateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remotePath => $composableBuilder(
    column: $table.remotePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uploadState => $composableBuilder(
    column: $table.uploadState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PhotoAttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhotoAttachmentsTable> {
  $$PhotoAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get aggregateType => $composableBuilder(
    column: $table.aggregateType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aggregateId => $composableBuilder(
    column: $table.aggregateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<String> get remotePath => $composableBuilder(
    column: $table.remotePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uploadState => $composableBuilder(
    column: $table.uploadState,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );
}

class $$PhotoAttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhotoAttachmentsTable,
          PhotoAttachment,
          $$PhotoAttachmentsTableFilterComposer,
          $$PhotoAttachmentsTableOrderingComposer,
          $$PhotoAttachmentsTableAnnotationComposer,
          $$PhotoAttachmentsTableCreateCompanionBuilder,
          $$PhotoAttachmentsTableUpdateCompanionBuilder,
          (
            PhotoAttachment,
            BaseReferences<
              _$AppDatabase,
              $PhotoAttachmentsTable,
              PhotoAttachment
            >,
          ),
          PhotoAttachment,
          PrefetchHooks Function()
        > {
  $$PhotoAttachmentsTableTableManager(
    _$AppDatabase db,
    $PhotoAttachmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhotoAttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhotoAttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhotoAttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> aggregateType = const Value.absent(),
                Value<String> aggregateId = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<String?> remotePath = const Value.absent(),
                Value<String> uploadState = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotoAttachmentsCompanion(
                id: id,
                ownerId: ownerId,
                aggregateType: aggregateType,
                aggregateId: aggregateId,
                localPath: localPath,
                contentHash: contentHash,
                mimeType: mimeType,
                remotePath: remotePath,
                uploadState: uploadState,
                capturedAt: capturedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String aggregateType,
                required String aggregateId,
                required String localPath,
                required String contentHash,
                required String mimeType,
                Value<String?> remotePath = const Value.absent(),
                Value<String> uploadState = const Value.absent(),
                required DateTime capturedAt,
                Value<int> rowid = const Value.absent(),
              }) => PhotoAttachmentsCompanion.insert(
                id: id,
                ownerId: ownerId,
                aggregateType: aggregateType,
                aggregateId: aggregateId,
                localPath: localPath,
                contentHash: contentHash,
                mimeType: mimeType,
                remotePath: remotePath,
                uploadState: uploadState,
                capturedAt: capturedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PhotoAttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhotoAttachmentsTable,
      PhotoAttachment,
      $$PhotoAttachmentsTableFilterComposer,
      $$PhotoAttachmentsTableOrderingComposer,
      $$PhotoAttachmentsTableAnnotationComposer,
      $$PhotoAttachmentsTableCreateCompanionBuilder,
      $$PhotoAttachmentsTableUpdateCompanionBuilder,
      (
        PhotoAttachment,
        BaseReferences<_$AppDatabase, $PhotoAttachmentsTable, PhotoAttachment>,
      ),
      PhotoAttachment,
      PrefetchHooks Function()
    >;
typedef $$RemindersTableCreateCompanionBuilder = RemindersCompanion Function({
  required String id,
  required String ownerId,
  Value<String?> sectorId,
  required String title,
  Value<String?> notes,
  required DateTime scheduledAt,
  Value<bool> isCompleted,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$RemindersTableUpdateCompanionBuilder = RemindersCompanion Function({
  Value<String> id,
  Value<String> ownerId,
  Value<String?> sectorId,
  Value<String> title,
  Value<String?> notes,
  Value<DateTime> scheduledAt,
  Value<bool> isCompleted,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sectorId => $composableBuilder(
    column: $table.sectorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sectorId => $composableBuilder(
    column: $table.sectorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get sectorId =>
      $composableBuilder(column: $table.sectorId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          Reminder,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (Reminder, BaseReferences<_$AppDatabase, $RemindersTable, Reminder>),
          Reminder,
          PrefetchHooks Function()
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String?> sectorId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> scheduledAt = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                ownerId: ownerId,
                sectorId: sectorId,
                title: title,
                notes: notes,
                scheduledAt: scheduledAt,
                isCompleted: isCompleted,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                Value<String?> sectorId = const Value.absent(),
                required String title,
                Value<String?> notes = const Value.absent(),
                required DateTime scheduledAt,
                Value<bool> isCompleted = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                ownerId: ownerId,
                sectorId: sectorId,
                title: title,
                notes: notes,
                scheduledAt: scheduledAt,
                isCompleted: isCompleted,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      Reminder,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (Reminder, BaseReferences<_$AppDatabase, $RemindersTable, Reminder>),
      Reminder,
      PrefetchHooks Function()
    >;
typedef $$DeviceInstallationsTableCreateCompanionBuilder =
    DeviceInstallationsCompanion Function({
      required String id,
      required String ownerId,
      required String fcmToken,
      Value<String> platform,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DeviceInstallationsTableUpdateCompanionBuilder =
    DeviceInstallationsCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> fcmToken,
      Value<String> platform,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$DeviceInstallationsTableFilterComposer
    extends Composer<_$AppDatabase, $DeviceInstallationsTable> {
  $$DeviceInstallationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fcmToken => $composableBuilder(
    column: $table.fcmToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DeviceInstallationsTableOrderingComposer
    extends Composer<_$AppDatabase, $DeviceInstallationsTable> {
  $$DeviceInstallationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fcmToken => $composableBuilder(
    column: $table.fcmToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DeviceInstallationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeviceInstallationsTable> {
  $$DeviceInstallationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get fcmToken =>
      $composableBuilder(column: $table.fcmToken, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DeviceInstallationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeviceInstallationsTable,
          DeviceInstallation,
          $$DeviceInstallationsTableFilterComposer,
          $$DeviceInstallationsTableOrderingComposer,
          $$DeviceInstallationsTableAnnotationComposer,
          $$DeviceInstallationsTableCreateCompanionBuilder,
          $$DeviceInstallationsTableUpdateCompanionBuilder,
          (
            DeviceInstallation,
            BaseReferences<
              _$AppDatabase,
              $DeviceInstallationsTable,
              DeviceInstallation
            >,
          ),
          DeviceInstallation,
          PrefetchHooks Function()
        > {
  $$DeviceInstallationsTableTableManager(
    _$AppDatabase db,
    $DeviceInstallationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeviceInstallationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeviceInstallationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DeviceInstallationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> fcmToken = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeviceInstallationsCompanion(
                id: id,
                ownerId: ownerId,
                fcmToken: fcmToken,
                platform: platform,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String fcmToken,
                Value<String> platform = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DeviceInstallationsCompanion.insert(
                id: id,
                ownerId: ownerId,
                fcmToken: fcmToken,
                platform: platform,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DeviceInstallationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeviceInstallationsTable,
      DeviceInstallation,
      $$DeviceInstallationsTableFilterComposer,
      $$DeviceInstallationsTableOrderingComposer,
      $$DeviceInstallationsTableAnnotationComposer,
      $$DeviceInstallationsTableCreateCompanionBuilder,
      $$DeviceInstallationsTableUpdateCompanionBuilder,
      (
        DeviceInstallation,
        BaseReferences<
          _$AppDatabase,
          $DeviceInstallationsTable,
          DeviceInstallation
        >,
      ),
      DeviceInstallation,
      PrefetchHooks Function()
    >;
typedef $$ApiaryInspectionsTableCreateCompanionBuilder =
    ApiaryInspectionsCompanion Function({
      required String id,
      required String ownerId,
      required String sectorId,
      required String taskType,
      required String beekeeperName,
      required int hiveCount,
      required String queenStatus,
      required String broodStatus,
      required String feedingStatus,
      required String healthNotes,
      required String pestNotes,
      required bool superInstalled,
      Value<String?> observations,
      required DateTime inspectedAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ApiaryInspectionsTableUpdateCompanionBuilder =
    ApiaryInspectionsCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> sectorId,
      Value<String> taskType,
      Value<String> beekeeperName,
      Value<int> hiveCount,
      Value<String> queenStatus,
      Value<String> broodStatus,
      Value<String> feedingStatus,
      Value<String> healthNotes,
      Value<String> pestNotes,
      Value<bool> superInstalled,
      Value<String?> observations,
      Value<DateTime> inspectedAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ApiaryInspectionsTableFilterComposer
    extends Composer<_$AppDatabase, $ApiaryInspectionsTable> {
  $$ApiaryInspectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sectorId => $composableBuilder(
    column: $table.sectorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskType => $composableBuilder(
    column: $table.taskType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beekeeperName => $composableBuilder(
    column: $table.beekeeperName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hiveCount => $composableBuilder(
    column: $table.hiveCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get queenStatus => $composableBuilder(
    column: $table.queenStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get broodStatus => $composableBuilder(
    column: $table.broodStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedingStatus => $composableBuilder(
    column: $table.feedingStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get healthNotes => $composableBuilder(
    column: $table.healthNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pestNotes => $composableBuilder(
    column: $table.pestNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get superInstalled => $composableBuilder(
    column: $table.superInstalled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get inspectedAt => $composableBuilder(
    column: $table.inspectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ApiaryInspectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ApiaryInspectionsTable> {
  $$ApiaryInspectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sectorId => $composableBuilder(
    column: $table.sectorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskType => $composableBuilder(
    column: $table.taskType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beekeeperName => $composableBuilder(
    column: $table.beekeeperName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hiveCount => $composableBuilder(
    column: $table.hiveCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get queenStatus => $composableBuilder(
    column: $table.queenStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get broodStatus => $composableBuilder(
    column: $table.broodStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedingStatus => $composableBuilder(
    column: $table.feedingStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get healthNotes => $composableBuilder(
    column: $table.healthNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pestNotes => $composableBuilder(
    column: $table.pestNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get superInstalled => $composableBuilder(
    column: $table.superInstalled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get inspectedAt => $composableBuilder(
    column: $table.inspectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ApiaryInspectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ApiaryInspectionsTable> {
  $$ApiaryInspectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get sectorId =>
      $composableBuilder(column: $table.sectorId, builder: (column) => column);

  GeneratedColumn<String> get taskType =>
      $composableBuilder(column: $table.taskType, builder: (column) => column);

  GeneratedColumn<String> get beekeeperName => $composableBuilder(
    column: $table.beekeeperName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hiveCount =>
      $composableBuilder(column: $table.hiveCount, builder: (column) => column);

  GeneratedColumn<String> get queenStatus => $composableBuilder(
    column: $table.queenStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get broodStatus => $composableBuilder(
    column: $table.broodStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get feedingStatus => $composableBuilder(
    column: $table.feedingStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get healthNotes => $composableBuilder(
    column: $table.healthNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pestNotes =>
      $composableBuilder(column: $table.pestNotes, builder: (column) => column);

  GeneratedColumn<bool> get superInstalled => $composableBuilder(
    column: $table.superInstalled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get inspectedAt => $composableBuilder(
    column: $table.inspectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ApiaryInspectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ApiaryInspectionsTable,
          ApiaryInspection,
          $$ApiaryInspectionsTableFilterComposer,
          $$ApiaryInspectionsTableOrderingComposer,
          $$ApiaryInspectionsTableAnnotationComposer,
          $$ApiaryInspectionsTableCreateCompanionBuilder,
          $$ApiaryInspectionsTableUpdateCompanionBuilder,
          (
            ApiaryInspection,
            BaseReferences<
              _$AppDatabase,
              $ApiaryInspectionsTable,
              ApiaryInspection
            >,
          ),
          ApiaryInspection,
          PrefetchHooks Function()
        > {
  $$ApiaryInspectionsTableTableManager(
    _$AppDatabase db,
    $ApiaryInspectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ApiaryInspectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ApiaryInspectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ApiaryInspectionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> sectorId = const Value.absent(),
                Value<String> taskType = const Value.absent(),
                Value<String> beekeeperName = const Value.absent(),
                Value<int> hiveCount = const Value.absent(),
                Value<String> queenStatus = const Value.absent(),
                Value<String> broodStatus = const Value.absent(),
                Value<String> feedingStatus = const Value.absent(),
                Value<String> healthNotes = const Value.absent(),
                Value<String> pestNotes = const Value.absent(),
                Value<bool> superInstalled = const Value.absent(),
                Value<String?> observations = const Value.absent(),
                Value<DateTime> inspectedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ApiaryInspectionsCompanion(
                id: id,
                ownerId: ownerId,
                sectorId: sectorId,
                taskType: taskType,
                beekeeperName: beekeeperName,
                hiveCount: hiveCount,
                queenStatus: queenStatus,
                broodStatus: broodStatus,
                feedingStatus: feedingStatus,
                healthNotes: healthNotes,
                pestNotes: pestNotes,
                superInstalled: superInstalled,
                observations: observations,
                inspectedAt: inspectedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String sectorId,
                required String taskType,
                required String beekeeperName,
                required int hiveCount,
                required String queenStatus,
                required String broodStatus,
                required String feedingStatus,
                required String healthNotes,
                required String pestNotes,
                required bool superInstalled,
                Value<String?> observations = const Value.absent(),
                required DateTime inspectedAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ApiaryInspectionsCompanion.insert(
                id: id,
                ownerId: ownerId,
                sectorId: sectorId,
                taskType: taskType,
                beekeeperName: beekeeperName,
                hiveCount: hiveCount,
                queenStatus: queenStatus,
                broodStatus: broodStatus,
                feedingStatus: feedingStatus,
                healthNotes: healthNotes,
                pestNotes: pestNotes,
                superInstalled: superInstalled,
                observations: observations,
                inspectedAt: inspectedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ApiaryInspectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ApiaryInspectionsTable,
      ApiaryInspection,
      $$ApiaryInspectionsTableFilterComposer,
      $$ApiaryInspectionsTableOrderingComposer,
      $$ApiaryInspectionsTableAnnotationComposer,
      $$ApiaryInspectionsTableCreateCompanionBuilder,
      $$ApiaryInspectionsTableUpdateCompanionBuilder,
      (
        ApiaryInspection,
        BaseReferences<
          _$AppDatabase,
          $ApiaryInspectionsTable,
          ApiaryInspection
        >,
      ),
      ApiaryInspection,
      PrefetchHooks Function()
    >;
typedef $$WeatherCacheTableCreateCompanionBuilder =
    WeatherCacheCompanion Function({
      required String id,
      required String ownerId,
      required String locality,
      required String payloadJson,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$WeatherCacheTableUpdateCompanionBuilder =
    WeatherCacheCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> locality,
      Value<String> payloadJson,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$WeatherCacheTableFilterComposer
    extends Composer<_$AppDatabase, $WeatherCacheTable> {
  $$WeatherCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locality => $composableBuilder(
    column: $table.locality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeatherCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $WeatherCacheTable> {
  $$WeatherCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locality => $composableBuilder(
    column: $table.locality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeatherCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeatherCacheTable> {
  $$WeatherCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get locality =>
      $composableBuilder(column: $table.locality, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$WeatherCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeatherCacheTable,
          WeatherCacheData,
          $$WeatherCacheTableFilterComposer,
          $$WeatherCacheTableOrderingComposer,
          $$WeatherCacheTableAnnotationComposer,
          $$WeatherCacheTableCreateCompanionBuilder,
          $$WeatherCacheTableUpdateCompanionBuilder,
          (
            WeatherCacheData,
            BaseReferences<_$AppDatabase, $WeatherCacheTable, WeatherCacheData>,
          ),
          WeatherCacheData,
          PrefetchHooks Function()
        > {
  $$WeatherCacheTableTableManager(_$AppDatabase db, $WeatherCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeatherCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeatherCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeatherCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> locality = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeatherCacheCompanion(
                id: id,
                ownerId: ownerId,
                locality: locality,
                payloadJson: payloadJson,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String locality,
                required String payloadJson,
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => WeatherCacheCompanion.insert(
                id: id,
                ownerId: ownerId,
                locality: locality,
                payloadJson: payloadJson,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeatherCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeatherCacheTable,
      WeatherCacheData,
      $$WeatherCacheTableFilterComposer,
      $$WeatherCacheTableOrderingComposer,
      $$WeatherCacheTableAnnotationComposer,
      $$WeatherCacheTableCreateCompanionBuilder,
      $$WeatherCacheTableUpdateCompanionBuilder,
      (
        WeatherCacheData,
        BaseReferences<_$AppDatabase, $WeatherCacheTable, WeatherCacheData>,
      ),
      WeatherCacheData,
      PrefetchHooks Function()
    >;
typedef $$AiMessagesTableCreateCompanionBuilder = AiMessagesCompanion Function({
  required String id,
  required String ownerId,
  required String role,
  required String content,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$AiMessagesTableUpdateCompanionBuilder = AiMessagesCompanion Function({
  Value<String> id,
  Value<String> ownerId,
  Value<String> role,
  Value<String> content,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$AiMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $AiMessagesTable> {
  $$AiMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $AiMessagesTable> {
  $$AiMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiMessagesTable> {
  $$AiMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AiMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiMessagesTable,
          AiMessage,
          $$AiMessagesTableFilterComposer,
          $$AiMessagesTableOrderingComposer,
          $$AiMessagesTableAnnotationComposer,
          $$AiMessagesTableCreateCompanionBuilder,
          $$AiMessagesTableUpdateCompanionBuilder,
          (
            AiMessage,
            BaseReferences<_$AppDatabase, $AiMessagesTable, AiMessage>,
          ),
          AiMessage,
          PrefetchHooks Function()
        > {
  $$AiMessagesTableTableManager(_$AppDatabase db, $AiMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiMessagesCompanion(
                id: id,
                ownerId: ownerId,
                role: role,
                content: content,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String role,
                required String content,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AiMessagesCompanion.insert(
                id: id,
                ownerId: ownerId,
                role: role,
                content: content,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiMessagesTable,
      AiMessage,
      $$AiMessagesTableFilterComposer,
      $$AiMessagesTableOrderingComposer,
      $$AiMessagesTableAnnotationComposer,
      $$AiMessagesTableCreateCompanionBuilder,
      $$AiMessagesTableUpdateCompanionBuilder,
      (AiMessage, BaseReferences<_$AppDatabase, $AiMessagesTable, AiMessage>),
      AiMessage,
      PrefetchHooks Function()
    >;
typedef $$ExportSnapshotsTableCreateCompanionBuilder =
    ExportSnapshotsCompanion Function({
      required String id,
      required String ownerId,
      required String status,
      required String manifestJson,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ExportSnapshotsTableUpdateCompanionBuilder =
    ExportSnapshotsCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> status,
      Value<String> manifestJson,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ExportSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $ExportSnapshotsTable> {
  $$ExportSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manifestJson => $composableBuilder(
    column: $table.manifestJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExportSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExportSnapshotsTable> {
  $$ExportSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manifestJson => $composableBuilder(
    column: $table.manifestJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExportSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExportSnapshotsTable> {
  $$ExportSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get manifestJson => $composableBuilder(
    column: $table.manifestJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ExportSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExportSnapshotsTable,
          ExportSnapshot,
          $$ExportSnapshotsTableFilterComposer,
          $$ExportSnapshotsTableOrderingComposer,
          $$ExportSnapshotsTableAnnotationComposer,
          $$ExportSnapshotsTableCreateCompanionBuilder,
          $$ExportSnapshotsTableUpdateCompanionBuilder,
          (
            ExportSnapshot,
            BaseReferences<
              _$AppDatabase,
              $ExportSnapshotsTable,
              ExportSnapshot
            >,
          ),
          ExportSnapshot,
          PrefetchHooks Function()
        > {
  $$ExportSnapshotsTableTableManager(
    _$AppDatabase db,
    $ExportSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExportSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExportSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExportSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> manifestJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExportSnapshotsCompanion(
                id: id,
                ownerId: ownerId,
                status: status,
                manifestJson: manifestJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String status,
                required String manifestJson,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ExportSnapshotsCompanion.insert(
                id: id,
                ownerId: ownerId,
                status: status,
                manifestJson: manifestJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExportSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExportSnapshotsTable,
      ExportSnapshot,
      $$ExportSnapshotsTableFilterComposer,
      $$ExportSnapshotsTableOrderingComposer,
      $$ExportSnapshotsTableAnnotationComposer,
      $$ExportSnapshotsTableCreateCompanionBuilder,
      $$ExportSnapshotsTableUpdateCompanionBuilder,
      (
        ExportSnapshot,
        BaseReferences<_$AppDatabase, $ExportSnapshotsTable, ExportSnapshot>,
      ),
      ExportSnapshot,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalProfilesTableTableManager get localProfiles =>
      $$LocalProfilesTableTableManager(_db, _db.localProfiles);
  $$AppPreferencesTableTableManager get appPreferences =>
      $$AppPreferencesTableTableManager(_db, _db.appPreferences);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
  $$SyncCursorsTableTableManager get syncCursors =>
      $$SyncCursorsTableTableManager(_db, _db.syncCursors);
  $$SyncConflictsTableTableManager get syncConflicts =>
      $$SyncConflictsTableTableManager(_db, _db.syncConflicts);
  $$FormDraftsTableTableManager get formDrafts =>
      $$FormDraftsTableTableManager(_db, _db.formDrafts);
  $$ParcelsTableTableManager get parcels =>
      $$ParcelsTableTableManager(_db, _db.parcels);
  $$SectorsTableTableManager get sectors =>
      $$SectorsTableTableManager(_db, _db.sectors);
  $$OfficialCropsTableTableManager get officialCrops =>
      $$OfficialCropsTableTableManager(_db, _db.officialCrops);
  $$CustomCropsTableTableManager get customCrops =>
      $$CustomCropsTableTableManager(_db, _db.customCrops);
  $$CropSeasonsTableTableManager get cropSeasons =>
      $$CropSeasonsTableTableManager(_db, _db.cropSeasons);
  $$LaborsTableTableManager get labors =>
      $$LaborsTableTableManager(_db, _db.labors);
  $$SoilMeasurementsTableTableManager get soilMeasurements =>
      $$SoilMeasurementsTableTableManager(_db, _db.soilMeasurements);
  $$IrrigationRecordsTableTableManager get irrigationRecords =>
      $$IrrigationRecordsTableTableManager(_db, _db.irrigationRecords);
  $$CropIrrigationRulesTableTableManager get cropIrrigationRules =>
      $$CropIrrigationRulesTableTableManager(_db, _db.cropIrrigationRules);
  $$IrrigationEstimatesTableTableManager get irrigationEstimates =>
      $$IrrigationEstimatesTableTableManager(_db, _db.irrigationEstimates);
  $$ProductionRecordsTableTableManager get productionRecords =>
      $$ProductionRecordsTableTableManager(_db, _db.productionRecords);
  $$PhotoAttachmentsTableTableManager get photoAttachments =>
      $$PhotoAttachmentsTableTableManager(_db, _db.photoAttachments);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$DeviceInstallationsTableTableManager get deviceInstallations =>
      $$DeviceInstallationsTableTableManager(_db, _db.deviceInstallations);
  $$ApiaryInspectionsTableTableManager get apiaryInspections =>
      $$ApiaryInspectionsTableTableManager(_db, _db.apiaryInspections);
  $$WeatherCacheTableTableManager get weatherCache =>
      $$WeatherCacheTableTableManager(_db, _db.weatherCache);
  $$AiMessagesTableTableManager get aiMessages =>
      $$AiMessagesTableTableManager(_db, _db.aiMessages);
  $$ExportSnapshotsTableTableManager get exportSnapshots =>
      $$ExportSnapshotsTableTableManager(_db, _db.exportSnapshots);
}
