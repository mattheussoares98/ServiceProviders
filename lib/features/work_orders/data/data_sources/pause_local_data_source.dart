import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/handlers/error_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/pause_reason_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/pause_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_responsability.dart';

abstract interface class PauseLocalDataSource {
  FutureList<PauseReasonModel> getPauseReasons(String companyId);
  FutureBool savePauseReason(PauseReasonModel reason);
  FutureList<PauseRequestModel> getPauseRequests(String workOrderId);
  FutureBool savePauseRequest(PauseRequestModel request);
  FutureBool reviewPause({
    required String id,
    required String status,
    String? reviewObservation,
    required String reviewedById,
    String? reasonId,
  });
  FutureBool cancelPause({required String id, required DateTime resumedAt});
}

@LazySingleton(as: PauseLocalDataSource)
final class PauseLocalDataSourceImpl implements PauseLocalDataSource {
  const PauseLocalDataSourceImpl({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  @override
  FutureList<PauseReasonModel> getPauseReasons(String companyId) {
    return ErrorHandler.execute(() async {
      final query = _database.select(_database.pauseReasons)
        ..where((t) => t.companyId.equals(companyId) & t.deletedAt.isNull());
      final rows = await query.get();
      final list = rows
          .map(
            (r) => PauseReasonModel(
              id: r.id,
              companyId: r.companyId,
              name: r.name,
              isActive: r.isActive,
              createdAt: r.createdAt,
              updatedAt: r.updatedAt,
              deletedAt: r.deletedAt,
            ),
          )
          .toList();
      return SuccessState(data: list);
    });
  }

  @override
  FutureBool savePauseReason(PauseReasonModel reason) {
    return ErrorHandler.execute(() async {
      await _database
          .into(_database.pauseReasons)
          .insertOnConflictUpdate(
            PauseReasonsCompanion(
              id: Value(reason.id),
              companyId: Value(reason.companyId),
              name: Value(reason.name),
              isActive: Value(reason.isActive),
              createdAt: Value(reason.createdAt),
              updatedAt: Value(reason.updatedAt),
              deletedAt: Value(reason.deletedAt),
            ),
          );
      return const SuccessState(data: true);
    });
  }

  @override
  FutureList<PauseRequestModel> getPauseRequests(String workOrderId) {
    return ErrorHandler.execute(() async {
      final query = _database.select(_database.workOrderPauseRequests)
        ..where((t) => t.workOrderId.equals(workOrderId));
      final rows = await query.get();
      final list = rows
          .map(
            (r) => PauseRequestModel(
              id: r.id,
              companyId: r.companyId,
              workOrderId: r.workOrderId,
              requestedById: r.requestedById,
              reasonId: r.reasonId,
              customReason: r.customReason,
              observation: r.observation,
              responsibility: PauseResponsibility.fromValue(r.responsibility),
              sector: r.sector,
              status: PauseRequestStatus.fromValue(r.status),
              pausedAt: r.pausedAt,
              resumedAt: r.resumedAt,
              reviewedById: r.reviewedById,
              reviewObservation: r.reviewObservation,
              affectsSla: r.affectsSla,
              createdAt: r.createdAt,
              updatedAt: r.updatedAt,
            ),
          )
          .toList();
      return SuccessState(data: list);
    });
  }

  @override
  FutureBool savePauseRequest(PauseRequestModel request) {
    return ErrorHandler.execute(() async {
      await _database
          .into(_database.workOrderPauseRequests)
          .insertOnConflictUpdate(
            WorkOrderPauseRequestsCompanion(
              id: Value(request.id),
              companyId: Value(request.companyId),
              workOrderId: Value(request.workOrderId),
              requestedById: Value(request.requestedById),
              reasonId: Value(request.reasonId),
              customReason: Value(request.customReason),
              observation: Value(request.observation),
              responsibility: Value(request.responsibility.value),
              sector: Value(request.sector),
              status: Value(request.status.value),
              pausedAt: Value(request.pausedAt),
              resumedAt: Value(request.resumedAt),
              reviewedById: Value(request.reviewedById),
              reviewObservation: Value(request.reviewObservation),
              affectsSla: Value(request.affectsSla),
              createdAt: Value(request.createdAt),
              updatedAt: Value(request.updatedAt),
            ),
          );
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool reviewPause({
    required String id,
    required String status,
    String? reviewObservation,
    required String reviewedById,
    String? reasonId,
  }) {
    return ErrorHandler.execute(() async {
      final query = _database.update(_database.workOrderPauseRequests)
        ..where((t) => t.id.equals(id));
      await query.write(
        WorkOrderPauseRequestsCompanion(
          status: Value(status),
          reviewedById: Value(reviewedById),
          reviewObservation: reviewObservation != null
              ? Value(reviewObservation)
              : const Value.absent(),
          reasonId: reasonId != null ? Value(reasonId) : const Value.absent(),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool cancelPause({required String id, required DateTime resumedAt}) {
    return ErrorHandler.execute(() async {
      final query = _database.update(_database.workOrderPauseRequests)
        ..where((t) => t.id.equals(id));
      await query.write(
        WorkOrderPauseRequestsCompanion(
          status: const Value('cancelled_by_provider'),
          resumedAt: Value(resumedAt),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return const SuccessState(data: true);
    });
  }
}
