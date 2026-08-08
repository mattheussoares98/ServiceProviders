import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/handlers/supabase_handler.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/models/responses/service_provider_company_response_model.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/models/responses/service_provider_invitation_response_model.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/models/responses/service_provider_profile_response_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


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
  FutureList<ServiceProviderProfileResponseModel>
  getServiceProviderProfilesByCompanyIds(
    List<String> serviceProviderCompanyIds,
  );
  FutureList<ServiceProviderProfileResponseModel>
  getServiceProviderProfilesByAuthUser(String authUserId);
  FutureBool createServiceProviderProfile(
    ServiceProviderProfileResponseModel request,
  );
  FutureBool updateServiceProviderProfile(
    ServiceProviderProfileResponseModel request,
  );

  FutureList<ServiceProviderInvitationResponseModel>
  getServiceProviderInvitations(String serviceProviderCompanyId);
  FutureBool sendServiceProviderInvitation({
    required String serviceProviderCompanyId,
    required String email,
  });
  FutureBool acceptServiceProviderInvitation(String email);
  FutureBool deleteServiceProviderInvitation(String invitationId);
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
        SupabaseFilter.eq('is_active', true),
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
        SupabaseFilter.eq('is_active', true),
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
  FutureList<ServiceProviderProfileResponseModel>
  getServiceProviderProfilesByCompanyIds(
    List<String> serviceProviderCompanyIds,
  ) => SupabaseHandler.call(() async {
    if (serviceProviderCompanyIds.isEmpty) return [];
    final response = await _database.selectList(
      table: 'service_provider_profiles',
      filters: [
        SupabaseFilter.inList(
          'service_provider_company_id',
          serviceProviderCompanyIds,
        ),
      ],
    );
    return response.map(ServiceProviderProfileResponseModel.fromJson).toList();
  });

  @override
  FutureList<ServiceProviderProfileResponseModel>
  getServiceProviderProfilesByAuthUser(String authUserId) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectList(
          table: 'service_provider_profiles',
          filters: [SupabaseFilter.eq('auth_user_id', authUserId)],
        );
        return response
            .map(ServiceProviderProfileResponseModel.fromJson)
            .toList();
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

  @override
  FutureList<ServiceProviderInvitationResponseModel>
  getServiceProviderInvitations(String serviceProviderCompanyId) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectList(
          table: 'service_provider_invitations',
          filters: [
            SupabaseFilter.eq(
              'service_provider_company_id',
              serviceProviderCompanyId,
            ),
          ],
        );
        return response
            .map(ServiceProviderInvitationResponseModel.fromJson)
            .toList();
      });

  @override
  FutureBool sendServiceProviderInvitation({
    required String serviceProviderCompanyId,
    required String email,
  }) => SupabaseHandler.call(() async {
    await _database.invokeFunction(
      'invite-service-provider',
      method: HttpMethod.post,
      body: {
        'service_provider_company_id': serviceProviderCompanyId,
        'email': email,
      },
    );
    return true;
  });

  @override
  FutureBool acceptServiceProviderInvitation(String email) =>
      SupabaseHandler.call(() async {
        await _database.rpc(
          functionName: 'accept_service_provider_invitation',
          params: {'p_email': email},
        );
        return true;
      });

  @override
  FutureBool deleteServiceProviderInvitation(String invitationId) =>
      SupabaseHandler.call(() async {
        await _database.rpc(
          functionName: 'delete_service_provider_invitation',
          params: {'p_invitation_id': invitationId},
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
