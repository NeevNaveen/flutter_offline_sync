import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'sync_database.g.dart';

@DriftDatabase(tables: [SyncRecords, SyncMetadata])
class SyncDatabase extends _$SyncDatabase {
  SyncDatabase(super.executor);

  SyncDatabase.memory() : super(NativeDatabase.memory());

  factory SyncDatabase.open({String name = 'sync_engine'}) {
    return SyncDatabase(driftDatabase(name: name));
  }

  @override
  int get schemaVersion => 1;
}
