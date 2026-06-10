import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/company/domain/entities/company_entity.dart';
import 'package:clean_architecture/features/company/domain/repositories/company_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class CreateCompanyUseCase implements UseCase<CompanyEntity, CompanyEntity> {
  CreateCompanyUseCase({required CompanyRepository companyRepository})
    : _companyRepository = companyRepository;

  final CompanyRepository _companyRepository;

  @override
  FutureData<CompanyEntity> call(CompanyEntity request) =>
      _companyRepository.createCompany(request);
}
