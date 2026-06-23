part of 'assets_cubit.dart';

class AssetsState extends BaseState {
  const AssetsState({
    required this.assets,
    required this.areas,
    required this.categories,
    required this.deletingIds,
    super.status = StateStatus.initial,
    super.errorMessage = '',
  });

  const AssetsState.initial()
    : assets = const [],
      areas = const [],
      categories = const [],
      deletingIds = const {},
      super(status: StateStatus.initial, errorMessage: '');

  final List<AssetEntity> assets;
  final List<AreaEntity> areas;
  final List<CategoryEntity> categories;
  final Set<String> deletingIds;

  AssetsState copyWith({
    List<AssetEntity>? assets,
    List<AreaEntity>? areas,
    List<CategoryEntity>? categories,
    StateStatus? status,
    String? errorMessage,
    Set<String>? deletingIds,
    bool? annulErrorMessage,
  }) {
    return AssetsState(
      assets: assets ?? this.assets,
      areas: areas ?? this.areas,
      categories: categories ?? this.categories,
      status: status ?? this.status,
      errorMessage: annulErrorMessage == true
          ? null
          : errorMessage ?? this.errorMessage,
      deletingIds: deletingIds ?? this.deletingIds,
    );
  }

  @override
  List<Object?> get props => [
    assets,
    areas,
    categories,
    status,
    errorMessage,
    deletingIds,
  ];
}
