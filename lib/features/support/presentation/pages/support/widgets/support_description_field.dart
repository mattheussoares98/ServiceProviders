import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/support/presentation/cubits/support/support_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class SupportDescriptionField extends StatelessWidget {
  const SupportDescriptionField({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BaseText('Como podemos ajudar?'.hardcoded, fontWeight: .bold),
        gapH8,
        BaseTextFormField(
          controller: controller,
          focusNode: focusNode,
          maxLines: 6,
          maxLength: SupportState.maxDescriptionLength,
          showCounter: true,
          hintText:
              'Descreva detalhadamente o problema ou sua dúvida...'.hardcoded,
          onChanged: context.read<SupportCubit>().updateDescription,
        ),
      ],
    );
  }
}
