import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_profile_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_service_provider_profiles_by_auth_user_use_case.dart';

/// The session user's own provider profile, optionally narrowed to one provider
/// company.
///
/// Anything written from provider mode is attributed to a
/// `service_provider_profiles` row rather than to a `user_profiles` row, since
/// a provider-only user has none of the latter. Pass the
/// `serviceProviderCompanyId` of the record being acted on so the right profile
/// is chosen when the user belongs to more than one provider company.
@LazySingleton()
class GetSessionProviderProfileUseCase
    implements UseCase<ServiceProviderProfileEntity, String?> {
  GetSessionProviderProfileUseCase({
    required GetSessionUserUseCase getSessionUser,
    required GetServiceProviderProfilesByAuthUserUseCase
    getServiceProviderProfilesByAuthUser,
  }) : _getSessionUser = getSessionUser,
       _getServiceProviderProfilesByAuthUser =
           getServiceProviderProfilesByAuthUser;

  final GetSessionUserUseCase _getSessionUser;
  final GetServiceProviderProfilesByAuthUserUseCase
  _getServiceProviderProfilesByAuthUser;

  static const _notFoundMessage = 'Perfil de prestador não encontrado.';

  @override
  FutureData<ServiceProviderProfileEntity> call(
    String? serviceProviderCompanyId,
  ) async {
    final user = _getSessionUser();
    if (user.id.isEmpty) {
      return FailureState(message: _notFoundMessage.hardcoded);
    }

    final result = await _getServiceProviderProfilesByAuthUser(user.id);
    if (result is! SuccessState<List<ServiceProviderProfileEntity>>) {
      return FailureState(
        message: result.message ?? _notFoundMessage.hardcoded,
      );
    }

    final profiles = result.data ?? const <ServiceProviderProfileEntity>[];
    final profile =
        profiles.firstWhereOrNull(
          (e) => e.serviceProviderCompanyId == serviceProviderCompanyId,
        ) ??
        profiles.firstOrNull;

    if (profile == null) {
      return FailureState(message: _notFoundMessage.hardcoded);
    }
    return SuccessState(data: profile);
  }
}
