import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/mode_switcher/mode_switcher_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'mode_switcher_state.dart';

enum ModeSwitcherSections implements SectionKey { save }

@injectable
class ModeSwitcherCubit extends BaseCubit<ModeSwitcherState> {
  ModeSwitcherCubit({required ModeSwitcherCubitUseCases useCases})
    : _useCases = useCases,
      super(const ModeSwitcherState());

  final ModeSwitcherCubitUseCases _useCases;

  Future<void> checkEligibilityAndLoadMode() async {
    final user = _useCases.getSessionUser.call();
    final hasInternalProfile = user.companyId.isNotEmpty;

    bool hasProviderProfile = false;
    if (user.id.isNotEmpty) {
      final providerProfilesState = await _useCases
          .getServiceProviderProfilesByAuthUser
          .call(user.id);
      if (providerProfilesState is SuccessState &&
          providerProfilesState.data != null) {
        hasProviderProfile = providerProfilesState.data!.isNotEmpty;
      }
    }

    final canSwitch = hasInternalProfile && hasProviderProfile;

    final savedMode = _useCases.getSelectedMode.call();
    final currentMode = AppMode.fromName(savedMode);

    emit(state.copyWith(canSwitchMode: canSwitch, selectedMode: currentMode));
  }

  Future<void> selectMode(AppMode mode) async {
    emit(
      state.copyWith(
        sections: withSection(ModeSwitcherSections.save, SectionStatus.running),
        selectedMode: mode,
      ),
    );

    try {
      await _useCases.saveSelectedMode.call(mode.name);
      emit(
        state.copyWith(
          sections: withSection(
            ModeSwitcherSections.save,
            SectionStatus.success,
          ),
        ),
      );

      if (mode == AppMode.provider) {
        await replaceAllRoute(const ProviderHomeRoute());
      } else {
        await replaceAllRoute(const HomeRoute());
      }
    } catch (e) {
      emit(
        state.copyWith(
          sections: withSection(ModeSwitcherSections.save, SectionStatus.error),
        ),
      );
    }
  }
}
