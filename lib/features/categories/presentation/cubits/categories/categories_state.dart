part of 'categories_cubit.dart';

class CategoriesState extends BaseState {
  const CategoriesState({
    required this.categories,
    this.deletingIds = const {},
    super.status = StateStatus.initial,
    super.errorMessage = '',
    super.sections = const {},
  });

  const CategoriesState.initial()
    : categories = const [],
      deletingIds = const {},
      super(
        status: StateStatus.initial,
        errorMessage: '',
        sections: const {},
      );

  const CategoriesState.empty()
    : categories = const [],
      deletingIds = const {},
      super(
        status: StateStatus.initial,
        errorMessage: '',
        sections: const {},
      );

  final List<CategoryEntity> categories;
  final Set<String> deletingIds;

  CategoriesState copyWith({
    List<CategoryEntity>? categories,
    Set<String>? deletingIds,
    StateStatus? status,
    String? errorMessage,
    bool? annulErrorMessage,
    Map<SectionKey, StateStatus>? sections,
  }) {
    return CategoriesState(
      categories: categories ?? this.categories,
      deletingIds: deletingIds ?? this.deletingIds,
      status: status ?? this.status,
      errorMessage: annulErrorMessage == true
          ? null
          : errorMessage ?? this.errorMessage,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [
        categories,
        deletingIds,
        status,
        errorMessage,
        sections,
      ];
}