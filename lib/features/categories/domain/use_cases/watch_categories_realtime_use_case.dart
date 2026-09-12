import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/features/categories/domain/entities/category_entity.dart';
import 'package:o_jogo_da_obra/features/categories/domain/repositories/categories_repository.dart';

@LazySingleton()
class WatchCategoriesRealtimeUseCase {
  const WatchCategoriesRealtimeUseCase({
    required CategoriesRepository categoriesRepository,
  }) : _categoriesRepository = categoriesRepository;

  final CategoriesRepository _categoriesRepository;

  Stream<RealtimeEvent<CategoryEntity>> call({String? companyId}) =>
      _categoriesRepository.watchCategoriesRealtime(companyId: companyId);
}
