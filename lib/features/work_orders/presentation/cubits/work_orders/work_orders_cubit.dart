import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/upload_status.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/cubits/attachments/attachments_cubit.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_profile_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_change_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_history_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/cancel_pause_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_provider_work_orders_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_orders_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/review_work_order_change_request_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/value_objects/work_order_filter.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit_sections.dart';

part 'work_orders_state.dart';

@injectable
class WorkOrdersCubit extends BaseCubit<WorkOrdersState> {
  WorkOrdersCubit({required WorkOrdersCubitUseCases useCases})
    : _useCases = useCases,
      super(const WorkOrdersState.initial());

  final WorkOrdersCubitUseCases _useCases;

  static const _pageSize = 50;

  /// Provider mode changes how work orders are scoped and fetched, so the
  /// entry points shared with internal mode branch on it.
  bool get _isProviderMode =>
      AppMode.fromName(_useCases.getSelectedMode()) == AppMode.provider;

  Future<bool> loadWorkOrdersAndChangeRequests({
    bool showLoading = true,
    WorkOrderFilter? filter,
  }) async {
    final activeFilter = filter ?? state.activeFilter;

    emit(state.copyWith(activeFilter: activeFilter));
    final companyId = _useCases.getActiveCompanyId();

    if (showLoading) {
      emit(state.copyWith(status: StateStatus.loading));
    }

    final results = await Future.wait([
      _useCases.getWorkOrders(
        GetWorkOrdersParams(companyId: companyId, filter: activeFilter),
      ),
      _useCases.getChangeRequests(companyId),
    ]);
    if (isClosed) return false;

    final workOrdersResult = results[0];
    final changeRequestsResult = results[1];

    if (workOrdersResult is SuccessState<List<WorkOrderEntity>> &&
        changeRequestsResult
            is SuccessState<List<WorkOrderChangeRequestEntity>>) {
      final fetchedOrders = workOrdersResult.data ?? [];
      emit(
        state.copyWith(
          status: StateStatus.loaded,
          workOrders: fetchedOrders,
          changeRequests: changeRequestsResult.data,
          activeFilter: activeFilter,
          hasMorePages: fetchedOrders.length == _pageSize,
          isLoadingMore: false,
          annulErrorMessage: true,
        ),
      );
      return true;
    } else {
      final errorMessage = workOrdersResult is FailureState
          ? workOrdersResult.message
          : changeRequestsResult.message;
      emit(
        state.copyWith(
          status: StateStatus.loadingError,
          errorMessage: errorMessage,
        ),
      );
      return false;
    }
  }


  // ===========================================================================
  // Provider mode (AppMode.provider)
  // ===========================================================================
  // Provider work orders span every contracting company the provider serves, so
  // they are scoped by provider company instead of by `company_id`, and are
  // fetched online-only (V2 §1.4). Everything downstream — details, execution,
  // pauses, attachments — reuses the internal-mode widgets unchanged.

  /// Loads the provider companies the user belongs to, then their work orders.
  /// Call this instead of [loadWorkOrdersAndChangeRequests] in provider mode.
  Future<bool> loadProviderWorkOrders({
    bool showLoading = true,
    WorkOrderFilter? filter,
  }) async {
    if (showLoading) {
      emit(state.copyWith(status: StateStatus.loading));
    }

    final companies = await _loadProviderCompanies();
    if (isClosed) return false;

    if (companies.isEmpty) {
      emit(
        state.copyWith(
          status: StateStatus.loaded,
          workOrders: const [],
          providerCompanies: const [],
          hasMorePages: false,
          isLoadingMore: false,
        ),
      );
      return true;
    }

    final activeFilter = filter ?? state.activeFilter;
    final result = await _useCases.getProviderWorkOrders(
      GetProviderWorkOrdersParams(
        serviceProviderCompanyIds: companies.map((e) => e.id).toList(),
        filter: activeFilter,
      ),
    );
    if (isClosed) return false;

    if (result is SuccessState<List<WorkOrderEntity>>) {
      final fetched = result.data ?? [];
      emit(
        state.copyWith(
          status: StateStatus.loaded,
          workOrders: fetched,
          changeRequests: const [],
          providerCompanies: companies,
          activeFilter: activeFilter,
          hasMorePages: fetched.length == _pageSize,
          isLoadingMore: false,
          annulErrorMessage: true,
        ),
      );
      return true;
    }

    emit(
      state.copyWith(
        status: StateStatus.loadingError,
        errorMessage: result.message,
        providerCompanies: companies,
      ),
    );
    return false;
  }

