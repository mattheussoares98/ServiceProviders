import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/repositories/attachments_repository.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/pick_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/home/home_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/update_user_avatar_use_case.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'home_state.dart';

@injectable
class HomeCubit extends BaseCubit<HomeState> {
  HomeCubit({required HomeCubitUseCases useCases})
    : _useCases = useCases,
      super(const HomeState.empty());

  final HomeCubitUseCases _useCases;

  Future<void> logout() async {
    await _useCases.logOut.call();
    unawaited(_useCases.clearLocalAttachments.call());
    await replaceAllRoute(const LoginRoute());
  }

  Future<void> navigateToCompany() async {
    await pushRoute(const CompanyRoute());
  }

  Future<void> navigateToConfigurations() async {
    await pushRoute(const ConfigurationsRoute());
  }

  Future<void> navigateToPermissions() async {
    await pushRoute(const UsersAndPermissionsRoute());
  }

  Future<void> navigateToModeSwitcher() async {
    await pushRoute(const ModeSwitcherRoute());
  }

  Future<void> changeAvatar(AttachmentSource source) async {
    final user = _useCases.getSessionUser.call();

    emit(state.copyWith(status: StateStatus.saving));

    final pickResult = await _useCases.pickAttachment.call(
      PickAttachmentParams(
        source: source,
        workOrderId: 'avatar', // Dummy ID for R2 path prefix validation
        companyId: user.companyId,
        userId: user.id,
        multiple: false,
      ),
    );

    if (isClosed) return;

    if (pickResult is! SuccessState<List<AttachmentEntity>>) {
      showDataStateToast(pickResult);
      emit(state.copyWith(status: StateStatus.loaded));
      return;
    }

    final attachments = pickResult.data ?? [];
    if (attachments.isEmpty) {
      emit(state.copyWith(status: StateStatus.loaded));
      return;
    }

    final localPath = attachments.first.localPath;
    if (localPath == null || localPath.isEmpty) {
      showErrorToast('Erro ao obter o arquivo da imagem'.hardcoded);
      emit(state.copyWith(status: StateStatus.loaded));
      return;
    }

    final uploadResult = await _useCases.updateUserAvatar.call(
      UpdateUserAvatarParams(userProfile: user, localPath: localPath),
    );

    if (isClosed) return;

    if (uploadResult is SuccessState<bool>) {
      showSuccessToast('Foto de perfil atualizada com sucesso'.hardcoded);
      emit(state.copyWith(status: StateStatus.loaded));
    } else {
      showDataStateToast(uploadResult);
      emit(state.copyWith(status: StateStatus.savingError));
    }
  }
}
