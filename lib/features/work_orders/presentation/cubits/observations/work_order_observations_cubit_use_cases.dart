import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/work_order_observations_use_cases.dart';

@LazySingleton()
class WorkOrderObservationsCubitUseCases {
  const WorkOrderObservationsCubitUseCases({
    required this.getObservations,
    required this.createObservation,
    required this.deleteObservation,
  });

  final GetWorkOrderObservationsUseCase getObservations;
  final CreateWorkOrderObservationUseCase createObservation;
  final DeleteWorkOrderObservationUseCase deleteObservation;
}
