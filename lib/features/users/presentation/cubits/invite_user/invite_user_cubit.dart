import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/users/domain/entities/invite_user_params.dart';
import 'package:clean_architecture/features/users/presentation/cubits/invite_user/invite_user_usecases.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:injectable/injectable.dart';

part 'invite_user_state.dart';

@injectable
class InviteUserCubit extends BaseCubit<InviteUserState> {
  InviteUserCubit({required InviteUserCubitUseCases useCases})
    : _useCases = useCases,
      super(const InviteUserState());

  final InviteUserCubitUseCases _useCases;

  Future<bool> invite({required String email, required String groupId}) async {
    final user = _useCases.getSessionUser();
    if (user.companyId.isEmpty) {
      showErrorToast(
        'Erro não esperado. O usuário está sem o ID da companhia'.hardcoded,
      );
      emit(state.copyWith(status: StateStatus.loadingError));
      //TODO instead of treat it inside a lot of different methods, centralize it
      return false;
    }

    emit(state.copyWith(status: StateStatus.loading));

    final dataState = await _useCases.inviteUser(
      InviteUserParams(
        email: email,
        companyId: user.companyId,
        groupId: groupId,
      ),
    );

    showDataStateToast(
      dataState,
      message:
          'Convite enviado com sucesso. Cheque o e-mail para aceitar o convite'
              .hardcoded,
    );
    emit(state.copyWith(status: StateStatus.loaded));
    if (dataState is SuccessState<void>) {
      return true;
    } else {
      return false;
    }
  }
}
