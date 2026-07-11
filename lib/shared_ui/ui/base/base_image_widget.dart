import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

sealed class BaseImageSource {
  const BaseImageSource();

  factory BaseImageSource.network(String? url) = NetworkImageSource;
  factory BaseImageSource.local(String? path) = LocalImageSource;
}

final class NetworkImageSource extends BaseImageSource {
  const NetworkImageSource(this.url);
  final String? url;
}

final class LocalImageSource extends BaseImageSource {
  const LocalImageSource(this.path);
  final String? path;
}

final Set<String> _brokenUrls = {};

class BaseImageWidget extends StatelessWidget {
  const BaseImageWidget({
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.enableFullScreenOnTap = false,
    this.heroTag,
    this.borderRadius,
    super.key,
  });

  final BaseImageSource source;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final bool enableFullScreenOnTap;
  final String? heroTag;
  final BorderRadius? borderRadius;

  void _showFullScreenImage(BuildContext context) {
    final tag = heroTag ?? source.hashCode.toString();
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierLabel: 'Fechar'.hardcoded,
        barrierColor: Colors.black.withValues(alpha: 0.6),
        pageBuilder: (context, animation, secondaryAnimation) {
          return GestureDetector(
            onTap: Navigator.of(context).pop,
            child: Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Center(
                      child: InteractiveViewer(
                        minScale: 1,
                        maxScale: 4,
                        child: BaseImageWidget(
                          source: source,
                          fit: BoxFit.contain,
                          heroTag: tag,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + Sizes.p16,
                    right: Sizes.p16,
                    child: IconButton(
                      icon: const PlatformIcon(
                        materialIcon: Icons.close,
                        cupertinoIcon: CupertinoIcons.xmark,
                        color: Colors.white,
                      ),
                      onPressed: Navigator.of(context).pop,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _buildContent);
  }

  Widget _buildContent(BuildContext context, BoxConstraints constraints) {
    final fallbackWidget = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.4,
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(Sizes.p8),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            PlatformIcon(
              materialIcon: Icons.image_not_supported_outlined,
              cupertinoIcon: CupertinoIcons.photo,
              size: (width != null && width! < 80) ? 20 : 32,
              color: context.colorScheme.onSurfaceVariant.withValues(
                alpha: 0.6,
              ),
            ),
            if ((width == null || width! >= 100) &&
                (height == null || height! >= 80)) ...[
              gapH8,
              Text(
                'Sem imagem'.hardcoded,
                style: context.theme.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.7,
                  ),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    final double devicePixelRatio =
        MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0;
    final screenSize = MediaQuery.sizeOf(context);

    final double effectiveWidth =
        width ??
        (constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : screenSize.width);
    final double effectiveHeight =
        height ??
        (constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : screenSize.height);

    final int resolvedCacheWidth = (effectiveWidth * devicePixelRatio).round();
    final int resolvedCacheHeight = (effectiveHeight * devicePixelRatio)
        .round();

    final image = switch (source) {
      NetworkImageSource(:final url) =>
        (url == null ||
                url.trim().isEmpty ||
                url.trim() == 'null' ||
                _brokenUrls.contains(url.trim()) ||
                (!url.trim().startsWith('http://') &&
                    !url.trim().startsWith('https://')))
            ? fallbackWidget
            : CachedNetworkImage(
                cacheKey: url.trim(),
                imageUrl: url.trim(),
                width: width,
                height: height,
                fit: fit,
                placeholder: (context, url) =>
                    placeholder ?? const LoadingCircle(),
                errorWidget: (context, url, error) {
                  _brokenUrls.add(url.trim());
                  return fallbackWidget;
                },
                memCacheWidth: resolvedCacheWidth,
                memCacheHeight: resolvedCacheHeight,
                maxWidthDiskCache: resolvedCacheWidth,
                maxHeightDiskCache: resolvedCacheHeight,
              ),
      LocalImageSource(:final path) =>
        path?.isEmpty ?? true
            ? fallbackWidget
            : (path!.startsWith('assets/')
                  ? Image.asset(
                      key: ValueKey(path),
                      path,
                      width: width,
                      height: height,
                      fit: fit,
                      cacheWidth: resolvedCacheWidth,
                      cacheHeight: resolvedCacheHeight,
                      errorBuilder: (context, error, stackTrace) =>
                          fallbackWidget,
                    )
                  : Image.file(
                      key: ValueKey(path),
                      File(path),
                      width: width,
                      height: height,
                      fit: fit,
                      cacheWidth: resolvedCacheWidth,
                      cacheHeight: resolvedCacheHeight,
                      errorBuilder: (context, error, stackTrace) =>
                          fallbackWidget,
                    )),
    };

    final tag = heroTag ?? source.hashCode.toString();

    final content = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(Sizes.p8),
      ),
      child: Hero(tag: tag, child: image),
    );

    if (enableFullScreenOnTap) {
      return GestureDetector(
        onTap: () => _showFullScreenImage(context),
        child: content,
      );
    }

    return content;
  }
}
