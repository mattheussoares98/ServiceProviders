import 'dart:async';

import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/upload_status.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/cubits/attachments/attachments_cubit.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_profile_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_change_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_provider_work_orders_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_orders_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/value_objects/work_order_filter.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'work_orders_state.dart';

@injectable
class WorkOrdersCubit extends BaseCubit<WorkOrdersState> {
  WorkOrdersCubit({required WorkOrdersCubitUseCases useCases})
    : _useCases = useCases,
      super(const WorkOrdersState.initial()) {
    _syncSubscription = _useCases.syncEngine.onSyncCompleted.listen((_) {
      _refreshWorkOrders();
    });
    _initRealtime();
  }

  final WorkOrdersCubitUseCases _useCases;
  StreamSubscription<void>? _syncSubscription;
  StreamSubscription<RealtimeEvent<WorkOrderEntity>>? _realtimeSubscription;
  final _realtimeEventsController =
      StreamController<RealtimeEvent<WorkOrderEntity>>.broadcast();

  Stream<RealtimeEvent<WorkOrderEntity>> get realtimeEvents =>
      _realtimeEventsController.stream;

  void _initRealtime() {
    _realtimeSubscription?.cancel();
    final companyId = _isProviderMode ? null : _useCases.getActiveCompanyId();
    _realtimeSubscription = _useCases
        .watchWorkOrdersRealtime(companyId: companyId)
        .listen(_handleRealtimeEvent);
  }

  void _handleRealtimeEvent(RealtimeEvent<WorkOrderEntity> event) {
    if (isClosed) return;

    switch (event.eventType) {
      case RealtimeEventType.update:
        if (event.entity != null) {
          final exists = state.workOrders.any((wo) => wo.id == event.id);
          if (exists) {
            if (event.entity!.deletedAt != null) {
              final updated = state.workOrders
                  .where((wo) => wo.id != event.id)
                  .toList();
              emit(state.copyWith(workOrders: updated));
            } else {
              final updated = state.workOrders
                  .map((wo) => wo.id == event.id ? event.entity! : wo)
                  .toList();
              emit(state.copyWith(workOrders: updated));
            }
          }
        }
      case RealtimeEventType.insert:
        if (event.entity != null && event.entity!.deletedAt == null) {
          final exists = state.workOrders.any((wo) => wo.id == event.id);
          if (!exists) {
            emit(
              state.copyWith(workOrders: [event.entity!, ...state.workOrders]),
            );
          }
        }
      case RealtimeEventType.delete:
        final updated = state.workOrders
            .where((wo) => wo.id != event.id)
            .toList();
        emit(state.copyWith(workOrders: updated));
    }

    if (!_realtimeEventsController.isClosed) {
      _realtimeEventsController.add(event);
    }
  }

  static const _pageSize = 50;

  /// Provider mode changes how work orders are scoped and fetched, so the
  /// entry points shared with internal mode branch on it.
  bool get _isProviderMode =>
      AppMode.fromName(_useCases.getSelectedMode()) == AppMode.provider;

  /// Reload after a write. Provider mode must never fall through to the
  /// internal path: that one scopes by `getActiveCompanyId()`, which for a
  /// provider resolves to the wrong company (or none) and empties the list.
  Future<void> _refreshWorkOrders() => _isProviderMode
      ? loadProviderWorkOrders(showLoading: false)
      : loadWorkOrdersAndChangeRequests(showLoading: false);

