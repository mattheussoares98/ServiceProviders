import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/company/domain/entities/company_entity.dart';
import 'package:clean_architecture/features/company/domain/entities/company_parameter_entity.dart';

abstract interface class CompanyRepository {
  FutureData<CompanyEntity> createCompany(CompanyEntity company);
  FutureData<CompanyEntity> getCompany(String id, {bool forceRefresh = false});
  FutureData<CompanyParameterEntity> getCompanyParameters(String companyId);
  FutureBool saveCompany(CompanyEntity company);
  FutureBool saveCompanyParameters(CompanyParameterEntity parameters);
}
