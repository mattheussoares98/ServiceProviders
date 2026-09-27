import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/customers/data/data_sources/customers_local_data_source.dart';
import 'package:o_jogo_da_obra/features/customers/data/data_sources/customers_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/customers/data/models/responses/customer_model.dart';
import 'package:o_jogo_da_obra/features/customers/domain/entities/customer_entity.dart';
import 'package:o_jogo_da_obra/features/customers/domain/repositories/customers_repository.dart';

@LazySingleton(as: CustomersRepository)
final class CustomersRepositoryImpl implements CustomersRepository {
  CustomersRepositoryImpl({
    required InternetClient internet,
    required CustomersRemoteDataSource remoteDataSource,
    required CustomersLocalDataSource localDataSource,
  }) : _internet = internet,
       _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final InternetClient _internet;
  final CustomersRemoteDataSource _remoteDataSource;
  final CustomersLocalDataSource _localDataSource;

  @override
  FutureList<CustomerEntity> getCustomers(String companyId) =>
      RepositoryHandler.fetchWithFallbackAndMapList<
        CustomerModel,
        CustomerEntity
      >(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.getCustomers(companyId),
        localCallback: () => _localDataSource.getCustomers(companyId),
        onRemoteSuccess: _localDataSource.saveCustomers,
      );

  @override
  FutureList<CustomerEntity> getCustomersByIds(List<String> ids) =>
      RepositoryHandler.fetchWithFallbackAndMapList<
        CustomerModel,
        CustomerEntity
      >(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.getCustomersByIds(ids),
      );

  @override
  FutureData<CustomerEntity> getCustomerById(String id) =>
      RepositoryHandler.fetchWithFallbackAndMap<CustomerModel, CustomerEntity>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.getCustomerById(id),
        localCallback: () => _localDataSource.getCustomerById(id),
        onRemoteSuccess: _localDataSource.saveCustomer,
      );

  @override
  FutureBool createCustomer(CustomerEntity customer) =>
      RepositoryHandler.executeMutation<CustomerModel>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.createCustomer(
          CustomerModel.fromEntity(customer),
        ),
        onRemoteSuccess: _localDataSource.saveCustomer,
        localCallback: () =>
            _localDataSource.saveCustomer(CustomerModel.fromEntity(customer)),
      );

  @override
  FutureBool updateCustomer(CustomerEntity customer) =>
      RepositoryHandler.executeMutation<CustomerModel>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.updateCustomer(
          CustomerModel.fromEntity(customer),
        ),
        onRemoteSuccess: _localDataSource.saveCustomer,
        localCallback: () =>
            _localDataSource.saveCustomer(CustomerModel.fromEntity(customer)),
      );

  @override
  FutureBool deleteCustomer(String id) =>
      RepositoryHandler.executeMutation<void>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.deleteCustomer(id),
        onRemoteSuccess: (_) => _localDataSource.deleteCustomer(id),
        localCallback: () => _localDataSource.deleteCustomer(id),
      );
}