  /// Narrows the provider list to one company, or back to all of them when
  /// [serviceProviderCompanyId] is null.
  Future<void> selectProviderCompany(String? serviceProviderCompanyId) async {
    final filter = state.activeFilter.copyWith(
      serviceProviderCompanyIds: serviceProviderCompanyId == null
          ? const []
          : [serviceProviderCompanyId],
    );
    await loadProviderWorkOrders(filter: filter);
  }

  /// Applies a search or attribute filter while staying in provider scope.
  Future<void> applyProviderFilter(WorkOrderFilter filter) =>
      loadProviderWorkOrders(
        filter: filter.copyWith(
          serviceProviderCompanyIds:
              state.activeFilter.serviceProviderCompanyIds,
        ),
      );

  /// Resolves the provider companies from the signed-in user's provider
  /// profiles. Returns the already-loaded list when it is available so that
  /// filtering does not refetch it on every keystroke.
  Future<List<ServiceProviderCompanyEntity>> _loadProviderCompanies() async {
    if (state.providerCompanies.isNotEmpty) {
      return state.providerCompanies;
    }

    final user = _useCases.getSessionUser();
    if (user.id.isEmpty) return const [];

    final profilesResult = await _useCases.getServiceProviderProfilesByAuthUser(
      user.id,
    );
    if (profilesResult is! SuccessState<List<ServiceProviderProfileEntity>>) {
      return const [];
    }

    final companyIds = (profilesResult.data ?? [])
        .where((profile) => profile.isActive)
        .map((profile) => profile.serviceProviderCompanyId)
        .toSet()
        .toList();
    if (companyIds.isEmpty) return const [];

    final companiesResult = await _useCases.getServiceProviderCompaniesByIds(
      companyIds,
    );
    if (companiesResult is SuccessState<List<ServiceProviderCompanyEntity>>) {
      final companies = [...companiesResult.data ?? <ServiceProviderCompanyEntity>[]]
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return companies;
    }
    return const [];
  }

  Future<bool> loadWorkOrderById(String id, {bool showLoading = false}) async {
    if (showLoading) {
      emit(state.copyWith(status: StateStatus.loading));
    }

    final dataState = await _useCases.getWorkOrderById(id);
    if (isClosed) return false;

    if (dataState is SuccessState<WorkOrderEntity> && dataState.data != null) {
      final updatedOrder = dataState.data!;
      final exists = state.workOrders.any((wo) => wo.id == id);
      final updatedList = exists
          ? state.workOrders
                .map((wo) => wo.id == id ? updatedOrder : wo)
                .toList()
          : [...state.workOrders, updatedOrder];

      emit(
        state.copyWith(
          status: showLoading ? StateStatus.loaded : state.status,
          workOrders: updatedList,
          annulErrorMessage: true,
        ),
      );
      return true;
    } else {
      if (showLoading) {
        emit(
          state.copyWith(
            status: StateStatus.loadingError,
            errorMessage: dataState.message,
          ),
        );
      } else {
        showDataStateToast(dataState);
      }
      return false;
    }
  }

  Future<bool> syncWorkOrders() async {
    final companyId = _useCases.getActiveCompanyId();
    final result = await _useCases.syncWorkOrders(companyId);
    return result is SuccessState<bool>;
  }

  Future<void> applyFilter(WorkOrderFilter filter) => _isProviderMode
      ? applyProviderFilter(filter)
      : loadWorkOrdersAndChangeRequests(filter: filter);

