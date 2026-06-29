import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/users/domain/entities/invite_user_params.dart';
import 'package:clean_architecture/features/users/domain/use_cases/invite_user_use_case.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:injectable/injectable.dart';

part 'invite_user_state.dart';

@injectable
class InviteUserCubit extends BaseCubit<InviteUserState> {
  InviteUserCubit({required InviteUserUseCase inviteUser})
    : _inviteUser = inviteUser,
      super(const InviteUserState());

  final InviteUserUseCase _inviteUser;

  Future<bool> invite({
    required String email,
    required String companyId,
    required String groupId,
  }) async {
    emit(state.copyWith(status: StateStatus.loading));

    final dataState = await _inviteUser(
      InviteUserParams(email: email, companyId: companyId, groupId: groupId),
    );

    showDataStateToast(dataState);
    emit(state.copyWith(status: StateStatus.loaded));
    if (dataState is SuccessState<void>) {
      return true;
    } else {
      return false;
    }
  }
}
