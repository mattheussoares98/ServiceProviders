import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_entity.dart';
import 'package:o_jogo_da_obra/features/company/domain/repositories/company_repository.dart';

@LazySingleton()
class GetCompanyUseCase implements UseCase<CompanyEntity, String> {
  GetCompanyUseCase({required CompanyRepository companyRepository})
    : _companyRepository = companyRepository;

  final CompanyRepository _companyRepository;

  @override
  FutureData<CompanyEntity> call(String request, {bool forceRefresh = false}) =>
      _companyRepository.getCompany(request, forceRefresh: forceRefresh);
}
