part of 'assets_cubit.dart';

class AssetsState extends BaseState {
  const AssetsState({
    required this.assets,
    required this.locations,
    required this.areas,
    required this.categories,
    super.status = StateStatus.initial,
    super.errorMessage = '',
  });

  const AssetsState.initial()
    : assets = const [],
      locations = const [],
      areas = const [],
      categories = const [],
      super(status: StateStatus.initial, errorMessage: '');

  final List<AssetEntity> assets;
  final List<LocationEntity> locations;
  final List<AreaEntity> areas;
  final List<CategoryEntity> categories;

  AssetsState copyWith({
    List<AssetEntity>? assets,
    List<LocationEntity>? locations,
    List<AreaEntity>? areas,
    List<CategoryEntity>? categories,
    StateStatus? status,
    String? errorMessage,
    bool? annulErrorMessage,
  }) {
    return AssetsState(
      assets: assets ?? this.assets,
      locations: locations ?? this.locations,
      areas: areas ?? this.areas,
      categories: categories ?? this.categories,
      status: status ?? this.status,
      errorMessage: annulErrorMessage == true
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    assets,
    locations,
    areas,
    categories,
    status,
    errorMessage,
  ];
}
