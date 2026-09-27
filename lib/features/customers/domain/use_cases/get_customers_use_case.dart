import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/customers/domain/entities/customer_entity.dart';
import 'package:o_jogo_da_obra/features/customers/domain/repositories/customers_repository.dart';

@LazySingleton()
class GetCustomersUseCase implements UseCase<List<CustomerEntity>, String> {
  GetCustomersUseCase({required CustomersRepository customersRepository})
    : _customersRepository = customersRepository;

  final CustomersRepository _customersRepository;

  @override
  FutureList<CustomerEntity> call(String request) =>
      _customersRepository.getCustomers(request);
}
