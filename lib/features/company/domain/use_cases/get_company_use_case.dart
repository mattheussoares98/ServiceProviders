import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/company/domain/repositories/company_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class GetCompanyUseCase implements UseCase<String, String> {
  GetCompanyUseCase({required CompanyRepository companyRepository})
      : _companyRepository = companyRepository;

  final CompanyRepository _companyRepository;

  @override
  FutureData<String> call(String request) async => const SuccessState(data: '');
}
