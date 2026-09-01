part of 'sectors_cubit.dart';

class SectorsState extends BaseState {
  const SectorsState({
    super.status,
    super.errorMessage,
    super.sections = const {},
    this.sectors = const [],
    this.selectedSector,
  });

  const SectorsState.initial() : this();

  final List<SectorEntity> sectors;
  final SectorEntity? selectedSector;

  SectorsState copyWith({
    DataStatus? status,
    String? errorMessage,
    bool? annulErrorMessage,
    Map<SectionKey, SectionStatus>? sections,
    List<SectorEntity>? sectors,
    SectorEntity? selectedSector,
    bool? annulSelectedSector,
  }) {
    return SectorsState(
      status: status ?? this.status,
      errorMessage: annulErrorMessage == true
          ? null
          : (errorMessage ?? this.errorMessage),
      sections: sections ?? this.sections,
      sectors: sectors ?? this.sectors,
      selectedSector: annulSelectedSector == true
          ? null
          : (selectedSector ?? this.selectedSector),
    );
  }

  @override
  List<Object?> get props => [...super.props, sectors, selectedSector];
}
