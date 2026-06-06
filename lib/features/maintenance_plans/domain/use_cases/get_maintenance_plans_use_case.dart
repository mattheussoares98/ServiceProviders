import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/maintenance_plans/domain/repositories/maintenance_plans_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class GetMaintenancePlansUseCase implements UseCase<String, String> {
  GetMaintenancePlansUseCase({required MaintenancePlansRepository maintenancePlansRepository})
      : _maintenancePlansRepository = maintenancePlansRepository;

  final MaintenancePlansRepository _maintenancePlansRepository;

  @override
  FutureData<String> call(String request) async => const SuccessState(data: '');
}
