part of 'assets_cubit.dart';

class AssetsState extends BaseState {
  const AssetsState({
    required this.assets,
    super.sections,
  });

  const AssetsState.initial()
    : assets = const [],
      super();

  final List<AssetEntity> assets;

  AssetsState copyWith({
    List<AssetEntity>? assets,
    Map<SectionKey, SectionState>? sections,
  }) {
    return AssetsState(
      assets: assets ?? this.assets,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [assets, sections];
}
