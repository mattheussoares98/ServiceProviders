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
    return BlocBuilder<SupportCubit, SupportState>(
      buildWhen: (prev, current) =>
          prev.userDescription != current.userDescription,
      builder: (context, state) {
        final currentLength = state.userDescription.length;
        const maxLength = SupportState.maxDescriptionLength;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BaseText(
              'Como podemos ajudar?'.hardcoded,
              fontWeight: FontWeight.w600,
            ),
            gapH8,
            BaseTextFormField(
              controller: controller,
              focusNode: focusNode,
              maxLines: 6,
              maxLength: maxLength,
              hintText:
                  'Descreva detalhadamente o problema ou sua dúvida...'.hardcoded,
              onChanged: (text) =>
                  context.read<SupportCubit>().updateDescription(text),
            ),
            gapH4,
            Align(
              alignment: Alignment.centerRight,
              child: BaseText(
                '$currentLength / $maxLength'.hardcoded,
                textType: TextType.caption,
                color: currentLength > maxLength
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).hintColor,
              ),
            ),
          ],
        );
      },
    );
  }
}
