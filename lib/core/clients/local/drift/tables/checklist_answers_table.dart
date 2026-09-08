import 'package:drift/drift.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/checklist_items_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/companies_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/work_orders_table.dart';

/// Offline cache of `public.checklist_answers`.
///
/// Answers used to be squeezed into the `tasks` table, which has no columns for
/// the text, number, photo or selection values — every non-boolean answer was
/// lost. This mirrors the remote table so the execution screen reads back what
/// was written.
class ChecklistAnswers extends Table {
  TextColumn get id => text()();
  TextColumn get companyId =>
      text().references(Companies, #id, onDelete: KeyAction.cascade)();
  TextColumn get workOrderId =>
      text().references(WorkOrders, #id, onDelete: KeyAction.cascade)();
  TextColumn get checklistItemId =>
      text().references(ChecklistItems, #id, onDelete: KeyAction.cascade)();
  BoolColumn get booleanValue => boolean().nullable()();
  TextColumn get textValue => text().nullable()();
  RealColumn get numberValue => real().nullable()();
  TextColumn get photoUrl => text().nullable()();
  TextColumn get selectedOption => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  // Mirrors idx_checklist_answers_unique_item: one answer per item per order.
  @override
  List<Set<Column>> get uniqueKeys => [
    {workOrderId, checklistItemId},
  ];
}
