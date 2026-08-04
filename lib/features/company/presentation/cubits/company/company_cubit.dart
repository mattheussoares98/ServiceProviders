import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_entity.dart';
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

    final dataState = await _useCases.getCompany(
      user.companyId,
      forceRefresh: forceRefresh,
    );
    if (isClosed) return;

    if (dataState is SuccessState<CompanyEntity>) {
      emit(state.copyWith(status: StateStatus.loaded, company: dataState.data));
    } else {
      emit(state.copyWith(status: StateStatus.loadingError));
      showDataStateToast(dataState);
    }
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
    if (user.isAdmin) {
      await pushRoute(const CreateCompanyRoute());
    } else {
      showErrorToast(
        'Somente administradores podem acessar essa página. Essa opção nem deveria estar aparecendo para você já que você não é administrador'
            .hardcoded,
      );
    }
  }
}
