import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/service_provider_profile_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/create_service_provider_company_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/create_service_provider_profile_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_service_provider_companies_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_service_provider_profiles_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/update_service_provider_company_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/update_service_provider_profile_use_case.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'service_providers_state.dart';

@injectable
class ServiceProvidersCubit extends BaseCubit<ServiceProvidersState> {
  ServiceProvidersCubit({
    required GetServiceProviderCompaniesUseCase getCompanies,
    required GetServiceProviderProfilesUseCase getProfiles,
    required CreateServiceProviderCompanyUseCase createCompany,
    required UpdateServiceProviderCompanyUseCase updateCompany,
    required CreateServiceProviderProfileUseCase createProfile,
    required UpdateServiceProviderProfileUseCase updateProfile,
  }) : _getCompanies = getCompanies,
       _getProfiles = getProfiles,
       _createCompany = createCompany,
       _updateCompany = updateCompany,
       _createProfile = createProfile,
       _updateProfile = updateProfile,
       super(const ServiceProvidersState.initial());

  final GetServiceProviderCompaniesUseCase _getCompanies;
  final GetServiceProviderProfilesUseCase _getProfiles;
  final CreateServiceProviderCompanyUseCase _createCompany;
  final UpdateServiceProviderCompanyUseCase _updateCompany;
  final CreateServiceProviderProfileUseCase _createProfile;
  final UpdateServiceProviderProfileUseCase _updateProfile;

  Future<void> loadCompanies(String companyId) async {
    emit(state.copyWith(status: StateStatus.loading));
    final result = await _getCompanies.call(companyId);

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
          errorMessage:
              result.message ?? 'Erro ao carregar prestadores de serviços.',
        ),
      );
    }
  }

  Future<void> selectCompany(String? companyId) async {
    if (companyId == null) {
      emit(
        state.copyWith(
          annulCompanyId: true,
          annulProfileId: true,
          profiles: [],
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        selectedCompanyId: companyId,
        annulProfileId: true,
        status: StateStatus.loading,
      ),
    );

    final result = await _getProfiles.call(companyId);

    if (isClosed) return;

    if (result is SuccessState<List<ServiceProviderProfileEntity>>) {
      emit(
        state.copyWith(status: StateStatus.loaded, profiles: result.data ?? []),
      );
    } else {
      emit(
        state.copyWith(
          status: StateStatus.loadingError,
          errorMessage:
              result.message ?? 'Erro ao carregar técnicos do prestador.',
        ),
      );
    }
  }

  void selectProfile(String? profileId) {
    if (profileId == null) {
      emit(state.copyWith(annulProfileId: true));
    } else {
      emit(state.copyWith(selectedProfileId: profileId));
    }
  }

  Future<bool> saveCompany(ServiceProviderCompanyEntity company) async {
    emit(state.copyWith(status: StateStatus.saving));
    final isUpdate =
        company.id.isNotEmpty && state.companies.any((e) => e.id == company.id);

    final result = isUpdate
        ? await _updateCompany.call(company)
        : await _createCompany.call(company);

    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      await loadCompanies(company.companyId);
      return true;
    } else {
      emit(
        state.copyWith(
          status: StateStatus.savingError,
          errorMessage:
              result.message ?? 'Erro ao salvar prestador de serviços.',
        ),
      );
      return false;
    }
  }

  Future<bool> saveProfile(ServiceProviderProfileEntity profile) async {
    emit(state.copyWith(status: StateStatus.saving));
    final isUpdate =
        profile.id.isNotEmpty && state.profiles.any((e) => e.id == profile.id);

    final result = isUpdate
        ? await _updateProfile.call(profile)
        : await _createProfile.call(profile);

    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      await selectCompany(profile.serviceProviderCompanyId);
      return true;
    } else {
      emit(
        state.copyWith(
          status: StateStatus.savingError,
          errorMessage:
              result.message ?? 'Erro ao salvar técnico do prestador.',
        ),
      );
      return false;
    }
  }
}
