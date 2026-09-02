part of 'locations_cubit.dart';

class LocationsState extends BaseState {
  const LocationsState({
    required this.locations,
    required this.allAreas,
    required this.areasByLocation,
    super.sections = const {},
  });

  const LocationsState.initial()
    : locations = const [],
      areasByLocation = const <String, List<AreaEntity>>{},
      allAreas = const [],
      super(sections: const {});

  final List<LocationEntity> locations;
  final Map<String, List<AreaEntity>> areasByLocation;
  final List<AreaEntity> allAreas;

  LocationsState copyWith({
    List<LocationEntity>? locations,
    List<AreaEntity>? allAreas,
    Map<String, List<AreaEntity>>? areasByLocation,
    Map<SectionKey, SectionState>? sections,
  }) {
    return LocationsState(
      locations: locations ?? this.locations,
      allAreas: allAreas ?? this.allAreas,
      areasByLocation: areasByLocation ?? this.areasByLocation,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [
    locations,
    areasByLocation,
    allAreas,
    sections,
  ];
}