  Future<void> clearFilter() => _isProviderMode
      // Keep the company selection: it is a scope, not one of the chip filters.
      ? applyProviderFilter(const WorkOrderFilter())
      : loadWorkOrdersAndChangeRequests(filter: const WorkOrderFilter());

  Future<void> loadNextPage() async {
    // isLoadingMore prevents duplicate concurrent requests for the same page
    // when multiple scroll trigger events fire within a short timeframe.
    if (!state.hasMorePages || state.isLoadingMore) return;

    emit(state.copyWith(isLoadingMore: true));

    final dataState = _isProviderMode
        ? await _useCases.getProviderWorkOrders(
            GetProviderWorkOrdersParams(
              serviceProviderCompanyIds: state.providerCompanies
                  .map((company) => company.id)
                  .toList(),
              filter: state.activeFilter,
              offset: state.workOrders.length,
            ),
          )
        : await _useCases.getWorkOrders(
            GetWorkOrdersParams(
              companyId: _useCases.getActiveCompanyId(),
              filter: state.activeFilter,
              offset: state.workOrders.length,
            ),
          );
    if (isClosed) return;

    if (dataState is SuccessState<List<WorkOrderEntity>>) {
      final newOrders = dataState.data ?? [];
      emit(
        state.copyWith(
          workOrders: [...state.workOrders, ...newOrders],
          hasMorePages: newOrders.length == _pageSize,
          isLoadingMore: false,
        ),
      );
    } else {
      showErrorToast(
        dataState.message ??
            'Erro ao carregar mais ordens de serviço'.hardcoded,
      );
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  Future<void> loadWorkOrderHistory(String workOrderId) async {
    final dataState = await _useCases.getWorkOrderHistory(workOrderId);
    if (isClosed) return;

    if (dataState is SuccessState<List<WorkOrderHistoryEntity>>) {
      final historyList = dataState.data ?? [];
      final updatedHistory = Map<String, List<WorkOrderHistoryEntity>>.from(
        state.historyByWorkOrder,
      );
      updatedHistory[workOrderId] = historyList;
      emit(state.copyWith(historyByWorkOrder: updatedHistory));
    } else {
      showDataStateToast(dataState);
    }
  }

  Future<bool> saveWorkOrder({
    required String id,
    required bool isEditing,
    String? assetId,
    required String locationId,
    String? assignedToId,
    String? areaId,
    required String createdById,
    String? maintenancePlanId,
    required String title,
    String? description,
    required Priority priority,
    required WorkOrderStatus status,
    required WorkOrderType type,
    DateTime? scheduledDate,
    DateTime? startedAt,
    DateTime? completedAt,
    int? estimatedDuration,
    int? actualDuration,
    double? laborCost,
    double? partsCost,
    double? totalCost,
    String? notes,
    DateTime? createdAt,
    AttachmentsCubit? attachmentsCubit,
    String? serviceProviderCompanyId,
    String? providerProfileId,
    String? slaPolicyId,
    AppMode openedBy = AppMode.internal,
  }) async {
    emit(state.copyWith(status: StateStatus.saving));

    final now = DateTime.now();
    final companyId = _useCases.getActiveCompanyId();

    final computedStartedAt =
        startedAt ?? (status == WorkOrderStatus.inProgress ? now : null);

    DateTime? computedCompletedAt = completedAt;
    if (status == WorkOrderStatus.completed) {
      computedCompletedAt ??= now;
    } else if (status == WorkOrderStatus.open ||
        status == WorkOrderStatus.inProgress ||
        status == WorkOrderStatus.onHold) {
      computedCompletedAt = null;
    }

    final workOrder = WorkOrderEntity(
      id: id,
      companyId: companyId,
      assetId: assetId?.trimToNull(),
      locationId: locationId,
      areaId: areaId,
      assignedToId: assignedToId?.trimToNull(),
      createdById: createdById,
      maintenancePlanId: maintenancePlanId?.trimToNull(),
      title: title.trim(),
      description: description?.trimToNull(),
      priority: priority,
      status: status,
      type: type,
      scheduledDate: scheduledDate,
      startedAt: computedStartedAt,
      completedAt: computedCompletedAt,
      estimatedDuration: estimatedDuration,
      actualDuration: actualDuration,
      laborCost: laborCost,
      partsCost: partsCost,
      totalCost: totalCost,
      notes: notes?.trimToNull(),
      createdAt: createdAt ?? now,
      updatedAt: now,
      deletedAt: null,
      serviceProviderCompanyId: serviceProviderCompanyId?.trimToNull(),
      providerProfileId: providerProfileId?.trimToNull(),
      slaPolicyId: slaPolicyId,
      slaDeadlineAt: null,
      netActiveDuration: null,
      completionReason: null,
      completionResponsibility: null,
      completionSectorId: null,
      openedBy: openedBy,
    );

    final dataState = isEditing
        ? await _useCases.updateWorkOrder(workOrder)
        : await _useCases.createWorkOrder(workOrder);
    if (isClosed) return false;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      if (attachmentsCubit != null) {
        final pendingDeletions = attachmentsCubit.state.pendingDeletions;
        if (pendingDeletions.isNotEmpty) {
          await Future.wait([
            for (final dId in pendingDeletions) _useCases.deleteAttachment(dId),
          ]);
        }

        final pendingToSave = attachmentsCubit.state.attachments
            .where(
              (e) =>
                  e.uploadStatus == UploadStatus.pending ||
                  e.uploadStatus == UploadStatus.failed,
            )
            .toList();
        if (pendingToSave.isNotEmpty) {
          await Future.wait([
            for (final attachment in pendingToSave)
              _useCases.createAttachment(attachment),
          ]);
        }
      }

      final attachmentsResult = await _useCases.getAttachments(workOrder.id);
      if (attachmentsResult is SuccessState<List<AttachmentEntity>>) {
        final pending = attachmentsResult.data!
            .where(
              (e) =>
                  e.uploadStatus == UploadStatus.pending ||
                  e.uploadStatus == UploadStatus.failed,
            )
            .toList();
        if (pending.isNotEmpty) {
          final result = await Future.wait([
            for (final attachment in pending)
              _useCases.uploadAttachment(attachment),
          ]);

          final anyFailure = result.firstWhere(
            (element) => element is FailureState,
            orElse: () => const SuccessState(data: true),
          );

          if (anyFailure is FailureState) {
            emit(
              state.copyWith(
                status: StateStatus.savingError,
                errorMessage: anyFailure.message,
              ),
            );
            showDataStateToast(anyFailure);
            return false;
          }
        }
      }

      if (attachmentsCubit != null) {
        await attachmentsCubit.refreshAttachments();
      }

      await loadWorkOrdersAndChangeRequests(showLoading: false);
      return true;
    } else {
      emit(
        state.copyWith(
          status: StateStatus.savingError,
          errorMessage: dataState is FailureState
              ? (dataState as FailureState).message
              : '',
        ),
      );
      showDataStateToast(dataState);
      return false;
    }
  }

  Future<bool> changeWorkOrderStatus({
    required WorkOrderEntity workOrder,
    required WorkOrderStatus status,
  }) async {
    emit(state.copyWith(status: StateStatus.saving));

    final now = DateTime.now();

    final computedStartedAt =
        workOrder.startedAt ??
        (status == WorkOrderStatus.inProgress
            //*not started yet and it is starting now
            ? now
            : null);

    DateTime? computedCompletedAt = workOrder.completedAt;
    bool annulCompletedAt = false;

    if (status == WorkOrderStatus.completed) {
      //*not completed yet and it is completing now
      computedCompletedAt ??= now;
    } else if (status == WorkOrderStatus.open ||
        status == WorkOrderStatus.inProgress ||
        status == WorkOrderStatus.onHold) {
      computedCompletedAt = null;
      annulCompletedAt = true;
    }

    final updatedWorkOrder = workOrder.copyWith(
      status: status,
      startedAt: computedStartedAt,
      completedAt: computedCompletedAt,
      annulCompletedAt: annulCompletedAt,
      updatedAt: now,
    );

    final dataState = await _useCases.updateWorkOrder(updatedWorkOrder);
    if (isClosed) return false;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      final updatedList = state.workOrders.map((wo) {
        if (wo.id == updatedWorkOrder.id) {
          return updatedWorkOrder;
        }
        return wo;
      }).toList();
      emit(state.copyWith(workOrders: updatedList));

      await loadWorkOrdersAndChangeRequests(showLoading: false);
      return true;
    } else {
      emit(
        state.copyWith(
          status: StateStatus.savingError,
          errorMessage:
              dataState.message ??
              'Erro não esperado para atualizar o status'.hardcoded,
        ),
      );
      showDataStateToast(dataState);
      return false;
    }
  }

