import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/document_type.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_invitation_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_invitation_status.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_profile_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/send_service_provider_invitation_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/cubits/service_providers/service_providers_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:uuid/uuid.dart';

part 'service_providers_state.dart';

@injectable
class ServiceProvidersCubit extends BaseCubit<ServiceProvidersState> {
  ServiceProvidersCubit({required ServiceProvidersCubitUseCases useCases})
    : _useCases = useCases,
      super(const ServiceProvidersState.initial());

  final ServiceProvidersCubitUseCases _useCases;

  Future<void> loadCompaniesAndProfiles({
    bool forceRefresh = false,
    bool emitLoading = true,
  }) async {
    if (!forceRefresh && state.companies.isNotEmpty) {
      return;
    }

    emit(state.copyWith(status: emitLoading ? StateStatus.loading : null));

    final companyId = _useCases.getActiveCompanyId();
    final result = await _useCases.getCompanies.call(companyId);
    if (isClosed) return;

    if (result is FailureState<List<ServiceProviderCompanyEntity>>) {
      emit(
        state.copyWith(
          status: StateStatus.loadingError,
          errorMessage: result.message,
        ),
      );
      showErrorToast(result.message);
      return;
    }

    final companies =
        (result as SuccessState<List<ServiceProviderCompanyEntity>>).data ?? [];
    final companyIds = companies.map((c) => c.id).toList();

    final profilesResult = await _useCases.getProfilesByCompanyIds.call(
      companyIds,
    );
    if (isClosed) return;

    final updatedProfiles =
        Map<String, List<ServiceProviderProfileEntity>>.from(state.profiles);
    if (profilesResult is SuccessState<List<ServiceProviderProfileEntity>>) {
      final allProfiles = profilesResult.data ?? [];
      for (final profile in allProfiles) {
        updatedProfiles.putIfAbsent(
          profile.serviceProviderCompanyId,
          () => [profile],
        );
      }
    }

    emit(
      state.copyWith(
        status: StateStatus.loaded,
        companies: companies,
        profiles: updatedProfiles,
      ),
    );
  }

  Future<void> selectCompany(
    String? companyId, {
    bool emitLoading = true,
  }) async {
    if (companyId == null) {
      emit(state.copyWith(annulCompanyId: true, annulProfileId: true));
      return;
    }

    if (state.profiles.containsKey(companyId) &&
        state.invitations.containsKey(companyId)) {
      // Both profiles and invitations are already loaded for this company
      emit(state.copyWith(selectedCompanyId: companyId, annulProfileId: true));
      return;
    }

    final updatedLoadingIds = Set<String>.from(state.loadingCompanyIds)
      ..add(companyId);

    emit(
      state.copyWith(
        selectedCompanyId: companyId,
        annulProfileId: true,
        status: emitLoading ? StateStatus.loading : null,
        loadingCompanyIds: updatedLoadingIds,
      ),
    );

    final results = await Future.wait([
      _useCases.getProfiles.call(companyId),
      _useCases.getInvitations.call(companyId),
    ]);

    if (isClosed) return;

    final finishedLoadingIds = Set<String>.from(state.loadingCompanyIds)
      ..remove(companyId);

    final profilesResult =
        results[0] as DataState<List<ServiceProviderProfileEntity>>;
    final invitationsResult =
        results[1] as DataState<List<ServiceProviderInvitationEntity>>;

    if (profilesResult is FailureState<List<ServiceProviderProfileEntity>>) {
      emit(
        state.copyWith(
          status: StateStatus.loadingError,
          errorMessage: profilesResult.message,
          loadingCompanyIds: finishedLoadingIds,
        ),
      );
      showErrorToast(profilesResult.message);
      return;
    }

    if (invitationsResult
        is FailureState<List<ServiceProviderInvitationEntity>>) {
      emit(
        state.copyWith(
          status: StateStatus.loadingError,
          errorMessage: invitationsResult.message,
          loadingCompanyIds: finishedLoadingIds,
        ),
      );
      showErrorToast(invitationsResult.message);
      return;
    }

    final updatedProfiles =
        Map<String, List<ServiceProviderProfileEntity>>.from(state.profiles);
    final updatedInvitations =
        Map<String, List<ServiceProviderInvitationEntity>>.from(
          state.invitations,
        );

    if (profilesResult is SuccessState<List<ServiceProviderProfileEntity>>) {
      updatedProfiles[companyId] = profilesResult.data ?? [];
    }

    if (invitationsResult
        is SuccessState<List<ServiceProviderInvitationEntity>>) {
      updatedInvitations[companyId] = invitationsResult.data ?? [];
    }

    emit(
      state.copyWith(
        status: StateStatus.loaded,
        profiles: updatedProfiles,
        invitations: updatedInvitations,
        loadingCompanyIds: finishedLoadingIds,
      ),
    );
  }

