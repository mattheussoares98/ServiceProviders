import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/handlers/error_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/pause_reason_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/pause_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_event_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_responsability.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';

abstract interface class PauseLocalDataSource {
  FutureList<PauseReasonModel> getPauseReasons(String companyId);
  FutureBool savePauseReason(PauseReasonModel reason);
  FutureList<PauseRequestModel> getPauseRequests(
    String workOrderId, {
    String? status,
  });
  FutureBool savePauseRequest(PauseRequestModel request);
  FutureBool reviewPause({
    required String id,
    required String workOrderId,
    required String status,
    String? reviewObservation,
    required String reviewedById,
    String? reasonId,
    String? responsibility,
  });
  FutureBool reviewCompletion({
    required String id,
    required String workOrderId,
    required String status,
    required String reviewedById,
    String? reviewObservation,
    String? responsibility,
    String? completionReason,
    String? completionSectorId,
  });
  FutureBool cancelPause({
    required String id,
    required String workOrderId,
    required DateTime resumedAt,
    required String resumedById,
  });
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
              createdAt: r.createdAt.toUtc(),
              updatedAt: r.updatedAt.toUtc(),
              deletedAt: r.deletedAt?.toUtc(),
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
  FutureList<PauseRequestModel> getPauseRequests(
    String workOrderId, {
    String? status,
  }) {
    return ErrorHandler.execute(() async {
      final query = _database.select(_database.workOrderPauseRequests)
        ..where(
          (t) =>
              t.workOrderId.equals(workOrderId) &
              (status != null
                  ? t.status.equals(status)
                  : const Constant(true)),
        );
      final rows = await query.get();
      final list = rows
          .map(
            (r) => PauseRequestModel(
              id: r.id,
              companyId: r.companyId,
              workOrderId: r.workOrderId,
              requestedById: r.requestedById,
              eventType: PauseEventType.fromValue(r.eventType),
              reasonId: r.reasonId,
              customReason: r.customReason,
              observation: r.observation,
              responsibility: r.responsibility != null
                  ? PauseResponsibility.fromValue(r.responsibility!)
                  : null,
              sectorId: r.sectorId,
              status: PauseRequestStatus.fromValue(r.status),
              pausedAt: r.pausedAt.toUtc(),
              resumedAt: r.resumedAt?.toUtc(),
              resumedById: r.resumedById,
              reviewedById: r.reviewedById,
              reviewObservation: r.reviewObservation,
              affectsSla: r.affectsSla,
              createdAt: r.createdAt.toUtc(),
              updatedAt: r.updatedAt.toUtc(),
            ),
          )
          .toList();
      return SuccessState(data: list);
    });
  }

