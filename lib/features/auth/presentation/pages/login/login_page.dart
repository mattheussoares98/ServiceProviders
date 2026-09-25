import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/login/login_cubit.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/pages/login/widgets/create_account_button.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/pages/login/widgets/login_button.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/pages/login/widgets/login_form.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/pages/login/widgets/reset_password.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/pages/login/widgets/support_button.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/widgets/welcome_logo.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/screen_util/screen_util.dart';

@RoutePage()
class LoginPage extends HookWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final passwordFocusNode = useFocusNode();
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final loginCubit = useMemoized(() => GetIt.I<LoginCubit>()..clearSession());

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await loginCubit.getUserData();
        final email = loginCubit.state.userData?.user.email;
        if (email != null && email.isNotEmpty) {
          emailController.text = email;
        }
      });
      return null;
    }, const []);

    return BlocProvider.value(
      value: loginCubit,
      child: Scaffold(
        body: Center(
          child: SizedBox(
            width: ScreenType.tablet.maxWidth,
            child: Padding(
              padding: const .all(Sizes.p12),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: .end,
                    mainAxisAlignment: .center,
                    children: [
                      gapH24,
                      const WelcomeLogo(),
                      gapH12,
                      Form(
                        key: formKey,
                        child: AutofillGroup(
                          child: LoginForm(
                            formKey: formKey,
                            emailController: emailController,
                            passwordController: passwordController,
                            passwordFocusNode: passwordFocusNode,
                          ),
                        ),
                      ),
                      gapH32,
                      LoginButton(
                        formKey: formKey,
                        emailController: emailController,
                        passwordController: passwordController,
                      ),
                      gapH16,
                      const CreateAccountButton(),
                      gapH32,
                      ResetPassword(emailController: emailController),
                      gapH16,
                      const SupportButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
