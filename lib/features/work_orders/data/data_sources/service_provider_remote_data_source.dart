import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/handlers/supabase_handler.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/service_provider_company_response_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/service_provider_profile_response_model.dart';

abstract interface class ServiceProviderRemoteDataSource {
  FutureList<ServiceProviderCompanyResponseModel> getServiceProviderCompanies(
    String companyId,
  );
  FutureData<ServiceProviderCompanyResponseModel> getServiceProviderCompanyById(
    String id,
  );
  FutureBool createServiceProviderCompany(
    ServiceProviderCompanyResponseModel request,
  );
  FutureBool updateServiceProviderCompany(
    ServiceProviderCompanyResponseModel request,
  );

  FutureList<ServiceProviderProfileResponseModel> getServiceProviderProfiles(
    String serviceProviderCompanyId,
  );
  FutureBool createServiceProviderProfile(
    ServiceProviderProfileResponseModel request,
  );
  FutureBool updateServiceProviderProfile(
    ServiceProviderProfileResponseModel request,
  );
}

@LazySingleton(as: ServiceProviderRemoteDataSource)
final class ServiceProviderRemoteDataSourceImpl
    implements ServiceProviderRemoteDataSource {
  const ServiceProviderRemoteDataSourceImpl({
    required SupabaseDatabaseClient database,
  }) : _database = database;

  final SupabaseDatabaseClient _database;

  @override
  FutureList<ServiceProviderCompanyResponseModel> getServiceProviderCompanies(
    String companyId,
  ) => SupabaseHandler.call(() async {
    final response = await _database.selectList(
      table: 'service_provider_companies',
      filters: [
        SupabaseFilter.eq('company_id', companyId),
        SupabaseFilter.isFilter('deleted_at', null),
      ],
    );
    return response.map(ServiceProviderCompanyResponseModel.fromJson).toList();
  });

  @override
  FutureData<ServiceProviderCompanyResponseModel> getServiceProviderCompanyById(
    String id,
  ) => SupabaseHandler.call(() async {
    final response = await _database.selectOne(
      table: 'service_provider_companies',
      filters: [
        SupabaseFilter.eq('id', id),
        SupabaseFilter.isFilter('deleted_at', null),
      ],
    );
    if (response == null) {
      throw _NotFoundException('Prestador de serviço não encontrado'.hardcoded);
    }
    return ServiceProviderCompanyResponseModel.fromJson(response);
  });

  @override
  FutureBool createServiceProviderCompany(
    ServiceProviderCompanyResponseModel request,
  ) => SupabaseHandler.call(() async {
    await _database.insert(
      table: 'service_provider_companies',
      values: request.toJson(),
    );
    return true;
  });

  @override
  FutureBool updateServiceProviderCompany(
    ServiceProviderCompanyResponseModel request,
  ) => SupabaseHandler.call(() async {
    await _database.update(
      table: 'service_provider_companies',
      values: request.toJson(),
      filters: [SupabaseFilter.eq('id', request.id)],
    );
    return true;
  });

  @override
  FutureList<ServiceProviderProfileResponseModel> getServiceProviderProfiles(
    String serviceProviderCompanyId,
  ) => SupabaseHandler.call(() async {
    final response = await _database.selectList(
      table: 'service_provider_profiles',
      filters: [
        SupabaseFilter.eq(
          'service_provider_company_id',
          serviceProviderCompanyId,
        ),
      ],
    );
    return response.map(ServiceProviderProfileResponseModel.fromJson).toList();
  });

  @override
  FutureBool createServiceProviderProfile(
    ServiceProviderProfileResponseModel request,
  ) => SupabaseHandler.call(() async {
    await _database.insert(
      table: 'service_provider_profiles',
      values: request.toJson(),
    );
    return true;
  });

  @override
  FutureBool updateServiceProviderProfile(
    ServiceProviderProfileResponseModel request,
  ) => SupabaseHandler.call(() async {
    await _database.update(
      table: 'service_provider_profiles',
      values: request.toJson(),
      filters: [SupabaseFilter.eq('id', request.id)],
    );
    return true;
  });
}

final class _NotFoundException implements Exception {
  const _NotFoundException(this.message);
  final String message;
  @override
  String toString() => message;
}
