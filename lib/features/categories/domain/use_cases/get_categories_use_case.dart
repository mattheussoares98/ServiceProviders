import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/categories/domain/repositories/categories_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class GetCategoriesUseCase implements UseCase<String, String> {
  GetCategoriesUseCase({required CategoriesRepository categoriesRepository})
      : _categoriesRepository = categoriesRepository;

  final CategoriesRepository _categoriesRepository;

  @override
  FutureData<String> call(String request) async => const SuccessState(data: '');
}
