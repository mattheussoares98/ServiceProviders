import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/features/auth/presentation/cubits/sign_up/sign_up_cubit.dart';
import 'package:clean_architecture/features/auth/presentation/pages/sign_up/widgets/sign_up_button.dart';
import 'package:clean_architecture/features/auth/presentation/pages/sign_up/widgets/sign_up_form.dart';
import 'package:clean_architecture/shared_ui/cubits/screen_observer/screen_observer_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_scaffold.dart';
import 'package:clean_architecture/shared_ui/utils/screen_util/screen_util.dart';
import 'package:clean_architecture/shared_ui/utils/ui_helpers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';

@RoutePage()
class SignUpPage extends HookWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new);

    return BlocProvider(
      create: (context) => GetIt.I<SignUpCubit>(),
      child: BlocBuilder<ScreenObserverCubit, ScreenObserverState>(
        buildWhen: (previous, current) =>
            previous.screenTypeChanges != current.screenTypeChanges,
        builder: (context, state) {
          return BaseScaffold(
            appBar: const BaseAppBar(title: 'Sign Up'),
            padding: _getHorizontalPadding(),
            showAnnotatedRegion: true,
            body: Column(
              children: [
                UIHelpers.spaceV24,
                Form(
                  key: formKey,
                  child: SignUpForm(
                    nameController: nameController,
                    emailController: emailController,
                    passwordController: passwordController,
                  ),
                ),
                UIHelpers.spaceV40,
                SignUpButton(
                  formKey: formKey,
                  nameController: nameController,
                  emailController: emailController,
                  passwordController: passwordController,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  EdgeInsets _getHorizontalPadding() => EdgeInsets.symmetric(
    horizontal: ScreenUtil.I.getResponsiveValue(
      base: 24,
      screens: {
        {.largeTablet}: 22.widthPart(),
        {.desktop}: kIsWeb ? 32.5.widthPart() : 27.widthPart(),
      },
    ),
  );
}
