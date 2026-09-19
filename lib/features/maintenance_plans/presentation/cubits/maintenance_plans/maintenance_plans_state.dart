part of 'maintenance_plans_cubit.dart';

enum MaintenancePlansSections implements SectionKey {
  save,
  delete,
  toggleActive,
}

class MaintenancePlansState extends BaseState {
  const MaintenancePlansState({
    super.sections = const {},
    this.maintenancePlans = const [],
    this.selectedMaintenancePlan,
  });

  const MaintenancePlansState.initial() : this();

  const MaintenancePlansState.empty() : this();

  final List<MaintenancePlanEntity> maintenancePlans;
  final MaintenancePlanEntity? selectedMaintenancePlan;

  List<MaintenancePlanEntity> get activePlans =>
      maintenancePlans.where((p) => p.isActive).toList();

  List<MaintenancePlanEntity> get plansWithErrors => maintenancePlans
      .where((p) => p.lastError != null && p.lastError!.isNotEmpty)
      .toList();

  MaintenancePlansState copyWith({
    Map<SectionKey, SectionState>? sections,
    List<MaintenancePlanEntity>? maintenancePlans,
    MaintenancePlanEntity? selectedMaintenancePlan,
    bool? annulSelectedMaintenancePlan,
  }) {
    return MaintenancePlansState(
      sections: sections ?? this.sections,
      maintenancePlans: maintenancePlans ?? this.maintenancePlans,
      selectedMaintenancePlan: annulSelectedMaintenancePlan == true
          ? null
          : (selectedMaintenancePlan ?? this.selectedMaintenancePlan),
    );
  }

  @override
  List<Object?> get props => [
    sections,
    maintenancePlans,
    selectedMaintenancePlan,
  ];
}