  Future<bool> _resumePausedWorkOrder({
    required WorkOrderEntity workOrder,
    required String currentUserId,
    required String pauseId,
  }) async {
    emit(state.copyWith(status: StateStatus.saving));

    final cancelResult = await _useCases.cancelPause(
      CancelPauseParams(
        id: pauseId,
        workOrderId: workOrder.id,
        resumedAt: DateTime.now(),
        resumedById: currentUserId,
      ),
    );
    if (isClosed) return false;

    if (cancelResult is FailureState) {
      final message =
          cancelResult.message ?? 'Erro ao retomar trabalho'.hardcoded;
      emit(
        state.copyWith(status: StateStatus.savingError, errorMessage: message),
      );
      showDataStateToast(cancelResult);
      return false;
    }

    final updatedWorkOrder = workOrder.copyWith(
      status: WorkOrderStatus.inProgress,
      updatedAt: DateTime.now(),
    );
    final updatedList = state.workOrders.map((wo) {
      if (wo.id == workOrder.id) {
        return updatedWorkOrder;
      }
      return wo;
    }).toList();
    emit(state.copyWith(workOrders: updatedList));

    await loadWorkOrdersAndChangeRequests(showLoading: false);
    return true;
  }

  /// Resumes work on a paused or pending-completion work order.
  /// Handles cancelling active pauses, cancelling pending completions,
  /// and transitioning the work order back to inProgress.
  /// Status transitions are handled atomically at the datasource level.
  Future<bool> resumeWork({
    required WorkOrderEntity workOrder,
    required String currentUserId,
    required PauseWorkflowCubit pauseCubit,
  }) async {
    emit(
      state.copyWith(
        sections: withSection(WorkOrdersSection.resumeWork, StateStatus.saving),
      ),
    );

    var success = false;
    try {
      final pendingCompletion = pauseCubit.pendingCompletionRequest;
      final activePause = pauseCubit.activePauseRequest;

      if (workOrder.status.isPendingConclusionApproval &&
          pendingCompletion != null) {
        success = await pauseCubit.reviewCompletion(
          id: pendingCompletion.id,
          status: PauseRequestStatus.cancelled,
          reviewedById: currentUserId,
          workOrderId: workOrder.id,
        );
        if (success) {
          final updatedWorkOrder = workOrder.copyWith(
            status: WorkOrderStatus.inProgress,
            updatedAt: DateTime.now(),
          );
          final updatedList = state.workOrders.map((wo) {
            if (wo.id == workOrder.id) {
              return updatedWorkOrder;
            }
            return wo;
          }).toList();
          emit(state.copyWith(workOrders: updatedList));

          await loadWorkOrdersAndChangeRequests(showLoading: false);
        }
      } else if (activePause != null) {
        success = await _resumePausedWorkOrder(
          workOrder: workOrder,
          currentUserId: currentUserId,
          pauseId: activePause.id,
        );
      } else {
        success = await changeWorkOrderStatus(
          workOrder: workOrder,
          status: WorkOrderStatus.inProgress,
        );
      }

      if (success) {
        await pauseCubit.loadPauseRequests(workOrder.id);
      }
    } finally {
      if (!isClosed) {
        emit(
          state.copyWith(
            sections: withSection(
              WorkOrdersSection.resumeWork,
              StateStatus.loaded,
            ),
          ),
        );
      }
    }

    return success;
  }

