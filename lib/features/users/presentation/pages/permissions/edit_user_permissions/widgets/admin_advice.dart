import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
