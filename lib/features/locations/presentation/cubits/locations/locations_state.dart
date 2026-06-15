part of 'locations_cubit.dart';

class LocationsState extends BaseState {
  const LocationsState({
    required this.locations,
    required this.areasByLocation,
    super.status = StateStatus.initial,
    this.errorMessage = '',
  });

  const LocationsState.initial()
    : locations = const [],
      areasByLocation = const <String, List<AreaEntity>>{},
      errorMessage = '',
      super(status: StateStatus.initial);

  final List<LocationEntity> locations;
  final Map<String, List<AreaEntity>> areasByLocation;
  final String errorMessage;

  LocationsState copyWith({
    List<LocationEntity>? locations,
    Map<String, List<AreaEntity>>? areasByLocation,
    StateStatus? status,
    String? errorMessage,
  }) {
    return LocationsState(
      locations: locations ?? this.locations,
      areasByLocation: areasByLocation ?? this.areasByLocation,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [locations, areasByLocation, status, errorMessage];
}
