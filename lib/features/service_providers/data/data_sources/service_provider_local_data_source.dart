import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/handlers/error_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/models/responses/service_provider_company_model.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/models/responses/service_provider_invitation_model.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/models/responses/service_provider_profile_model.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/document_type.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_invitation_status.dart';

abstract interface class ServiceProviderLocalDataSource {
  FutureList<ServiceProviderCompanyModel> getServiceProviderCompanies(
    String companyId,
  );
  FutureData<ServiceProviderCompanyModel> getServiceProviderCompanyById(
    String id,
  );
  FutureBool saveServiceProviderCompany(ServiceProviderCompanyModel company);
  FutureBool saveServiceProviderCompanies(
    List<ServiceProviderCompanyModel> companies,
  );

  FutureList<ServiceProviderProfileModel> getServiceProviderProfiles(
    String serviceProviderCompanyId,
  );
  FutureList<ServiceProviderProfileModel>
  getServiceProviderProfilesByCompanyIds(
    List<String> serviceProviderCompanyIds,
  );
  FutureBool saveServiceProviderProfile(ServiceProviderProfileModel profile);
  FutureBool saveServiceProviderProfiles(
    List<ServiceProviderProfileModel> profiles,
  );

  FutureList<ServiceProviderInvitationModel> getServiceProviderInvitations(
    String serviceProviderCompanyId,
  );
  FutureBool saveServiceProviderInvitations(
    List<ServiceProviderInvitationModel> invitations,
  );
  FutureBool deleteServiceProviderInvitation(String invitationId);
}

