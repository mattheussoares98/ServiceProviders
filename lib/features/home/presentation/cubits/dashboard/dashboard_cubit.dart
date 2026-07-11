import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_entity.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/dashboard/dashboard_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'dashboard_state.dart';

@injectable
class DashboardCubit extends BaseCubit<DashboardState> {
  DashboardCubit({required DashboardCubitUseCases useCases})
    : _useCases = useCases,
      super(const DashboardState.initial());

  final DashboardCubitUseCases _useCases;

  Future<void> loadDashboardData() async {
    emit(state.copyWith(status: StateStatus.loading, annulErrorMessage: true));

    final user = _useCases.getSessionUser.call();
    if (user.id.isEmpty || user.companyId.isEmpty) {
      emit(
        state.copyWith(
          status: StateStatus.loadingError,
          errorMessage: 'Usuário não autenticado'.hardcoded,
        ),
      );
      return;
    }

    final companyId = user.companyId;

    // Run work orders and assets calls concurrently
    final results = await Future.wait([
      _useCases.getWorkOrders.call(companyId),
      _useCases.getAssets.call(companyId),
    ]);

    final workOrdersResult = results[0];
    final assetsResult = results[1];

    if (workOrdersResult is FailureState) {
      emit(
        state.copyWith(
          status: StateStatus.loadingError,
          errorMessage:
              (workOrdersResult as FailureState).message ??
              'Erro ao carregar ordens de serviço'.hardcoded,
        ),
      );
      return;
    }

    if (assetsResult is FailureState) {
      emit(
        state.copyWith(
          status: StateStatus.loadingError,
          errorMessage:
              (assetsResult as FailureState).message ??
              'Erro ao carregar equipamentos'.hardcoded,
        ),
      );
      return;
    }

    final workOrders =
        (workOrdersResult as SuccessState<List<WorkOrderEntity>>).data ??
        const [];
    final assets =
        (assetsResult as SuccessState<List<AssetEntity>>).data ?? const [];

    // 1. Counts
    final openCount = workOrders
        .where((wo) => wo.status == WorkOrderStatus.open)
        .length;
    final inProgressCount = workOrders
        .where((wo) => wo.status == WorkOrderStatus.inProgress)
        .length;

    // Pending Revisions: assets where revisionForecast is not null and is before today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final pendingRevisionsCount = assets.where((asset) {
      final forecast = asset.revisionForecast;
      if (forecast == null) return false;
      return forecast.isBefore(today) || forecast.isAtSameMomentAs(today);
    }).length;

    // 2. Recent Work Orders (take 5 sorted by updatedAt desc)
    final sortedWorkOrders = [...workOrders]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final recentWorkOrders = sortedWorkOrders.take(5).toList();

    // 3. Active Work Orders (technician has running orders, sorted by updatedAt desc)
    final activeWorkOrders =
        workOrders
            .where((wo) => wo.status == WorkOrderStatus.inProgress)
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    emit(
      state.copyWith(
        status: StateStatus.loaded,
        openWorkOrdersCount: openCount,
        inProgressWorkOrdersCount: inProgressCount,
        pendingRevisionsCount: pendingRevisionsCount,
        recentWorkOrders: recentWorkOrders,
        userProfile: user,
        activeWorkOrders: activeWorkOrders,
        annulActiveWorkOrders: activeWorkOrders.isEmpty,
      ),
    );
  }

  Future<void> navigateToCreateUpdateWorkOrder([String? workOrderId]) async {
    await pushRoute(CreateUpdateWorkOrderRoute(workOrderId: workOrderId));
  }

  Future<void> navigateToWorkOrderDetails(String workOrderId) async {
    await pushRoute(WorkOrderDetailsRoute(workOrderId: workOrderId));
  }

  Future<void> navigateToCreateUpdateAsset() async {
    await pushRoute(CreateUpdateAssetRoute());
  }
}
