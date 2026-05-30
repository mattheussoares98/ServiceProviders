import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/auth/domain/entities/sign_up_entity.dart';
import 'package:clean_architecture/features/auth/presentation/cubits/sign_up/sign_up_cubit_use_cases.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:injectable/injectable.dart';

part 'sign_up_state.dart';

@injectable
class SignUpCubit extends BaseCubit<SignUpState> {
  SignUpCubit({required SignUpCubitUseCases useCases})
    : _useCases = useCases,
      super(const SignUpState.initial());

  final SignUpCubitUseCases _useCases;
  bool _passwordVisibility = false;
  bool _confirmPasswordVisibility = false;

  void _refreshState([StateStatus status = StateStatus.loaded]) {
    emit(
      SignUpState(
        passwordVisibility: _passwordVisibility,
        confirmPasswordVisibility: _confirmPasswordVisibility,
        status: status,
      ),
    );
  }

  void togglePasswordVisibility() {
    _passwordVisibility = !_passwordVisibility;
    _refreshState();
  }

  void toggleConfirmPasswordVisibility() {
    _confirmPasswordVisibility = !_confirmPasswordVisibility;
    _refreshState();
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _refreshState(StateStatus.loading);

    final signUpEntity = SignUpEntity(
      name: name,
      email: email,
      password: password,
    );

    final dataState = await _useCases.signUp.call(signUpEntity);
    if (isClosed) return;

    if (dataState is SuccessState) {
      await maybePopRoute();
      showDataStateToast(
        dataState,
        message: 'Confirme o cadastro no seu e-mail'.hardcoded,
      );
    }

    _refreshState();
  }
}
