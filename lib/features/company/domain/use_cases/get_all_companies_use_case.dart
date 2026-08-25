import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_entity.dart';
import 'package:o_jogo_da_obra/features/company/domain/repositories/company_repository.dart';

@LazySingleton()
class GetAllCompaniesUseCase implements UseCaseNoParameter<List<CompanyEntity>> {
  GetAllCompaniesUseCase({required CompanyRepository repository})
    : _repository = repository;

  final CompanyRepository _repository;

  @override
  FutureList<CompanyEntity> call() => _repository.getAllCompanies();
}
