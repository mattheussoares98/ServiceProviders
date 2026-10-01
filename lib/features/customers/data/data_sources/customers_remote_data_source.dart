import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/handlers/supabase_handler.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/customers/data/models/responses/customer_model.dart';

abstract interface class CustomersRemoteDataSource {
  FutureList<CustomerModel> getCustomers(String companyId);
  FutureList<CustomerModel> getCustomersByIds(List<String> ids);
  FutureData<CustomerModel> getCustomerById(String id);
  FutureData<CustomerModel> createCustomer(CustomerModel request);
  FutureData<CustomerModel> updateCustomer(CustomerModel request);
  FutureVoid deleteCustomer(String id);
  FutureBool hasNonDeletedCustomers(String companyId);
}

@LazySingleton(as: CustomersRemoteDataSource)
final class CustomersRemoteDataSourceImpl implements CustomersRemoteDataSource {
  const CustomersRemoteDataSourceImpl({
    required SupabaseDatabaseClient database,
  }) : _database = database;

  final SupabaseDatabaseClient _database;

  @override
  FutureList<CustomerModel> getCustomers(String companyId) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectList(
          table: 'customers',
          filters: [
            SupabaseFilter.eq('company_id', companyId),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
        );
        return response.map(CustomerModel.fromJson).toList();
      });

  @override
  FutureList<CustomerModel> getCustomersByIds(List<String> ids) =>
      SupabaseHandler.call(() async {
        if (ids.isEmpty) return <CustomerModel>[];
        final response = await _database.selectList(
          table: 'customers',
          filters: [
            SupabaseFilter.inList('id', ids),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
        );
        return response.map(CustomerModel.fromJson).toList();
      });

  @override
  FutureData<CustomerModel> getCustomerById(String id) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectOne(
          table: 'customers',
          filters: [
            SupabaseFilter.eq('id', id),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
        );
        if (response == null) {
          throw Exception('Cliente não encontrado'.hardcoded);
        }
        return CustomerModel.fromJson(response);
      });

  @override
  FutureData<CustomerModel> createCustomer(CustomerModel request) =>
      SupabaseHandler.call(() async {
        final response = await _database.insert(
          table: 'customers',
          values: request.toJson(),
        );
        return CustomerModel.fromJson(response.first);
      });

  @override
  FutureData<CustomerModel> updateCustomer(CustomerModel request) =>
      SupabaseHandler.call(() async {
        final response = await _database.update(
          table: 'customers',
          values: request.toJson(),
          filters: [SupabaseFilter.eq('id', request.id)],
        );
        return CustomerModel.fromJson(response.first);
      });

  @override
  FutureVoid deleteCustomer(String id) => SupabaseHandler.voidCall(() async {
    await _database.update(
      table: 'customers',
      values: {'deleted_at': DateTime.now().toIsoUtcString()},
      filters: [SupabaseFilter.eq('id', id)],
    );
  });

  @override
  FutureBool hasNonDeletedCustomers(String companyId) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectList(
          table: 'customers',
          columns: 'id',
          limit: 1,
          filters: [
            SupabaseFilter.eq('company_id', companyId),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
        );
        return response.isNotEmpty;
      });
}
