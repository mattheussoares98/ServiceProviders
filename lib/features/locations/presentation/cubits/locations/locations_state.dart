part of 'locations_cubit.dart';

class LocationsState extends BaseState {
  const LocationsState({
    required this.locations,
    required this.allAreas,
    required this.areasByLocation,
    this.hasLocations = false,
    this.hasAreas = false,
    super.sections = const {},
  });

  const LocationsState.initial()
    : locations = const [],
      areasByLocation = const <String, List<AreaEntity>>{},
      allAreas = const [],
      hasLocations = false,
      hasAreas = false,
      super(sections: const {});

  final List<LocationEntity> locations;
  final Map<String, List<AreaEntity>> areasByLocation;
  final List<AreaEntity> allAreas;
  final bool hasLocations;
  final bool hasAreas;

  LocationsState copyWith({
    List<LocationEntity>? locations,
    List<AreaEntity>? allAreas,
    Map<String, List<AreaEntity>>? areasByLocation,
    bool? hasLocations,
    bool? hasAreas,
    Map<SectionKey, SectionState>? sections,
  }) {
    return LocationsState(
      locations: locations ?? this.locations,
      allAreas: allAreas ?? this.allAreas,
      areasByLocation: areasByLocation ?? this.areasByLocation,
      hasLocations: hasLocations ?? this.hasLocations,
      hasAreas: hasAreas ?? this.hasAreas,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [
    locations,
    areasByLocation,
    allAreas,
    hasLocations,
    hasAreas,
    sections,
  ];
}
