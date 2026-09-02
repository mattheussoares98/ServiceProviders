import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/repositories/attachments_repository.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/pick_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_entity.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_parameter_entity.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/update_company_logo_use_case.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission_group_entity.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'company_state.dart';

enum CompanySections implements SectionKey {
  switchCompany,
  updateEscalationParameters,
  changeLogo,
}

@injectable
class CompanyCubit extends BaseCubit<CompanyState> {
  CompanyCubit({required CompanyCubitUseCases useCases})
    : _useCases = useCases,
      super(const CompanyState.initial());

  final CompanyCubitUseCases _useCases;

  Future<void> loadCompany({bool forceRefresh = false}) async {
    final user = _useCases.getSessionUser();
    emit(
      state.copyWith(
        sections: withSection(BaseSections.load, SectionStatus.running),
      ),
    );

    if (user.isSuperAdmin) {
      final allCompaniesState = await _useCases.getAllCompanies();
      if (isClosed) return;

      if (allCompaniesState is SuccessState<List<CompanyEntity>>) {
        final companies = allCompaniesState.data ?? [];
        final activeCompanyId = _useCases.getActiveCompanyId();
        CompanyEntity? activeCompany;
        if (companies.isNotEmpty) {
          activeCompany = companies.firstWhere(
            (c) => c.id == activeCompanyId,
            orElse: () => companies.first,
          );
        }

        final targetId = activeCompany?.id ?? activeCompanyId;
        final paramsState = await _useCases.getCompanyParameters(targetId);
        final groupsState = await _useCases.getPermissionGroups(targetId);

        if (isClosed) return;

        emit(
          state.copyWith(
            sections: withSection(BaseSections.load, SectionStatus.success),
            companies: companies,
            company: activeCompany,
            selectedCompanyId: activeCompany?.id,
            parameters: paramsState is SuccessState<CompanyParameterEntity>
                ? paramsState.data
                : null,
            permissionGroups:
                groupsState is SuccessState<List<PermissionGroupEntity>>
                ? (groupsState.data ?? [])
                : const [],
          ),
        );
        return;
      } else {
        emit(
          state.copyWith(
            sections: withSection(
              BaseSections.load,
              SectionStatus.error,
              errorMessage: allCompaniesState.message,
            ),
          ),
        );
        showDataStateToast(allCompaniesState);
        return;
      }
    }

    final companyId = _useCases.getActiveCompanyId();
    final dataState = await _useCases.getCompany(
      companyId,
      forceRefresh: forceRefresh,
    );
    if (isClosed) return;

    if (dataState is SuccessState<CompanyEntity>) {
      final paramsState = await _useCases.getCompanyParameters(companyId);
      final groupsState = await _useCases.getPermissionGroups(companyId);

      if (isClosed) return;

      emit(
        state.copyWith(
          sections: withSection(BaseSections.load, SectionStatus.success),
          company: dataState.data,
          companies: dataState.data != null ? [dataState.data!] : const [],
          selectedCompanyId: dataState.data?.id,
          parameters: paramsState is SuccessState<CompanyParameterEntity>
              ? paramsState.data
              : null,
          permissionGroups:
              groupsState is SuccessState<List<PermissionGroupEntity>>
              ? (groupsState.data ?? [])
              : const [],
        ),
      );
    } else {
      emit(
        state.copyWith(
          sections: withSection(
            BaseSections.load,
            SectionStatus.error,
            errorMessage: dataState.message,
          ),
        ),
      );
      showDataStateToast(dataState);
    }
  }

  Future<void> switchCompany(String companyId) async {
    final user = _useCases.getSessionUser();
    if (!user.isSuperAdmin) return;

    emit(
      state.copyWith(
        sections: withSection(
          CompanySections.switchCompany,
          SectionStatus.running,
        ),
      ),
    );

    final updatedUser = user.copyWith(companyId: companyId);
    final result = await _useCases.updateUserProfile(updatedUser);
    if (isClosed) return;

    if (result is! SuccessState<bool> || result.data != true) {
      emit(
        state.copyWith(
          sections: withSection(
            CompanySections.switchCompany,
            SectionStatus.error,
          ),
        ),
      );
      showDataStateToast(result);
      return;
    }

    await _useCases.setSelectedCompanyId(companyId);
    CompanyEntity? selectedCompany;
    if (state.companies.isNotEmpty) {
      for (final c in state.companies) {
        if (c.id == companyId) {
          selectedCompany = c;
          break;
        }
      }
    }

    final paramsState = await _useCases.getCompanyParameters(companyId);
    final groupsState = await _useCases.getPermissionGroups(companyId);

    if (isClosed) return;

    emit(
      state.copyWith(
        sections: withSection(
          CompanySections.switchCompany,
          SectionStatus.success,
        ),
        company: selectedCompany,
        selectedCompanyId: companyId,
        parameters: paramsState is SuccessState<CompanyParameterEntity>
            ? paramsState.data
            : null,
        permissionGroups:
            groupsState is SuccessState<List<PermissionGroupEntity>>
            ? (groupsState.data ?? [])
            : const [],
      ),
    );
  }

