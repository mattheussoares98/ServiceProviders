part of 'categories_cubit.dart';

class CategoriesState extends BaseState {
  const CategoriesState({
    required this.categories,
    this.deletingIds = const {},
    super.status = StateStatus.initial,
    super.errorMessage = '',
  });

  const CategoriesState.initial()
    : categories = const [],
      deletingIds = const {},
      super(status: StateStatus.initial, errorMessage: '');

  const CategoriesState.empty()
    : categories = const [],
      deletingIds = const {},
      super(status: StateStatus.initial, errorMessage: '');

  final List<CategoryEntity> categories;
  final Set<String> deletingIds;

  CategoriesState copyWith({
    List<CategoryEntity>? categories,
    Set<String>? deletingIds,
    StateStatus? status,
    String? errorMessage,
    bool? annulErrorMessage,
  }) {
    return CategoriesState(
      categories: categories ?? this.categories,
      deletingIds: deletingIds ?? this.deletingIds,
      status: status ?? this.status,
      errorMessage: annulErrorMessage == true
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        categories,
        deletingIds,
        status,
        errorMessage,
      ];
}