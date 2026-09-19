import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/can_provider_create_work_order_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/create_company_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/get_all_companies_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/get_company_parameters_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/get_company_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/save_company_parameters_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/update_company_logo_use_case.dart';

class MockCreateCompanyUseCase extends Mock implements CreateCompanyUseCase {}

class MockGetCompanyUseCase extends Mock implements GetCompanyUseCase {}

class MockUpdateCompanyLogoUseCase extends Mock
    implements UpdateCompanyLogoUseCase {}

class MockGetAllCompaniesUseCase extends Mock
    implements GetAllCompaniesUseCase {}

class MockGetCompanyParametersUseCase extends Mock
    implements GetCompanyParametersUseCase {}

class MockCanProviderCreateWorkOrderUseCase extends Mock
    implements CanProviderCreateWorkOrderUseCase {}

class MockSaveCompanyParametersUseCase extends Mock
    implements SaveCompanyParametersUseCase {}