  Future<void> updateEscalationParameters({
    int? advanceWarningMinutes,
    List<String>? advanceWarningGroupIds,
    int? delayedNotificationIntervalMinutes,
    List<String>? escalationGroupIds,
  }) async {
    final params = state.parameters;
    if (params == null) return;

    emit(
      state.copyWith(
        sections: withSection(
          CompanySections.updateEscalationParameters,
          SectionStatus.running,
        ),
      ),
    );

    final updated = params.copyWith(
      advanceWarningMinutes: advanceWarningMinutes,
      advanceWarningGroupIds: advanceWarningGroupIds,
      delayedNotificationIntervalMinutes: delayedNotificationIntervalMinutes,
      escalationGroupIds: escalationGroupIds,
      updatedAt: DateTime.now().toUtc(),
    );

    final result = await _useCases.saveCompanyParameters(updated);
    if (isClosed) return;

    if (result is SuccessState<bool> && result.data == true) {
      emit(
        state.copyWith(
          sections: withSection(
            CompanySections.updateEscalationParameters,
            SectionStatus.success,
          ),
          parameters: updated,
        ),
      );
    } else {
      emit(
        state.copyWith(
          sections: withSection(
            CompanySections.updateEscalationParameters,
            SectionStatus.error,
          ),
        ),
      );
      showDataStateToast(result);
    }
  }

  Future<void> createCompany({required String name, String? cnpj}) async {
    emit(
      state.copyWith(
        sections: withSection(BaseSections.load, SectionStatus.running),
        annulCompany: true,
      ),
    );

    final now = DateTime.now();
    final company = CompanyEntity(
      id: '',
      name: name.trim(),
      cnpj: cnpj?.trim(),
      isActive: true,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
      logoUrl: null,
    );

    final dataState = await _useCases.createCompany(company);
    if (isClosed) return;

    if (dataState is SuccessState<CompanyEntity>) {
      await maybePopRoute();
    }

    if (isClosed) return;
    showDataStateToast(
      dataState,
      message: 'Empresa criada com sucesso'.hardcoded,
    );
    emit(
      state.copyWith(
        sections: withSection(BaseSections.load, SectionStatus.success),
        company: dataState.data,
      ),
    );
  }

  Future<void> navigateToCreateCompany() async {
    final user = _useCases.getSessionUser();
    if (user.isSuperAdmin) {
      await pushRoute(const CreateCompanyRoute());
    } else {
      showErrorToast(
        'Somente super administradores podem acessar essa página. Essa opção não deveria estar disponível.'
            .hardcoded,
      );
    }
  }

  Future<void> changeLogo(AttachmentSource source) async {
    final company = state.company;
    if (company == null) return;

    final user = _useCases.getSessionUser();
    if (!user.isAdmin) {
      showErrorToast(
        'Somente administradores podem alterar a imagem da empresa'.hardcoded,
      );
      return;
    }

    emit(
      state.copyWith(
        sections: withSection(
          CompanySections.changeLogo,
          SectionStatus.running,
        ),
      ),
    );

    final pickResult = await _useCases.pickAttachment.call(
      PickAttachmentParams(
        source: source,
        workOrderId: 'logo',
        companyId: company.id,
        userId: user.id,
        multiple: false,
      ),
    );

    if (isClosed) return;

    if (pickResult is! SuccessState<List<AttachmentEntity>>) {
      showDataStateToast(pickResult);
      emit(
        state.copyWith(
          sections: withSection(
            CompanySections.changeLogo,
            SectionStatus.error,
          ),
        ),
      );
      return;
    }

    final attachments = pickResult.data ?? [];
    if (attachments.isEmpty) {
      emit(
        state.copyWith(
          sections: withSection(CompanySections.changeLogo, SectionStatus.idle),
        ),
      );
      return;
    }

    final localPath = attachments.first.localPath;
    if (localPath == null || localPath.isEmpty) {
      showErrorToast('Erro ao obter o arquivo da imagem'.hardcoded);
      emit(
        state.copyWith(
          sections: withSection(
            CompanySections.changeLogo,
            SectionStatus.error,
          ),
        ),
      );
      return;
    }

    final uploadResult = await _useCases.updateCompanyLogo.call(
      UpdateCompanyLogoParams(company: company, localPath: localPath),
    );

    if (isClosed) return;

    if (uploadResult is SuccessState<CompanyEntity>) {
      emit(
        state.copyWith(
          company: uploadResult.data,
          sections: withSection(
            CompanySections.changeLogo,
            SectionStatus.success,
          ),
        ),
      );
    } else {
      showDataStateToast(uploadResult);
      emit(
        state.copyWith(
          sections: withSection(
            CompanySections.changeLogo,
            SectionStatus.error,
          ),
        ),
      );
    }
  }
}