  void selectProfile(String? profileId) {
    if (profileId == null) {
      emit(state.copyWith(annulProfileId: true));
    } else {
      emit(state.copyWith(selectedProfileId: profileId));
    }
  }

  /// Loads profiles for [companyId] only if they are not already cached.
  /// Does not affect selection state or invitations — safe to call for read-only display.
  Future<void> ensureProfilesLoaded(String companyId) async {
    if (state.profiles.containsKey(companyId)) return;

    final result = await _useCases.getProfiles.call(companyId);
    if (isClosed) return;

    if (result is SuccessState<List<ServiceProviderProfileEntity>>) {
      final updatedProfiles =
          Map<String, List<ServiceProviderProfileEntity>>.from(state.profiles);
      updatedProfiles[companyId] = result.data ?? [];
      emit(state.copyWith(profiles: updatedProfiles));
    }
  }

  Future<bool> saveCompany({
    required String name,
    required String document,
    required DocumentType documentType,
    String? serviceProviderCompanyId,
    String? contactEmail,
    String? contactPhone,
    bool sendInvite = false,
  }) async {
    emit(state.copyWith(status: StateStatus.saving));
    final activeCompanyId = _useCases.getActiveCompanyId();
    final now = DateTime.now();

    final isUpdate =
        serviceProviderCompanyId != null && serviceProviderCompanyId.isNotEmpty;
    final existingCompany = isUpdate
        ? state.companies.firstWhereOrNull(
            (c) => c.id == serviceProviderCompanyId,
          )
        : null;

    final company = ServiceProviderCompanyEntity(
      id: serviceProviderCompanyId ?? const Uuid().v4(),
      companyId: activeCompanyId,
      name: name,
      contactEmail: contactEmail,
      contactPhone: contactPhone,
      document: document,
      documentType: documentType,
      isActive: existingCompany?.isActive ?? true,
      createdAt: existingCompany?.createdAt ?? now,
      updatedAt: now,
      deletedAt: existingCompany?.deletedAt,
      invitationStatus: sendInvite
          ? ServiceProviderInvitationStatus.pending
          : existingCompany?.invitationStatus,
    );

    final DataState<bool> result;
    if (isUpdate) {
      result = await _useCases.updateCompany.call(company);
    } else {
      result = await _useCases.createCompany.call(company);
    }

    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      DataState<bool>? sentInvitation;
      if (sendInvite &&
          contactEmail != null &&
          contactEmail.trim().isNotEmpty) {
        sentInvitation = await _useCases.sendInvitation.call(
          SendServiceProviderInvitationParams(
            serviceProviderCompanyId: company.id,
            email: contactEmail.trim(),
          ),
        );

        await _useCases.getInvitations.call(company.id);
      }

      await loadCompaniesAndProfiles(forceRefresh: true, emitLoading: false);

      if (sentInvitation is FailureState) {
        emit(
          state.copyWith(
            status: StateStatus.savingError,
            errorMessage: sentInvitation?.message,
          ),
        );
        showErrorToast(
          'Erro para enviar o convite: ${sentInvitation?.message}',
        );
      }
      return true;
    } else {
      emit(
        state.copyWith(
          status: StateStatus.savingError,
          errorMessage: result.message,
        ),
      );
      showErrorToast(result.message);
      return false;
    }
  }

  Future<bool> saveProfile({
    required String serviceProviderCompanyId,
    required String name,
    required String email,
    required String phone,
    String? profileId,
  }) async {
    emit(state.copyWith(status: StateStatus.saving));
    final now = DateTime.now();

    final isUpdate = profileId != null && profileId.isNotEmpty;
    final companyProfiles = state.profiles[serviceProviderCompanyId] ?? [];
    final existingProfile = isUpdate
        ? companyProfiles.firstWhereOrNull((p) => p.id == profileId)
        : null;

    final profile = ServiceProviderProfileEntity(
      id: profileId ?? const Uuid().v4(),
      authUserId: existingProfile?.authUserId,
      serviceProviderCompanyId: serviceProviderCompanyId,
      name: name,
      email: email,
      phone: phone.isEmpty ? null : phone,
      isActive: existingProfile?.isActive ?? true,
      createdAt: existingProfile?.createdAt ?? now,
      updatedAt: now,
    );

    final DataState<bool> result;
    if (isUpdate) {
      result = await _useCases.updateProfile.call(profile);
    } else {
      result = await _useCases.createProfile.call(profile);
    }

    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      final fetchResult = await _useCases.getProfiles.call(
        serviceProviderCompanyId,
      );
      if (fetchResult is SuccessState<List<ServiceProviderProfileEntity>>) {
        final updatedProfiles =
            Map<String, List<ServiceProviderProfileEntity>>.from(
              state.profiles,
            );
        updatedProfiles[serviceProviderCompanyId] = fetchResult.data ?? [];
        emit(
          state.copyWith(status: StateStatus.loaded, profiles: updatedProfiles),
        );
      }
      return true;
    } else {
      emit(
        state.copyWith(
          status: StateStatus.savingError,
          errorMessage: result.message,
        ),
      );
      showErrorToast(result.message);
      return false;
    }
  }

  Future<bool> sendInvitation({
    required String serviceProviderCompanyId,
    required String email,
  }) async {
    emit(state.copyWith(status: StateStatus.saving));

    final result = await _useCases.sendInvitation.call(
      SendServiceProviderInvitationParams(
        serviceProviderCompanyId: serviceProviderCompanyId,
        email: email,
      ),
    );

    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      final activeCompanyId = _useCases.getActiveCompanyId.call();
      if (activeCompanyId.isNotEmpty) {
        final companiesResult = await _useCases.getCompanies.call(
          activeCompanyId,
        );
        if (companiesResult
            is SuccessState<List<ServiceProviderCompanyEntity>>) {
          emit(state.copyWith(companies: companiesResult.data ?? []));
        }
      }

      final fetchResult = await _useCases.getInvitations.call(
        serviceProviderCompanyId,
      );
      if (fetchResult is SuccessState<List<ServiceProviderInvitationEntity>>) {
        final updatedInvitations =
            Map<String, List<ServiceProviderInvitationEntity>>.from(
              state.invitations,
            );
        updatedInvitations[serviceProviderCompanyId] = fetchResult.data ?? [];
        emit(
          state.copyWith(
            status: StateStatus.loaded,
            invitations: updatedInvitations,
          ),
        );
      } else {
        emit(state.copyWith(status: StateStatus.loaded));
      }
      showSuccessToast('Convite enviado com sucesso!'.hardcoded);
      return true;
    } else {
      emit(
        state.copyWith(
          status: StateStatus.savingError,
          errorMessage: result.message,
        ),
      );
      showErrorToast(result.message);
      return false;
    }
  }

  Future<bool> deleteInvitation({
    required String invitationId,
    required String serviceProviderCompanyId,
  }) async {
    emit(state.copyWith(status: StateStatus.saving));

    final result = await _useCases.deleteInvitation.call(invitationId);

    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      final activeCompanyId = _useCases.getActiveCompanyId.call();
      if (activeCompanyId.isNotEmpty) {
        final companiesResult = await _useCases.getCompanies.call(
          activeCompanyId,
        );
        if (companiesResult
            is SuccessState<List<ServiceProviderCompanyEntity>>) {
          emit(state.copyWith(companies: companiesResult.data ?? []));
        }
      }

      final fetchResult = await _useCases.getInvitations.call(
        serviceProviderCompanyId,
      );
      if (fetchResult is SuccessState<List<ServiceProviderInvitationEntity>>) {
        final updatedInvitations =
            Map<String, List<ServiceProviderInvitationEntity>>.from(
              state.invitations,
            );
        updatedInvitations[serviceProviderCompanyId] = fetchResult.data ?? [];
        emit(
          state.copyWith(
            status: StateStatus.loaded,
            invitations: updatedInvitations,
          ),
        );
      } else {
        emit(state.copyWith(status: StateStatus.loaded));
      }
      return true;
    } else {
      emit(
        state.copyWith(
          status: StateStatus.savingError,
          errorMessage: result.message,
        ),
      );
      showErrorToast(result.message);
      return false;
    }
  }

  Future<void> navigateToCreateUpdateServiceProviderCompany(
    String? serviceProviderCompanyId,
  ) async {
    await pushRoute(
      CreateUpdateServiceProviderCompanyRoute(
        serviceProviderCompanyId: serviceProviderCompanyId,
      ),
    );
  }
}
