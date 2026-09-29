import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';
import 'package:o_jogo_da_obra/features/customers/data/data_sources/customers_local_data_source.dart';
import 'package:o_jogo_da_obra/features/customers/data/data_sources/customers_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/customers/data/models/responses/customer_model.dart';
import 'package:o_jogo_da_obra/features/customers/domain/entities/customer_entity.dart';
import 'package:o_jogo_da_obra/features/customers/domain/repositories/customers_repository.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_entity_type.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_operation_type.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_queue_item_entity.dart';
import 'package:o_jogo_da_obra/features/sync/domain/repositories/sync_repository.dart';
import 'package:uuid/uuid.dart';

@LazySingleton(as: CustomersRepository)
final class CustomersRepositoryImpl implements CustomersRepository {
  CustomersRepositoryImpl({
    required InternetClient internet,
    required CustomersRemoteDataSource remoteDataSource,
    required CustomersLocalDataSource localDataSource,
    required SyncRepository syncRepository,
    required SessionRepository sessionRepository,
  }) : _internet = internet,
       _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _syncRepository = syncRepository,
       _sessionRepository = sessionRepository;

  final InternetClient _internet;
  final CustomersRemoteDataSource _remoteDataSource;
  final CustomersLocalDataSource _localDataSource;
  final SyncRepository _syncRepository;
  final SessionRepository _sessionRepository;

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
        localCallback: () async {
          final model = CustomerModel.fromEntity(customer);
          final result = await _localDataSource.saveCustomer(model);
          if (result is SuccessState<bool> && result.data == true) {
            await _syncRepository.enqueue(
              SyncQueueItemEntity(
                id: const Uuid().v4(),
                companyId: customer.companyId,
                userProfileId: _sessionRepository.userData.user.id,
                entityType: SyncEntityType.customer,
                entityId: customer.id,
                operation: SyncOperationType.create,
                payload: jsonEncode(model.toJson()),
                createdAt: DateTime.now(),
              ),
            );
          }
          return result;
        },
      );

  @override
  FutureBool updateCustomer(CustomerEntity customer) =>
      RepositoryHandler.executeMutation<CustomerModel>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.updateCustomer(
          CustomerModel.fromEntity(customer),
        ),
        onRemoteSuccess: _localDataSource.saveCustomer,
        localCallback: () async {
          final model = CustomerModel.fromEntity(customer);
          final result = await _localDataSource.saveCustomer(model);
          if (result is SuccessState<bool> && result.data == true) {
            await _syncRepository.enqueue(
              SyncQueueItemEntity(
                id: const Uuid().v4(),
                companyId: customer.companyId,
                userProfileId: _sessionRepository.userData.user.id,
                entityType: SyncEntityType.customer,
                entityId: customer.id,
                operation: SyncOperationType.update,
                payload: jsonEncode(model.toJson()),
                createdAt: DateTime.now(),
              ),
            );
          }
          return result;
        },
      );

  @override
  FutureBool deleteCustomer(String id) =>
      RepositoryHandler.executeMutation<void>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.deleteCustomer(id),
        onRemoteSuccess: (_) => _localDataSource.deleteCustomer(id),
        localCallback: () async {
          final result = await _localDataSource.deleteCustomer(id);
          if (result is SuccessState<bool> && result.data == true) {
            final companyId = _sessionRepository.getSelectedCompanyId() ?? '';
            final userId = _sessionRepository.userData.user.id;
            await _syncRepository.enqueue(
              SyncQueueItemEntity(
                id: const Uuid().v4(),
                companyId: companyId,
                userProfileId: userId,
                entityType: SyncEntityType.customer,
                entityId: id,
                operation: SyncOperationType.delete,
                createdAt: DateTime.now(),
              ),
            );
          }
          return result;
        },
      );
}
