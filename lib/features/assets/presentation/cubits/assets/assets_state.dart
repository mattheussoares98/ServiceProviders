part of 'assets_cubit.dart';

class AssetsState extends BaseState {
  const AssetsState({
    required this.assets,
    this.hasAssets = false,
    super.sections,
  });

  const AssetsState.initial()
    : assets = const [],
      hasAssets = false,
      super();

  final List<AssetEntity> assets;
  final bool hasAssets;

  AssetsState copyWith({
    List<AssetEntity>? assets,
    bool? hasAssets,
    Map<SectionKey, SectionState>? sections,
  }) {
    return AssetsState(
      assets: assets ?? this.assets,
      hasAssets: hasAssets ?? this.hasAssets,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [assets, hasAssets, sections];
}
