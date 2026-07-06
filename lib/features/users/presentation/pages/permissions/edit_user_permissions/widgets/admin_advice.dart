import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class AdminAdvice extends StatelessWidget {
  const AdminAdvice({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p8),
        child: Row(
          children: [
            const PlatformIcon(
              materialIcon: Icons.info_outline,
              cupertinoIcon: CupertinoIcons.info,
              color: Colors.orange,
            ),
            gapW12,
            Expanded(
              child: BaseText(
                'Este usuário é um Administrador do sistema. Ele possui acesso total irrestrito a todos os recursos e suas permissões não podem ser customizadas.'
                    .hardcoded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
