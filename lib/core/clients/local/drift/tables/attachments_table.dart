import 'package:drift/drift.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/companies_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/user_profiles_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/work_orders_table.dart';

@TableIndex(name: 'idx_attachments_work_order', columns: {#workOrderId})
class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get workOrderId =>
      text().references(WorkOrders, #id, onDelete: KeyAction.cascade)();
  TextColumn get companyId =>
      text().references(Companies, #id, onDelete: KeyAction.cascade)();
  TextColumn get uploadedById =>
      text().references(UserProfiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get fileName => text()();
  TextColumn get fileType => text()(); // enum: image, pdf, document, signature
  TextColumn get localPath => text().nullable()();
  TextColumn get remoteUrl => text().nullable()();
  IntColumn get fileSizeBytes => integer().nullable()();
  BoolColumn get isCompressed => boolean().withDefault(const Constant(false))();
  TextColumn get uploadStatus => text().withDefault(
    const Constant('pending'),
  )(); // enum: pending, uploaded, failed
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get originalPath => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
