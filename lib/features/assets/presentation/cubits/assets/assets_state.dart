part of 'assets_cubit.dart';

class AssetsState extends BaseState {
  const AssetsState({
    required this.assets,
    super.status = StateStatus.initial,
    super.errorMessage = '',
  });

  const AssetsState.initial()
      : assets = const [],
        super(status: StateStatus.initial, errorMessage: '');

  final List<AssetEntity> assets;

  AssetsState copyWith({
    List<AssetEntity>? assets,
    StateStatus? status,
    String? errorMessage,
  }) {
    return AssetsState(
      assets: assets ?? this.assets,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [assets, status, errorMessage];
}