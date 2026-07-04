part of 'locations_cubit.dart';

class LocationsState extends BaseState {
  const LocationsState({
    required this.locations,
    required this.allAreas,
    required this.areasByLocation,
    super.status = StateStatus.initial,
    super.errorMessage = '',
  });

  const LocationsState.initial()
    : locations = const [],
      areasByLocation = const <String, List<AreaEntity>>{},
      allAreas = const [],
      super(status: StateStatus.initial, errorMessage: '');

  final List<LocationEntity> locations;
  final Map<String, List<AreaEntity>> areasByLocation;
  final List<AreaEntity> allAreas;

  LocationsState copyWith({
    List<LocationEntity>? locations,
    List<AreaEntity>? allAreas,
    Map<String, List<AreaEntity>>? areasByLocation,
    StateStatus? status,
    String? errorMessage,
    bool? annulErrorMessage,
  }) {
    return LocationsState(
      locations: locations ?? this.locations,
      allAreas: allAreas ?? this.allAreas,
      areasByLocation: areasByLocation ?? this.areasByLocation,
      status: status ?? this.status,
      errorMessage: annulErrorMessage == true
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    locations,
    areasByLocation,
    allAreas,
    status,
    errorMessage,
  ];
}
