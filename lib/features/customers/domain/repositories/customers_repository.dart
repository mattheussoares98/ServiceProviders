import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/customers/domain/entities/customer_entity.dart';

abstract interface class CustomersRepository {
  FutureList<CustomerEntity> getCustomers(String companyId);
  FutureList<CustomerEntity> getCustomersByIds(List<String> ids);
  FutureData<CustomerEntity> getCustomerById(String id);
  FutureBool createCustomer(CustomerEntity customer);
  FutureBool updateCustomer(CustomerEntity customer);
  FutureBool deleteCustomer(String id);
}
