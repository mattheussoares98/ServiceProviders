part of 'attachment_item.dart';

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.attachment, this.isPlayable = false});

  final AttachmentEntity attachment;
  final bool isPlayable;

  @override
  Widget build(BuildContext context) {
    BaseImageSource? source;

    if (isPlayable) {
      final thumbnailPath = context.select<AttachmentsCubit, String?>(
        (cubit) => cubit.state.videoThumbnails[attachment.id],
      );

      if (thumbnailPath == null || thumbnailPath.isEmpty) {
        if (kIsWeb) {
          return Container(
            color: Colors.black.withValues(alpha: 0.8),
            height: _kAttachmentPreviewHeight,
            alignment: Alignment.center,
            child: const PlatformIcon(
              materialIcon: Icons.play_arrow_rounded,
              cupertinoIcon: CupertinoIcons.play_arrow_solid,
              color: Colors.white,
              size: 40,
            ),
          );
        }
        return Container(
          color: Colors.blue[700]?.withValues(alpha: 0.1),
          height: _kAttachmentPreviewHeight,
          alignment: Alignment.center,
          child: const LoadingCircle(),
        );
      }
      source = BaseImageSource.local(thumbnailPath);
    } else {
      if ((attachment.localPath?.isNotEmpty ?? false) && !kIsWeb) {
        source = BaseImageSource.local(attachment.localPath);
      } else if (attachment.remoteUrl?.isNotEmpty ?? false) {
        source = BaseImageSource.network(attachment.remoteUrl);
      }
    }

    if (source != null) {
      final imageWidget = BaseImageWidget(
        source: source,
        enableFullScreenOnTap: !isPlayable,
        heroTag: source.hashCode.toString(),
        height: _kAttachmentPreviewHeight,
        fit: BoxFit.fill,
      );

      if (isPlayable) {
        return SizedBox(
          height: _kAttachmentPreviewHeight,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(child: imageWidget),
              const PlatformIcon(
                materialIcon: Icons.play_arrow_rounded,
                cupertinoIcon: CupertinoIcons.play_arrow_solid,
                color: Colors.white,
                size: 40,
              ),
            ],
          ),
        );
      }

      return imageWidget;
    }

    return const SizedBox.shrink();
  }
}
