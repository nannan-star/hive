// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _templateEnabledMeta = const VerificationMeta(
    'templateEnabled',
  );
  @override
  late final GeneratedColumn<bool> templateEnabled = GeneratedColumn<bool>(
    'template_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("template_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _templateDefaultAmountMeta =
      const VerificationMeta('templateDefaultAmount');
  @override
  late final GeneratedColumn<int> templateDefaultAmount = GeneratedColumn<int>(
    'template_default_amount',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _templateDefaultNoteMeta =
      const VerificationMeta('templateDefaultNote');
  @override
  late final GeneratedColumn<String> templateDefaultNote =
      GeneratedColumn<String>(
        'template_default_note',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _templateDayMeta = const VerificationMeta(
    'templateDay',
  );
  @override
  late final GeneratedColumn<int> templateDay = GeneratedColumn<int>(
    'template_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    sortOrder,
    enabled,
    note,
    templateEnabled,
    templateDefaultAmount,
    templateDefaultNote,
    templateDay,
    familyId,
    memberId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('template_enabled')) {
      context.handle(
        _templateEnabledMeta,
        templateEnabled.isAcceptableOrUnknown(
          data['template_enabled']!,
          _templateEnabledMeta,
        ),
      );
    }
    if (data.containsKey('template_default_amount')) {
      context.handle(
        _templateDefaultAmountMeta,
        templateDefaultAmount.isAcceptableOrUnknown(
          data['template_default_amount']!,
          _templateDefaultAmountMeta,
        ),
      );
    }
    if (data.containsKey('template_default_note')) {
      context.handle(
        _templateDefaultNoteMeta,
        templateDefaultNote.isAcceptableOrUnknown(
          data['template_default_note']!,
          _templateDefaultNoteMeta,
        ),
      );
    }
    if (data.containsKey('template_day')) {
      context.handle(
        _templateDayMeta,
        templateDay.isAcceptableOrUnknown(
          data['template_day']!,
          _templateDayMeta,
        ),
      );
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
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
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      templateEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}template_enabled'],
      )!,
      templateDefaultAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}template_default_amount'],
      ),
      templateDefaultNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_default_note'],
      ),
      templateDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}template_day'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      ),
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String name;
  final int sortOrder;
  final bool enabled;
  final String? note;
  final bool templateEnabled;
  final int? templateDefaultAmount;
  final String? templateDefaultNote;
  final int templateDay;
  final String? familyId;
  final String? memberId;
  final int createdAt;
  const Category({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.enabled,
    this.note,
    required this.templateEnabled,
    this.templateDefaultAmount,
    this.templateDefaultNote,
    required this.templateDay,
    this.familyId,
    this.memberId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    map['enabled'] = Variable<bool>(enabled);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['template_enabled'] = Variable<bool>(templateEnabled);
    if (!nullToAbsent || templateDefaultAmount != null) {
      map['template_default_amount'] = Variable<int>(templateDefaultAmount);
    }
    if (!nullToAbsent || templateDefaultNote != null) {
      map['template_default_note'] = Variable<String>(templateDefaultNote);
    }
    map['template_day'] = Variable<int>(templateDay);
    if (!nullToAbsent || familyId != null) {
      map['family_id'] = Variable<String>(familyId);
    }
    if (!nullToAbsent || memberId != null) {
      map['member_id'] = Variable<String>(memberId);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      sortOrder: Value(sortOrder),
      enabled: Value(enabled),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      templateEnabled: Value(templateEnabled),
      templateDefaultAmount: templateDefaultAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(templateDefaultAmount),
      templateDefaultNote: templateDefaultNote == null && nullToAbsent
          ? const Value.absent()
          : Value(templateDefaultNote),
      templateDay: Value(templateDay),
      familyId: familyId == null && nullToAbsent
          ? const Value.absent()
          : Value(familyId),
      memberId: memberId == null && nullToAbsent
          ? const Value.absent()
          : Value(memberId),
      createdAt: Value(createdAt),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      note: serializer.fromJson<String?>(json['note']),
      templateEnabled: serializer.fromJson<bool>(json['templateEnabled']),
      templateDefaultAmount: serializer.fromJson<int?>(
        json['templateDefaultAmount'],
      ),
      templateDefaultNote: serializer.fromJson<String?>(
        json['templateDefaultNote'],
      ),
      templateDay: serializer.fromJson<int>(json['templateDay']),
      familyId: serializer.fromJson<String?>(json['familyId']),
      memberId: serializer.fromJson<String?>(json['memberId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'enabled': serializer.toJson<bool>(enabled),
      'note': serializer.toJson<String?>(note),
      'templateEnabled': serializer.toJson<bool>(templateEnabled),
      'templateDefaultAmount': serializer.toJson<int?>(templateDefaultAmount),
      'templateDefaultNote': serializer.toJson<String?>(templateDefaultNote),
      'templateDay': serializer.toJson<int>(templateDay),
      'familyId': serializer.toJson<String?>(familyId),
      'memberId': serializer.toJson<String?>(memberId),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Category copyWith({
    String? id,
    String? name,
    int? sortOrder,
    bool? enabled,
    Value<String?> note = const Value.absent(),
    bool? templateEnabled,
    Value<int?> templateDefaultAmount = const Value.absent(),
    Value<String?> templateDefaultNote = const Value.absent(),
    int? templateDay,
    Value<String?> familyId = const Value.absent(),
    Value<String?> memberId = const Value.absent(),
    int? createdAt,
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
    enabled: enabled ?? this.enabled,
    note: note.present ? note.value : this.note,
    templateEnabled: templateEnabled ?? this.templateEnabled,
    templateDefaultAmount: templateDefaultAmount.present
        ? templateDefaultAmount.value
        : this.templateDefaultAmount,
    templateDefaultNote: templateDefaultNote.present
        ? templateDefaultNote.value
        : this.templateDefaultNote,
    templateDay: templateDay ?? this.templateDay,
    familyId: familyId.present ? familyId.value : this.familyId,
    memberId: memberId.present ? memberId.value : this.memberId,
    createdAt: createdAt ?? this.createdAt,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      note: data.note.present ? data.note.value : this.note,
      templateEnabled: data.templateEnabled.present
          ? data.templateEnabled.value
          : this.templateEnabled,
      templateDefaultAmount: data.templateDefaultAmount.present
          ? data.templateDefaultAmount.value
          : this.templateDefaultAmount,
      templateDefaultNote: data.templateDefaultNote.present
          ? data.templateDefaultNote.value
          : this.templateDefaultNote,
      templateDay: data.templateDay.present
          ? data.templateDay.value
          : this.templateDay,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('enabled: $enabled, ')
          ..write('note: $note, ')
          ..write('templateEnabled: $templateEnabled, ')
          ..write('templateDefaultAmount: $templateDefaultAmount, ')
          ..write('templateDefaultNote: $templateDefaultNote, ')
          ..write('templateDay: $templateDay, ')
          ..write('familyId: $familyId, ')
          ..write('memberId: $memberId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    sortOrder,
    enabled,
    note,
    templateEnabled,
    templateDefaultAmount,
    templateDefaultNote,
    templateDay,
    familyId,
    memberId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.enabled == this.enabled &&
          other.note == this.note &&
          other.templateEnabled == this.templateEnabled &&
          other.templateDefaultAmount == this.templateDefaultAmount &&
          other.templateDefaultNote == this.templateDefaultNote &&
          other.templateDay == this.templateDay &&
          other.familyId == this.familyId &&
          other.memberId == this.memberId &&
          other.createdAt == this.createdAt);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<bool> enabled;
  final Value<String?> note;
  final Value<bool> templateEnabled;
  final Value<int?> templateDefaultAmount;
  final Value<String?> templateDefaultNote;
  final Value<int> templateDay;
  final Value<String?> familyId;
  final Value<String?> memberId;
  final Value<int> createdAt;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.enabled = const Value.absent(),
    this.note = const Value.absent(),
    this.templateEnabled = const Value.absent(),
    this.templateDefaultAmount = const Value.absent(),
    this.templateDefaultNote = const Value.absent(),
    this.templateDay = const Value.absent(),
    this.familyId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    required int sortOrder,
    this.enabled = const Value.absent(),
    this.note = const Value.absent(),
    this.templateEnabled = const Value.absent(),
    this.templateDefaultAmount = const Value.absent(),
    this.templateDefaultNote = const Value.absent(),
    this.templateDay = const Value.absent(),
    this.familyId = const Value.absent(),
    this.memberId = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       sortOrder = Value(sortOrder),
       createdAt = Value(createdAt);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<bool>? enabled,
    Expression<String>? note,
    Expression<bool>? templateEnabled,
    Expression<int>? templateDefaultAmount,
    Expression<String>? templateDefaultNote,
    Expression<int>? templateDay,
    Expression<String>? familyId,
    Expression<String>? memberId,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (enabled != null) 'enabled': enabled,
      if (note != null) 'note': note,
      if (templateEnabled != null) 'template_enabled': templateEnabled,
      if (templateDefaultAmount != null)
        'template_default_amount': templateDefaultAmount,
      if (templateDefaultNote != null)
        'template_default_note': templateDefaultNote,
      if (templateDay != null) 'template_day': templateDay,
      if (familyId != null) 'family_id': familyId,
      if (memberId != null) 'member_id': memberId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<bool>? enabled,
    Value<String?>? note,
    Value<bool>? templateEnabled,
    Value<int?>? templateDefaultAmount,
    Value<String?>? templateDefaultNote,
    Value<int>? templateDay,
    Value<String?>? familyId,
    Value<String?>? memberId,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      enabled: enabled ?? this.enabled,
      note: note ?? this.note,
      templateEnabled: templateEnabled ?? this.templateEnabled,
      templateDefaultAmount:
          templateDefaultAmount ?? this.templateDefaultAmount,
      templateDefaultNote: templateDefaultNote ?? this.templateDefaultNote,
      templateDay: templateDay ?? this.templateDay,
      familyId: familyId ?? this.familyId,
      memberId: memberId ?? this.memberId,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (templateEnabled.present) {
      map['template_enabled'] = Variable<bool>(templateEnabled.value);
    }
    if (templateDefaultAmount.present) {
      map['template_default_amount'] = Variable<int>(
        templateDefaultAmount.value,
      );
    }
    if (templateDefaultNote.present) {
      map['template_default_note'] = Variable<String>(
        templateDefaultNote.value,
      );
    }
    if (templateDay.present) {
      map['template_day'] = Variable<int>(templateDay.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('enabled: $enabled, ')
          ..write('note: $note, ')
          ..write('templateEnabled: $templateEnabled, ')
          ..write('templateDefaultAmount: $templateDefaultAmount, ')
          ..write('templateDefaultNote: $templateDefaultNote, ')
          ..write('templateDay: $templateDay, ')
          ..write('familyId: $familyId, ')
          ..write('memberId: $memberId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SpendEntriesTable extends SpendEntries
    with TableInfo<$SpendEntriesTable, SpendEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpendEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
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
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    amountCents,
    date,
    note,
    source,
    status,
    familyId,
    memberId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'spend_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpendEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
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
  SpendEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpendEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      ),
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SpendEntriesTable createAlias(String alias) {
    return $SpendEntriesTable(attachedDatabase, alias);
  }
}

class SpendEntry extends DataClass implements Insertable<SpendEntry> {
  final String id;
  final String categoryId;
  final int amountCents;
  final String date;
  final String? note;
  final String source;
  final String status;
  final String? familyId;
  final String? memberId;
  final int createdAt;
  const SpendEntry({
    required this.id,
    required this.categoryId,
    required this.amountCents,
    required this.date,
    this.note,
    required this.source,
    required this.status,
    this.familyId,
    this.memberId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category_id'] = Variable<String>(categoryId);
    map['amount_cents'] = Variable<int>(amountCents);
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['source'] = Variable<String>(source);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || familyId != null) {
      map['family_id'] = Variable<String>(familyId);
    }
    if (!nullToAbsent || memberId != null) {
      map['member_id'] = Variable<String>(memberId);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  SpendEntriesCompanion toCompanion(bool nullToAbsent) {
    return SpendEntriesCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      amountCents: Value(amountCents),
      date: Value(date),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      source: Value(source),
      status: Value(status),
      familyId: familyId == null && nullToAbsent
          ? const Value.absent()
          : Value(familyId),
      memberId: memberId == null && nullToAbsent
          ? const Value.absent()
          : Value(memberId),
      createdAt: Value(createdAt),
    );
  }

  factory SpendEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpendEntry(
      id: serializer.fromJson<String>(json['id']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      date: serializer.fromJson<String>(json['date']),
      note: serializer.fromJson<String?>(json['note']),
      source: serializer.fromJson<String>(json['source']),
      status: serializer.fromJson<String>(json['status']),
      familyId: serializer.fromJson<String?>(json['familyId']),
      memberId: serializer.fromJson<String?>(json['memberId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'categoryId': serializer.toJson<String>(categoryId),
      'amountCents': serializer.toJson<int>(amountCents),
      'date': serializer.toJson<String>(date),
      'note': serializer.toJson<String?>(note),
      'source': serializer.toJson<String>(source),
      'status': serializer.toJson<String>(status),
      'familyId': serializer.toJson<String?>(familyId),
      'memberId': serializer.toJson<String?>(memberId),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  SpendEntry copyWith({
    String? id,
    String? categoryId,
    int? amountCents,
    String? date,
    Value<String?> note = const Value.absent(),
    String? source,
    String? status,
    Value<String?> familyId = const Value.absent(),
    Value<String?> memberId = const Value.absent(),
    int? createdAt,
  }) => SpendEntry(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    amountCents: amountCents ?? this.amountCents,
    date: date ?? this.date,
    note: note.present ? note.value : this.note,
    source: source ?? this.source,
    status: status ?? this.status,
    familyId: familyId.present ? familyId.value : this.familyId,
    memberId: memberId.present ? memberId.value : this.memberId,
    createdAt: createdAt ?? this.createdAt,
  );
  SpendEntry copyWithCompanion(SpendEntriesCompanion data) {
    return SpendEntry(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
      source: data.source.present ? data.source.value : this.source,
      status: data.status.present ? data.status.value : this.status,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpendEntry(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('amountCents: $amountCents, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('familyId: $familyId, ')
          ..write('memberId: $memberId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    categoryId,
    amountCents,
    date,
    note,
    source,
    status,
    familyId,
    memberId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpendEntry &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.amountCents == this.amountCents &&
          other.date == this.date &&
          other.note == this.note &&
          other.source == this.source &&
          other.status == this.status &&
          other.familyId == this.familyId &&
          other.memberId == this.memberId &&
          other.createdAt == this.createdAt);
}

class SpendEntriesCompanion extends UpdateCompanion<SpendEntry> {
  final Value<String> id;
  final Value<String> categoryId;
  final Value<int> amountCents;
  final Value<String> date;
  final Value<String?> note;
  final Value<String> source;
  final Value<String> status;
  final Value<String?> familyId;
  final Value<String?> memberId;
  final Value<int> createdAt;
  final Value<int> rowid;
  const SpendEntriesCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.source = const Value.absent(),
    this.status = const Value.absent(),
    this.familyId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpendEntriesCompanion.insert({
    required String id,
    required String categoryId,
    required int amountCents,
    required String date,
    this.note = const Value.absent(),
    required String source,
    required String status,
    this.familyId = const Value.absent(),
    this.memberId = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       categoryId = Value(categoryId),
       amountCents = Value(amountCents),
       date = Value(date),
       source = Value(source),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<SpendEntry> custom({
    Expression<String>? id,
    Expression<String>? categoryId,
    Expression<int>? amountCents,
    Expression<String>? date,
    Expression<String>? note,
    Expression<String>? source,
    Expression<String>? status,
    Expression<String>? familyId,
    Expression<String>? memberId,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (amountCents != null) 'amount_cents': amountCents,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
      if (source != null) 'source': source,
      if (status != null) 'status': status,
      if (familyId != null) 'family_id': familyId,
      if (memberId != null) 'member_id': memberId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpendEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? categoryId,
    Value<int>? amountCents,
    Value<String>? date,
    Value<String?>? note,
    Value<String>? source,
    Value<String>? status,
    Value<String?>? familyId,
    Value<String?>? memberId,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return SpendEntriesCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amountCents: amountCents ?? this.amountCents,
      date: date ?? this.date,
      note: note ?? this.note,
      source: source ?? this.source,
      status: status ?? this.status,
      familyId: familyId ?? this.familyId,
      memberId: memberId ?? this.memberId,
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
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpendEntriesCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('amountCents: $amountCents, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('familyId: $familyId, ')
          ..write('memberId: $memberId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DreamJarsTable extends DreamJars
    with TableInfo<$DreamJarsTable, DreamJar> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DreamJarsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetCentsMeta = const VerificationMeta(
    'targetCents',
  );
  @override
  late final GeneratedColumn<int> targetCents = GeneratedColumn<int>(
    'target_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    targetCents,
    status,
    description,
    familyId,
    memberId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dream_jars';
  @override
  VerificationContext validateIntegrity(
    Insertable<DreamJar> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_cents')) {
      context.handle(
        _targetCentsMeta,
        targetCents.isAcceptableOrUnknown(
          data['target_cents']!,
          _targetCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetCentsMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
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
  DreamJar map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DreamJar(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      targetCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_cents'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      ),
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DreamJarsTable createAlias(String alias) {
    return $DreamJarsTable(attachedDatabase, alias);
  }
}

class DreamJar extends DataClass implements Insertable<DreamJar> {
  final String id;
  final String name;
  final int targetCents;
  final String status;
  final String? description;
  final String? familyId;
  final String? memberId;
  final int createdAt;
  const DreamJar({
    required this.id,
    required this.name,
    required this.targetCents,
    required this.status,
    this.description,
    this.familyId,
    this.memberId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['target_cents'] = Variable<int>(targetCents);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || familyId != null) {
      map['family_id'] = Variable<String>(familyId);
    }
    if (!nullToAbsent || memberId != null) {
      map['member_id'] = Variable<String>(memberId);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  DreamJarsCompanion toCompanion(bool nullToAbsent) {
    return DreamJarsCompanion(
      id: Value(id),
      name: Value(name),
      targetCents: Value(targetCents),
      status: Value(status),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      familyId: familyId == null && nullToAbsent
          ? const Value.absent()
          : Value(familyId),
      memberId: memberId == null && nullToAbsent
          ? const Value.absent()
          : Value(memberId),
      createdAt: Value(createdAt),
    );
  }

  factory DreamJar.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DreamJar(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      targetCents: serializer.fromJson<int>(json['targetCents']),
      status: serializer.fromJson<String>(json['status']),
      description: serializer.fromJson<String?>(json['description']),
      familyId: serializer.fromJson<String?>(json['familyId']),
      memberId: serializer.fromJson<String?>(json['memberId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'targetCents': serializer.toJson<int>(targetCents),
      'status': serializer.toJson<String>(status),
      'description': serializer.toJson<String?>(description),
      'familyId': serializer.toJson<String?>(familyId),
      'memberId': serializer.toJson<String?>(memberId),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  DreamJar copyWith({
    String? id,
    String? name,
    int? targetCents,
    String? status,
    Value<String?> description = const Value.absent(),
    Value<String?> familyId = const Value.absent(),
    Value<String?> memberId = const Value.absent(),
    int? createdAt,
  }) => DreamJar(
    id: id ?? this.id,
    name: name ?? this.name,
    targetCents: targetCents ?? this.targetCents,
    status: status ?? this.status,
    description: description.present ? description.value : this.description,
    familyId: familyId.present ? familyId.value : this.familyId,
    memberId: memberId.present ? memberId.value : this.memberId,
    createdAt: createdAt ?? this.createdAt,
  );
  DreamJar copyWithCompanion(DreamJarsCompanion data) {
    return DreamJar(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      targetCents: data.targetCents.present
          ? data.targetCents.value
          : this.targetCents,
      status: data.status.present ? data.status.value : this.status,
      description: data.description.present
          ? data.description.value
          : this.description,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DreamJar(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetCents: $targetCents, ')
          ..write('status: $status, ')
          ..write('description: $description, ')
          ..write('familyId: $familyId, ')
          ..write('memberId: $memberId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    targetCents,
    status,
    description,
    familyId,
    memberId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DreamJar &&
          other.id == this.id &&
          other.name == this.name &&
          other.targetCents == this.targetCents &&
          other.status == this.status &&
          other.description == this.description &&
          other.familyId == this.familyId &&
          other.memberId == this.memberId &&
          other.createdAt == this.createdAt);
}

class DreamJarsCompanion extends UpdateCompanion<DreamJar> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> targetCents;
  final Value<String> status;
  final Value<String?> description;
  final Value<String?> familyId;
  final Value<String?> memberId;
  final Value<int> createdAt;
  final Value<int> rowid;
  const DreamJarsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.targetCents = const Value.absent(),
    this.status = const Value.absent(),
    this.description = const Value.absent(),
    this.familyId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DreamJarsCompanion.insert({
    required String id,
    required String name,
    required int targetCents,
    required String status,
    this.description = const Value.absent(),
    this.familyId = const Value.absent(),
    this.memberId = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       targetCents = Value(targetCents),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<DreamJar> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? targetCents,
    Expression<String>? status,
    Expression<String>? description,
    Expression<String>? familyId,
    Expression<String>? memberId,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (targetCents != null) 'target_cents': targetCents,
      if (status != null) 'status': status,
      if (description != null) 'description': description,
      if (familyId != null) 'family_id': familyId,
      if (memberId != null) 'member_id': memberId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DreamJarsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? targetCents,
    Value<String>? status,
    Value<String?>? description,
    Value<String?>? familyId,
    Value<String?>? memberId,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return DreamJarsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      targetCents: targetCents ?? this.targetCents,
      status: status ?? this.status,
      description: description ?? this.description,
      familyId: familyId ?? this.familyId,
      memberId: memberId ?? this.memberId,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (targetCents.present) {
      map['target_cents'] = Variable<int>(targetCents.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DreamJarsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetCents: $targetCents, ')
          ..write('status: $status, ')
          ..write('description: $description, ')
          ..write('familyId: $familyId, ')
          ..write('memberId: $memberId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DreamDepositsTable extends DreamDeposits
    with TableInfo<$DreamDepositsTable, DreamDeposit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DreamDepositsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jarIdMeta = const VerificationMeta('jarId');
  @override
  late final GeneratedColumn<String> jarId = GeneratedColumn<String>(
    'jar_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jarId,
    amountCents,
    date,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dream_deposits';
  @override
  VerificationContext validateIntegrity(
    Insertable<DreamDeposit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('jar_id')) {
      context.handle(
        _jarIdMeta,
        jarId.isAcceptableOrUnknown(data['jar_id']!, _jarIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jarIdMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
  DreamDeposit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DreamDeposit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      jarId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jar_id'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DreamDepositsTable createAlias(String alias) {
    return $DreamDepositsTable(attachedDatabase, alias);
  }
}

class DreamDeposit extends DataClass implements Insertable<DreamDeposit> {
  final String id;
  final String jarId;
  final int amountCents;
  final String date;
  final String? note;
  final int createdAt;
  const DreamDeposit({
    required this.id,
    required this.jarId,
    required this.amountCents,
    required this.date,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['jar_id'] = Variable<String>(jarId);
    map['amount_cents'] = Variable<int>(amountCents);
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  DreamDepositsCompanion toCompanion(bool nullToAbsent) {
    return DreamDepositsCompanion(
      id: Value(id),
      jarId: Value(jarId),
      amountCents: Value(amountCents),
      date: Value(date),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory DreamDeposit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DreamDeposit(
      id: serializer.fromJson<String>(json['id']),
      jarId: serializer.fromJson<String>(json['jarId']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      date: serializer.fromJson<String>(json['date']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'jarId': serializer.toJson<String>(jarId),
      'amountCents': serializer.toJson<int>(amountCents),
      'date': serializer.toJson<String>(date),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  DreamDeposit copyWith({
    String? id,
    String? jarId,
    int? amountCents,
    String? date,
    Value<String?> note = const Value.absent(),
    int? createdAt,
  }) => DreamDeposit(
    id: id ?? this.id,
    jarId: jarId ?? this.jarId,
    amountCents: amountCents ?? this.amountCents,
    date: date ?? this.date,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  DreamDeposit copyWithCompanion(DreamDepositsCompanion data) {
    return DreamDeposit(
      id: data.id.present ? data.id.value : this.id,
      jarId: data.jarId.present ? data.jarId.value : this.jarId,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DreamDeposit(')
          ..write('id: $id, ')
          ..write('jarId: $jarId, ')
          ..write('amountCents: $amountCents, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, jarId, amountCents, date, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DreamDeposit &&
          other.id == this.id &&
          other.jarId == this.jarId &&
          other.amountCents == this.amountCents &&
          other.date == this.date &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class DreamDepositsCompanion extends UpdateCompanion<DreamDeposit> {
  final Value<String> id;
  final Value<String> jarId;
  final Value<int> amountCents;
  final Value<String> date;
  final Value<String?> note;
  final Value<int> createdAt;
  final Value<int> rowid;
  const DreamDepositsCompanion({
    this.id = const Value.absent(),
    this.jarId = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DreamDepositsCompanion.insert({
    required String id,
    required String jarId,
    required int amountCents,
    required String date,
    this.note = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       jarId = Value(jarId),
       amountCents = Value(amountCents),
       date = Value(date),
       createdAt = Value(createdAt);
  static Insertable<DreamDeposit> custom({
    Expression<String>? id,
    Expression<String>? jarId,
    Expression<int>? amountCents,
    Expression<String>? date,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jarId != null) 'jar_id': jarId,
      if (amountCents != null) 'amount_cents': amountCents,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DreamDepositsCompanion copyWith({
    Value<String>? id,
    Value<String>? jarId,
    Value<int>? amountCents,
    Value<String>? date,
    Value<String?>? note,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return DreamDepositsCompanion(
      id: id ?? this.id,
      jarId: jarId ?? this.jarId,
      amountCents: amountCents ?? this.amountCents,
      date: date ?? this.date,
      note: note ?? this.note,
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
    if (jarId.present) {
      map['jar_id'] = Variable<String>(jarId.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DreamDepositsCompanion(')
          ..write('id: $id, ')
          ..write('jarId: $jarId, ')
          ..write('amountCents: $amountCents, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $SpendEntriesTable spendEntries = $SpendEntriesTable(this);
  late final $DreamJarsTable dreamJars = $DreamJarsTable(this);
  late final $DreamDepositsTable dreamDeposits = $DreamDepositsTable(this);
  late final CategoriesDao categoriesDao = CategoriesDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    spendEntries,
    dreamJars,
    dreamDeposits,
  ];
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String name,
      required int sortOrder,
      Value<bool> enabled,
      Value<String?> note,
      Value<bool> templateEnabled,
      Value<int?> templateDefaultAmount,
      Value<String?> templateDefaultNote,
      Value<int> templateDay,
      Value<String?> familyId,
      Value<String?> memberId,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> sortOrder,
      Value<bool> enabled,
      Value<String?> note,
      Value<bool> templateEnabled,
      Value<int?> templateDefaultAmount,
      Value<String?> templateDefaultNote,
      Value<int> templateDay,
      Value<String?> familyId,
      Value<String?> memberId,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get templateEnabled => $composableBuilder(
    column: $table.templateEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get templateDefaultAmount => $composableBuilder(
    column: $table.templateDefaultAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateDefaultNote => $composableBuilder(
    column: $table.templateDefaultNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get templateDay => $composableBuilder(
    column: $table.templateDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get templateEnabled => $composableBuilder(
    column: $table.templateEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get templateDefaultAmount => $composableBuilder(
    column: $table.templateDefaultAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateDefaultNote => $composableBuilder(
    column: $table.templateDefaultNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get templateDay => $composableBuilder(
    column: $table.templateDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get templateEnabled => $composableBuilder(
    column: $table.templateEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get templateDefaultAmount => $composableBuilder(
    column: $table.templateDefaultAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get templateDefaultNote => $composableBuilder(
    column: $table.templateDefaultNote,
    builder: (column) => column,
  );

  GeneratedColumn<int> get templateDay => $composableBuilder(
    column: $table.templateDay,
    builder: (column) => column,
  );

  GeneratedColumn<String> get familyId =>
      $composableBuilder(column: $table.familyId, builder: (column) => column);

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
          Category,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> templateEnabled = const Value.absent(),
                Value<int?> templateDefaultAmount = const Value.absent(),
                Value<String?> templateDefaultNote = const Value.absent(),
                Value<int> templateDay = const Value.absent(),
                Value<String?> familyId = const Value.absent(),
                Value<String?> memberId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                sortOrder: sortOrder,
                enabled: enabled,
                note: note,
                templateEnabled: templateEnabled,
                templateDefaultAmount: templateDefaultAmount,
                templateDefaultNote: templateDefaultNote,
                templateDay: templateDay,
                familyId: familyId,
                memberId: memberId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int sortOrder,
                Value<bool> enabled = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> templateEnabled = const Value.absent(),
                Value<int?> templateDefaultAmount = const Value.absent(),
                Value<String?> templateDefaultNote = const Value.absent(),
                Value<int> templateDay = const Value.absent(),
                Value<String?> familyId = const Value.absent(),
                Value<String?> memberId = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                sortOrder: sortOrder,
                enabled: enabled,
                note: note,
                templateEnabled: templateEnabled,
                templateDefaultAmount: templateDefaultAmount,
                templateDefaultNote: templateDefaultNote,
                templateDay: templateDay,
                familyId: familyId,
                memberId: memberId,
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

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
      Category,
      PrefetchHooks Function()
    >;
typedef $$SpendEntriesTableCreateCompanionBuilder =
    SpendEntriesCompanion Function({
      required String id,
      required String categoryId,
      required int amountCents,
      required String date,
      Value<String?> note,
      required String source,
      required String status,
      Value<String?> familyId,
      Value<String?> memberId,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$SpendEntriesTableUpdateCompanionBuilder =
    SpendEntriesCompanion Function({
      Value<String> id,
      Value<String> categoryId,
      Value<int> amountCents,
      Value<String> date,
      Value<String?> note,
      Value<String> source,
      Value<String> status,
      Value<String?> familyId,
      Value<String?> memberId,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$SpendEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SpendEntriesTable> {
  $$SpendEntriesTableFilterComposer({
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

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SpendEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SpendEntriesTable> {
  $$SpendEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SpendEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpendEntriesTable> {
  $$SpendEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get familyId =>
      $composableBuilder(column: $table.familyId, builder: (column) => column);

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SpendEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SpendEntriesTable,
          SpendEntry,
          $$SpendEntriesTableFilterComposer,
          $$SpendEntriesTableOrderingComposer,
          $$SpendEntriesTableAnnotationComposer,
          $$SpendEntriesTableCreateCompanionBuilder,
          $$SpendEntriesTableUpdateCompanionBuilder,
          (
            SpendEntry,
            BaseReferences<_$AppDatabase, $SpendEntriesTable, SpendEntry>,
          ),
          SpendEntry,
          PrefetchHooks Function()
        > {
  $$SpendEntriesTableTableManager(_$AppDatabase db, $SpendEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpendEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpendEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpendEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> familyId = const Value.absent(),
                Value<String?> memberId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SpendEntriesCompanion(
                id: id,
                categoryId: categoryId,
                amountCents: amountCents,
                date: date,
                note: note,
                source: source,
                status: status,
                familyId: familyId,
                memberId: memberId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String categoryId,
                required int amountCents,
                required String date,
                Value<String?> note = const Value.absent(),
                required String source,
                required String status,
                Value<String?> familyId = const Value.absent(),
                Value<String?> memberId = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SpendEntriesCompanion.insert(
                id: id,
                categoryId: categoryId,
                amountCents: amountCents,
                date: date,
                note: note,
                source: source,
                status: status,
                familyId: familyId,
                memberId: memberId,
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

typedef $$SpendEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SpendEntriesTable,
      SpendEntry,
      $$SpendEntriesTableFilterComposer,
      $$SpendEntriesTableOrderingComposer,
      $$SpendEntriesTableAnnotationComposer,
      $$SpendEntriesTableCreateCompanionBuilder,
      $$SpendEntriesTableUpdateCompanionBuilder,
      (
        SpendEntry,
        BaseReferences<_$AppDatabase, $SpendEntriesTable, SpendEntry>,
      ),
      SpendEntry,
      PrefetchHooks Function()
    >;
typedef $$DreamJarsTableCreateCompanionBuilder =
    DreamJarsCompanion Function({
      required String id,
      required String name,
      required int targetCents,
      required String status,
      Value<String?> description,
      Value<String?> familyId,
      Value<String?> memberId,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$DreamJarsTableUpdateCompanionBuilder =
    DreamJarsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> targetCents,
      Value<String> status,
      Value<String?> description,
      Value<String?> familyId,
      Value<String?> memberId,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$DreamJarsTableFilterComposer
    extends Composer<_$AppDatabase, $DreamJarsTable> {
  $$DreamJarsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetCents => $composableBuilder(
    column: $table.targetCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DreamJarsTableOrderingComposer
    extends Composer<_$AppDatabase, $DreamJarsTable> {
  $$DreamJarsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetCents => $composableBuilder(
    column: $table.targetCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DreamJarsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DreamJarsTable> {
  $$DreamJarsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get targetCents => $composableBuilder(
    column: $table.targetCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get familyId =>
      $composableBuilder(column: $table.familyId, builder: (column) => column);

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DreamJarsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DreamJarsTable,
          DreamJar,
          $$DreamJarsTableFilterComposer,
          $$DreamJarsTableOrderingComposer,
          $$DreamJarsTableAnnotationComposer,
          $$DreamJarsTableCreateCompanionBuilder,
          $$DreamJarsTableUpdateCompanionBuilder,
          (DreamJar, BaseReferences<_$AppDatabase, $DreamJarsTable, DreamJar>),
          DreamJar,
          PrefetchHooks Function()
        > {
  $$DreamJarsTableTableManager(_$AppDatabase db, $DreamJarsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DreamJarsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DreamJarsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DreamJarsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> targetCents = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> familyId = const Value.absent(),
                Value<String?> memberId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DreamJarsCompanion(
                id: id,
                name: name,
                targetCents: targetCents,
                status: status,
                description: description,
                familyId: familyId,
                memberId: memberId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int targetCents,
                required String status,
                Value<String?> description = const Value.absent(),
                Value<String?> familyId = const Value.absent(),
                Value<String?> memberId = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DreamJarsCompanion.insert(
                id: id,
                name: name,
                targetCents: targetCents,
                status: status,
                description: description,
                familyId: familyId,
                memberId: memberId,
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

typedef $$DreamJarsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DreamJarsTable,
      DreamJar,
      $$DreamJarsTableFilterComposer,
      $$DreamJarsTableOrderingComposer,
      $$DreamJarsTableAnnotationComposer,
      $$DreamJarsTableCreateCompanionBuilder,
      $$DreamJarsTableUpdateCompanionBuilder,
      (DreamJar, BaseReferences<_$AppDatabase, $DreamJarsTable, DreamJar>),
      DreamJar,
      PrefetchHooks Function()
    >;
typedef $$DreamDepositsTableCreateCompanionBuilder =
    DreamDepositsCompanion Function({
      required String id,
      required String jarId,
      required int amountCents,
      required String date,
      Value<String?> note,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$DreamDepositsTableUpdateCompanionBuilder =
    DreamDepositsCompanion Function({
      Value<String> id,
      Value<String> jarId,
      Value<int> amountCents,
      Value<String> date,
      Value<String?> note,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$DreamDepositsTableFilterComposer
    extends Composer<_$AppDatabase, $DreamDepositsTable> {
  $$DreamDepositsTableFilterComposer({
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

  ColumnFilters<String> get jarId => $composableBuilder(
    column: $table.jarId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DreamDepositsTableOrderingComposer
    extends Composer<_$AppDatabase, $DreamDepositsTable> {
  $$DreamDepositsTableOrderingComposer({
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

  ColumnOrderings<String> get jarId => $composableBuilder(
    column: $table.jarId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DreamDepositsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DreamDepositsTable> {
  $$DreamDepositsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get jarId =>
      $composableBuilder(column: $table.jarId, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DreamDepositsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DreamDepositsTable,
          DreamDeposit,
          $$DreamDepositsTableFilterComposer,
          $$DreamDepositsTableOrderingComposer,
          $$DreamDepositsTableAnnotationComposer,
          $$DreamDepositsTableCreateCompanionBuilder,
          $$DreamDepositsTableUpdateCompanionBuilder,
          (
            DreamDeposit,
            BaseReferences<_$AppDatabase, $DreamDepositsTable, DreamDeposit>,
          ),
          DreamDeposit,
          PrefetchHooks Function()
        > {
  $$DreamDepositsTableTableManager(_$AppDatabase db, $DreamDepositsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DreamDepositsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DreamDepositsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DreamDepositsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> jarId = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DreamDepositsCompanion(
                id: id,
                jarId: jarId,
                amountCents: amountCents,
                date: date,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String jarId,
                required int amountCents,
                required String date,
                Value<String?> note = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DreamDepositsCompanion.insert(
                id: id,
                jarId: jarId,
                amountCents: amountCents,
                date: date,
                note: note,
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

typedef $$DreamDepositsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DreamDepositsTable,
      DreamDeposit,
      $$DreamDepositsTableFilterComposer,
      $$DreamDepositsTableOrderingComposer,
      $$DreamDepositsTableAnnotationComposer,
      $$DreamDepositsTableCreateCompanionBuilder,
      $$DreamDepositsTableUpdateCompanionBuilder,
      (
        DreamDeposit,
        BaseReferences<_$AppDatabase, $DreamDepositsTable, DreamDeposit>,
      ),
      DreamDeposit,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$SpendEntriesTableTableManager get spendEntries =>
      $$SpendEntriesTableTableManager(_db, _db.spendEntries);
  $$DreamJarsTableTableManager get dreamJars =>
      $$DreamJarsTableTableManager(_db, _db.dreamJars);
  $$DreamDepositsTableTableManager get dreamDeposits =>
      $$DreamDepositsTableTableManager(_db, _db.dreamDeposits);
}
