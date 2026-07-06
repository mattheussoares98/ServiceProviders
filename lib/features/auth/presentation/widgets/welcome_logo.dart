import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/constants/app_colors.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class WelcomeLogo extends StatelessWidget {
  const WelcomeLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        gapH4,
        BaseText(
          'Bem-vindo(a)'.hardcoded,
          color: AppColors.primary,
          textType: TextType.headlineLarge,
          fontWeight: FontWeight.w900,
        ),
        gapH32,
        Align(
          alignment: Alignment.centerLeft,
          child: BaseText.titleMedium('Login'.hardcoded),
        ),
      ],
    );
  }
}