  @override
  FutureBool savePauseRequest(PauseRequestModel request) {
    return ErrorHandler.execute(() async {
      await _database.transaction(() async {
        await _database
            .into(_database.workOrderPauseRequests)
            .insertOnConflictUpdate(
              WorkOrderPauseRequestsCompanion(
                id: Value(request.id),
                companyId: Value(request.companyId),
                workOrderId: Value(request.workOrderId),
                requestedById: Value(request.requestedById),
                eventType: Value(request.eventType.value),
                reasonId: Value(request.reasonId),
                customReason: Value(request.customReason),
                observation: Value(request.observation),
                responsibility: Value(request.responsibility?.value),
                sectorId: Value(request.sectorId),
                status: Value(request.status.value),
                pausedAt: Value(request.pausedAt),
                resumedAt: Value(request.resumedAt),
                resumedById: Value(request.resumedById),
                reviewedById: Value(request.reviewedById),
                reviewObservation: Value(request.reviewObservation),
                affectsSla: Value(request.affectsSla),
                createdAt: Value(request.createdAt),
                updatedAt: Value(request.updatedAt),
              ),
            );

        final woQuery = _database.update(_database.workOrders)
          ..where((t) => t.id.equals(request.workOrderId));

        if (request.eventType == PauseEventType.completion) {
          if (request.status == PauseRequestStatus.approved) {
            await woQuery.write(
              WorkOrdersCompanion(
                status: Value(WorkOrderStatus.completed.code),
                completedAt: Value(DateTime.now()),
                completionReason: request.customReason != null
                    ? Value(request.customReason)
                    : const Value.absent(),
                completionResponsibility: request.responsibility != null
                    ? Value(request.responsibility!.value)
                    : const Value.absent(),
                completionSectorId: request.sectorId != null
                    ? Value(request.sectorId)
                    : const Value.absent(),
                updatedAt: Value(DateTime.now()),
              ),
            );
          } else {
            await woQuery.write(
              WorkOrdersCompanion(
                status: Value(WorkOrderStatus.pendingConclusionApproval.code),
                updatedAt: Value(DateTime.now()),
              ),
            );
          }
        } else {
          await woQuery.write(
            WorkOrdersCompanion(
              status: Value(WorkOrderStatus.onHold.code),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }
      });
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool reviewPause({
    required String id,
    required String workOrderId,
    required String status,
    String? reviewObservation,
    required String reviewedById,
    String? reasonId,
    String? responsibility,
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
          responsibility: responsibility != null
              ? Value(responsibility)
              : const Value.absent(),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool reviewCompletion({
    required String id,
    required String workOrderId,
    required String status,
    required String reviewedById,
    String? reviewObservation,
    String? responsibility,
    String? completionReason,
    String? completionSectorId,
  }) {
    return ErrorHandler.execute(() async {
      await _database.transaction(() async {
        final query = _database.update(_database.workOrderPauseRequests)
          ..where((t) => t.id.equals(id));
        await query.write(
          WorkOrderPauseRequestsCompanion(
            status: Value(status),
            reviewedById: Value(reviewedById),
            reviewObservation: reviewObservation != null
                ? Value(reviewObservation)
                : const Value.absent(),
            responsibility: responsibility != null
                ? Value(responsibility)
                : const Value.absent(),
            updatedAt: Value(DateTime.now()),
          ),
        );

        final isApproved = status == PauseRequestStatus.approved.value;
        final woQuery = _database.update(_database.workOrders)
          ..where((t) => t.id.equals(workOrderId));

        if (isApproved) {
          await woQuery.write(
            WorkOrdersCompanion(
              status: Value(WorkOrderStatus.completed.code),
              completedAt: Value(DateTime.now()),
              completionReason: completionReason != null
                  ? Value(completionReason)
                  : const Value.absent(),
              completionResponsibility: responsibility != null
                  ? Value(responsibility)
                  : const Value.absent(),
              completionSectorId: completionSectorId != null
                  ? Value(completionSectorId)
                  : const Value.absent(),
              updatedAt: Value(DateTime.now()),
            ),
          );
        } else {
          await woQuery.write(
            WorkOrdersCompanion(
              status: Value(WorkOrderStatus.inProgress.code),
              completedAt: const Value(null),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }
      });
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool cancelPause({
    required String id,
    required String workOrderId,
    required DateTime resumedAt,
    required String resumedById,
  }) {
    return ErrorHandler.execute(() async {
      await _database.transaction(() async {
        final query = _database.update(_database.workOrderPauseRequests)
          ..where((t) => t.id.equals(id));
        await query.write(
          WorkOrderPauseRequestsCompanion(
            resumedAt: Value(resumedAt),
            resumedById: Value(resumedById),
            updatedAt: Value(DateTime.now()),
          ),
        );

        final woQuery = _database.update(_database.workOrders)
          ..where((t) => t.id.equals(workOrderId));
        await woQuery.write(
          WorkOrdersCompanion(
            status: Value(WorkOrderStatus.inProgress.code),
            updatedAt: Value(DateTime.now()),
          ),
        );
      });
      return const SuccessState(data: true);
    });
  }
}
