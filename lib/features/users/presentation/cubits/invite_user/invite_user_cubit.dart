import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/invite_user_params.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/invite_user/invite_user_usecases.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'invite_user_state.dart';

enum InviteUserSections implements SectionKey { invite }

@injectable
class InviteUserCubit extends BaseCubit<InviteUserState> {
  InviteUserCubit({required InviteUserCubitUseCases useCases})
    : _useCases = useCases,
      super(const InviteUserState());

  final InviteUserCubitUseCases _useCases;

  Future<bool> invite({required String email, required String groupId}) async {
    final companyId = _useCases.getActiveCompanyId();

    emit(
      state.copyWith(
        sections: withSection(InviteUserSections.invite, SectionStatus.running),
      ),
    );

    final dataState = await _useCases.inviteUser(
      InviteUserParams(email: email, companyId: companyId, groupId: groupId),
    );

    showDataStateToast(
      dataState,
      message:
          'Convite enviado com sucesso. Cheque o e-mail para aceitar o convite'
              .hardcoded,
    );
    if (dataState is SuccessState<void>) {
      emit(
        state.copyWith(
          sections: withSection(
            InviteUserSections.invite,
            SectionStatus.success,
          ),
        ),
      );
      return true;
    } else {
      emit(
        state.copyWith(
          sections: withSection(InviteUserSections.invite, SectionStatus.error),
        ),
      );
      return false;
    }
  }
}
