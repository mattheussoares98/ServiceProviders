part of 'sectors_cubit.dart';

class SectorsState extends BaseState {
  const SectorsState({
    super.sections = const {},
    this.sectors = const [],
    this.selectedSector,
  });

  const SectorsState.initial() : this();

  final List<SectorEntity> sectors;
  final SectorEntity? selectedSector;

  SectorsState copyWith({
    Map<SectionKey, SectionState>? sections,
    List<SectorEntity>? sectors,
    SectorEntity? selectedSector,
    bool? annulSelectedSector,
  }) {
    return SectorsState(
      sections: sections ?? this.sections,
      sectors: sectors ?? this.sectors,
      selectedSector: annulSelectedSector == true
          ? null
          : (selectedSector ?? this.selectedSector),
    );
  }

  @override
  List<Object?> get props => [sections, sectors, selectedSector];
}
