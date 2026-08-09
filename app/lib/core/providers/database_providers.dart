// ignore_for_file: deprecated_member_use_from_same_package
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_database.dart';
import '../../features/priorities/data/priority_repository.dart';
import '../../features/timeline/data/time_block_repository.dart';

part 'database_providers.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

@Riverpod(keepAlive: true)
PriorityRepository priorityRepository(PriorityRepositoryRef ref) =>
    PriorityRepository(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
TimeBlockRepository timeBlockRepository(TimeBlockRepositoryRef ref) =>
    TimeBlockRepository(ref.watch(appDatabaseProvider));
