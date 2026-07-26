import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<UsersCubit, UsersState, (String?, bool)>(
      selector: (cubit) =>
          (cubit.errorMessage, cubit.status == StateStatus.loading),
      builder: (context, selected) {
        final errorMessage = selected.$1;
        final isLoading = selected.$2;

        return BaseScaffold(
          observeScreenChanges: true,
          isScrollable: false,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(Sizes.p32),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const PlatformIcon(
                      materialIcon: Icons.error_outline,
                      cupertinoIcon: CupertinoIcons.exclamationmark_triangle,
                      color: Colors.red,
                      size: Sizes.p64,
                    ),
                    const SizedBox(height: Sizes.p16),
                    BaseText.error(
                      'Erro ao carregar dados do usuário'.hardcoded,
                    ),
                    const SizedBox(height: 8),
                    BaseText(
                      errorMessage ?? 'Ocorreu um erro não esperado'.hardcoded,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Sizes.p24),
                    BaseButton(
                      isLoading: isLoading,
                      onTap: isLoading
                          ? null
                          : context.read<UsersCubit>().loadAll,
                      text: 'Tentar novamente'.hardcoded,
                      platformIcon: const PlatformIcon(
                        materialIcon: Icons.refresh,
                        cupertinoIcon: CupertinoIcons.refresh,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
