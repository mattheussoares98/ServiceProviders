import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/assets/domain/repositories/assets_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class GetAssetsUseCase implements UseCase<String, String> {
  GetAssetsUseCase({required AssetsRepository assetsRepository})
    : _assetsRepository = assetsRepository;

  final AssetsRepository _assetsRepository;

  @override
  FutureData<String> call(String request) async => const SuccessState(data: '');
}
