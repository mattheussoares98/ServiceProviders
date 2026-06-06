import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/company/domain/entities/company_parameter_entity.dart';
import 'package:clean_architecture/features/company/domain/repositories/company_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class SaveCompanyParametersUseCase
    implements UseCase<bool, CompanyParameterEntity> {
  SaveCompanyParametersUseCase({required CompanyRepository companyRepository})
    : _companyRepository = companyRepository;

  final CompanyRepository _companyRepository;

  @override
  FutureBool call(CompanyParameterEntity request) =>
      _companyRepository.saveCompanyParameters(request);
}
