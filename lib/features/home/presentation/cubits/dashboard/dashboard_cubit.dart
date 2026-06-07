import 'dart:async';

import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_entity.dart';
import 'package:clean_architecture/features/home/presentation/cubits/dashboard/dashboard_cubit_use_cases.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_status.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:injectable/injectable.dart';

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
    if (user.id.isEmpty) {
      emit(
        state.copyWith(
          status: StateStatus.error,
          errorMessage: 'Usuário não autenticado'.hardcoded,
        ),
      );
      return;
    }

    final userProfileResult = await _useCases.getUserProfileById.call(user.id);

    if (userProfileResult is FailureState) {
      emit(
        state.copyWith(
          status: StateStatus.error,
          errorMessage:
              (userProfileResult as FailureState).message ??
              'Erro ao carregar perfil'.hardcoded,
        ),
      );
      return;
    }

    final companyId = userProfileResult.data!.companyId;

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
          status: StateStatus.error,
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
          status: StateStatus.error,
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

    emit(
      state.copyWith(
        status: StateStatus.loaded,
        openWorkOrdersCount: openCount,
        inProgressWorkOrdersCount: inProgressCount,
        pendingRevisionsCount: pendingRevisionsCount,
        recentWorkOrders: recentWorkOrders,
      ),
    );
  }
}
