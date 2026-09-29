import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/customers/domain/use_cases/create_customer_use_case.dart';
import 'package:o_jogo_da_obra/features/customers/domain/use_cases/delete_customer_use_case.dart';
import 'package:o_jogo_da_obra/features/customers/domain/use_cases/get_customer_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/customers/domain/use_cases/get_customers_by_ids_use_case.dart';
import 'package:o_jogo_da_obra/features/customers/domain/use_cases/get_customers_use_case.dart';
import 'package:o_jogo_da_obra/features/customers/domain/use_cases/update_customer_use_case.dart';

class MockGetCustomersUseCase extends Mock implements GetCustomersUseCase {}

class MockGetCustomersByIdsUseCase extends Mock
    implements GetCustomersByIdsUseCase {}

class MockGetCustomerByIdUseCase extends Mock
    implements GetCustomerByIdUseCase {}

class MockCreateCustomerUseCase extends Mock implements CreateCustomerUseCase {}

class MockUpdateCustomerUseCase extends Mock implements UpdateCustomerUseCase {}

class MockDeleteCustomerUseCase extends Mock implements DeleteCustomerUseCase {}
