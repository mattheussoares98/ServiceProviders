import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/customers/domain/use_cases/create_customer_use_case.dart';
import 'package:o_jogo_da_obra/features/customers/domain/use_cases/delete_customer_use_case.dart';
import 'package:o_jogo_da_obra/features/customers/domain/use_cases/get_customer_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/customers/domain/use_cases/get_customers_use_case.dart';
import 'package:o_jogo_da_obra/features/customers/domain/use_cases/update_customer_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/get_address_by_cep_use_case.dart';

@LazySingleton()
class CustomersCubitUseCases {
  const CustomersCubitUseCases({
    required this.getActiveCompanyId,
    required this.getCustomers,
    required this.getCustomerById,
    required this.createCustomer,
    required this.updateCustomer,
    required this.deleteCustomer,
    required this.getAddressByCep,
  });

  final GetActiveCompanyIdUseCase getActiveCompanyId;
  final GetCustomersUseCase getCustomers;
  final GetCustomerByIdUseCase getCustomerById;
  final CreateCustomerUseCase createCustomer;
  final UpdateCustomerUseCase updateCustomer;
  final DeleteCustomerUseCase deleteCustomer;
  final GetAddressByCepUseCase getAddressByCep;
}
