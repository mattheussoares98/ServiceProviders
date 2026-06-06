import 'package:drift/drift.dart';

class UserSessions extends Table {
  TextColumn get id => text()(); // user id
  TextColumn get name => text()();
  TextColumn get email => text()();
  BoolColumn get isActive => boolean()();
  TextColumn get accessToken => text()();
  TextColumn get refreshToken => text()();

  @override
  Set<Column> get primaryKey => {id};
}
