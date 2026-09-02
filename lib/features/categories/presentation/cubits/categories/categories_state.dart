part of 'categories_cubit.dart';

class CategoriesState extends BaseState {
  const CategoriesState({
    required this.categories,
    this.deletingIds = const {},
    super.sections = const {},
  });

  const CategoriesState.initial()
    : categories = const [],
      deletingIds = const {},
      super(sections: const {});

  const CategoriesState.empty()
    : categories = const [],
      deletingIds = const {},
      super(sections: const {});

  final List<CategoryEntity> categories;
  final Set<String> deletingIds;

  CategoriesState copyWith({
    List<CategoryEntity>? categories,
    Set<String>? deletingIds,
    Map<SectionKey, SectionState>? sections,
  }) {
    return CategoriesState(
      categories: categories ?? this.categories,
      deletingIds: deletingIds ?? this.deletingIds,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [
    categories,
    deletingIds,
    sections,
  ];
}
