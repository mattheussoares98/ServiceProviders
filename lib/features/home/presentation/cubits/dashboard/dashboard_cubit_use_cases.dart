import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/assets/domain/use_cases/get_assets_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_orders_use_case.dart';

@LazySingleton()
class DashboardCubitUseCases {
  const DashboardCubitUseCases({
    required this.getWorkOrders,
    required this.getAssets,
    required this.getSessionUser,
    required this.getActiveCompanyId,
  });

  final GetWorkOrdersUseCase getWorkOrders;
  final GetAssetsUseCase getAssets;
  final GetSessionUserUseCase getSessionUser;
  final GetActiveCompanyIdUseCase getActiveCompanyId;
}
