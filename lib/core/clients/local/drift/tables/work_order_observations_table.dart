import 'package:drift/drift.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/companies_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/service_provider_profiles_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/user_profiles_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/work_orders_table.dart';

class WorkOrderObservations extends Table {
  TextColumn get id => text()();
  TextColumn get companyId =>
      text().references(Companies, #id, onDelete: KeyAction.cascade)();
  TextColumn get workOrderId =>
      text().references(WorkOrders, #id, onDelete: KeyAction.cascade)();
  /// Exactly one of [authorId] / [authorProviderProfileId] is set: internal
  /// employees have a user profile, providers have a provider profile.
  TextColumn get authorId => text()
      .nullable()
      .references(UserProfiles, #id, onDelete: KeyAction.restrict)();
  TextColumn get authorProviderProfileId => text()
      .nullable()
      .references(
        ServiceProviderProfiles,
        #id,
        onDelete: KeyAction.restrict,
      )();
  TextColumn get authorName => text()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
