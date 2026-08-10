import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/platform_util.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/repositories/attachments_repository.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_list_tile.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class AttachmentSourceSheet extends StatelessWidget {
  const AttachmentSourceSheet({super.key});

  static Future<AttachmentSource?> show(BuildContext context) {
    return showModalBottomSheet<AttachmentSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Sizes.p16)),
      ),
      builder: (context) => const AttachmentSourceSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Sizes.p16,
          vertical: Sizes.p24,
        ),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          children: [
            Align(
              child: Container(
                width: Sizes.p32,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.4,
                  ),
                  borderRadius: BorderRadius.circular(Sizes.p4),
                ),
              ),
            ),
            gapH16,
            Center(child: BaseText.titleMedium('Adicionar anexo'.hardcoded)),
            gapH16,
            if (PlatformUtil.isMobile) ...[
              BaseListTile(
                platformIcon: const PlatformIcon(
                  materialIcon: Icons.camera_alt_outlined,
                  cupertinoIcon: CupertinoIcons.camera,
                ),
                title: 'Tirar foto'.hardcoded,
                subtitle: '1 foto por vez'.hardcoded,
                onTap: () =>
                    Navigator.of(context).pop(AttachmentSource.cameraPhoto),
              ),
              BaseListTile(
                platformIcon: const PlatformIcon(
                  materialIcon: Icons.videocam_outlined,
                  cupertinoIcon: CupertinoIcons.video_camera,
                ),
                title: 'Gravar vídeo'.hardcoded,
                subtitle: 'Máx. 30s'.hardcoded,
                onTap: () =>
                    Navigator.of(context).pop(AttachmentSource.cameraVideo),
              ),
              BaseListTile(
                platformIcon: const PlatformIcon(
                  materialIcon: Icons.photo_library_outlined,
                  cupertinoIcon: CupertinoIcons.photo_on_rectangle,
                ),
                title: 'Galeria'.hardcoded,
                subtitle: 'Fotos e vídeos'.hardcoded,
                onTap: () =>
                    Navigator.of(context).pop(AttachmentSource.gallery),
              ),
            ],

            BaseListTile(
              platformIcon: const PlatformIcon(
                materialIcon: Icons.attach_file_outlined,
                cupertinoIcon: CupertinoIcons.paperclip,
              ),
              title: 'Selecionar arquivo'.hardcoded,
              subtitle: kIsWeb
                  ? 'PDF, word, excel, imagens e vídeos'.hardcoded
                  : 'PDF, word, excel'.hardcoded,
              onTap: () => Navigator.of(context).pop(AttachmentSource.document),
            ),
          ],
        ),
      ),
    );
  }
}