@LazySingleton(as: ServiceProviderLocalDataSource)
final class ServiceProviderLocalDataSourceImpl
    implements ServiceProviderLocalDataSource {
  ServiceProviderLocalDataSourceImpl({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  @override
  FutureList<ServiceProviderCompanyModel> getServiceProviderCompanies(
    String companyId,
  ) {
    return ErrorHandler.execute(() async {
      final query = _database.select(_database.serviceProviderCompanies)
        ..where((t) => t.companyId.equals(companyId) & t.deletedAt.isNull());
      final rows = await query.get();

      final list = rows
          .map(
            (row) => ServiceProviderCompanyModel(
              id: row.id,
              companyId: row.companyId,
              name: row.name,
              document: row.document ?? '',
              documentType: DocumentType.fromName(row.documentType ?? 'cpf'),
              contactEmail: row.contactEmail,
              contactPhone: row.contactPhone,
              isActive: row.isActive,
              invitationStatus: row.invitationStatus != null
                  ? ServiceProviderInvitationStatus.fromString(
                      row.invitationStatus!,
                    )
                  : null,
              createdAt: row.createdAt,
              updatedAt: row.updatedAt,
              deletedAt: row.deletedAt,
            ),
          )
          .toList();

      return SuccessState(data: list);
    });
  }

  @override
  FutureData<ServiceProviderCompanyModel> getServiceProviderCompanyById(
    String id,
  ) {
    return ErrorHandler.execute(() async {
      final query = _database.select(_database.serviceProviderCompanies)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull());
      final row = await query.getSingleOrNull();

      if (row == null) {
        return FailureState(
          message: 'Empresa prestadora não encontrada'.hardcoded,
        );
      }

      final model = ServiceProviderCompanyModel(
        id: row.id,
        companyId: row.companyId,
        name: row.name,
        document: row.document ?? '',
        documentType: DocumentType.fromName(row.documentType ?? 'cpf'),
        contactEmail: row.contactEmail,
        contactPhone: row.contactPhone,
        isActive: row.isActive,
        invitationStatus: row.invitationStatus != null
            ? ServiceProviderInvitationStatus.fromString(row.invitationStatus!)
            : null,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        deletedAt: row.deletedAt,
      );

      return SuccessState(data: model);
    });
  }

  @override
  FutureBool saveServiceProviderCompany(ServiceProviderCompanyModel company) {
    return ErrorHandler.execute(() async {
      await _database
          .into(_database.serviceProviderCompanies)
          .insertOnConflictUpdate(
            ServiceProviderCompaniesCompanion(
              id: Value(company.id),
              companyId: Value(company.companyId),
              name: Value(company.name),
              document: Value(company.document),
              documentType: Value(company.documentType.name),
              contactEmail: Value(company.contactEmail),
              contactPhone: Value(company.contactPhone),
              isActive: Value(company.isActive),
              invitationStatus: Value(company.invitationStatus?.value),
              createdAt: Value(company.createdAt),
              updatedAt: Value(company.updatedAt),
              deletedAt: Value(company.deletedAt),
            ),
          );
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool saveServiceProviderCompanies(
    List<ServiceProviderCompanyModel> companies,
  ) {
    return ErrorHandler.execute(() async {
      await _database.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _database.serviceProviderCompanies,
          companies
              .map(
                (company) => ServiceProviderCompaniesCompanion(
                  id: Value(company.id),
                  companyId: Value(company.companyId),
                  name: Value(company.name),
                  document: Value(company.document),
                  documentType: Value(company.documentType.name),
                  contactEmail: Value(company.contactEmail),
                  contactPhone: Value(company.contactPhone),
                  isActive: Value(company.isActive),
                  invitationStatus: Value(company.invitationStatus?.value),
                  createdAt: Value(company.createdAt),
                  updatedAt: Value(company.updatedAt),
                  deletedAt: Value(company.deletedAt),
                ),
              )
              .toList(),
        );
      });
      return const SuccessState(data: true);
    });
  }

  @override
  FutureList<ServiceProviderProfileModel> getServiceProviderProfiles(
    String serviceProviderCompanyId,
  ) {
    return ErrorHandler.execute(() async {
      final query = _database.select(_database.serviceProviderProfiles)
        ..where(
          (t) => t.serviceProviderCompanyId.equals(serviceProviderCompanyId),
        );
      final rows = await query.get();

      final list = rows
          .map(
            (row) => ServiceProviderProfileModel(
              id: row.id,
              authUserId: row.authUserId,
              serviceProviderCompanyId: row.serviceProviderCompanyId,
              name: row.name,
              email: row.email,
              phone: row.phone,
              isActive: row.isActive,
              createdAt: row.createdAt,
              updatedAt: row.updatedAt,
            ),
          )
          .toList();

      return SuccessState(data: list);
    });
  }

  @override
  FutureList<ServiceProviderProfileModel>
  getServiceProviderProfilesByCompanyIds(
    List<String> serviceProviderCompanyIds,
  ) {
    return ErrorHandler.execute(() async {
      if (serviceProviderCompanyIds.isEmpty) {
        return const SuccessState(data: []);
      }
      final query = _database.select(_database.serviceProviderProfiles)
        ..where(
          (t) => t.serviceProviderCompanyId.isIn(serviceProviderCompanyIds),
        );
      final rows = await query.get();

      final list = rows
          .map(
            (row) => ServiceProviderProfileModel(
              id: row.id,
              authUserId: row.authUserId,
              serviceProviderCompanyId: row.serviceProviderCompanyId,
              name: row.name,
              email: row.email,
              phone: row.phone,
              isActive: row.isActive,
              createdAt: row.createdAt,
              updatedAt: row.updatedAt,
            ),
          )
          .toList();

      return SuccessState(data: list);
    });
  }

  @override
  FutureBool saveServiceProviderProfile(ServiceProviderProfileModel profile) {
    return ErrorHandler.execute(() async {
      await _database
          .into(_database.serviceProviderProfiles)
          .insertOnConflictUpdate(
            ServiceProviderProfilesCompanion(
              id: Value(profile.id),
              authUserId: Value(profile.authUserId),
              serviceProviderCompanyId: Value(profile.serviceProviderCompanyId),
              name: Value(profile.name),
              email: Value(profile.email),
              phone: Value(profile.phone),
              isActive: Value(profile.isActive),
              createdAt: Value(profile.createdAt),
              updatedAt: Value(profile.updatedAt),
            ),
          );
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool saveServiceProviderProfiles(
    List<ServiceProviderProfileModel> profiles,
  ) {
    return ErrorHandler.execute(() async {
      await _database.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _database.serviceProviderProfiles,
          profiles
              .map(
                (profile) => ServiceProviderProfilesCompanion(
                  id: Value(profile.id),
                  authUserId: Value(profile.authUserId),
                  serviceProviderCompanyId: Value(
                    profile.serviceProviderCompanyId,
                  ),
                  name: Value(profile.name),
                  email: Value(profile.email),
                  phone: Value(profile.phone),
                  isActive: Value(profile.isActive),
                  createdAt: Value(profile.createdAt),
                  updatedAt: Value(profile.updatedAt),
                ),
              )
              .toList(),
        );
      });
      return const SuccessState(data: true);
    });
  }

  @override
  FutureList<ServiceProviderInvitationModel> getServiceProviderInvitations(
    String serviceProviderCompanyId,
  ) {
    return ErrorHandler.execute(() async {
      final query = _database.select(_database.serviceProviderInvitations)
        ..where(
          (t) => t.serviceProviderCompanyId.equals(serviceProviderCompanyId),
        );
      final rows = await query.get();

      final list = rows
          .map(
            (row) => ServiceProviderInvitationModel(
              id: row.id,
              email: row.email,
              serviceProviderCompanyId: row.serviceProviderCompanyId,
              inviteToken: row.inviteToken,
              status: ServiceProviderInvitationStatus.fromString(row.status),
              createdAt: row.createdAt,
              acceptedAt: row.acceptedAt,
              expiresAt: row.expiresAt,
            ),
          )
          .toList();

      return SuccessState(data: list);
    });
  }

  @override
  FutureBool saveServiceProviderInvitations(
    List<ServiceProviderInvitationModel> invitations,
  ) {
    return ErrorHandler.execute(() async {
      await _database.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _database.serviceProviderInvitations,
          invitations
              .map(
                (invitation) => ServiceProviderInvitationsCompanion(
                  id: Value(invitation.id),
                  email: Value(invitation.email),
                  serviceProviderCompanyId: Value(
                    invitation.serviceProviderCompanyId,
                  ),
                  inviteToken: Value(invitation.inviteToken),
                  status: Value(invitation.status.value),
                  createdAt: Value(invitation.createdAt),
                  acceptedAt: Value(invitation.acceptedAt),
                  expiresAt: Value(invitation.expiresAt),
                ),
              )
              .toList(),
        );
      });
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool deleteServiceProviderInvitation(String invitationId) {
    return ErrorHandler.execute(() async {
      final query = _database.delete(_database.serviceProviderInvitations)
        ..where((t) => t.id.equals(invitationId));
      await query.go();
      return const SuccessState(data: true);
    });
  }
}
