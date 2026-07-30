import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/local_storage_client.dart';

@LazySingleton()
class GetSelectedModeUseCase {
  GetSelectedModeUseCase(this._localStorageClient);
  final LocalStorageClient _localStorageClient;

  String? call() => _localStorageClient.getSelectedMode();
}
