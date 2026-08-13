import 'package:drift/drift.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/companies_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/pause_reasons_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/sectors_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/user_profiles_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/work_orders_table.dart';

class WorkOrderPauseRequests extends Table {
  TextColumn get id => text()();
  TextColumn get companyId =>
      text().references(Companies, #id, onDelete: KeyAction.cascade)();
  TextColumn get workOrderId =>
      text().references(WorkOrders, #id, onDelete: KeyAction.cascade)();
  TextColumn get requestedById => text().nullable().references(
    UserProfiles,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get eventType =>
      text().withDefault(const Constant('pause'))();
  TextColumn get reasonId => text().nullable().references(
    PauseReasons,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get customReason => text().nullable()();
  TextColumn get observation => text().nullable()();
  TextColumn get responsibility => text()();
  TextColumn get sectorId =>
      text().nullable().references(Sectors, #id, onDelete: KeyAction.setNull)();
  TextColumn get status => text()();
  DateTimeColumn get pausedAt => dateTime()();
  DateTimeColumn get resumedAt => dateTime().nullable()();
  TextColumn get resumedById => text().nullable().references(
    UserProfiles,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get reviewedById => text().nullable().references(
    UserProfiles,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get reviewObservation => text().nullable()();
  BoolColumn get affectsSla => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