  /// Optimistically updates the status of a specific work order in local state
  /// and optionally triggers a background sync without showing a loading spinner.
  void updateLocalWorkOrderStatus(
    String workOrderId,
    WorkOrderStatus newStatus, {
    bool syncRemotely = false,
  }) {
    final updatedList = state.workOrders.map((wo) {
      if (wo.id == workOrderId) {
        return wo.copyWith(status: newStatus);
      }
      return wo;
    }).toList();

    emit(state.copyWith(workOrders: updatedList));

    if (syncRemotely) {
      unawaited(loadWorkOrdersAndChangeRequests(showLoading: false));
    }
  }

  /// Directly concludes a work order (when user has permission and no pending pauses).
  Future<bool> concludeDirectly({required WorkOrderEntity workOrder}) =>
      changeWorkOrderStatus(
        workOrder: workOrder,
        status: WorkOrderStatus.completed,
      );

  Future<bool> deleteWorkOrder(String id) async {
    emit(state.copyWith(status: StateStatus.deleting));
    final dataState = await _useCases.deleteWorkOrder(id);
    if (isClosed) return false;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      await loadWorkOrdersAndChangeRequests(showLoading: false);
      return true;
    } else {
      emit(
        state.copyWith(
          status: StateStatus.deletingError,
          errorMessage: state.errorMessage,
        ),
      );
      showDataStateToast(dataState);
      return false;
    }
  }

  Future<void> createChangeRequest(WorkOrderChangeRequestEntity request) async {
    emit(state.copyWith(status: StateStatus.saving));
    final dataState = await _useCases.createChangeRequest(request);
    if (isClosed) return;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      showSuccessToast(
        'Solicitação de alteração enviada com sucesso'.hardcoded,
      );
      await loadWorkOrdersAndChangeRequests(showLoading: false);
    } else {
      emit(
        state.copyWith(
          status: StateStatus.savingError,
          errorMessage: state.errorMessage,
        ),
      );
      showDataStateToast(dataState);
    }
  }

  Future<void> reviewChangeRequest(ReviewChangeRequestParams params) async {
    emit(state.copyWith(status: StateStatus.saving));
    final dataState = await _useCases.reviewChangeRequest(params);
    if (isClosed) return;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      showSuccessToast(
        'Solicitação de alteração avaliada com sucesso'.hardcoded,
      );
      await loadWorkOrdersAndChangeRequests(showLoading: false);
    } else {
      emit(
        state.copyWith(
          status: StateStatus.savingError,
          errorMessage: state.errorMessage,
        ),
      );
      showDataStateToast(dataState);
    }
  }

  Future<void> navigateToCreateUpdateWorkOrder(
    String? workOrderId, {
    AttachmentsCubit? attachmentsCubit,
  }) async {
    final result = await pushRoute<dynamic>(
      CreateUpdateWorkOrderRoute(
        workOrderId: workOrderId,
        attachmentsCubit: attachmentsCubit,
      ),
    );
    if (result == true && workOrderId != null) {
      //! very important to update the correct cubit that is being used in the previous screen
      //!since using getIt.get<AttachmentsCubit>() would get a new instance every time
      await attachmentsCubit?.refreshAttachments();
    }
  }

  Future<void> navigateToWorkOrderDetails(String workOrderId) async {
    await pushRoute(WorkOrderDetailsRoute(workOrderId: workOrderId));
  }

  Future<void> navigateToWorkOrderPendingRequests(
    WorkOrderEntity workOrder,
    String currentUserId,
  ) async {
    await pushRoute(
      WorkOrderPendingRequestsRoute(
        workOrder: workOrder,
        currentUserId: currentUserId,
      ),
    );
  }

  Future<void> navigateToCreateSlaPolicy() async {
    await pushRoute(CreateUpdateSlaPolicyRoute());
  }
}
