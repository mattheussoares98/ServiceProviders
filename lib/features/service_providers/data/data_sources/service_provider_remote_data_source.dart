import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/realtime/realtime_payload_mapper.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/realtime/supabase_realtime_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/supabase_handler.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/models/responses/service_provider_company_model.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/models/responses/service_provider_invitation_model.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/models/responses/service_provider_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ServiceProviderRemoteDataSource {
  FutureList<ServiceProviderCompanyModel> getServiceProviderCompanies(
    String companyId,
  );
  FutureData<ServiceProviderCompanyModel> getServiceProviderCompanyById(
    String id,
  );

  /// Provider mode. Loads the provider companies the signed-in user belongs to,
  /// which span multiple contracting companies.
  FutureList<ServiceProviderCompanyModel> getServiceProviderCompaniesByIds(
    List<String> ids,
  );
  FutureBool createServiceProviderCompany(ServiceProviderCompanyModel request);
  FutureBool updateServiceProviderCompany(ServiceProviderCompanyModel request);

  Stream<RealtimeEvent<ServiceProviderCompanyModel>>
  watchServiceProviderCompaniesRealtime({String? companyId});

  FutureList<ServiceProviderProfileModel> getServiceProviderProfiles(
    String serviceProviderCompanyId,
  );
  FutureList<ServiceProviderProfileModel>
  getServiceProviderProfilesByCompanyIds(
    List<String> serviceProviderCompanyIds,
  );
  FutureList<ServiceProviderProfileModel> getServiceProviderProfilesByAuthUser(
    String authUserId,
  );
  FutureBool createServiceProviderProfile(ServiceProviderProfileModel request);
  FutureBool updateServiceProviderProfile(ServiceProviderProfileModel request);

  Stream<RealtimeEvent<ServiceProviderProfileModel>>
  watchServiceProviderProfilesRealtime({String? serviceProviderCompanyId});

  FutureList<ServiceProviderInvitationModel> getServiceProviderInvitations(
    String serviceProviderCompanyId,
  );
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
    required SupabaseRealtimeClient realtimeClient,
  }) : _database = database,
       _realtimeClient = realtimeClient;

  final SupabaseDatabaseClient _database;
  final SupabaseRealtimeClient _realtimeClient;

  @override
  FutureList<ServiceProviderCompanyModel> getServiceProviderCompanies(
    String companyId,
  ) => SupabaseHandler.call(() async {
    final response = await _database.selectList(
      table: 'service_provider_companies',
      filters: [
        SupabaseFilter.eq('company_id', companyId),
        SupabaseFilter.eq('is_active', true),
      ],
    );
    return response.map(ServiceProviderCompanyModel.fromJson).toList();
  });

  @override
  FutureList<ServiceProviderCompanyModel> getServiceProviderCompaniesByIds(
    List<String> ids,
  ) => SupabaseHandler.call(() async {
    if (ids.isEmpty) {
      return <ServiceProviderCompanyModel>[];
    }
    final response = await _database.selectList(
      table: 'service_provider_companies',
      filters: [
        SupabaseFilter.inList('id', ids),
        SupabaseFilter.eq('is_active', true),
      ],
    );
    return response.map(ServiceProviderCompanyModel.fromJson).toList();
  });

  @override
  FutureData<ServiceProviderCompanyModel> getServiceProviderCompanyById(
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
    return ServiceProviderCompanyModel.fromJson(response);
  });

  @override
  FutureBool createServiceProviderCompany(
    ServiceProviderCompanyModel request,
  ) => SupabaseHandler.call(() async {
    await _database.insert(
      table: 'service_provider_companies',
      values: request.toJson(),
    );
    return true;
  });

  @override
  FutureBool updateServiceProviderCompany(
    ServiceProviderCompanyModel request,
  ) => SupabaseHandler.call(() async {
    await _database.update(
      table: 'service_provider_companies',
      values: request.toJson(),
      filters: [SupabaseFilter.eq('id', request.id)],
    );
    return true;
  });

  @override
  Stream<RealtimeEvent<ServiceProviderCompanyModel>>
  watchServiceProviderCompaniesRealtime({String? companyId}) {
    final filter = companyId != null && companyId.isNotEmpty
        ? PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'company_id',
            value: companyId,
          )
        : null;

    return _realtimeClient
        .streamTableChanges(
          table: 'service_provider_companies',
          schema: 'public',
          event: PostgresChangeEvent.all,
          filter: filter,
        )
        .map(
          (payload) => RealtimePayloadMapper.map<ServiceProviderCompanyModel>(
            payload,
            ServiceProviderCompanyModel.fromJson,
          ),
        );
  }

  @override
  FutureList<ServiceProviderProfileModel> getServiceProviderProfiles(
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
    return response.map(ServiceProviderProfileModel.fromJson).toList();
  });

  @override
  FutureList<ServiceProviderProfileModel>
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
    return response.map(ServiceProviderProfileModel.fromJson).toList();
  });

  @override
  FutureList<ServiceProviderProfileModel> getServiceProviderProfilesByAuthUser(
    String authUserId,
  ) => SupabaseHandler.call(() async {
    final response = await _database.selectList(
      table: 'service_provider_profiles',
      filters: [SupabaseFilter.eq('auth_user_id', authUserId)],
    );
    return response.map(ServiceProviderProfileModel.fromJson).toList();
  });

  @override
  FutureBool createServiceProviderProfile(
    ServiceProviderProfileModel request,
  ) => SupabaseHandler.call(() async {
    await _database.insert(
      table: 'service_provider_profiles',
      values: request.toJson(),
    );
    return true;
  });

  @override
  FutureBool updateServiceProviderProfile(
    ServiceProviderProfileModel request,
  ) => SupabaseHandler.call(() async {
    await _database.update(
      table: 'service_provider_profiles',
      values: request.toJson(),
      filters: [SupabaseFilter.eq('id', request.id)],
    );
    return true;
  });

  @override
  Stream<RealtimeEvent<ServiceProviderProfileModel>>
  watchServiceProviderProfilesRealtime({String? serviceProviderCompanyId}) {
    final filter = serviceProviderCompanyId != null &&
            serviceProviderCompanyId.isNotEmpty
        ? PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'service_provider_company_id',
            value: serviceProviderCompanyId,
          )
        : null;

    return _realtimeClient
        .streamTableChanges(
          table: 'service_provider_profiles',
          schema: 'public',
          event: PostgresChangeEvent.all,
          filter: filter,
        )
        .map(
          (payload) => RealtimePayloadMapper.map<ServiceProviderProfileModel>(
            payload,
            ServiceProviderProfileModel.fromJson,
          ),
        );
  }

  @override
  FutureList<ServiceProviderInvitationModel> getServiceProviderInvitations(
    String serviceProviderCompanyId,
  ) => SupabaseHandler.call(() async {
    final response = await _database.selectList(
      table: 'service_provider_invitations',
      filters: [
        SupabaseFilter.eq(
          'service_provider_company_id',
          serviceProviderCompanyId,
        ),
      ],
    );
    return response.map(ServiceProviderInvitationModel.fromJson).toList();
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
