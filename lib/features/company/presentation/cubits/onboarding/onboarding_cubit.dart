import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_entity.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/work_type.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/onboarding/onboarding_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'onboarding_state.dart';

@injectable
class OnboardingCubit extends BaseCubit<OnboardingState> {
  OnboardingCubit({required OnboardingCubitUseCases useCases})
    : _useCases = useCases,
      super(const OnboardingState.initial());

  final OnboardingCubitUseCases _useCases;

  void setStep(int step) {
    if (step < 0 || step > 2) return;
    emit(state.copyWith(currentStep: step));
  }

  void nextStep() {
    if (state.currentStep < 2) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  void updateCompanyInfo({required String name, String? cnpj}) {
    emit(
      state.copyWith(
        companyName: name.trim(),
        cnpj: cnpj?.trim() ?? '',
      ),
    );
  }

  void selectWorkType(WorkType workType) {
    emit(state.copyWith(workType: workType));
  }

  Future<void> submit() async {
    final companyName = state.companyName.trim();
    if (companyName.isEmpty) {
      showErrorToast('Por favor, informe o nome da empresa'.hardcoded);
      emit(state.copyWith(currentStep: 0));
      return;
    }

    emit(
      state.copyWith(
        sections: withSection(BaseSections.load, SectionStatus.running),
      ),
    );

    final now = DateTime.now();
    final company = CompanyEntity(
      id: '',
      name: companyName,
      cnpj: state.cnpj.trim().isEmpty ? null : state.cnpj.trim(),
      isActive: true,
      workType: state.workType,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
      logoUrl: null,
    );

    final result = await _useCases.createCompany(company);
    if (isClosed) return;

    if (result is! SuccessState<CompanyEntity> || result.data == null) {
      emit(
        state.copyWith(
          sections: withSection(
            BaseSections.load,
            SectionStatus.error,
            errorMessage: result.message,
          ),
        ),
      );
      showDataStateToast(result);
      return;
    }

    final createdCompany = result.data!;
    final user = _useCases.getSessionUser();

    // Fetch newly created permission groups for the company to assign user to 'Administrador'
    final groupsResult = await _useCases.getPermissionGroups(createdCompany.id);
    if (isClosed) return;

    final groups = groupsResult.data ?? [];
    final adminGroup = groups.firstWhereOrNull(
      (g) => g.name.toLowerCase().contains('admin'),
    );

    final updatedProfile = user.copyWith(
      companyId: createdCompany.id,
      permissionGroupId: adminGroup?.id,
      isAdmin: true,
      isActive: true,
    );

    final updateResult = await _useCases.updateUserProfile(updatedProfile);
    if (isClosed) return;

    if (updateResult is! SuccessState<bool> || updateResult.data != true) {
      emit(
        state.copyWith(
          sections: withSection(
            BaseSections.load,
            SectionStatus.error,
            errorMessage: updateResult.message,
          ),
        ),
      );
      showDataStateToast(updateResult);
      return;
    }

    // Update active session and local storage
    final currentSessionData = _useCases.sessionRepository.userData;
    final updatedUserData = UserDataEntity(
      user: updatedProfile,
      accessToken: currentSessionData.accessToken,
      refreshToken: currentSessionData.refreshToken,
    );
    _useCases.setSession(updatedUserData);
    await _useCases.saveUserData(updatedUserData);
    await _useCases.setSelectedCompanyId(createdCompany.id);
    await _useCases.localStorageClient.saveSelectedMode(AppMode.internal.name);

    if (isClosed) return;

    emit(
      state.copyWith(
        sections: withSection(BaseSections.load, SectionStatus.success),
      ),
    );
    showSuccessToast('Empresa criada com sucesso!'.hardcoded);

    await replaceAllRoute(const HomeRoute());
  }
}
