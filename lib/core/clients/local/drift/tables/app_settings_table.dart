import 'package:drift/drift.dart';

class AppSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  BoolColumn get pushNotificationsEnabled => boolean().withDefault(
    const Constant(false),
  )(); //TODO check if we really need this table
}
