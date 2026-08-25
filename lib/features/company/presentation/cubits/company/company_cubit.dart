import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/repositories/attachments_repository.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/pick_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_entity.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/update_company_logo_use_case.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'company_state.dart';

@injectable
class CompanyCubit extends BaseCubit<CompanyState> {
  CompanyCubit({required CompanyCubitUseCases useCases})
    : _useCases = useCases,
      super(const CompanyState.initial());

  final CompanyCubitUseCases _useCases;

  Future<void> loadCompany({bool forceRefresh = false}) async {
    final user = _useCases.getSessionUser();
    emit(state.copyWith(status: StateStatus.loading));

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
        emit(
          state.copyWith(
            status: StateStatus.loaded,
            companies: companies,
            company: activeCompany,
            selectedCompanyId: activeCompany?.id,
          ),
        );
        return;
      } else {
        emit(state.copyWith(status: StateStatus.loadingError));
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
      emit(
        state.copyWith(
          status: StateStatus.loaded,
          company: dataState.data,
          companies: dataState.data != null ? [dataState.data!] : const [],
          selectedCompanyId: dataState.data?.id,
        ),
      );
    } else {
      emit(state.copyWith(status: StateStatus.loadingError));
      showDataStateToast(dataState);
    }
  }

  Future<void> switchCompany(String companyId) async {
    final user = _useCases.getSessionUser();
    if (!user.isSuperAdmin) return;

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

    emit(
      state.copyWith(
        company: selectedCompany,
        selectedCompanyId: companyId,
      ),
    );
    showSuccessToast('Empresa ativa alterada com sucesso'.hardcoded);
  }

  Future<void> createCompany({required String name, String? cnpj}) async {
    emit(state.copyWith(status: StateStatus.loading, annulCompany: true));

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
    emit(state.copyWith(status: StateStatus.loaded, company: dataState.data));
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

    emit(state.copyWith(status: StateStatus.saving));

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
      emit(state.copyWith(status: StateStatus.loaded));
      return;
    }

    final attachments = pickResult.data ?? [];
    if (attachments.isEmpty) {
      emit(state.copyWith(status: StateStatus.loaded));
      return;
    }

    final localPath = attachments.first.localPath;
    if (localPath == null || localPath.isEmpty) {
      showErrorToast('Erro ao obter o arquivo da imagem'.hardcoded);
      emit(state.copyWith(status: StateStatus.loaded));
      return;
    }

    final uploadResult = await _useCases.updateCompanyLogo.call(
      UpdateCompanyLogoParams(company: company, localPath: localPath),
    );

    if (isClosed) return;

    if (uploadResult is SuccessState<CompanyEntity>) {
      showSuccessToast('Logo da empresa atualizada com sucesso'.hardcoded);
      emit(
        state.copyWith(
          status: StateStatus.loaded,
          company: uploadResult.data,
        ),
      );
    } else {
      showDataStateToast(uploadResult);
      emit(state.copyWith(status: StateStatus.savingError));
    }
  }
}
