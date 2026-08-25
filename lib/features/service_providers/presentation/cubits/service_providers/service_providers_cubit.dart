import 'dart:async';

import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
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
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit_sections.dart';
import 'package:uuid/uuid.dart';

part 'service_providers_state.dart';

enum ServiceProviderSection implements SectionKey { selectCompany }

@injectable
class ServiceProvidersCubit extends BaseCubit<ServiceProvidersState> {
  ServiceProvidersCubit({required ServiceProvidersCubitUseCases useCases})
    : _useCases = useCases,
      super(const ServiceProvidersState.initial()) {
    _initRealtime();
  }

  final ServiceProvidersCubitUseCases _useCases;
  StreamSubscription<RealtimeEvent<ServiceProviderCompanyEntity>>?
  _companiesSubscription;
  StreamSubscription<RealtimeEvent<ServiceProviderProfileEntity>>?
  _profilesSubscription;

  void _initRealtime() {
    final companyId = _useCases.getActiveCompanyId();
    _companiesSubscription = _useCases.watchCompaniesRealtime
        .call(companyId: companyId)
        .listen(_handleCompanyRealtimeEvent);
    _profilesSubscription = _useCases.watchProfilesRealtime
        .call()
        .listen(_handleProfileRealtimeEvent);
  }

  void _handleCompanyRealtimeEvent(
    RealtimeEvent<ServiceProviderCompanyEntity> event,
  ) {
    if (isClosed) return;

    final currentCompanies = List<ServiceProviderCompanyEntity>.from(
      state.companies,
    );

    switch (event.eventType) {
      case RealtimeEventType.insert:
        if (event.entity != null) {
          final index = currentCompanies.indexWhere((c) => c.id == event.id);
          if (index == -1) {
            currentCompanies.insert(0, event.entity!);
          } else {
            currentCompanies[index] = event.entity!;
          }
          emit(state.copyWith(companies: currentCompanies));
        }
      case RealtimeEventType.update:
        if (event.entity != null) {
          final index = currentCompanies.indexWhere((c) => c.id == event.id);
          if (index != -1) {
            currentCompanies[index] = event.entity!;
          } else {
            currentCompanies.add(event.entity!);
          }
          emit(state.copyWith(companies: currentCompanies));
        }
      case RealtimeEventType.delete:
        final index = currentCompanies.indexWhere((c) => c.id == event.id);
        if (index != -1) {
          currentCompanies.removeAt(index);
          emit(state.copyWith(companies: currentCompanies));
        }
    }
  }

  void _handleProfileRealtimeEvent(
    RealtimeEvent<ServiceProviderProfileEntity> event,
  ) {
    if (isClosed) return;

    final updatedProfiles =
        Map<String, List<ServiceProviderProfileEntity>>.from(
      state.profiles.map(
        (key, value) =>
            MapEntry(key, List<ServiceProviderProfileEntity>.from(value)),
      ),
    );

    switch (event.eventType) {
      case RealtimeEventType.insert:
        if (event.entity != null) {
          final companyId = event.entity!.serviceProviderCompanyId;
          final list = updatedProfiles.putIfAbsent(companyId, () => []);
          final index = list.indexWhere((p) => p.id == event.id);
          if (index == -1) {
            list.insert(0, event.entity!);
          } else {
            list[index] = event.entity!;
          }
          emit(state.copyWith(profiles: updatedProfiles));
        }
      case RealtimeEventType.update:
        if (event.entity != null) {
          final companyId = event.entity!.serviceProviderCompanyId;
          final list = updatedProfiles.putIfAbsent(companyId, () => []);
          final index = list.indexWhere((p) => p.id == event.id);
          if (index != -1) {
            list[index] = event.entity!;
          } else {
            list.add(event.entity!);
          }
          emit(state.copyWith(profiles: updatedProfiles));
        }
      case RealtimeEventType.delete:
        var changed = false;
        for (final list in updatedProfiles.values) {
          final index = list.indexWhere((p) => p.id == event.id);
          if (index != -1) {
            list.removeAt(index);
            changed = true;
            break;
          }
        }
        if (changed) {
          emit(state.copyWith(profiles: updatedProfiles));
        }
    }
  }

  Future<void> loadCompaniesAndProfiles({
    bool forceRefresh = false,
    bool emitLoading = true,
  }) async {
    if (!forceRefresh && state.companies.isNotEmpty) {
      return;
    }

    emit(
      state.copyWith(
        status: emitLoading ? StateStatus.loading : null,
        annulCompanyId: forceRefresh,
      ),
    );

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

    if (profilesResult is FailureState<List<ServiceProviderProfileEntity>>) {
      emit(
        state.copyWith(
          status: StateStatus.loadingError,
          errorMessage: profilesResult.message,
        ),
      );
      return;
    }

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
        invitations: forceRefresh ? const {} : state.invitations,
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
        sections: emitLoading
            ? withSection(
                ServiceProviderSection.selectCompany,
                StateStatus.loading,
              )
            : null,
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
          sections: emitLoading
              ? withSection(
                  ServiceProviderSection.selectCompany,
                  StateStatus.loadingError,
                )
              : null,
          errorMessage: profilesResult.message,
          loadingCompanyIds: finishedLoadingIds,
        ),
      );
      return;
    }

    if (invitationsResult
        is FailureState<List<ServiceProviderInvitationEntity>>) {
      emit(
        state.copyWith(
          sections: withSection(
            ServiceProviderSection.selectCompany,
            StateStatus.loadingError,
          ),
          errorMessage: invitationsResult.message,
          loadingCompanyIds: finishedLoadingIds,
        ),
      );
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
        sections: withSection(
          ServiceProviderSection.selectCompany,
          StateStatus.loaded,
        ),
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
    final now = DateTime.now().toUtc();

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
    final now = DateTime.now().toUtc();

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

  @override
  Future<void> close() {
    _companiesSubscription?.cancel();
    _profilesSubscription?.cancel();
    return super.close();
  }
}
