import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/support/presentation/cubits/support/support_cubit.dart';
import 'package:o_jogo_da_obra/features/support/presentation/pages/support/widgets/support_description_field.dart';
import 'package:o_jogo_da_obra/features/support/presentation/pages/support/widgets/support_email_card.dart';
import 'package:o_jogo_da_obra/features/support/presentation/pages/support/widgets/support_launch_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/screen_util/screen_util.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/toast_util.dart';

@RoutePage()
class SupportPage extends HookWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = useMemoized(() => GetIt.I<SupportCubit>()..init());
    final descriptionController = useTextEditingController();
    final focusNode = useFocusNode();

    return BlocProvider.value(
      value: cubit,
      child: BaseScaffold(
        appBar: BaseAppBar(title: 'Contato com o Suporte'.hardcoded),
        body: BlocListener<SupportCubit, SupportState>(
          listenWhen: (prev, current) =>
              prev.sections[SupportSection.copy] !=
                  current.sections[SupportSection.copy] ||
              prev.sections[SupportSection.launch] !=
                  current.sections[SupportSection.launch],
          listener: (context, state) {
            final copy = state.section(SupportSection.copy);
            if (copy.isSuccess) {
              ToastUtil.showSuccess('Email copiado'.hardcoded);
            } else if (copy.isError) {
              ToastUtil.showError('Não foi possível copiar o texto.'.hardcoded);
            }
            final launch = state.section(SupportSection.launch);
            if (launch.isError) {
              ToastUtil.showError(
                'Não foi possível abrir o aplicativo de e-mail. Você pode copiar o endereço acima.'
                    .hardcoded,
              );
            }
          },
          child: Center(
            child: SizedBox(
              width: ScreenType.tablet.maxWidth,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: Sizes.p16,
                  vertical: Sizes.p24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SupportEmailCard(),
                    gapH24,
                    SupportDescriptionField(
                      controller: descriptionController,
                      focusNode: focusNode,
                    ),
                    gapH32,
                    const SupportLaunchButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
