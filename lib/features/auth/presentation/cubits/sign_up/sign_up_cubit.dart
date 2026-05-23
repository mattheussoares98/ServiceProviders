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

  void _refreshState() {
    emit(SignUpState(passwordVisibility: _passwordVisibility));
  }

  void togglePasswordVisibility() {
    _passwordVisibility = !_passwordVisibility;
    _refreshState();
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(
      SignUpState(
        passwordVisibility: _passwordVisibility,
        status: StateStatus.loading,
      ),
    );

    final signUpEntity = SignUpEntity(
      name: name,
      email: email,
      password: password,
    );

    final dataState = await _useCases.signUp.call(signUpEntity);
    showDataStateToast(
      dataState,
      message: 'Confirme o cadastro no seu e-mail'.hardcoded,
    );

    emit(
      SignUpState(
        passwordVisibility: _passwordVisibility,
        status: StateStatus.loaded,
      ),
    );

    if (!dataState.hasError) {
      //when signup succeeds, supabase auto set a session
      //TODO: Navigate to home
    }
  }
}
