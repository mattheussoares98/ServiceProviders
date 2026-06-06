import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/company/domain/entities/company_parameter_entity.dart';
import 'package:clean_architecture/features/company/domain/repositories/company_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class GetCompanyParametersUseCase
    implements UseCase<CompanyParameterEntity, String> {
  GetCompanyParametersUseCase({required CompanyRepository companyRepository})
    : _companyRepository = companyRepository;

  final CompanyRepository _companyRepository;

  @override
  FutureData<CompanyParameterEntity> call(String request) =>
      _companyRepository.getCompanyParameters(request);
}
