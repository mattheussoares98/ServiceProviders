import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/{{feature.snakeCase()}}/domain/repositories/{{feature.snakeCase()}}_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class Get{{feature.pascalCase()}}UseCase implements UseCase<String, String> {
  Get{{feature.pascalCase()}}UseCase({required {{feature.pascalCase()}}Repository {{feature.camelCase()}}Repository})
      : _{{feature.camelCase()}}Repository = {{feature.camelCase()}}Repository;

  final {{feature.pascalCase()}}Repository _{{feature.camelCase()}}Repository;

  @override
  FutureData<String> call(String request) async => const SuccessState(data: "");
}
