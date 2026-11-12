import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'daos/brain_dump_dao.dart';
import 'daos/priority_dao.dart';
import 'daos/time_block_dao.dart';

part 'app_database.g.dart';

// -- Tables

class DayConfigs extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get startHour => integer()();    // e.g. 9
  IntColumn get startMinute => integer()();  // 0 or 30
  IntColumn get endHour => integer()();
  IntColumn get endMinute => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Priorities extends Table {
  TextColumn get id => text()();
  TextColumn get dayConfigId => text().references(DayConfigs, #id)();
  TextColumn get title => text()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer()();
  IntColumn get estimatedMinutes => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class BrainDumpNotes extends Table {
  TextColumn get id => text()();
  TextColumn get dayConfigId => text().references(DayConfigs, #id)();
  TextColumn get content => text()();
  TextColumn get contentFormat => text().withDefault(const Constant('plain'))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class TimeBlocks extends Table {
  TextColumn get id => text()();
  TextColumn get dayConfigId => text().references(DayConfigs, #id)();
  TextColumn get title => text()();
  // nullable link to a priority
  TextColumn get priorityId => text().nullable().references(Priorities, #id)();
  IntColumn get startHour => integer()();
  IntColumn get startMinute => integer()();
  IntColumn get endHour => integer()();
  IntColumn get endMinute => integer()();
  // 'scheduled' | 'in_progress' | 'completed' | 'missed'
  TextColumn get status => text().withDefault(const Constant('scheduled'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class UserSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

// -- Database

@DriftDatabase(
  tables: [DayConfigs, Priorities, BrainDumpNotes, TimeBlocks, UserSettings],
  daos: [BrainDumpDao, PriorityDao, TimeBlockDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(brainDumpNotes, brainDumpNotes.contentFormat);
      }
      if (from < 3) {
        await m.addColumn(priorities, priorities.estimatedMinutes);
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'timebox_db');
  }

  Future<void> deleteAllData() async {
    await delete(brainDumpNotes).go();
    await delete(timeBlocks).go();
    await delete(priorities).go();
    await delete(dayConfigs).go();
    await delete(userSettings).go();
  }

  Future<void> ensureDayConfig(String id, DateTime date) async {
    await into(dayConfigs).insert(
      DayConfigsCompanion.insert(
        id: id,
        date: date,
        startHour: 9,
        startMinute: 0,
        endHour: 18,
        endMinute: 0,
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }
}
