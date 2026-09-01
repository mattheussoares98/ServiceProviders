part of 'assets_cubit.dart';

class AssetsState extends BaseState {
  const AssetsState({
    required this.assets,
    super.status = DataStatus.initial,
    super.errorMessage = '',
    super.sections,
  });

  const AssetsState.initial()
    : assets = const [],
      super(status: DataStatus.initial, errorMessage: '');

  final List<AssetEntity> assets;

  AssetsState copyWith({
    List<AssetEntity>? assets,
    DataStatus? status,
    String? errorMessage,
    bool? annulErrorMessage,
    Map<SectionKey, SectionStatus>? sections,
  }) {
    return AssetsState(
      assets: assets ?? this.assets,
      status: status ?? this.status,
      errorMessage: annulErrorMessage == true
          ? null
          : errorMessage ?? this.errorMessage,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [assets, status, errorMessage, sections];
}
