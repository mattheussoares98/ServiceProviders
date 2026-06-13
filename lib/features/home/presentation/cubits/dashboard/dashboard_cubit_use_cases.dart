import 'package:clean_architecture/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:clean_architecture/features/assets/domain/use_cases/get_assets_use_case.dart';
import 'package:clean_architecture/features/work_orders/domain/use_cases/get_work_orders_use_case.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class DashboardCubitUseCases {
  const DashboardCubitUseCases({
    required this.getWorkOrders,
    required this.getAssets,
    required this.getSessionUser,
  });

  final GetWorkOrdersUseCase getWorkOrders;
  final GetAssetsUseCase getAssets;
  final GetSessionUserUseCase getSessionUser;
}
