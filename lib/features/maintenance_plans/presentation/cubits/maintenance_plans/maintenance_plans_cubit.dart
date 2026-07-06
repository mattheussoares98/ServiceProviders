import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'maintenance_plans_state.dart';

@injectable
class MaintenancePlansCubit extends BaseCubit<MaintenancePlansState> {
  MaintenancePlansCubit() : super(const MaintenancePlansState.empty());
}
