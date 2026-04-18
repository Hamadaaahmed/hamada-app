// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedMachinesTable extends CachedMachines
    with TableInfo<$CachedMachinesTable, CachedMachine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedMachinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('🧵'));
  static const VerificationMeta _priceCentsMeta =
      const VerificationMeta('priceCents');
  @override
  late final GeneratedColumn<int> priceCents = GeneratedColumn<int>(
      'price_cents', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
      'active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, icon, priceCents, active, sortOrder, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_machines';
  @override
  VerificationContext validateIntegrity(Insertable<CachedMachine> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    if (data.containsKey('price_cents')) {
      context.handle(
          _priceCentsMeta,
          priceCents.isAcceptableOrUnknown(
              data['price_cents']!, _priceCentsMeta));
    } else if (isInserting) {
      context.missing(_priceCentsMeta);
    }
    if (data.containsKey('active')) {
      context.handle(_activeMeta,
          active.isAcceptableOrUnknown(data['active']!, _activeMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedMachine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedMachine(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon'])!,
      priceCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}price_cents'])!,
      active: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}active'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CachedMachinesTable createAlias(String alias) {
    return $CachedMachinesTable(attachedDatabase, alias);
  }
}

class CachedMachine extends DataClass implements Insertable<CachedMachine> {
  final int id;
  final String name;
  final String icon;
  final int priceCents;
  final bool active;
  final int sortOrder;
  final DateTime updatedAt;
  const CachedMachine(
      {required this.id,
      required this.name,
      required this.icon,
      required this.priceCents,
      required this.active,
      required this.sortOrder,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['price_cents'] = Variable<int>(priceCents);
    map['active'] = Variable<bool>(active);
    map['sort_order'] = Variable<int>(sortOrder);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CachedMachinesCompanion toCompanion(bool nullToAbsent) {
    return CachedMachinesCompanion(
      id: Value(id),
      name: Value(name),
      icon: Value(icon),
      priceCents: Value(priceCents),
      active: Value(active),
      sortOrder: Value(sortOrder),
      updatedAt: Value(updatedAt),
    );
  }

  factory CachedMachine.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedMachine(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      priceCents: serializer.fromJson<int>(json['priceCents']),
      active: serializer.fromJson<bool>(json['active']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'priceCents': serializer.toJson<int>(priceCents),
      'active': serializer.toJson<bool>(active),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CachedMachine copyWith(
          {int? id,
          String? name,
          String? icon,
          int? priceCents,
          bool? active,
          int? sortOrder,
          DateTime? updatedAt}) =>
      CachedMachine(
        id: id ?? this.id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        priceCents: priceCents ?? this.priceCents,
        active: active ?? this.active,
        sortOrder: sortOrder ?? this.sortOrder,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CachedMachine copyWithCompanion(CachedMachinesCompanion data) {
    return CachedMachine(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      priceCents:
          data.priceCents.present ? data.priceCents.value : this.priceCents,
      active: data.active.present ? data.active.value : this.active,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedMachine(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('priceCents: $priceCents, ')
          ..write('active: $active, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, icon, priceCents, active, sortOrder, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedMachine &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.priceCents == this.priceCents &&
          other.active == this.active &&
          other.sortOrder == this.sortOrder &&
          other.updatedAt == this.updatedAt);
}

class CachedMachinesCompanion extends UpdateCompanion<CachedMachine> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> icon;
  final Value<int> priceCents;
  final Value<bool> active;
  final Value<int> sortOrder;
  final Value<DateTime> updatedAt;
  const CachedMachinesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.priceCents = const Value.absent(),
    this.active = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CachedMachinesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.icon = const Value.absent(),
    required int priceCents,
    this.active = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime updatedAt,
  })  : name = Value(name),
        priceCents = Value(priceCents),
        updatedAt = Value(updatedAt);
  static Insertable<CachedMachine> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<int>? priceCents,
    Expression<bool>? active,
    Expression<int>? sortOrder,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (priceCents != null) 'price_cents': priceCents,
      if (active != null) 'active': active,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CachedMachinesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? icon,
      Value<int>? priceCents,
      Value<bool>? active,
      Value<int>? sortOrder,
      Value<DateTime>? updatedAt}) {
    return CachedMachinesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      priceCents: priceCents ?? this.priceCents,
      active: active ?? this.active,
      sortOrder: sortOrder ?? this.sortOrder,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (priceCents.present) {
      map['price_cents'] = Variable<int>(priceCents.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedMachinesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('priceCents: $priceCents, ')
          ..write('active: $active, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CachedAnnouncementsTable extends CachedAnnouncements
    with TableInfo<$CachedAnnouncementsTable, CachedAnnouncement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedAnnouncementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, message, isActive, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_announcements';
  @override
  VerificationContext validateIntegrity(Insertable<CachedAnnouncement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedAnnouncement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedAnnouncement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CachedAnnouncementsTable createAlias(String alias) {
    return $CachedAnnouncementsTable(attachedDatabase, alias);
  }
}

class CachedAnnouncement extends DataClass
    implements Insertable<CachedAnnouncement> {
  final int id;
  final String message;
  final bool isActive;
  final DateTime updatedAt;
  const CachedAnnouncement(
      {required this.id,
      required this.message,
      required this.isActive,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['message'] = Variable<String>(message);
    map['is_active'] = Variable<bool>(isActive);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CachedAnnouncementsCompanion toCompanion(bool nullToAbsent) {
    return CachedAnnouncementsCompanion(
      id: Value(id),
      message: Value(message),
      isActive: Value(isActive),
      updatedAt: Value(updatedAt),
    );
  }

  factory CachedAnnouncement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedAnnouncement(
      id: serializer.fromJson<int>(json['id']),
      message: serializer.fromJson<String>(json['message']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'message': serializer.toJson<String>(message),
      'isActive': serializer.toJson<bool>(isActive),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CachedAnnouncement copyWith(
          {int? id, String? message, bool? isActive, DateTime? updatedAt}) =>
      CachedAnnouncement(
        id: id ?? this.id,
        message: message ?? this.message,
        isActive: isActive ?? this.isActive,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CachedAnnouncement copyWithCompanion(CachedAnnouncementsCompanion data) {
    return CachedAnnouncement(
      id: data.id.present ? data.id.value : this.id,
      message: data.message.present ? data.message.value : this.message,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedAnnouncement(')
          ..write('id: $id, ')
          ..write('message: $message, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, message, isActive, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedAnnouncement &&
          other.id == this.id &&
          other.message == this.message &&
          other.isActive == this.isActive &&
          other.updatedAt == this.updatedAt);
}

class CachedAnnouncementsCompanion extends UpdateCompanion<CachedAnnouncement> {
  final Value<int> id;
  final Value<String> message;
  final Value<bool> isActive;
  final Value<DateTime> updatedAt;
  const CachedAnnouncementsCompanion({
    this.id = const Value.absent(),
    this.message = const Value.absent(),
    this.isActive = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CachedAnnouncementsCompanion.insert({
    this.id = const Value.absent(),
    this.message = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime updatedAt,
  }) : updatedAt = Value(updatedAt);
  static Insertable<CachedAnnouncement> custom({
    Expression<int>? id,
    Expression<String>? message,
    Expression<bool>? isActive,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (message != null) 'message': message,
      if (isActive != null) 'is_active': isActive,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CachedAnnouncementsCompanion copyWith(
      {Value<int>? id,
      Value<String>? message,
      Value<bool>? isActive,
      Value<DateTime>? updatedAt}) {
    return CachedAnnouncementsCompanion(
      id: id ?? this.id,
      message: message ?? this.message,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedAnnouncementsCompanion(')
          ..write('id: $id, ')
          ..write('message: $message, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CachedAccountSummariesTable extends CachedAccountSummaries
    with TableInfo<$CachedAccountSummariesTable, CachedAccountSummary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedAccountSummariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<int> clientId = GeneratedColumn<int>(
      'client_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _walletCentsMeta =
      const VerificationMeta('walletCents');
  @override
  late final GeneratedColumn<int> walletCents = GeneratedColumn<int>(
      'wallet_cents', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _debtCentsMeta =
      const VerificationMeta('debtCents');
  @override
  late final GeneratedColumn<int> debtCents = GeneratedColumn<int>(
      'debt_cents', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [clientId, phone, walletCents, debtCents, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_account_summaries';
  @override
  VerificationContext validateIntegrity(
      Insertable<CachedAccountSummary> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('wallet_cents')) {
      context.handle(
          _walletCentsMeta,
          walletCents.isAcceptableOrUnknown(
              data['wallet_cents']!, _walletCentsMeta));
    }
    if (data.containsKey('debt_cents')) {
      context.handle(_debtCentsMeta,
          debtCents.isAcceptableOrUnknown(data['debt_cents']!, _debtCentsMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientId};
  @override
  CachedAccountSummary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedAccountSummary(
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}client_id'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      walletCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}wallet_cents'])!,
      debtCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}debt_cents'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CachedAccountSummariesTable createAlias(String alias) {
    return $CachedAccountSummariesTable(attachedDatabase, alias);
  }
}

class CachedAccountSummary extends DataClass
    implements Insertable<CachedAccountSummary> {
  final int clientId;
  final String phone;
  final int walletCents;
  final int debtCents;
  final DateTime updatedAt;
  const CachedAccountSummary(
      {required this.clientId,
      required this.phone,
      required this.walletCents,
      required this.debtCents,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_id'] = Variable<int>(clientId);
    map['phone'] = Variable<String>(phone);
    map['wallet_cents'] = Variable<int>(walletCents);
    map['debt_cents'] = Variable<int>(debtCents);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CachedAccountSummariesCompanion toCompanion(bool nullToAbsent) {
    return CachedAccountSummariesCompanion(
      clientId: Value(clientId),
      phone: Value(phone),
      walletCents: Value(walletCents),
      debtCents: Value(debtCents),
      updatedAt: Value(updatedAt),
    );
  }

  factory CachedAccountSummary.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedAccountSummary(
      clientId: serializer.fromJson<int>(json['clientId']),
      phone: serializer.fromJson<String>(json['phone']),
      walletCents: serializer.fromJson<int>(json['walletCents']),
      debtCents: serializer.fromJson<int>(json['debtCents']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientId': serializer.toJson<int>(clientId),
      'phone': serializer.toJson<String>(phone),
      'walletCents': serializer.toJson<int>(walletCents),
      'debtCents': serializer.toJson<int>(debtCents),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CachedAccountSummary copyWith(
          {int? clientId,
          String? phone,
          int? walletCents,
          int? debtCents,
          DateTime? updatedAt}) =>
      CachedAccountSummary(
        clientId: clientId ?? this.clientId,
        phone: phone ?? this.phone,
        walletCents: walletCents ?? this.walletCents,
        debtCents: debtCents ?? this.debtCents,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CachedAccountSummary copyWithCompanion(CachedAccountSummariesCompanion data) {
    return CachedAccountSummary(
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      phone: data.phone.present ? data.phone.value : this.phone,
      walletCents:
          data.walletCents.present ? data.walletCents.value : this.walletCents,
      debtCents: data.debtCents.present ? data.debtCents.value : this.debtCents,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedAccountSummary(')
          ..write('clientId: $clientId, ')
          ..write('phone: $phone, ')
          ..write('walletCents: $walletCents, ')
          ..write('debtCents: $debtCents, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(clientId, phone, walletCents, debtCents, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedAccountSummary &&
          other.clientId == this.clientId &&
          other.phone == this.phone &&
          other.walletCents == this.walletCents &&
          other.debtCents == this.debtCents &&
          other.updatedAt == this.updatedAt);
}

class CachedAccountSummariesCompanion
    extends UpdateCompanion<CachedAccountSummary> {
  final Value<int> clientId;
  final Value<String> phone;
  final Value<int> walletCents;
  final Value<int> debtCents;
  final Value<DateTime> updatedAt;
  const CachedAccountSummariesCompanion({
    this.clientId = const Value.absent(),
    this.phone = const Value.absent(),
    this.walletCents = const Value.absent(),
    this.debtCents = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CachedAccountSummariesCompanion.insert({
    this.clientId = const Value.absent(),
    this.phone = const Value.absent(),
    this.walletCents = const Value.absent(),
    this.debtCents = const Value.absent(),
    required DateTime updatedAt,
  }) : updatedAt = Value(updatedAt);
  static Insertable<CachedAccountSummary> custom({
    Expression<int>? clientId,
    Expression<String>? phone,
    Expression<int>? walletCents,
    Expression<int>? debtCents,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (clientId != null) 'client_id': clientId,
      if (phone != null) 'phone': phone,
      if (walletCents != null) 'wallet_cents': walletCents,
      if (debtCents != null) 'debt_cents': debtCents,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CachedAccountSummariesCompanion copyWith(
      {Value<int>? clientId,
      Value<String>? phone,
      Value<int>? walletCents,
      Value<int>? debtCents,
      Value<DateTime>? updatedAt}) {
    return CachedAccountSummariesCompanion(
      clientId: clientId ?? this.clientId,
      phone: phone ?? this.phone,
      walletCents: walletCents ?? this.walletCents,
      debtCents: debtCents ?? this.debtCents,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientId.present) {
      map['client_id'] = Variable<int>(clientId.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (walletCents.present) {
      map['wallet_cents'] = Variable<int>(walletCents.value);
    }
    if (debtCents.present) {
      map['debt_cents'] = Variable<int>(debtCents.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedAccountSummariesCompanion(')
          ..write('clientId: $clientId, ')
          ..write('phone: $phone, ')
          ..write('walletCents: $walletCents, ')
          ..write('debtCents: $debtCents, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CachedAdminPostsTable extends CachedAdminPosts
    with TableInfo<$CachedAdminPostsTable, CachedAdminPost> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedAdminPostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        message,
        imageUrl,
        version,
        isActive,
        createdAt,
        updatedAt,
        cachedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_admin_posts';
  @override
  VerificationContext validateIntegrity(Insertable<CachedAdminPost> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedAdminPost map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedAdminPost(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message'])!,
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $CachedAdminPostsTable createAlias(String alias) {
    return $CachedAdminPostsTable(attachedDatabase, alias);
  }
}

class CachedAdminPost extends DataClass implements Insertable<CachedAdminPost> {
  final int id;
  final String message;
  final String imageUrl;
  final int version;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final DateTime cachedAt;
  const CachedAdminPost(
      {required this.id,
      required this.message,
      required this.imageUrl,
      required this.version,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['message'] = Variable<String>(message);
    map['image_url'] = Variable<String>(imageUrl);
    map['version'] = Variable<int>(version);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedAdminPostsCompanion toCompanion(bool nullToAbsent) {
    return CachedAdminPostsCompanion(
      id: Value(id),
      message: Value(message),
      imageUrl: Value(imageUrl),
      version: Value(version),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedAdminPost.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedAdminPost(
      id: serializer.fromJson<int>(json['id']),
      message: serializer.fromJson<String>(json['message']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      version: serializer.fromJson<int>(json['version']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'message': serializer.toJson<String>(message),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'version': serializer.toJson<int>(version),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedAdminPost copyWith(
          {int? id,
          String? message,
          String? imageUrl,
          int? version,
          bool? isActive,
          String? createdAt,
          String? updatedAt,
          DateTime? cachedAt}) =>
      CachedAdminPost(
        id: id ?? this.id,
        message: message ?? this.message,
        imageUrl: imageUrl ?? this.imageUrl,
        version: version ?? this.version,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  CachedAdminPost copyWithCompanion(CachedAdminPostsCompanion data) {
    return CachedAdminPost(
      id: data.id.present ? data.id.value : this.id,
      message: data.message.present ? data.message.value : this.message,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      version: data.version.present ? data.version.value : this.version,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedAdminPost(')
          ..write('id: $id, ')
          ..write('message: $message, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('version: $version, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, message, imageUrl, version, isActive, createdAt, updatedAt, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedAdminPost &&
          other.id == this.id &&
          other.message == this.message &&
          other.imageUrl == this.imageUrl &&
          other.version == this.version &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.cachedAt == this.cachedAt);
}

class CachedAdminPostsCompanion extends UpdateCompanion<CachedAdminPost> {
  final Value<int> id;
  final Value<String> message;
  final Value<String> imageUrl;
  final Value<int> version;
  final Value<bool> isActive;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<DateTime> cachedAt;
  const CachedAdminPostsCompanion({
    this.id = const Value.absent(),
    this.message = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.version = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  CachedAdminPostsCompanion.insert({
    this.id = const Value.absent(),
    this.message = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.version = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required DateTime cachedAt,
  }) : cachedAt = Value(cachedAt);
  static Insertable<CachedAdminPost> custom({
    Expression<int>? id,
    Expression<String>? message,
    Expression<String>? imageUrl,
    Expression<int>? version,
    Expression<bool>? isActive,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<DateTime>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (message != null) 'message': message,
      if (imageUrl != null) 'image_url': imageUrl,
      if (version != null) 'version': version,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  CachedAdminPostsCompanion copyWith(
      {Value<int>? id,
      Value<String>? message,
      Value<String>? imageUrl,
      Value<int>? version,
      Value<bool>? isActive,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<DateTime>? cachedAt}) {
    return CachedAdminPostsCompanion(
      id: id ?? this.id,
      message: message ?? this.message,
      imageUrl: imageUrl ?? this.imageUrl,
      version: version ?? this.version,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedAdminPostsCompanion(')
          ..write('id: $id, ')
          ..write('message: $message, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('version: $version, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

class $CachedClientOrdersTable extends CachedClientOrders
    with TableInfo<$CachedClientOrdersTable, CachedClientOrder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedClientOrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _totalCentsMeta =
      const VerificationMeta('totalCents');
  @override
  late final GeneratedColumn<int> totalCents = GeneratedColumn<int>(
      'total_cents', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _paidCentsMeta =
      const VerificationMeta('paidCents');
  @override
  late final GeneratedColumn<int> paidCents = GeneratedColumn<int>(
      'paid_cents', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _adminNoteMeta =
      const VerificationMeta('adminNote');
  @override
  late final GeneratedColumn<String> adminNote = GeneratedColumn<String>(
      'admin_note', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _rejectReasonMeta =
      const VerificationMeta('rejectReason');
  @override
  late final GeneratedColumn<String> rejectReason = GeneratedColumn<String>(
      'reject_reason', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _scheduledAtMeta =
      const VerificationMeta('scheduledAt');
  @override
  late final GeneratedColumn<String> scheduledAt = GeneratedColumn<String>(
      'scheduled_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<String> completedAt = GeneratedColumn<String>(
      'completed_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        status,
        totalCents,
        paidCents,
        adminNote,
        rejectReason,
        scheduledAt,
        completedAt,
        createdAt,
        cachedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_client_orders';
  @override
  VerificationContext validateIntegrity(Insertable<CachedClientOrder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('total_cents')) {
      context.handle(
          _totalCentsMeta,
          totalCents.isAcceptableOrUnknown(
              data['total_cents']!, _totalCentsMeta));
    }
    if (data.containsKey('paid_cents')) {
      context.handle(_paidCentsMeta,
          paidCents.isAcceptableOrUnknown(data['paid_cents']!, _paidCentsMeta));
    }
    if (data.containsKey('admin_note')) {
      context.handle(_adminNoteMeta,
          adminNote.isAcceptableOrUnknown(data['admin_note']!, _adminNoteMeta));
    }
    if (data.containsKey('reject_reason')) {
      context.handle(
          _rejectReasonMeta,
          rejectReason.isAcceptableOrUnknown(
              data['reject_reason']!, _rejectReasonMeta));
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
          _scheduledAtMeta,
          scheduledAt.isAcceptableOrUnknown(
              data['scheduled_at']!, _scheduledAtMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedClientOrder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedClientOrder(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      totalCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_cents'])!,
      paidCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}paid_cents'])!,
      adminNote: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}admin_note'])!,
      rejectReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reject_reason'])!,
      scheduledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scheduled_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}completed_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $CachedClientOrdersTable createAlias(String alias) {
    return $CachedClientOrdersTable(attachedDatabase, alias);
  }
}

class CachedClientOrder extends DataClass
    implements Insertable<CachedClientOrder> {
  final int id;
  final String status;
  final int totalCents;
  final int paidCents;
  final String adminNote;
  final String rejectReason;
  final String scheduledAt;
  final String completedAt;
  final String createdAt;
  final DateTime cachedAt;
  const CachedClientOrder(
      {required this.id,
      required this.status,
      required this.totalCents,
      required this.paidCents,
      required this.adminNote,
      required this.rejectReason,
      required this.scheduledAt,
      required this.completedAt,
      required this.createdAt,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['status'] = Variable<String>(status);
    map['total_cents'] = Variable<int>(totalCents);
    map['paid_cents'] = Variable<int>(paidCents);
    map['admin_note'] = Variable<String>(adminNote);
    map['reject_reason'] = Variable<String>(rejectReason);
    map['scheduled_at'] = Variable<String>(scheduledAt);
    map['completed_at'] = Variable<String>(completedAt);
    map['created_at'] = Variable<String>(createdAt);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedClientOrdersCompanion toCompanion(bool nullToAbsent) {
    return CachedClientOrdersCompanion(
      id: Value(id),
      status: Value(status),
      totalCents: Value(totalCents),
      paidCents: Value(paidCents),
      adminNote: Value(adminNote),
      rejectReason: Value(rejectReason),
      scheduledAt: Value(scheduledAt),
      completedAt: Value(completedAt),
      createdAt: Value(createdAt),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedClientOrder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedClientOrder(
      id: serializer.fromJson<int>(json['id']),
      status: serializer.fromJson<String>(json['status']),
      totalCents: serializer.fromJson<int>(json['totalCents']),
      paidCents: serializer.fromJson<int>(json['paidCents']),
      adminNote: serializer.fromJson<String>(json['adminNote']),
      rejectReason: serializer.fromJson<String>(json['rejectReason']),
      scheduledAt: serializer.fromJson<String>(json['scheduledAt']),
      completedAt: serializer.fromJson<String>(json['completedAt']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'status': serializer.toJson<String>(status),
      'totalCents': serializer.toJson<int>(totalCents),
      'paidCents': serializer.toJson<int>(paidCents),
      'adminNote': serializer.toJson<String>(adminNote),
      'rejectReason': serializer.toJson<String>(rejectReason),
      'scheduledAt': serializer.toJson<String>(scheduledAt),
      'completedAt': serializer.toJson<String>(completedAt),
      'createdAt': serializer.toJson<String>(createdAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedClientOrder copyWith(
          {int? id,
          String? status,
          int? totalCents,
          int? paidCents,
          String? adminNote,
          String? rejectReason,
          String? scheduledAt,
          String? completedAt,
          String? createdAt,
          DateTime? cachedAt}) =>
      CachedClientOrder(
        id: id ?? this.id,
        status: status ?? this.status,
        totalCents: totalCents ?? this.totalCents,
        paidCents: paidCents ?? this.paidCents,
        adminNote: adminNote ?? this.adminNote,
        rejectReason: rejectReason ?? this.rejectReason,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        completedAt: completedAt ?? this.completedAt,
        createdAt: createdAt ?? this.createdAt,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  CachedClientOrder copyWithCompanion(CachedClientOrdersCompanion data) {
    return CachedClientOrder(
      id: data.id.present ? data.id.value : this.id,
      status: data.status.present ? data.status.value : this.status,
      totalCents:
          data.totalCents.present ? data.totalCents.value : this.totalCents,
      paidCents: data.paidCents.present ? data.paidCents.value : this.paidCents,
      adminNote: data.adminNote.present ? data.adminNote.value : this.adminNote,
      rejectReason: data.rejectReason.present
          ? data.rejectReason.value
          : this.rejectReason,
      scheduledAt:
          data.scheduledAt.present ? data.scheduledAt.value : this.scheduledAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedClientOrder(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('totalCents: $totalCents, ')
          ..write('paidCents: $paidCents, ')
          ..write('adminNote: $adminNote, ')
          ..write('rejectReason: $rejectReason, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, status, totalCents, paidCents, adminNote,
      rejectReason, scheduledAt, completedAt, createdAt, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedClientOrder &&
          other.id == this.id &&
          other.status == this.status &&
          other.totalCents == this.totalCents &&
          other.paidCents == this.paidCents &&
          other.adminNote == this.adminNote &&
          other.rejectReason == this.rejectReason &&
          other.scheduledAt == this.scheduledAt &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.cachedAt == this.cachedAt);
}

class CachedClientOrdersCompanion extends UpdateCompanion<CachedClientOrder> {
  final Value<int> id;
  final Value<String> status;
  final Value<int> totalCents;
  final Value<int> paidCents;
  final Value<String> adminNote;
  final Value<String> rejectReason;
  final Value<String> scheduledAt;
  final Value<String> completedAt;
  final Value<String> createdAt;
  final Value<DateTime> cachedAt;
  const CachedClientOrdersCompanion({
    this.id = const Value.absent(),
    this.status = const Value.absent(),
    this.totalCents = const Value.absent(),
    this.paidCents = const Value.absent(),
    this.adminNote = const Value.absent(),
    this.rejectReason = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  CachedClientOrdersCompanion.insert({
    this.id = const Value.absent(),
    this.status = const Value.absent(),
    this.totalCents = const Value.absent(),
    this.paidCents = const Value.absent(),
    this.adminNote = const Value.absent(),
    this.rejectReason = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    required DateTime cachedAt,
  }) : cachedAt = Value(cachedAt);
  static Insertable<CachedClientOrder> custom({
    Expression<int>? id,
    Expression<String>? status,
    Expression<int>? totalCents,
    Expression<int>? paidCents,
    Expression<String>? adminNote,
    Expression<String>? rejectReason,
    Expression<String>? scheduledAt,
    Expression<String>? completedAt,
    Expression<String>? createdAt,
    Expression<DateTime>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (status != null) 'status': status,
      if (totalCents != null) 'total_cents': totalCents,
      if (paidCents != null) 'paid_cents': paidCents,
      if (adminNote != null) 'admin_note': adminNote,
      if (rejectReason != null) 'reject_reason': rejectReason,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  CachedClientOrdersCompanion copyWith(
      {Value<int>? id,
      Value<String>? status,
      Value<int>? totalCents,
      Value<int>? paidCents,
      Value<String>? adminNote,
      Value<String>? rejectReason,
      Value<String>? scheduledAt,
      Value<String>? completedAt,
      Value<String>? createdAt,
      Value<DateTime>? cachedAt}) {
    return CachedClientOrdersCompanion(
      id: id ?? this.id,
      status: status ?? this.status,
      totalCents: totalCents ?? this.totalCents,
      paidCents: paidCents ?? this.paidCents,
      adminNote: adminNote ?? this.adminNote,
      rejectReason: rejectReason ?? this.rejectReason,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (totalCents.present) {
      map['total_cents'] = Variable<int>(totalCents.value);
    }
    if (paidCents.present) {
      map['paid_cents'] = Variable<int>(paidCents.value);
    }
    if (adminNote.present) {
      map['admin_note'] = Variable<String>(adminNote.value);
    }
    if (rejectReason.present) {
      map['reject_reason'] = Variable<String>(rejectReason.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<String>(scheduledAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<String>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedClientOrdersCompanion(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('totalCents: $totalCents, ')
          ..write('paidCents: $paidCents, ')
          ..write('adminNote: $adminNote, ')
          ..write('rejectReason: $rejectReason, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

class $CachedClientOrderDetailsTable extends CachedClientOrderDetails
    with TableInfo<$CachedClientOrderDetailsTable, CachedClientOrderDetail> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedClientOrderDetailsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _orderIdMeta =
      const VerificationMeta('orderId');
  @override
  late final GeneratedColumn<int> orderId = GeneratedColumn<int>(
      'order_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _orderJsonMeta =
      const VerificationMeta('orderJson');
  @override
  late final GeneratedColumn<String> orderJson = GeneratedColumn<String>(
      'order_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _itemsJsonMeta =
      const VerificationMeta('itemsJson');
  @override
  late final GeneratedColumn<String> itemsJson = GeneratedColumn<String>(
      'items_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [orderId, orderJson, itemsJson, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_client_order_details';
  @override
  VerificationContext validateIntegrity(
      Insertable<CachedClientOrderDetail> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('order_id')) {
      context.handle(_orderIdMeta,
          orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta));
    }
    if (data.containsKey('order_json')) {
      context.handle(_orderJsonMeta,
          orderJson.isAcceptableOrUnknown(data['order_json']!, _orderJsonMeta));
    }
    if (data.containsKey('items_json')) {
      context.handle(_itemsJsonMeta,
          itemsJson.isAcceptableOrUnknown(data['items_json']!, _itemsJsonMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {orderId};
  @override
  CachedClientOrderDetail map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedClientOrderDetail(
      orderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_id'])!,
      orderJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}order_json'])!,
      itemsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}items_json'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $CachedClientOrderDetailsTable createAlias(String alias) {
    return $CachedClientOrderDetailsTable(attachedDatabase, alias);
  }
}

class CachedClientOrderDetail extends DataClass
    implements Insertable<CachedClientOrderDetail> {
  final int orderId;
  final String orderJson;
  final String itemsJson;
  final DateTime cachedAt;
  const CachedClientOrderDetail(
      {required this.orderId,
      required this.orderJson,
      required this.itemsJson,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['order_id'] = Variable<int>(orderId);
    map['order_json'] = Variable<String>(orderJson);
    map['items_json'] = Variable<String>(itemsJson);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedClientOrderDetailsCompanion toCompanion(bool nullToAbsent) {
    return CachedClientOrderDetailsCompanion(
      orderId: Value(orderId),
      orderJson: Value(orderJson),
      itemsJson: Value(itemsJson),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedClientOrderDetail.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedClientOrderDetail(
      orderId: serializer.fromJson<int>(json['orderId']),
      orderJson: serializer.fromJson<String>(json['orderJson']),
      itemsJson: serializer.fromJson<String>(json['itemsJson']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'orderId': serializer.toJson<int>(orderId),
      'orderJson': serializer.toJson<String>(orderJson),
      'itemsJson': serializer.toJson<String>(itemsJson),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedClientOrderDetail copyWith(
          {int? orderId,
          String? orderJson,
          String? itemsJson,
          DateTime? cachedAt}) =>
      CachedClientOrderDetail(
        orderId: orderId ?? this.orderId,
        orderJson: orderJson ?? this.orderJson,
        itemsJson: itemsJson ?? this.itemsJson,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  CachedClientOrderDetail copyWithCompanion(
      CachedClientOrderDetailsCompanion data) {
    return CachedClientOrderDetail(
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      orderJson: data.orderJson.present ? data.orderJson.value : this.orderJson,
      itemsJson: data.itemsJson.present ? data.itemsJson.value : this.itemsJson,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedClientOrderDetail(')
          ..write('orderId: $orderId, ')
          ..write('orderJson: $orderJson, ')
          ..write('itemsJson: $itemsJson, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(orderId, orderJson, itemsJson, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedClientOrderDetail &&
          other.orderId == this.orderId &&
          other.orderJson == this.orderJson &&
          other.itemsJson == this.itemsJson &&
          other.cachedAt == this.cachedAt);
}

class CachedClientOrderDetailsCompanion
    extends UpdateCompanion<CachedClientOrderDetail> {
  final Value<int> orderId;
  final Value<String> orderJson;
  final Value<String> itemsJson;
  final Value<DateTime> cachedAt;
  const CachedClientOrderDetailsCompanion({
    this.orderId = const Value.absent(),
    this.orderJson = const Value.absent(),
    this.itemsJson = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  CachedClientOrderDetailsCompanion.insert({
    this.orderId = const Value.absent(),
    this.orderJson = const Value.absent(),
    this.itemsJson = const Value.absent(),
    required DateTime cachedAt,
  }) : cachedAt = Value(cachedAt);
  static Insertable<CachedClientOrderDetail> custom({
    Expression<int>? orderId,
    Expression<String>? orderJson,
    Expression<String>? itemsJson,
    Expression<DateTime>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (orderId != null) 'order_id': orderId,
      if (orderJson != null) 'order_json': orderJson,
      if (itemsJson != null) 'items_json': itemsJson,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  CachedClientOrderDetailsCompanion copyWith(
      {Value<int>? orderId,
      Value<String>? orderJson,
      Value<String>? itemsJson,
      Value<DateTime>? cachedAt}) {
    return CachedClientOrderDetailsCompanion(
      orderId: orderId ?? this.orderId,
      orderJson: orderJson ?? this.orderJson,
      itemsJson: itemsJson ?? this.itemsJson,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (orderId.present) {
      map['order_id'] = Variable<int>(orderId.value);
    }
    if (orderJson.present) {
      map['order_json'] = Variable<String>(orderJson.value);
    }
    if (itemsJson.present) {
      map['items_json'] = Variable<String>(itemsJson.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedClientOrderDetailsCompanion(')
          ..write('orderId: $orderId, ')
          ..write('orderJson: $orderJson, ')
          ..write('itemsJson: $itemsJson, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

class $CachedAdminOrdersTable extends CachedAdminOrders
    with TableInfo<$CachedAdminOrdersTable, CachedAdminOrder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedAdminOrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<int> clientId = GeneratedColumn<int>(
      'client_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
      'lat', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
      'lng', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _accuracyMMeta =
      const VerificationMeta('accuracyM');
  @override
  late final GeneratedColumn<double> accuracyM = GeneratedColumn<double>(
      'accuracy_m', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _totalCentsMeta =
      const VerificationMeta('totalCents');
  @override
  late final GeneratedColumn<int> totalCents = GeneratedColumn<int>(
      'total_cents', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _paidCentsMeta =
      const VerificationMeta('paidCents');
  @override
  late final GeneratedColumn<int> paidCents = GeneratedColumn<int>(
      'paid_cents', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _adminNoteMeta =
      const VerificationMeta('adminNote');
  @override
  late final GeneratedColumn<String> adminNote = GeneratedColumn<String>(
      'admin_note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _rejectReasonMeta =
      const VerificationMeta('rejectReason');
  @override
  late final GeneratedColumn<String> rejectReason = GeneratedColumn<String>(
      'reject_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _scheduledAtMeta =
      const VerificationMeta('scheduledAt');
  @override
  late final GeneratedColumn<String> scheduledAt = GeneratedColumn<String>(
      'scheduled_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<String> completedAt = GeneratedColumn<String>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        clientId,
        email,
        phone,
        lat,
        lng,
        accuracyM,
        status,
        totalCents,
        paidCents,
        adminNote,
        rejectReason,
        scheduledAt,
        completedAt,
        createdAt,
        cachedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_admin_orders';
  @override
  VerificationContext validateIntegrity(Insertable<CachedAdminOrder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('lat')) {
      context.handle(
          _latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    }
    if (data.containsKey('lng')) {
      context.handle(
          _lngMeta, lng.isAcceptableOrUnknown(data['lng']!, _lngMeta));
    }
    if (data.containsKey('accuracy_m')) {
      context.handle(_accuracyMMeta,
          accuracyM.isAcceptableOrUnknown(data['accuracy_m']!, _accuracyMMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('total_cents')) {
      context.handle(
          _totalCentsMeta,
          totalCents.isAcceptableOrUnknown(
              data['total_cents']!, _totalCentsMeta));
    }
    if (data.containsKey('paid_cents')) {
      context.handle(_paidCentsMeta,
          paidCents.isAcceptableOrUnknown(data['paid_cents']!, _paidCentsMeta));
    }
    if (data.containsKey('admin_note')) {
      context.handle(_adminNoteMeta,
          adminNote.isAcceptableOrUnknown(data['admin_note']!, _adminNoteMeta));
    }
    if (data.containsKey('reject_reason')) {
      context.handle(
          _rejectReasonMeta,
          rejectReason.isAcceptableOrUnknown(
              data['reject_reason']!, _rejectReasonMeta));
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
          _scheduledAtMeta,
          scheduledAt.isAcceptableOrUnknown(
              data['scheduled_at']!, _scheduledAtMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedAdminOrder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedAdminOrder(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}client_id'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      lat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lat']),
      lng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lng']),
      accuracyM: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}accuracy_m']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      totalCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_cents'])!,
      paidCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}paid_cents'])!,
      adminNote: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}admin_note']),
      rejectReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reject_reason']),
      scheduledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scheduled_at']),
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}completed_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at']),
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $CachedAdminOrdersTable createAlias(String alias) {
    return $CachedAdminOrdersTable(attachedDatabase, alias);
  }
}

class CachedAdminOrder extends DataClass
    implements Insertable<CachedAdminOrder> {
  final int id;
  final int clientId;
  final String email;
  final String phone;
  final double? lat;
  final double? lng;
  final double? accuracyM;
  final String status;
  final int totalCents;
  final int paidCents;
  final String? adminNote;
  final String? rejectReason;
  final String? scheduledAt;
  final String? completedAt;
  final String? createdAt;
  final DateTime cachedAt;
  const CachedAdminOrder(
      {required this.id,
      required this.clientId,
      required this.email,
      required this.phone,
      this.lat,
      this.lng,
      this.accuracyM,
      required this.status,
      required this.totalCents,
      required this.paidCents,
      this.adminNote,
      this.rejectReason,
      this.scheduledAt,
      this.completedAt,
      this.createdAt,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['client_id'] = Variable<int>(clientId);
    map['email'] = Variable<String>(email);
    map['phone'] = Variable<String>(phone);
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lng != null) {
      map['lng'] = Variable<double>(lng);
    }
    if (!nullToAbsent || accuracyM != null) {
      map['accuracy_m'] = Variable<double>(accuracyM);
    }
    map['status'] = Variable<String>(status);
    map['total_cents'] = Variable<int>(totalCents);
    map['paid_cents'] = Variable<int>(paidCents);
    if (!nullToAbsent || adminNote != null) {
      map['admin_note'] = Variable<String>(adminNote);
    }
    if (!nullToAbsent || rejectReason != null) {
      map['reject_reason'] = Variable<String>(rejectReason);
    }
    if (!nullToAbsent || scheduledAt != null) {
      map['scheduled_at'] = Variable<String>(scheduledAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<String>(completedAt);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedAdminOrdersCompanion toCompanion(bool nullToAbsent) {
    return CachedAdminOrdersCompanion(
      id: Value(id),
      clientId: Value(clientId),
      email: Value(email),
      phone: Value(phone),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lng: lng == null && nullToAbsent ? const Value.absent() : Value(lng),
      accuracyM: accuracyM == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracyM),
      status: Value(status),
      totalCents: Value(totalCents),
      paidCents: Value(paidCents),
      adminNote: adminNote == null && nullToAbsent
          ? const Value.absent()
          : Value(adminNote),
      rejectReason: rejectReason == null && nullToAbsent
          ? const Value.absent()
          : Value(rejectReason),
      scheduledAt: scheduledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedAdminOrder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedAdminOrder(
      id: serializer.fromJson<int>(json['id']),
      clientId: serializer.fromJson<int>(json['clientId']),
      email: serializer.fromJson<String>(json['email']),
      phone: serializer.fromJson<String>(json['phone']),
      lat: serializer.fromJson<double?>(json['lat']),
      lng: serializer.fromJson<double?>(json['lng']),
      accuracyM: serializer.fromJson<double?>(json['accuracyM']),
      status: serializer.fromJson<String>(json['status']),
      totalCents: serializer.fromJson<int>(json['totalCents']),
      paidCents: serializer.fromJson<int>(json['paidCents']),
      adminNote: serializer.fromJson<String?>(json['adminNote']),
      rejectReason: serializer.fromJson<String?>(json['rejectReason']),
      scheduledAt: serializer.fromJson<String?>(json['scheduledAt']),
      completedAt: serializer.fromJson<String?>(json['completedAt']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clientId': serializer.toJson<int>(clientId),
      'email': serializer.toJson<String>(email),
      'phone': serializer.toJson<String>(phone),
      'lat': serializer.toJson<double?>(lat),
      'lng': serializer.toJson<double?>(lng),
      'accuracyM': serializer.toJson<double?>(accuracyM),
      'status': serializer.toJson<String>(status),
      'totalCents': serializer.toJson<int>(totalCents),
      'paidCents': serializer.toJson<int>(paidCents),
      'adminNote': serializer.toJson<String?>(adminNote),
      'rejectReason': serializer.toJson<String?>(rejectReason),
      'scheduledAt': serializer.toJson<String?>(scheduledAt),
      'completedAt': serializer.toJson<String?>(completedAt),
      'createdAt': serializer.toJson<String?>(createdAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedAdminOrder copyWith(
          {int? id,
          int? clientId,
          String? email,
          String? phone,
          Value<double?> lat = const Value.absent(),
          Value<double?> lng = const Value.absent(),
          Value<double?> accuracyM = const Value.absent(),
          String? status,
          int? totalCents,
          int? paidCents,
          Value<String?> adminNote = const Value.absent(),
          Value<String?> rejectReason = const Value.absent(),
          Value<String?> scheduledAt = const Value.absent(),
          Value<String?> completedAt = const Value.absent(),
          Value<String?> createdAt = const Value.absent(),
          DateTime? cachedAt}) =>
      CachedAdminOrder(
        id: id ?? this.id,
        clientId: clientId ?? this.clientId,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        lat: lat.present ? lat.value : this.lat,
        lng: lng.present ? lng.value : this.lng,
        accuracyM: accuracyM.present ? accuracyM.value : this.accuracyM,
        status: status ?? this.status,
        totalCents: totalCents ?? this.totalCents,
        paidCents: paidCents ?? this.paidCents,
        adminNote: adminNote.present ? adminNote.value : this.adminNote,
        rejectReason:
            rejectReason.present ? rejectReason.value : this.rejectReason,
        scheduledAt: scheduledAt.present ? scheduledAt.value : this.scheduledAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  CachedAdminOrder copyWithCompanion(CachedAdminOrdersCompanion data) {
    return CachedAdminOrder(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      accuracyM: data.accuracyM.present ? data.accuracyM.value : this.accuracyM,
      status: data.status.present ? data.status.value : this.status,
      totalCents:
          data.totalCents.present ? data.totalCents.value : this.totalCents,
      paidCents: data.paidCents.present ? data.paidCents.value : this.paidCents,
      adminNote: data.adminNote.present ? data.adminNote.value : this.adminNote,
      rejectReason: data.rejectReason.present
          ? data.rejectReason.value
          : this.rejectReason,
      scheduledAt:
          data.scheduledAt.present ? data.scheduledAt.value : this.scheduledAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedAdminOrder(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('status: $status, ')
          ..write('totalCents: $totalCents, ')
          ..write('paidCents: $paidCents, ')
          ..write('adminNote: $adminNote, ')
          ..write('rejectReason: $rejectReason, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      clientId,
      email,
      phone,
      lat,
      lng,
      accuracyM,
      status,
      totalCents,
      paidCents,
      adminNote,
      rejectReason,
      scheduledAt,
      completedAt,
      createdAt,
      cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedAdminOrder &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.accuracyM == this.accuracyM &&
          other.status == this.status &&
          other.totalCents == this.totalCents &&
          other.paidCents == this.paidCents &&
          other.adminNote == this.adminNote &&
          other.rejectReason == this.rejectReason &&
          other.scheduledAt == this.scheduledAt &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.cachedAt == this.cachedAt);
}

class CachedAdminOrdersCompanion extends UpdateCompanion<CachedAdminOrder> {
  final Value<int> id;
  final Value<int> clientId;
  final Value<String> email;
  final Value<String> phone;
  final Value<double?> lat;
  final Value<double?> lng;
  final Value<double?> accuracyM;
  final Value<String> status;
  final Value<int> totalCents;
  final Value<int> paidCents;
  final Value<String?> adminNote;
  final Value<String?> rejectReason;
  final Value<String?> scheduledAt;
  final Value<String?> completedAt;
  final Value<String?> createdAt;
  final Value<DateTime> cachedAt;
  const CachedAdminOrdersCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.accuracyM = const Value.absent(),
    this.status = const Value.absent(),
    this.totalCents = const Value.absent(),
    this.paidCents = const Value.absent(),
    this.adminNote = const Value.absent(),
    this.rejectReason = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  CachedAdminOrdersCompanion.insert({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.accuracyM = const Value.absent(),
    this.status = const Value.absent(),
    this.totalCents = const Value.absent(),
    this.paidCents = const Value.absent(),
    this.adminNote = const Value.absent(),
    this.rejectReason = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    required DateTime cachedAt,
  }) : cachedAt = Value(cachedAt);
  static Insertable<CachedAdminOrder> custom({
    Expression<int>? id,
    Expression<int>? clientId,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<double>? accuracyM,
    Expression<String>? status,
    Expression<int>? totalCents,
    Expression<int>? paidCents,
    Expression<String>? adminNote,
    Expression<String>? rejectReason,
    Expression<String>? scheduledAt,
    Expression<String>? completedAt,
    Expression<String>? createdAt,
    Expression<DateTime>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (accuracyM != null) 'accuracy_m': accuracyM,
      if (status != null) 'status': status,
      if (totalCents != null) 'total_cents': totalCents,
      if (paidCents != null) 'paid_cents': paidCents,
      if (adminNote != null) 'admin_note': adminNote,
      if (rejectReason != null) 'reject_reason': rejectReason,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  CachedAdminOrdersCompanion copyWith(
      {Value<int>? id,
      Value<int>? clientId,
      Value<String>? email,
      Value<String>? phone,
      Value<double?>? lat,
      Value<double?>? lng,
      Value<double?>? accuracyM,
      Value<String>? status,
      Value<int>? totalCents,
      Value<int>? paidCents,
      Value<String?>? adminNote,
      Value<String?>? rejectReason,
      Value<String?>? scheduledAt,
      Value<String?>? completedAt,
      Value<String?>? createdAt,
      Value<DateTime>? cachedAt}) {
    return CachedAdminOrdersCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      accuracyM: accuracyM ?? this.accuracyM,
      status: status ?? this.status,
      totalCents: totalCents ?? this.totalCents,
      paidCents: paidCents ?? this.paidCents,
      adminNote: adminNote ?? this.adminNote,
      rejectReason: rejectReason ?? this.rejectReason,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<int>(clientId.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (accuracyM.present) {
      map['accuracy_m'] = Variable<double>(accuracyM.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (totalCents.present) {
      map['total_cents'] = Variable<int>(totalCents.value);
    }
    if (paidCents.present) {
      map['paid_cents'] = Variable<int>(paidCents.value);
    }
    if (adminNote.present) {
      map['admin_note'] = Variable<String>(adminNote.value);
    }
    if (rejectReason.present) {
      map['reject_reason'] = Variable<String>(rejectReason.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<String>(scheduledAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<String>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedAdminOrdersCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('status: $status, ')
          ..write('totalCents: $totalCents, ')
          ..write('paidCents: $paidCents, ')
          ..write('adminNote: $adminNote, ')
          ..write('rejectReason: $rejectReason, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

class $CachedAdminClientsTable extends CachedAdminClients
    with TableInfo<$CachedAdminClientsTable, CachedAdminClient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedAdminClientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _blockedMeta =
      const VerificationMeta('blocked');
  @override
  late final GeneratedColumn<bool> blocked = GeneratedColumn<bool>(
      'blocked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("blocked" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, email, phone, blocked, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_admin_clients';
  @override
  VerificationContext validateIntegrity(Insertable<CachedAdminClient> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('blocked')) {
      context.handle(_blockedMeta,
          blocked.isAcceptableOrUnknown(data['blocked']!, _blockedMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedAdminClient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedAdminClient(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      blocked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}blocked'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $CachedAdminClientsTable createAlias(String alias) {
    return $CachedAdminClientsTable(attachedDatabase, alias);
  }
}

class CachedAdminClient extends DataClass
    implements Insertable<CachedAdminClient> {
  final int id;
  final String email;
  final String phone;
  final bool blocked;
  final DateTime cachedAt;
  const CachedAdminClient(
      {required this.id,
      required this.email,
      required this.phone,
      required this.blocked,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['email'] = Variable<String>(email);
    map['phone'] = Variable<String>(phone);
    map['blocked'] = Variable<bool>(blocked);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedAdminClientsCompanion toCompanion(bool nullToAbsent) {
    return CachedAdminClientsCompanion(
      id: Value(id),
      email: Value(email),
      phone: Value(phone),
      blocked: Value(blocked),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedAdminClient.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedAdminClient(
      id: serializer.fromJson<int>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      phone: serializer.fromJson<String>(json['phone']),
      blocked: serializer.fromJson<bool>(json['blocked']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'email': serializer.toJson<String>(email),
      'phone': serializer.toJson<String>(phone),
      'blocked': serializer.toJson<bool>(blocked),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedAdminClient copyWith(
          {int? id,
          String? email,
          String? phone,
          bool? blocked,
          DateTime? cachedAt}) =>
      CachedAdminClient(
        id: id ?? this.id,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        blocked: blocked ?? this.blocked,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  CachedAdminClient copyWithCompanion(CachedAdminClientsCompanion data) {
    return CachedAdminClient(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      blocked: data.blocked.present ? data.blocked.value : this.blocked,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedAdminClient(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('blocked: $blocked, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, email, phone, blocked, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedAdminClient &&
          other.id == this.id &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.blocked == this.blocked &&
          other.cachedAt == this.cachedAt);
}

class CachedAdminClientsCompanion extends UpdateCompanion<CachedAdminClient> {
  final Value<int> id;
  final Value<String> email;
  final Value<String> phone;
  final Value<bool> blocked;
  final Value<DateTime> cachedAt;
  const CachedAdminClientsCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.blocked = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  CachedAdminClientsCompanion.insert({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.blocked = const Value.absent(),
    required DateTime cachedAt,
  }) : cachedAt = Value(cachedAt);
  static Insertable<CachedAdminClient> custom({
    Expression<int>? id,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<bool>? blocked,
    Expression<DateTime>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (blocked != null) 'blocked': blocked,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  CachedAdminClientsCompanion copyWith(
      {Value<int>? id,
      Value<String>? email,
      Value<String>? phone,
      Value<bool>? blocked,
      Value<DateTime>? cachedAt}) {
    return CachedAdminClientsCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      blocked: blocked ?? this.blocked,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (blocked.present) {
      map['blocked'] = Variable<bool>(blocked.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedAdminClientsCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('blocked: $blocked, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

class $CachedAdminClientAccountsTable extends CachedAdminClientAccounts
    with TableInfo<$CachedAdminClientAccountsTable, CachedAdminClientAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedAdminClientAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<int> clientId = GeneratedColumn<int>(
      'client_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _clientJsonMeta =
      const VerificationMeta('clientJson');
  @override
  late final GeneratedColumn<String> clientJson = GeneratedColumn<String>(
      'client_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _walletCentsMeta =
      const VerificationMeta('walletCents');
  @override
  late final GeneratedColumn<int> walletCents = GeneratedColumn<int>(
      'wallet_cents', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _debtCentsMeta =
      const VerificationMeta('debtCents');
  @override
  late final GeneratedColumn<int> debtCents = GeneratedColumn<int>(
      'debt_cents', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _netCentsMeta =
      const VerificationMeta('netCents');
  @override
  late final GeneratedColumn<int> netCents = GeneratedColumn<int>(
      'net_cents', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _entriesJsonMeta =
      const VerificationMeta('entriesJson');
  @override
  late final GeneratedColumn<String> entriesJson = GeneratedColumn<String>(
      'entries_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        clientId,
        clientJson,
        walletCents,
        debtCents,
        netCents,
        entriesJson,
        cachedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_admin_client_accounts';
  @override
  VerificationContext validateIntegrity(
      Insertable<CachedAdminClientAccount> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    }
    if (data.containsKey('client_json')) {
      context.handle(
          _clientJsonMeta,
          clientJson.isAcceptableOrUnknown(
              data['client_json']!, _clientJsonMeta));
    }
    if (data.containsKey('wallet_cents')) {
      context.handle(
          _walletCentsMeta,
          walletCents.isAcceptableOrUnknown(
              data['wallet_cents']!, _walletCentsMeta));
    }
    if (data.containsKey('debt_cents')) {
      context.handle(_debtCentsMeta,
          debtCents.isAcceptableOrUnknown(data['debt_cents']!, _debtCentsMeta));
    }
    if (data.containsKey('net_cents')) {
      context.handle(_netCentsMeta,
          netCents.isAcceptableOrUnknown(data['net_cents']!, _netCentsMeta));
    }
    if (data.containsKey('entries_json')) {
      context.handle(
          _entriesJsonMeta,
          entriesJson.isAcceptableOrUnknown(
              data['entries_json']!, _entriesJsonMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientId};
  @override
  CachedAdminClientAccount map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedAdminClientAccount(
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}client_id'])!,
      clientJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_json'])!,
      walletCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}wallet_cents'])!,
      debtCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}debt_cents'])!,
      netCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}net_cents'])!,
      entriesJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entries_json'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $CachedAdminClientAccountsTable createAlias(String alias) {
    return $CachedAdminClientAccountsTable(attachedDatabase, alias);
  }
}

class CachedAdminClientAccount extends DataClass
    implements Insertable<CachedAdminClientAccount> {
  final int clientId;
  final String clientJson;
  final int walletCents;
  final int debtCents;
  final int netCents;
  final String entriesJson;
  final DateTime cachedAt;
  const CachedAdminClientAccount(
      {required this.clientId,
      required this.clientJson,
      required this.walletCents,
      required this.debtCents,
      required this.netCents,
      required this.entriesJson,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_id'] = Variable<int>(clientId);
    map['client_json'] = Variable<String>(clientJson);
    map['wallet_cents'] = Variable<int>(walletCents);
    map['debt_cents'] = Variable<int>(debtCents);
    map['net_cents'] = Variable<int>(netCents);
    map['entries_json'] = Variable<String>(entriesJson);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedAdminClientAccountsCompanion toCompanion(bool nullToAbsent) {
    return CachedAdminClientAccountsCompanion(
      clientId: Value(clientId),
      clientJson: Value(clientJson),
      walletCents: Value(walletCents),
      debtCents: Value(debtCents),
      netCents: Value(netCents),
      entriesJson: Value(entriesJson),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedAdminClientAccount.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedAdminClientAccount(
      clientId: serializer.fromJson<int>(json['clientId']),
      clientJson: serializer.fromJson<String>(json['clientJson']),
      walletCents: serializer.fromJson<int>(json['walletCents']),
      debtCents: serializer.fromJson<int>(json['debtCents']),
      netCents: serializer.fromJson<int>(json['netCents']),
      entriesJson: serializer.fromJson<String>(json['entriesJson']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientId': serializer.toJson<int>(clientId),
      'clientJson': serializer.toJson<String>(clientJson),
      'walletCents': serializer.toJson<int>(walletCents),
      'debtCents': serializer.toJson<int>(debtCents),
      'netCents': serializer.toJson<int>(netCents),
      'entriesJson': serializer.toJson<String>(entriesJson),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedAdminClientAccount copyWith(
          {int? clientId,
          String? clientJson,
          int? walletCents,
          int? debtCents,
          int? netCents,
          String? entriesJson,
          DateTime? cachedAt}) =>
      CachedAdminClientAccount(
        clientId: clientId ?? this.clientId,
        clientJson: clientJson ?? this.clientJson,
        walletCents: walletCents ?? this.walletCents,
        debtCents: debtCents ?? this.debtCents,
        netCents: netCents ?? this.netCents,
        entriesJson: entriesJson ?? this.entriesJson,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  CachedAdminClientAccount copyWithCompanion(
      CachedAdminClientAccountsCompanion data) {
    return CachedAdminClientAccount(
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      clientJson:
          data.clientJson.present ? data.clientJson.value : this.clientJson,
      walletCents:
          data.walletCents.present ? data.walletCents.value : this.walletCents,
      debtCents: data.debtCents.present ? data.debtCents.value : this.debtCents,
      netCents: data.netCents.present ? data.netCents.value : this.netCents,
      entriesJson:
          data.entriesJson.present ? data.entriesJson.value : this.entriesJson,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedAdminClientAccount(')
          ..write('clientId: $clientId, ')
          ..write('clientJson: $clientJson, ')
          ..write('walletCents: $walletCents, ')
          ..write('debtCents: $debtCents, ')
          ..write('netCents: $netCents, ')
          ..write('entriesJson: $entriesJson, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(clientId, clientJson, walletCents, debtCents,
      netCents, entriesJson, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedAdminClientAccount &&
          other.clientId == this.clientId &&
          other.clientJson == this.clientJson &&
          other.walletCents == this.walletCents &&
          other.debtCents == this.debtCents &&
          other.netCents == this.netCents &&
          other.entriesJson == this.entriesJson &&
          other.cachedAt == this.cachedAt);
}

class CachedAdminClientAccountsCompanion
    extends UpdateCompanion<CachedAdminClientAccount> {
  final Value<int> clientId;
  final Value<String> clientJson;
  final Value<int> walletCents;
  final Value<int> debtCents;
  final Value<int> netCents;
  final Value<String> entriesJson;
  final Value<DateTime> cachedAt;
  const CachedAdminClientAccountsCompanion({
    this.clientId = const Value.absent(),
    this.clientJson = const Value.absent(),
    this.walletCents = const Value.absent(),
    this.debtCents = const Value.absent(),
    this.netCents = const Value.absent(),
    this.entriesJson = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  CachedAdminClientAccountsCompanion.insert({
    this.clientId = const Value.absent(),
    this.clientJson = const Value.absent(),
    this.walletCents = const Value.absent(),
    this.debtCents = const Value.absent(),
    this.netCents = const Value.absent(),
    this.entriesJson = const Value.absent(),
    required DateTime cachedAt,
  }) : cachedAt = Value(cachedAt);
  static Insertable<CachedAdminClientAccount> custom({
    Expression<int>? clientId,
    Expression<String>? clientJson,
    Expression<int>? walletCents,
    Expression<int>? debtCents,
    Expression<int>? netCents,
    Expression<String>? entriesJson,
    Expression<DateTime>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (clientId != null) 'client_id': clientId,
      if (clientJson != null) 'client_json': clientJson,
      if (walletCents != null) 'wallet_cents': walletCents,
      if (debtCents != null) 'debt_cents': debtCents,
      if (netCents != null) 'net_cents': netCents,
      if (entriesJson != null) 'entries_json': entriesJson,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  CachedAdminClientAccountsCompanion copyWith(
      {Value<int>? clientId,
      Value<String>? clientJson,
      Value<int>? walletCents,
      Value<int>? debtCents,
      Value<int>? netCents,
      Value<String>? entriesJson,
      Value<DateTime>? cachedAt}) {
    return CachedAdminClientAccountsCompanion(
      clientId: clientId ?? this.clientId,
      clientJson: clientJson ?? this.clientJson,
      walletCents: walletCents ?? this.walletCents,
      debtCents: debtCents ?? this.debtCents,
      netCents: netCents ?? this.netCents,
      entriesJson: entriesJson ?? this.entriesJson,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientId.present) {
      map['client_id'] = Variable<int>(clientId.value);
    }
    if (clientJson.present) {
      map['client_json'] = Variable<String>(clientJson.value);
    }
    if (walletCents.present) {
      map['wallet_cents'] = Variable<int>(walletCents.value);
    }
    if (debtCents.present) {
      map['debt_cents'] = Variable<int>(debtCents.value);
    }
    if (netCents.present) {
      map['net_cents'] = Variable<int>(netCents.value);
    }
    if (entriesJson.present) {
      map['entries_json'] = Variable<String>(entriesJson.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedAdminClientAccountsCompanion(')
          ..write('clientId: $clientId, ')
          ..write('clientJson: $clientJson, ')
          ..write('walletCents: $walletCents, ')
          ..write('debtCents: $debtCents, ')
          ..write('netCents: $netCents, ')
          ..write('entriesJson: $entriesJson, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedMachinesTable cachedMachines = $CachedMachinesTable(this);
  late final $CachedAnnouncementsTable cachedAnnouncements =
      $CachedAnnouncementsTable(this);
  late final $CachedAccountSummariesTable cachedAccountSummaries =
      $CachedAccountSummariesTable(this);
  late final $CachedAdminPostsTable cachedAdminPosts =
      $CachedAdminPostsTable(this);
  late final $CachedClientOrdersTable cachedClientOrders =
      $CachedClientOrdersTable(this);
  late final $CachedClientOrderDetailsTable cachedClientOrderDetails =
      $CachedClientOrderDetailsTable(this);
  late final $CachedAdminOrdersTable cachedAdminOrders =
      $CachedAdminOrdersTable(this);
  late final $CachedAdminClientsTable cachedAdminClients =
      $CachedAdminClientsTable(this);
  late final $CachedAdminClientAccountsTable cachedAdminClientAccounts =
      $CachedAdminClientAccountsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        cachedMachines,
        cachedAnnouncements,
        cachedAccountSummaries,
        cachedAdminPosts,
        cachedClientOrders,
        cachedClientOrderDetails,
        cachedAdminOrders,
        cachedAdminClients,
        cachedAdminClientAccounts
      ];
}

typedef $$CachedMachinesTableCreateCompanionBuilder = CachedMachinesCompanion
    Function({
  Value<int> id,
  required String name,
  Value<String> icon,
  required int priceCents,
  Value<bool> active,
  Value<int> sortOrder,
  required DateTime updatedAt,
});
typedef $$CachedMachinesTableUpdateCompanionBuilder = CachedMachinesCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String> icon,
  Value<int> priceCents,
  Value<bool> active,
  Value<int> sortOrder,
  Value<DateTime> updatedAt,
});

class $$CachedMachinesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedMachinesTable> {
  $$CachedMachinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priceCents => $composableBuilder(
      column: $table.priceCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get active => $composableBuilder(
      column: $table.active, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CachedMachinesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedMachinesTable> {
  $$CachedMachinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priceCents => $composableBuilder(
      column: $table.priceCents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get active => $composableBuilder(
      column: $table.active, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedMachinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedMachinesTable> {
  $$CachedMachinesTableAnnotationComposer({
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

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get priceCents => $composableBuilder(
      column: $table.priceCents, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CachedMachinesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedMachinesTable,
    CachedMachine,
    $$CachedMachinesTableFilterComposer,
    $$CachedMachinesTableOrderingComposer,
    $$CachedMachinesTableAnnotationComposer,
    $$CachedMachinesTableCreateCompanionBuilder,
    $$CachedMachinesTableUpdateCompanionBuilder,
    (
      CachedMachine,
      BaseReferences<_$AppDatabase, $CachedMachinesTable, CachedMachine>
    ),
    CachedMachine,
    PrefetchHooks Function()> {
  $$CachedMachinesTableTableManager(
      _$AppDatabase db, $CachedMachinesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedMachinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedMachinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedMachinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> icon = const Value.absent(),
            Value<int> priceCents = const Value.absent(),
            Value<bool> active = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              CachedMachinesCompanion(
            id: id,
            name: name,
            icon: icon,
            priceCents: priceCents,
            active: active,
            sortOrder: sortOrder,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String> icon = const Value.absent(),
            required int priceCents,
            Value<bool> active = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            required DateTime updatedAt,
          }) =>
              CachedMachinesCompanion.insert(
            id: id,
            name: name,
            icon: icon,
            priceCents: priceCents,
            active: active,
            sortOrder: sortOrder,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedMachinesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedMachinesTable,
    CachedMachine,
    $$CachedMachinesTableFilterComposer,
    $$CachedMachinesTableOrderingComposer,
    $$CachedMachinesTableAnnotationComposer,
    $$CachedMachinesTableCreateCompanionBuilder,
    $$CachedMachinesTableUpdateCompanionBuilder,
    (
      CachedMachine,
      BaseReferences<_$AppDatabase, $CachedMachinesTable, CachedMachine>
    ),
    CachedMachine,
    PrefetchHooks Function()>;
typedef $$CachedAnnouncementsTableCreateCompanionBuilder
    = CachedAnnouncementsCompanion Function({
  Value<int> id,
  Value<String> message,
  Value<bool> isActive,
  required DateTime updatedAt,
});
typedef $$CachedAnnouncementsTableUpdateCompanionBuilder
    = CachedAnnouncementsCompanion Function({
  Value<int> id,
  Value<String> message,
  Value<bool> isActive,
  Value<DateTime> updatedAt,
});

class $$CachedAnnouncementsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedAnnouncementsTable> {
  $$CachedAnnouncementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CachedAnnouncementsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedAnnouncementsTable> {
  $$CachedAnnouncementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedAnnouncementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedAnnouncementsTable> {
  $$CachedAnnouncementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CachedAnnouncementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedAnnouncementsTable,
    CachedAnnouncement,
    $$CachedAnnouncementsTableFilterComposer,
    $$CachedAnnouncementsTableOrderingComposer,
    $$CachedAnnouncementsTableAnnotationComposer,
    $$CachedAnnouncementsTableCreateCompanionBuilder,
    $$CachedAnnouncementsTableUpdateCompanionBuilder,
    (
      CachedAnnouncement,
      BaseReferences<_$AppDatabase, $CachedAnnouncementsTable,
          CachedAnnouncement>
    ),
    CachedAnnouncement,
    PrefetchHooks Function()> {
  $$CachedAnnouncementsTableTableManager(
      _$AppDatabase db, $CachedAnnouncementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedAnnouncementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedAnnouncementsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedAnnouncementsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> message = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              CachedAnnouncementsCompanion(
            id: id,
            message: message,
            isActive: isActive,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> message = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            required DateTime updatedAt,
          }) =>
              CachedAnnouncementsCompanion.insert(
            id: id,
            message: message,
            isActive: isActive,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedAnnouncementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedAnnouncementsTable,
    CachedAnnouncement,
    $$CachedAnnouncementsTableFilterComposer,
    $$CachedAnnouncementsTableOrderingComposer,
    $$CachedAnnouncementsTableAnnotationComposer,
    $$CachedAnnouncementsTableCreateCompanionBuilder,
    $$CachedAnnouncementsTableUpdateCompanionBuilder,
    (
      CachedAnnouncement,
      BaseReferences<_$AppDatabase, $CachedAnnouncementsTable,
          CachedAnnouncement>
    ),
    CachedAnnouncement,
    PrefetchHooks Function()>;
typedef $$CachedAccountSummariesTableCreateCompanionBuilder
    = CachedAccountSummariesCompanion Function({
  Value<int> clientId,
  Value<String> phone,
  Value<int> walletCents,
  Value<int> debtCents,
  required DateTime updatedAt,
});
typedef $$CachedAccountSummariesTableUpdateCompanionBuilder
    = CachedAccountSummariesCompanion Function({
  Value<int> clientId,
  Value<String> phone,
  Value<int> walletCents,
  Value<int> debtCents,
  Value<DateTime> updatedAt,
});

class $$CachedAccountSummariesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedAccountSummariesTable> {
  $$CachedAccountSummariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get walletCents => $composableBuilder(
      column: $table.walletCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get debtCents => $composableBuilder(
      column: $table.debtCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CachedAccountSummariesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedAccountSummariesTable> {
  $$CachedAccountSummariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get walletCents => $composableBuilder(
      column: $table.walletCents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get debtCents => $composableBuilder(
      column: $table.debtCents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedAccountSummariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedAccountSummariesTable> {
  $$CachedAccountSummariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<int> get walletCents => $composableBuilder(
      column: $table.walletCents, builder: (column) => column);

  GeneratedColumn<int> get debtCents =>
      $composableBuilder(column: $table.debtCents, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CachedAccountSummariesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedAccountSummariesTable,
    CachedAccountSummary,
    $$CachedAccountSummariesTableFilterComposer,
    $$CachedAccountSummariesTableOrderingComposer,
    $$CachedAccountSummariesTableAnnotationComposer,
    $$CachedAccountSummariesTableCreateCompanionBuilder,
    $$CachedAccountSummariesTableUpdateCompanionBuilder,
    (
      CachedAccountSummary,
      BaseReferences<_$AppDatabase, $CachedAccountSummariesTable,
          CachedAccountSummary>
    ),
    CachedAccountSummary,
    PrefetchHooks Function()> {
  $$CachedAccountSummariesTableTableManager(
      _$AppDatabase db, $CachedAccountSummariesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedAccountSummariesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedAccountSummariesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedAccountSummariesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> clientId = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<int> walletCents = const Value.absent(),
            Value<int> debtCents = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              CachedAccountSummariesCompanion(
            clientId: clientId,
            phone: phone,
            walletCents: walletCents,
            debtCents: debtCents,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> clientId = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<int> walletCents = const Value.absent(),
            Value<int> debtCents = const Value.absent(),
            required DateTime updatedAt,
          }) =>
              CachedAccountSummariesCompanion.insert(
            clientId: clientId,
            phone: phone,
            walletCents: walletCents,
            debtCents: debtCents,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedAccountSummariesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $CachedAccountSummariesTable,
        CachedAccountSummary,
        $$CachedAccountSummariesTableFilterComposer,
        $$CachedAccountSummariesTableOrderingComposer,
        $$CachedAccountSummariesTableAnnotationComposer,
        $$CachedAccountSummariesTableCreateCompanionBuilder,
        $$CachedAccountSummariesTableUpdateCompanionBuilder,
        (
          CachedAccountSummary,
          BaseReferences<_$AppDatabase, $CachedAccountSummariesTable,
              CachedAccountSummary>
        ),
        CachedAccountSummary,
        PrefetchHooks Function()>;
typedef $$CachedAdminPostsTableCreateCompanionBuilder
    = CachedAdminPostsCompanion Function({
  Value<int> id,
  Value<String> message,
  Value<String> imageUrl,
  Value<int> version,
  Value<bool> isActive,
  Value<String> createdAt,
  Value<String> updatedAt,
  required DateTime cachedAt,
});
typedef $$CachedAdminPostsTableUpdateCompanionBuilder
    = CachedAdminPostsCompanion Function({
  Value<int> id,
  Value<String> message,
  Value<String> imageUrl,
  Value<int> version,
  Value<bool> isActive,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<DateTime> cachedAt,
});

class $$CachedAdminPostsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedAdminPostsTable> {
  $$CachedAdminPostsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$CachedAdminPostsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedAdminPostsTable> {
  $$CachedAdminPostsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedAdminPostsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedAdminPostsTable> {
  $$CachedAdminPostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedAdminPostsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedAdminPostsTable,
    CachedAdminPost,
    $$CachedAdminPostsTableFilterComposer,
    $$CachedAdminPostsTableOrderingComposer,
    $$CachedAdminPostsTableAnnotationComposer,
    $$CachedAdminPostsTableCreateCompanionBuilder,
    $$CachedAdminPostsTableUpdateCompanionBuilder,
    (
      CachedAdminPost,
      BaseReferences<_$AppDatabase, $CachedAdminPostsTable, CachedAdminPost>
    ),
    CachedAdminPost,
    PrefetchHooks Function()> {
  $$CachedAdminPostsTableTableManager(
      _$AppDatabase db, $CachedAdminPostsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedAdminPostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedAdminPostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedAdminPostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> message = const Value.absent(),
            Value<String> imageUrl = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
          }) =>
              CachedAdminPostsCompanion(
            id: id,
            message: message,
            imageUrl: imageUrl,
            version: version,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            cachedAt: cachedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> message = const Value.absent(),
            Value<String> imageUrl = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            required DateTime cachedAt,
          }) =>
              CachedAdminPostsCompanion.insert(
            id: id,
            message: message,
            imageUrl: imageUrl,
            version: version,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            cachedAt: cachedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedAdminPostsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedAdminPostsTable,
    CachedAdminPost,
    $$CachedAdminPostsTableFilterComposer,
    $$CachedAdminPostsTableOrderingComposer,
    $$CachedAdminPostsTableAnnotationComposer,
    $$CachedAdminPostsTableCreateCompanionBuilder,
    $$CachedAdminPostsTableUpdateCompanionBuilder,
    (
      CachedAdminPost,
      BaseReferences<_$AppDatabase, $CachedAdminPostsTable, CachedAdminPost>
    ),
    CachedAdminPost,
    PrefetchHooks Function()>;
typedef $$CachedClientOrdersTableCreateCompanionBuilder
    = CachedClientOrdersCompanion Function({
  Value<int> id,
  Value<String> status,
  Value<int> totalCents,
  Value<int> paidCents,
  Value<String> adminNote,
  Value<String> rejectReason,
  Value<String> scheduledAt,
  Value<String> completedAt,
  Value<String> createdAt,
  required DateTime cachedAt,
});
typedef $$CachedClientOrdersTableUpdateCompanionBuilder
    = CachedClientOrdersCompanion Function({
  Value<int> id,
  Value<String> status,
  Value<int> totalCents,
  Value<int> paidCents,
  Value<String> adminNote,
  Value<String> rejectReason,
  Value<String> scheduledAt,
  Value<String> completedAt,
  Value<String> createdAt,
  Value<DateTime> cachedAt,
});

class $$CachedClientOrdersTableFilterComposer
    extends Composer<_$AppDatabase, $CachedClientOrdersTable> {
  $$CachedClientOrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalCents => $composableBuilder(
      column: $table.totalCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get paidCents => $composableBuilder(
      column: $table.paidCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get adminNote => $composableBuilder(
      column: $table.adminNote, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rejectReason => $composableBuilder(
      column: $table.rejectReason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$CachedClientOrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedClientOrdersTable> {
  $$CachedClientOrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalCents => $composableBuilder(
      column: $table.totalCents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get paidCents => $composableBuilder(
      column: $table.paidCents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get adminNote => $composableBuilder(
      column: $table.adminNote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rejectReason => $composableBuilder(
      column: $table.rejectReason,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedClientOrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedClientOrdersTable> {
  $$CachedClientOrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get totalCents => $composableBuilder(
      column: $table.totalCents, builder: (column) => column);

  GeneratedColumn<int> get paidCents =>
      $composableBuilder(column: $table.paidCents, builder: (column) => column);

  GeneratedColumn<String> get adminNote =>
      $composableBuilder(column: $table.adminNote, builder: (column) => column);

  GeneratedColumn<String> get rejectReason => $composableBuilder(
      column: $table.rejectReason, builder: (column) => column);

  GeneratedColumn<String> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => column);

  GeneratedColumn<String> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedClientOrdersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedClientOrdersTable,
    CachedClientOrder,
    $$CachedClientOrdersTableFilterComposer,
    $$CachedClientOrdersTableOrderingComposer,
    $$CachedClientOrdersTableAnnotationComposer,
    $$CachedClientOrdersTableCreateCompanionBuilder,
    $$CachedClientOrdersTableUpdateCompanionBuilder,
    (
      CachedClientOrder,
      BaseReferences<_$AppDatabase, $CachedClientOrdersTable, CachedClientOrder>
    ),
    CachedClientOrder,
    PrefetchHooks Function()> {
  $$CachedClientOrdersTableTableManager(
      _$AppDatabase db, $CachedClientOrdersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedClientOrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedClientOrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedClientOrdersTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> totalCents = const Value.absent(),
            Value<int> paidCents = const Value.absent(),
            Value<String> adminNote = const Value.absent(),
            Value<String> rejectReason = const Value.absent(),
            Value<String> scheduledAt = const Value.absent(),
            Value<String> completedAt = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
          }) =>
              CachedClientOrdersCompanion(
            id: id,
            status: status,
            totalCents: totalCents,
            paidCents: paidCents,
            adminNote: adminNote,
            rejectReason: rejectReason,
            scheduledAt: scheduledAt,
            completedAt: completedAt,
            createdAt: createdAt,
            cachedAt: cachedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> totalCents = const Value.absent(),
            Value<int> paidCents = const Value.absent(),
            Value<String> adminNote = const Value.absent(),
            Value<String> rejectReason = const Value.absent(),
            Value<String> scheduledAt = const Value.absent(),
            Value<String> completedAt = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            required DateTime cachedAt,
          }) =>
              CachedClientOrdersCompanion.insert(
            id: id,
            status: status,
            totalCents: totalCents,
            paidCents: paidCents,
            adminNote: adminNote,
            rejectReason: rejectReason,
            scheduledAt: scheduledAt,
            completedAt: completedAt,
            createdAt: createdAt,
            cachedAt: cachedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedClientOrdersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedClientOrdersTable,
    CachedClientOrder,
    $$CachedClientOrdersTableFilterComposer,
    $$CachedClientOrdersTableOrderingComposer,
    $$CachedClientOrdersTableAnnotationComposer,
    $$CachedClientOrdersTableCreateCompanionBuilder,
    $$CachedClientOrdersTableUpdateCompanionBuilder,
    (
      CachedClientOrder,
      BaseReferences<_$AppDatabase, $CachedClientOrdersTable, CachedClientOrder>
    ),
    CachedClientOrder,
    PrefetchHooks Function()>;
typedef $$CachedClientOrderDetailsTableCreateCompanionBuilder
    = CachedClientOrderDetailsCompanion Function({
  Value<int> orderId,
  Value<String> orderJson,
  Value<String> itemsJson,
  required DateTime cachedAt,
});
typedef $$CachedClientOrderDetailsTableUpdateCompanionBuilder
    = CachedClientOrderDetailsCompanion Function({
  Value<int> orderId,
  Value<String> orderJson,
  Value<String> itemsJson,
  Value<DateTime> cachedAt,
});

class $$CachedClientOrderDetailsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedClientOrderDetailsTable> {
  $$CachedClientOrderDetailsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get orderJson => $composableBuilder(
      column: $table.orderJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemsJson => $composableBuilder(
      column: $table.itemsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$CachedClientOrderDetailsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedClientOrderDetailsTable> {
  $$CachedClientOrderDetailsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get orderJson => $composableBuilder(
      column: $table.orderJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemsJson => $composableBuilder(
      column: $table.itemsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedClientOrderDetailsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedClientOrderDetailsTable> {
  $$CachedClientOrderDetailsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<String> get orderJson =>
      $composableBuilder(column: $table.orderJson, builder: (column) => column);

  GeneratedColumn<String> get itemsJson =>
      $composableBuilder(column: $table.itemsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedClientOrderDetailsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedClientOrderDetailsTable,
    CachedClientOrderDetail,
    $$CachedClientOrderDetailsTableFilterComposer,
    $$CachedClientOrderDetailsTableOrderingComposer,
    $$CachedClientOrderDetailsTableAnnotationComposer,
    $$CachedClientOrderDetailsTableCreateCompanionBuilder,
    $$CachedClientOrderDetailsTableUpdateCompanionBuilder,
    (
      CachedClientOrderDetail,
      BaseReferences<_$AppDatabase, $CachedClientOrderDetailsTable,
          CachedClientOrderDetail>
    ),
    CachedClientOrderDetail,
    PrefetchHooks Function()> {
  $$CachedClientOrderDetailsTableTableManager(
      _$AppDatabase db, $CachedClientOrderDetailsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedClientOrderDetailsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedClientOrderDetailsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedClientOrderDetailsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> orderId = const Value.absent(),
            Value<String> orderJson = const Value.absent(),
            Value<String> itemsJson = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
          }) =>
              CachedClientOrderDetailsCompanion(
            orderId: orderId,
            orderJson: orderJson,
            itemsJson: itemsJson,
            cachedAt: cachedAt,
          ),
          createCompanionCallback: ({
            Value<int> orderId = const Value.absent(),
            Value<String> orderJson = const Value.absent(),
            Value<String> itemsJson = const Value.absent(),
            required DateTime cachedAt,
          }) =>
              CachedClientOrderDetailsCompanion.insert(
            orderId: orderId,
            orderJson: orderJson,
            itemsJson: itemsJson,
            cachedAt: cachedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedClientOrderDetailsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $CachedClientOrderDetailsTable,
        CachedClientOrderDetail,
        $$CachedClientOrderDetailsTableFilterComposer,
        $$CachedClientOrderDetailsTableOrderingComposer,
        $$CachedClientOrderDetailsTableAnnotationComposer,
        $$CachedClientOrderDetailsTableCreateCompanionBuilder,
        $$CachedClientOrderDetailsTableUpdateCompanionBuilder,
        (
          CachedClientOrderDetail,
          BaseReferences<_$AppDatabase, $CachedClientOrderDetailsTable,
              CachedClientOrderDetail>
        ),
        CachedClientOrderDetail,
        PrefetchHooks Function()>;
typedef $$CachedAdminOrdersTableCreateCompanionBuilder
    = CachedAdminOrdersCompanion Function({
  Value<int> id,
  Value<int> clientId,
  Value<String> email,
  Value<String> phone,
  Value<double?> lat,
  Value<double?> lng,
  Value<double?> accuracyM,
  Value<String> status,
  Value<int> totalCents,
  Value<int> paidCents,
  Value<String?> adminNote,
  Value<String?> rejectReason,
  Value<String?> scheduledAt,
  Value<String?> completedAt,
  Value<String?> createdAt,
  required DateTime cachedAt,
});
typedef $$CachedAdminOrdersTableUpdateCompanionBuilder
    = CachedAdminOrdersCompanion Function({
  Value<int> id,
  Value<int> clientId,
  Value<String> email,
  Value<String> phone,
  Value<double?> lat,
  Value<double?> lng,
  Value<double?> accuracyM,
  Value<String> status,
  Value<int> totalCents,
  Value<int> paidCents,
  Value<String?> adminNote,
  Value<String?> rejectReason,
  Value<String?> scheduledAt,
  Value<String?> completedAt,
  Value<String?> createdAt,
  Value<DateTime> cachedAt,
});

class $$CachedAdminOrdersTableFilterComposer
    extends Composer<_$AppDatabase, $CachedAdminOrdersTable> {
  $$CachedAdminOrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lng => $composableBuilder(
      column: $table.lng, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get accuracyM => $composableBuilder(
      column: $table.accuracyM, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalCents => $composableBuilder(
      column: $table.totalCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get paidCents => $composableBuilder(
      column: $table.paidCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get adminNote => $composableBuilder(
      column: $table.adminNote, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rejectReason => $composableBuilder(
      column: $table.rejectReason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$CachedAdminOrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedAdminOrdersTable> {
  $$CachedAdminOrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lng => $composableBuilder(
      column: $table.lng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get accuracyM => $composableBuilder(
      column: $table.accuracyM, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalCents => $composableBuilder(
      column: $table.totalCents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get paidCents => $composableBuilder(
      column: $table.paidCents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get adminNote => $composableBuilder(
      column: $table.adminNote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rejectReason => $composableBuilder(
      column: $table.rejectReason,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedAdminOrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedAdminOrdersTable> {
  $$CachedAdminOrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<double> get accuracyM =>
      $composableBuilder(column: $table.accuracyM, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get totalCents => $composableBuilder(
      column: $table.totalCents, builder: (column) => column);

  GeneratedColumn<int> get paidCents =>
      $composableBuilder(column: $table.paidCents, builder: (column) => column);

  GeneratedColumn<String> get adminNote =>
      $composableBuilder(column: $table.adminNote, builder: (column) => column);

  GeneratedColumn<String> get rejectReason => $composableBuilder(
      column: $table.rejectReason, builder: (column) => column);

  GeneratedColumn<String> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => column);

  GeneratedColumn<String> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedAdminOrdersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedAdminOrdersTable,
    CachedAdminOrder,
    $$CachedAdminOrdersTableFilterComposer,
    $$CachedAdminOrdersTableOrderingComposer,
    $$CachedAdminOrdersTableAnnotationComposer,
    $$CachedAdminOrdersTableCreateCompanionBuilder,
    $$CachedAdminOrdersTableUpdateCompanionBuilder,
    (
      CachedAdminOrder,
      BaseReferences<_$AppDatabase, $CachedAdminOrdersTable, CachedAdminOrder>
    ),
    CachedAdminOrder,
    PrefetchHooks Function()> {
  $$CachedAdminOrdersTableTableManager(
      _$AppDatabase db, $CachedAdminOrdersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedAdminOrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedAdminOrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedAdminOrdersTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> clientId = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<double?> lat = const Value.absent(),
            Value<double?> lng = const Value.absent(),
            Value<double?> accuracyM = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> totalCents = const Value.absent(),
            Value<int> paidCents = const Value.absent(),
            Value<String?> adminNote = const Value.absent(),
            Value<String?> rejectReason = const Value.absent(),
            Value<String?> scheduledAt = const Value.absent(),
            Value<String?> completedAt = const Value.absent(),
            Value<String?> createdAt = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
          }) =>
              CachedAdminOrdersCompanion(
            id: id,
            clientId: clientId,
            email: email,
            phone: phone,
            lat: lat,
            lng: lng,
            accuracyM: accuracyM,
            status: status,
            totalCents: totalCents,
            paidCents: paidCents,
            adminNote: adminNote,
            rejectReason: rejectReason,
            scheduledAt: scheduledAt,
            completedAt: completedAt,
            createdAt: createdAt,
            cachedAt: cachedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> clientId = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<double?> lat = const Value.absent(),
            Value<double?> lng = const Value.absent(),
            Value<double?> accuracyM = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> totalCents = const Value.absent(),
            Value<int> paidCents = const Value.absent(),
            Value<String?> adminNote = const Value.absent(),
            Value<String?> rejectReason = const Value.absent(),
            Value<String?> scheduledAt = const Value.absent(),
            Value<String?> completedAt = const Value.absent(),
            Value<String?> createdAt = const Value.absent(),
            required DateTime cachedAt,
          }) =>
              CachedAdminOrdersCompanion.insert(
            id: id,
            clientId: clientId,
            email: email,
            phone: phone,
            lat: lat,
            lng: lng,
            accuracyM: accuracyM,
            status: status,
            totalCents: totalCents,
            paidCents: paidCents,
            adminNote: adminNote,
            rejectReason: rejectReason,
            scheduledAt: scheduledAt,
            completedAt: completedAt,
            createdAt: createdAt,
            cachedAt: cachedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedAdminOrdersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedAdminOrdersTable,
    CachedAdminOrder,
    $$CachedAdminOrdersTableFilterComposer,
    $$CachedAdminOrdersTableOrderingComposer,
    $$CachedAdminOrdersTableAnnotationComposer,
    $$CachedAdminOrdersTableCreateCompanionBuilder,
    $$CachedAdminOrdersTableUpdateCompanionBuilder,
    (
      CachedAdminOrder,
      BaseReferences<_$AppDatabase, $CachedAdminOrdersTable, CachedAdminOrder>
    ),
    CachedAdminOrder,
    PrefetchHooks Function()>;
typedef $$CachedAdminClientsTableCreateCompanionBuilder
    = CachedAdminClientsCompanion Function({
  Value<int> id,
  Value<String> email,
  Value<String> phone,
  Value<bool> blocked,
  required DateTime cachedAt,
});
typedef $$CachedAdminClientsTableUpdateCompanionBuilder
    = CachedAdminClientsCompanion Function({
  Value<int> id,
  Value<String> email,
  Value<String> phone,
  Value<bool> blocked,
  Value<DateTime> cachedAt,
});

class $$CachedAdminClientsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedAdminClientsTable> {
  $$CachedAdminClientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get blocked => $composableBuilder(
      column: $table.blocked, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$CachedAdminClientsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedAdminClientsTable> {
  $$CachedAdminClientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get blocked => $composableBuilder(
      column: $table.blocked, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedAdminClientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedAdminClientsTable> {
  $$CachedAdminClientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<bool> get blocked =>
      $composableBuilder(column: $table.blocked, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedAdminClientsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedAdminClientsTable,
    CachedAdminClient,
    $$CachedAdminClientsTableFilterComposer,
    $$CachedAdminClientsTableOrderingComposer,
    $$CachedAdminClientsTableAnnotationComposer,
    $$CachedAdminClientsTableCreateCompanionBuilder,
    $$CachedAdminClientsTableUpdateCompanionBuilder,
    (
      CachedAdminClient,
      BaseReferences<_$AppDatabase, $CachedAdminClientsTable, CachedAdminClient>
    ),
    CachedAdminClient,
    PrefetchHooks Function()> {
  $$CachedAdminClientsTableTableManager(
      _$AppDatabase db, $CachedAdminClientsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedAdminClientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedAdminClientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedAdminClientsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<bool> blocked = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
          }) =>
              CachedAdminClientsCompanion(
            id: id,
            email: email,
            phone: phone,
            blocked: blocked,
            cachedAt: cachedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<bool> blocked = const Value.absent(),
            required DateTime cachedAt,
          }) =>
              CachedAdminClientsCompanion.insert(
            id: id,
            email: email,
            phone: phone,
            blocked: blocked,
            cachedAt: cachedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedAdminClientsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedAdminClientsTable,
    CachedAdminClient,
    $$CachedAdminClientsTableFilterComposer,
    $$CachedAdminClientsTableOrderingComposer,
    $$CachedAdminClientsTableAnnotationComposer,
    $$CachedAdminClientsTableCreateCompanionBuilder,
    $$CachedAdminClientsTableUpdateCompanionBuilder,
    (
      CachedAdminClient,
      BaseReferences<_$AppDatabase, $CachedAdminClientsTable, CachedAdminClient>
    ),
    CachedAdminClient,
    PrefetchHooks Function()>;
typedef $$CachedAdminClientAccountsTableCreateCompanionBuilder
    = CachedAdminClientAccountsCompanion Function({
  Value<int> clientId,
  Value<String> clientJson,
  Value<int> walletCents,
  Value<int> debtCents,
  Value<int> netCents,
  Value<String> entriesJson,
  required DateTime cachedAt,
});
typedef $$CachedAdminClientAccountsTableUpdateCompanionBuilder
    = CachedAdminClientAccountsCompanion Function({
  Value<int> clientId,
  Value<String> clientJson,
  Value<int> walletCents,
  Value<int> debtCents,
  Value<int> netCents,
  Value<String> entriesJson,
  Value<DateTime> cachedAt,
});

class $$CachedAdminClientAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedAdminClientAccountsTable> {
  $$CachedAdminClientAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientJson => $composableBuilder(
      column: $table.clientJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get walletCents => $composableBuilder(
      column: $table.walletCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get debtCents => $composableBuilder(
      column: $table.debtCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get netCents => $composableBuilder(
      column: $table.netCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entriesJson => $composableBuilder(
      column: $table.entriesJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$CachedAdminClientAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedAdminClientAccountsTable> {
  $$CachedAdminClientAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientJson => $composableBuilder(
      column: $table.clientJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get walletCents => $composableBuilder(
      column: $table.walletCents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get debtCents => $composableBuilder(
      column: $table.debtCents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get netCents => $composableBuilder(
      column: $table.netCents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entriesJson => $composableBuilder(
      column: $table.entriesJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedAdminClientAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedAdminClientAccountsTable> {
  $$CachedAdminClientAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get clientJson => $composableBuilder(
      column: $table.clientJson, builder: (column) => column);

  GeneratedColumn<int> get walletCents => $composableBuilder(
      column: $table.walletCents, builder: (column) => column);

  GeneratedColumn<int> get debtCents =>
      $composableBuilder(column: $table.debtCents, builder: (column) => column);

  GeneratedColumn<int> get netCents =>
      $composableBuilder(column: $table.netCents, builder: (column) => column);

  GeneratedColumn<String> get entriesJson => $composableBuilder(
      column: $table.entriesJson, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedAdminClientAccountsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedAdminClientAccountsTable,
    CachedAdminClientAccount,
    $$CachedAdminClientAccountsTableFilterComposer,
    $$CachedAdminClientAccountsTableOrderingComposer,
    $$CachedAdminClientAccountsTableAnnotationComposer,
    $$CachedAdminClientAccountsTableCreateCompanionBuilder,
    $$CachedAdminClientAccountsTableUpdateCompanionBuilder,
    (
      CachedAdminClientAccount,
      BaseReferences<_$AppDatabase, $CachedAdminClientAccountsTable,
          CachedAdminClientAccount>
    ),
    CachedAdminClientAccount,
    PrefetchHooks Function()> {
  $$CachedAdminClientAccountsTableTableManager(
      _$AppDatabase db, $CachedAdminClientAccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedAdminClientAccountsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedAdminClientAccountsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedAdminClientAccountsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> clientId = const Value.absent(),
            Value<String> clientJson = const Value.absent(),
            Value<int> walletCents = const Value.absent(),
            Value<int> debtCents = const Value.absent(),
            Value<int> netCents = const Value.absent(),
            Value<String> entriesJson = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
          }) =>
              CachedAdminClientAccountsCompanion(
            clientId: clientId,
            clientJson: clientJson,
            walletCents: walletCents,
            debtCents: debtCents,
            netCents: netCents,
            entriesJson: entriesJson,
            cachedAt: cachedAt,
          ),
          createCompanionCallback: ({
            Value<int> clientId = const Value.absent(),
            Value<String> clientJson = const Value.absent(),
            Value<int> walletCents = const Value.absent(),
            Value<int> debtCents = const Value.absent(),
            Value<int> netCents = const Value.absent(),
            Value<String> entriesJson = const Value.absent(),
            required DateTime cachedAt,
          }) =>
              CachedAdminClientAccountsCompanion.insert(
            clientId: clientId,
            clientJson: clientJson,
            walletCents: walletCents,
            debtCents: debtCents,
            netCents: netCents,
            entriesJson: entriesJson,
            cachedAt: cachedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedAdminClientAccountsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $CachedAdminClientAccountsTable,
        CachedAdminClientAccount,
        $$CachedAdminClientAccountsTableFilterComposer,
        $$CachedAdminClientAccountsTableOrderingComposer,
        $$CachedAdminClientAccountsTableAnnotationComposer,
        $$CachedAdminClientAccountsTableCreateCompanionBuilder,
        $$CachedAdminClientAccountsTableUpdateCompanionBuilder,
        (
          CachedAdminClientAccount,
          BaseReferences<_$AppDatabase, $CachedAdminClientAccountsTable,
              CachedAdminClientAccount>
        ),
        CachedAdminClientAccount,
        PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedMachinesTableTableManager get cachedMachines =>
      $$CachedMachinesTableTableManager(_db, _db.cachedMachines);
  $$CachedAnnouncementsTableTableManager get cachedAnnouncements =>
      $$CachedAnnouncementsTableTableManager(_db, _db.cachedAnnouncements);
  $$CachedAccountSummariesTableTableManager get cachedAccountSummaries =>
      $$CachedAccountSummariesTableTableManager(
          _db, _db.cachedAccountSummaries);
  $$CachedAdminPostsTableTableManager get cachedAdminPosts =>
      $$CachedAdminPostsTableTableManager(_db, _db.cachedAdminPosts);
  $$CachedClientOrdersTableTableManager get cachedClientOrders =>
      $$CachedClientOrdersTableTableManager(_db, _db.cachedClientOrders);
  $$CachedClientOrderDetailsTableTableManager get cachedClientOrderDetails =>
      $$CachedClientOrderDetailsTableTableManager(
          _db, _db.cachedClientOrderDetails);
  $$CachedAdminOrdersTableTableManager get cachedAdminOrders =>
      $$CachedAdminOrdersTableTableManager(_db, _db.cachedAdminOrders);
  $$CachedAdminClientsTableTableManager get cachedAdminClients =>
      $$CachedAdminClientsTableTableManager(_db, _db.cachedAdminClients);
  $$CachedAdminClientAccountsTableTableManager get cachedAdminClientAccounts =>
      $$CachedAdminClientAccountsTableTableManager(
          _db, _db.cachedAdminClientAccounts);
}
