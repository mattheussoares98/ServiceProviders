import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/change_password/change_password_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'change_password_state.dart';

@injectable
class ChangePasswordCubit extends BaseCubit<ChangePasswordState> {
  ChangePasswordCubit({required ChangePasswordCubitUseCases useCases})
    : _useCases = useCases,
      super(const ChangePasswordState.initial());

  final ChangePasswordCubitUseCases _useCases;
  bool _passwordVisibility = false;
  bool _confirmPasswordVisibility = false;

  void togglePasswordVisibility() {
    _passwordVisibility = !_passwordVisibility;
    _refreshState();
  }

  void toggleConfirmPasswordVisibility() {
    _confirmPasswordVisibility = !_confirmPasswordVisibility;
    _refreshState();
  }

  void _refreshState([SectionStatus status = SectionStatus.success]) {
    emit(
      ChangePasswordState(
        passwordVisibility: _passwordVisibility,
        confirmPasswordVisibility: _confirmPasswordVisibility,
        sections: withSection(BaseSections.load, status),
      ),
    );
  }

  Future<void> changePassword(String password) async {
    _refreshState(SectionStatus.running);

    final dataState = await _useCases.changePassword.call(password);
    if (isClosed) return;

    showDataStateToast(
      dataState,
      message: 'Senha alterada com sucesso!'.hardcoded,
    );

    if (dataState is SuccessState) {
      _refreshState();
      await replaceAllRoute(const LoginRoute());
    } else {
      _refreshState(SectionStatus.error);
    }
  }
}
