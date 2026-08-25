import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/handlers/error_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_observation_model.dart';

abstract interface class WorkOrderObservationsLocalDataSource {
  FutureList<WorkOrderObservationModel> getObservations(String workOrderId);
  FutureBool saveObservation(WorkOrderObservationModel observation);
  FutureBool saveObservations(List<WorkOrderObservationModel> observations);
  FutureBool deleteObservation(String observationId);
}

@LazySingleton(as: WorkOrderObservationsLocalDataSource)
final class WorkOrderObservationsLocalDataSourceImpl
    implements WorkOrderObservationsLocalDataSource {
  const WorkOrderObservationsLocalDataSourceImpl({
    required AppDatabase database,
  }) : _database = database;

  final AppDatabase _database;

  @override
  FutureList<WorkOrderObservationModel> getObservations(String workOrderId) {
    return ErrorHandler.execute(() async {
      final query = _database.select(_database.workOrderObservations)
        ..where(
          (t) => t.workOrderId.equals(workOrderId) & t.deletedAt.isNull(),
        );
      final rows = await query.get();
      final list = rows
          .map(
            (r) => WorkOrderObservationModel(
              id: r.id,
              companyId: r.companyId,
              workOrderId: r.workOrderId,
              authorId: r.authorId,
              authorProviderProfileId: r.authorProviderProfileId,
              authorName: r.authorName,
              content: r.content,
              createdAt: r.createdAt.toUtc(),
              updatedAt: r.updatedAt.toUtc(),
            ),
          )
          .toList();
      return SuccessState(data: list);
    });
  }

  @override
  FutureBool saveObservation(WorkOrderObservationModel observation) {
    return ErrorHandler.execute(() async {
      await _database.into(_database.workOrderObservations).insertOnConflictUpdate(
            WorkOrderObservationsCompanion.insert(
              id: observation.id,
              companyId: observation.companyId,
              workOrderId: observation.workOrderId,
              authorId: Value(observation.authorId),
              authorProviderProfileId: Value(
                observation.authorProviderProfileId,
              ),
              authorName: observation.authorName,
              content: observation.content,
              createdAt: Value(observation.createdAt),
              updatedAt: Value(observation.updatedAt),
            ),
          );
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool saveObservations(List<WorkOrderObservationModel> observations) {
    return ErrorHandler.execute(() async {
      await _database.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _database.workOrderObservations,
          observations
              .map(
                (o) => WorkOrderObservationsCompanion.insert(
                  id: o.id,
                  companyId: o.companyId,
                  workOrderId: o.workOrderId,
                  authorId: Value(o.authorId),
                  authorProviderProfileId: Value(o.authorProviderProfileId),
                  authorName: o.authorName,
                  content: o.content,
                  createdAt: Value(o.createdAt),
                  updatedAt: Value(o.updatedAt),
                ),
              )
              .toList(),
        );
      });
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool deleteObservation(String observationId) {
    return ErrorHandler.execute(() async {
      final query = _database.update(_database.workOrderObservations)
        ..where((t) => t.id.equals(observationId));
      await query.write(
        WorkOrderObservationsCompanion(
          deletedAt: Value(DateTime.now()),
        ),
      );
      return const SuccessState(data: true);
    });
  }
}
