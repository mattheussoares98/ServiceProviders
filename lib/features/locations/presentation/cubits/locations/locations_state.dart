part of 'locations_cubit.dart';

class LocationsState extends BaseState with PendingActionsState {
  const LocationsState({
    required this.locations,
    required this.areasByLocation,
    this.deletingIds = const {},
    this.updatingIds = const {},
    super.status = StateStatus.initial,
    super.errorMessage = '',
  });

  const LocationsState.initial()
    : locations = const [],
      areasByLocation = const <String, List<AreaEntity>>{},
      deletingIds = const {},
      updatingIds = const {},
      super(status: StateStatus.initial, errorMessage: '');

  final List<LocationEntity> locations;
  final Map<String, List<AreaEntity>> areasByLocation;

  @override
  final Set<String> deletingIds;

  @override
  final Set<String> updatingIds;

  LocationsState copyWith({
    List<LocationEntity>? locations,
    Map<String, List<AreaEntity>>? areasByLocation,
    Set<String>? deletingIds,
    Set<String>? updatingIds,
    StateStatus? status,
    String? errorMessage,
    bool? annulErrorMessage,
  }) {
    return LocationsState(
      locations: locations ?? this.locations,
      areasByLocation: areasByLocation ?? this.areasByLocation,
      deletingIds: deletingIds ?? this.deletingIds,
      updatingIds: updatingIds ?? this.updatingIds,
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
        deletingIds,
        updatingIds,
        status,
        errorMessage,
      ];
}
