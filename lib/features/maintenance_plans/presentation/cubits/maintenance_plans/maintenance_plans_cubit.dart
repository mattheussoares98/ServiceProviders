import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:injectable/injectable.dart';

part 'maintenance_plans_state.dart';

@injectable
class MaintenancePlansCubit extends BaseCubit<MaintenancePlansState> {
  MaintenancePlansCubit() : super(const MaintenancePlansState.empty());
}