import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/customers/domain/entities/customer_entity.dart';
import 'package:o_jogo_da_obra/features/customers/domain/repositories/customers_repository.dart';

@LazySingleton()
class CreateCustomerUseCase implements UseCase<bool, CustomerEntity> {
  CreateCustomerUseCase({required CustomersRepository customersRepository})
    : _customersRepository = customersRepository;

  final CustomersRepository _customersRepository;

  @override
  FutureBool call(CustomerEntity request) =>
      _customersRepository.createCustomer(request);
}
