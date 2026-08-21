import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_selected_mode_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_session_provider_profile_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/work_order_observations_use_cases.dart';

@LazySingleton()
class WorkOrderObservationsCubitUseCases {
  const WorkOrderObservationsCubitUseCases({
    required this.getObservations,
    required this.createObservation,
    required this.deleteObservation,
    required this.getSessionUser,
    required this.getSelectedMode,
    required this.getSessionProviderProfile,
  });

  final GetWorkOrderObservationsUseCase getObservations;
  final CreateWorkOrderObservationUseCase createObservation;
  final DeleteWorkOrderObservationUseCase deleteObservation;
  final GetSessionUserUseCase getSessionUser;
  final GetSelectedModeUseCase getSelectedMode;
  final GetSessionProviderProfileUseCase getSessionProviderProfile;
}

