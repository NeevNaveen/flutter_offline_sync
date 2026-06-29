import 'package:drift/drift.dart';

@DataClassName('SyncRecordRow')
class SyncRecords extends Table {
  TextColumn get localId => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get eventType => text()();
  TextColumn get operation => text()();
  TextColumn get data => text()();
  TextColumn get syncStatus => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get editedAt => dateTime()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {localId};
}

class SyncMetadata extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
