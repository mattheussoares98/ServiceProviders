import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/shared_ui/ui/base/loading_circle.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

class BaseImageWidget extends StatelessWidget {
  const BaseImageWidget({
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
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
  final Widget? errorWidget;
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

  int _getStableCacheSize(int physicalPixels, int maxPhysicalSize) {
    final clamped = physicalPixels.clamp(1, maxPhysicalSize);
    if (clamped <= 256) return 256;
    if (clamped <= 512) return 512;
    if (clamped <= 1024) return 1024;
    return (clamped / 512).ceil() * 512;
  }

  @override
  Widget build(BuildContext context) {
    final fallbackWidget =
        errorWidget ??
        const PlatformIcon(
          materialIcon: Icons.broken_image,
          cupertinoIcon: Icons.broken_image,
        );

    final double devicePixelRatio =
        MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0;
    final screenSize = MediaQuery.sizeOf(context);
    final int maxPhysicalWidth = (screenSize.width * devicePixelRatio).round();
    final int maxPhysicalHeight = (screenSize.height * devicePixelRatio)
        .round();

    final int resolvedCacheWidth = _getStableCacheSize(
      width != null ? (width! * devicePixelRatio).round() : maxPhysicalWidth,
      maxPhysicalWidth,
    );
    final int resolvedCacheHeight = _getStableCacheSize(
      height != null ? (height! * devicePixelRatio).round() : maxPhysicalHeight,
      maxPhysicalHeight,
    );

    final image = switch (source) {
      NetworkImageSource(:final url) =>
        url?.isEmpty ?? true
            ? fallbackWidget
            : CachedNetworkImage(
                key: ValueKey(url),
                cacheKey: url,
                imageUrl: url!,
                width: width,
                height: height,
                fit: fit,
                placeholder: (context, url) =>
                    placeholder ?? const LoadingCircle(),
                errorWidget: (context, url, error) => fallbackWidget,
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
