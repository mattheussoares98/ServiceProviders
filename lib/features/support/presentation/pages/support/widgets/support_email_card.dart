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

class SupportEmailCard extends StatelessWidget {
  const SupportEmailCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SupportCubit, SupportState>(
      buildWhen: (prev, current) =>
          prev.supportEmail != current.supportEmail ||
          prev.isEmailAvailable != current.isEmailAvailable ||
          prev.sections[SupportSection.copy] !=
              current.sections[SupportSection.copy],
      builder: (context, state) {
        final email = state.supportEmail;
        final isAvailable = state.isEmailAvailable;
        final isCopying = state.section(SupportSection.copy).isRunning;

        return Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Sizes.p12),
            side: BorderSide(
              color: context.theme.dividerColor.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(Sizes.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const PlatformIcon(
                      materialIcon: Icons.email_outlined,
                      cupertinoIcon: CupertinoIcons.mail,
                    ),
                    gapW12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BaseText(
                            'Canal oficial por e-mail'.hardcoded,
                            fontWeight: FontWeight.w600,
                          ),
                          gapH4,
                          SelectableText(
                            isAvailable
                                ? email
                                : 'Canal temporariamente indisponível'
                                      .hardcoded,
                            style: context.theme.textTheme.bodySmall?.copyWith(
                              color: isAvailable
                                  ? context.theme.colorScheme.primary
                                  : context.theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isAvailable && email.isNotEmpty) ...[
                  gapH12,
                  BaseButton.secondary(
                    expandWidth: true,
                    isLoading: isCopying,
                    platformIcon: const PlatformIcon(
                      materialIcon: Icons.copy_rounded,
                      cupertinoIcon: CupertinoIcons.doc_on_clipboard,
                    ),
                    text: 'Copiar e-mail'.hardcoded,
                    onTap: () => context.read<SupportCubit>().copyText(email),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
