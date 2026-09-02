part of 'maintenance_plans_cubit.dart';

class MaintenancePlansState extends BaseState {
  const MaintenancePlansState({super.sections});

  const MaintenancePlansState.empty() : super();

  @override
  List<Object?> get props => [sections];
}