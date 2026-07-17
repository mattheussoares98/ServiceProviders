import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/local_storage_client.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'mode_switcher_state.dart';

@injectable
class ModeSwitcherCubit extends BaseCubit<ModeSwitcherState> {
  ModeSwitcherCubit({required LocalStorageClient localStorageClient})
    : _localStorageClient = localStorageClient,
      super(const ModeSwitcherState());

  final LocalStorageClient _localStorageClient;

  Future<void> selectMode(AppMode mode) async {
    emit(state.copyWith(status: StateStatus.loading, selectedMode: mode));

    try {
      await _localStorageClient.saveSelectedMode(mode.name);
      emit(state.copyWith(status: StateStatus.loaded));

      if (mode == AppMode.provider) {
        await replaceAllRoute(const ProviderHomeRoute());
      } else {
        await replaceAllRoute(const HomeRoute());
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: StateStatus.savingError,
          errorMessage: 'Erro ao salvar o modo de acesso.',
        ),
      );
    }
  }
}
