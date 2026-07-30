import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/local_storage_client.dart';

@LazySingleton()
class SaveSelectedModeUseCase {
  SaveSelectedModeUseCase(this._localStorageClient);
  final LocalStorageClient _localStorageClient;

  Future<void> call(String? mode) =>
      _localStorageClient.saveSelectedMode(mode);
}