  Future<bool> loadWorkOrdersAndChangeRequests({
    bool showLoading = true,
    WorkOrderFilter? filter,
  }) async {
    final activeFilter = filter ?? state.activeFilter;
    final companyId = _useCases.getActiveCompanyId();

    if (showLoading) {
      emit(
        state.copyWith(
          activeFilter: activeFilter,
          sections: withSection(BaseSections.load, SectionStatus.running),
        ),
      );
    } else if (filter != null) {
      emit(state.copyWith(activeFilter: activeFilter));
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
          sections: withSection(BaseSections.load, SectionStatus.success),
          workOrders: fetchedOrders,
          changeRequests: changeRequestsResult.data,
          activeFilter: activeFilter,
          hasMorePages: fetchedOrders.length == _pageSize,
          isLoadingMore: false,
        ),
      );
      return true;
    } else {
      final errorMessage = workOrdersResult is FailureState
          ? workOrdersResult.message
          : changeRequestsResult.message;
      emit(
        state.copyWith(
          sections: withSection(
            BaseSections.load,
            SectionStatus.error,
            errorMessage: errorMessage,
          ),
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
      emit(
        state.copyWith(
          sections: withSection(BaseSections.load, SectionStatus.running),
        ),
      );
    }

    final companies = await _loadProviderCompanies();
    if (isClosed) return false;

    if (companies.isEmpty) {
      emit(
        state.copyWith(
          sections: withSection(BaseSections.load, SectionStatus.success),
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
          sections: withSection(BaseSections.load, SectionStatus.success),
          workOrders: fetched,
          changeRequests: const [],
          providerCompanies: companies,
          activeFilter: activeFilter,
          hasMorePages: fetched.length == _pageSize,
          isLoadingMore: false,
        ),
      );
      return true;
    }

    emit(
      state.copyWith(
        sections: withSection(
          BaseSections.load,
          SectionStatus.error,
          errorMessage: result.message,
        ),
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
      final companies = [
        ...companiesResult.data ?? <ServiceProviderCompanyEntity>[],
      ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return companies;
    }
    return const [];
  }

  Future<bool> loadWorkOrderById(String id, {bool showLoading = false}) async {
    if (showLoading) {
      emit(
        state.copyWith(
          sections: withSection(BaseSections.load, SectionStatus.running),
        ),
      );
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
          sections: withSection(BaseSections.load, SectionStatus.success),
          workOrders: updatedList,
        ),
      );
      return true;
    } else {
      if (showLoading) {
        emit(
          state.copyWith(
            sections: withSection(
              BaseSections.load,
              SectionStatus.error,
              errorMessage: dataState.message,
            ),
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

  Future<bool> saveWorkOrder({
    required String id,
    required bool isEditing,
    String? assetId,
    required String locationId,
    String? assignedToId,
    String? areaId,
    String? createdById,
    String? createdByProviderProfileId,
    String? companyId,
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
    emit(
      state.copyWith(
        sections: withSection(
          WorkOrdersSections.saveWorkOrder,
          SectionStatus.running,
        ),
      ),
    );

    final now = DateTime.now();

    // An edit must keep the work order's own tenant. Deriving it from the
    // session would reassign the record to whatever company is active — in
    // provider mode that is the user's internal employer, or nothing at all.
    // Only a brand new work order belongs to the active company.
    final existing = isEditing
        ? state.workOrders.firstWhereOrNull((workOrder) => workOrder.id == id)
        : null;
    // A provider passes the contracting company explicitly: it has no active
    // company of its own to fall back on.
    final tenantId =
        existing?.companyId ?? companyId ?? _useCases.getActiveCompanyId();

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
      companyId: tenantId,
      assetId: assetId?.trimToNull(),
      locationId: locationId,
      areaId: areaId,
      assignedToId: assignedToId?.trimToNull(),
      createdById: isEditing
          ? (createdById ?? existing?.createdById)
          : createdById,
      createdByProviderProfileId: isEditing
          ? (createdByProviderProfileId ?? existing?.createdByProviderProfileId)
          : createdByProviderProfileId,
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
      slaDeadlineAt: existing?.slaDeadlineAt,
      slaBreached: existing?.slaBreached ?? false,
      netActiveDuration: existing?.netActiveDuration,
      completionReason: existing?.completionReason,
      completionResponsibility: existing?.completionResponsibility,
      completionSectorId: existing?.completionSectorId,
      openedBy: isEditing ? (existing?.openedBy ?? openedBy) : openedBy,
    );

    final DataState<bool> dataState = isEditing
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
                sections: withSection(
                  WorkOrdersSections.saveWorkOrder,
                  SectionStatus.error,
                ),
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

      emit(
        state.copyWith(
          sections: withSection(
            WorkOrdersSections.saveWorkOrder,
            SectionStatus.success,
          ),
        ),
      );
      await _refreshWorkOrders();
      return true;
    } else {
      emit(
        state.copyWith(
          sections: withSection(
            WorkOrdersSections.saveWorkOrder,
            SectionStatus.error,
          ),
        ),
      );
      showDataStateToast(dataState);
      return false;
    }
  }

  /// The provider company a new work order is opened for.
  ///
  /// [preferredId] is an explicit pick from the form, offered only when the
  /// provider serves more than one client and has not narrowed the list. The
  /// list filter's own selection comes next, and a provider that serves a
  /// single client never has to choose at all.
  ServiceProviderCompanyEntity? _providerCompanyToOpenFor(String? preferredId) {
    final companies = state.providerCompanies;
    final id = preferredId ?? state.selectedProviderCompanyId;

    if (id == null) {
      return companies.length == 1 ? companies.first : null;
    }
    return companies.firstWhereOrNull((company) => company.id == id);
  }

  /// Opens a work order from provider mode (V2 §1.3 / Q5).
  ///
  /// The tenant is the contracting company that hired the provider company, and
  /// authorship is a `service_provider_profiles` row: a provider-only user has
  /// no `user_profiles` row for `created_by_id` to point at. The work order is
  /// assigned to the author's own provider company from the start.
  ///
  /// Both companies come from state — [serviceProviderCompanyId] only overrides
  /// the resolution described in [_providerCompanyToOpenFor].
  Future<bool> createProviderWorkOrder({
    required String id,
    required String locationId,
    String? areaId,
    required String title,
    String? description,
    required Priority priority,
    required WorkOrderType type,
    DateTime? scheduledDate,
    int? estimatedDuration,
    String? serviceProviderCompanyId,
    AttachmentsCubit? attachmentsCubit,
  }) async {
    final company = _providerCompanyToOpenFor(serviceProviderCompanyId);
    if (company == null) {
      showErrorToast('Selecione a empresa contratante'.hardcoded);
      return false;
    }

    emit(
      state.copyWith(
        sections: withSection(
          WorkOrdersSections.saveWorkOrder,
          SectionStatus.running,
        ),
      ),
    );

    final profileResult = await _useCases.getSessionProviderProfile(company.id);
    if (isClosed) return false;

    if (profileResult is! SuccessState<ServiceProviderProfileEntity>) {
      emit(
        state.copyWith(
          sections: withSection(
            WorkOrdersSections.saveWorkOrder,
            SectionStatus.error,
            errorMessage: profileResult.message,
          ),
        ),
      );
      showDataStateToast(profileResult);
      return false;
    }

    final profileId = profileResult.data!.id;

    return saveWorkOrder(
      id: id,
      isEditing: false,
      companyId: company.companyId,
      locationId: locationId,
      areaId: areaId,
      title: title,
      description: description,
      priority: priority,
      status: WorkOrderStatus.open,
      type: type,
      scheduledDate: scheduledDate,
      estimatedDuration: estimatedDuration,
      serviceProviderCompanyId: company.id,
      providerProfileId: profileId,
      createdByProviderProfileId: profileId,
      openedBy: AppMode.provider,
      attachmentsCubit: attachmentsCubit,
    );
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
      unawaited(_refreshWorkOrders());
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

  Future<void> navigateToCreateProviderWorkOrder() async {
    await pushRoute(const CreateProviderWorkOrderRoute());
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

  @override
  Future<void> close() {
    _syncSubscription?.cancel();
    _realtimeSubscription?.cancel();
    _realtimeEventsController.close();
    return super.close();
  }
}
