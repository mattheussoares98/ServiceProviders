import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/support/presentation/cubits/support/support_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class SupportLaunchButton extends StatelessWidget {
  const SupportLaunchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SupportCubit, SupportState>(
      buildWhen: (prev, current) =>
          prev.hasValidDraft != current.hasValidDraft ||
          prev.isEmailAvailable != current.isEmailAvailable ||
          prev.sections[SupportSection.launch] !=
              current.sections[SupportSection.launch],
      builder: (context, state) {
        final isLaunching = state.section(SupportSection.launch).isRunning;
        final canSubmit = state.hasValidDraft && state.isEmailAvailable;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BaseButton(
              expandWidth: true,
              isLoading: isLaunching,
              platformIcon: const PlatformIcon(
                materialIcon: Icons.send_rounded,
                cupertinoIcon: CupertinoIcons.paperplane,
              ),
              text: 'Enviar e-mail'.hardcoded,
              onTap: canSubmit && !isLaunching
                  ? () => context.read<SupportCubit>().launchEmail()
                  : null,
            ),
            gapH8,
            BaseText(
              'Uma mensagem pré-preenchida será aberta no seu aplicativo de e-mail padrão para você revisar e enviar.'
                  .hardcoded,
              textType: TextType.caption,
              textAlign: TextAlign.center,
              color: context.theme.hintColor,
            ),
          ],
        );
      },
    );
  }
}
