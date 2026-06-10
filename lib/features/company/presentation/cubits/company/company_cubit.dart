import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/company/domain/entities/company_entity.dart';
import 'package:clean_architecture/features/company/presentation/cubits/company/company_cubit_use_cases.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:injectable/injectable.dart';

part 'company_state.dart';

@injectable
class CompanyCubit extends BaseCubit<CompanyState> {
  CompanyCubit({required CompanyCubitUseCases useCases})
    : _useCases = useCases,
      super(const CompanyState.initial());

  final CompanyCubitUseCases _useCases;

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
    );

    final dataState = await _useCases.createCompany(company);
    if (isClosed) return;

    if (dataState is SuccessState<CompanyEntity>) {
      await maybePopRoute();
    }
    emit(state.copyWith(status: StateStatus.loaded, company: dataState.data));
    showDataStateToast(
      SuccessState(data: 'Empresa criada com sucesso'.hardcoded),
    );
  }
}
