import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/document_type.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_invitation_entity.dart';
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

  Future<void> loadCompanies(
    String companyId, {
    bool forceRefresh = false,
    bool emitLoading = true,
  }) async {
    if (!forceRefresh && state.companies.isNotEmpty) {
      return;
    }

    emit(
      state.copyWith(
        status: emitLoading ? StateStatus.loading : null,
        invitations: {},
      ),
    );

    final result = await _useCases.getCompanies.call(companyId);

    if (isClosed) return;

    if (result is SuccessState<List<ServiceProviderCompanyEntity>>) {
      emit(
        state.copyWith(
          status: StateStatus.loaded,
          companies: result.data ?? [],
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: StateStatus.loadingError,
          errorMessage: result.message,
        ),
      );
      showErrorToast(result.message);
    }
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

  Future<bool> saveCompany({
    required String name,
    required String document,
    required DocumentType documentType,
    String? companyId,
    String? contactEmail,
    String? contactPhone,
    bool sendInvite = false,
  }) async {
    emit(state.copyWith(status: StateStatus.saving));
    final user = _useCases.getSessionUser();
    final now = DateTime.now();

    final isUpdate = companyId != null && companyId.isNotEmpty;
    final existingCompany = isUpdate
        ? state.companies.firstWhereOrNull((c) => c.id == companyId)
        : null;

    final company = ServiceProviderCompanyEntity(
      id: companyId ?? const Uuid().v4(),
      companyId: user.companyId,
      name: name,
      contactEmail: contactEmail,
      contactPhone: contactPhone,
      document: document,
      documentType: documentType,
      isActive: existingCompany?.isActive ?? true,
      createdAt: existingCompany?.createdAt ?? now,
      updatedAt: now,
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

      await loadCompanies(
        company.companyId,
        forceRefresh: true,
        emitLoading: false,
      );

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

  Future<bool> deleteInvitation({
    required String invitationId,
    required String serviceProviderCompanyId,
  }) async {
    emit(state.copyWith(status: StateStatus.saving));

    final result = await _useCases.deleteInvitation.call(invitationId);

    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
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
        cubit: this,
      ),
    );
  }
}
