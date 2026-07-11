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

class BaseImageWidget extends StatefulWidget {
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

  @override
  State<BaseImageWidget> createState() => _BaseImageWidgetState();
}

class _BaseImageWidgetState extends State<BaseImageWidget> {
  // Frozen on first layout. Never change again so that memCacheWidth/Height
  // stay stable across resizes and don't trigger a cache miss.
  int? _frozenCacheWidth;
  int? _frozenCacheHeight;

  void _showFullScreenImage(BuildContext context) {
    final tag = widget.heroTag ?? widget.source.hashCode.toString();
    // Capture once at tap time — must not change on resize to avoid cache miss.
    final screenSize = MediaQuery.sizeOf(context);
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
                          source: widget.source,
                          fit: BoxFit.contain,
                          heroTag: tag,
                          // Cap memory to screen size — no need to decode beyond it.
                          width: screenSize.width,
                          height: screenSize.height,
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
    // When explicit dimensions are provided, compute once and freeze.
    if (widget.width != null && _frozenCacheWidth == null) {
      final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0;
      _frozenCacheWidth = (widget.width! * dpr).round();
    }
    if (widget.height != null && _frozenCacheHeight == null) {
      final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0;
      _frozenCacheHeight = (widget.height! * dpr).round();
    }

    // For layout-driven sizes (no explicit width/height), use LayoutBuilder to
    // capture constraints once, then freeze them so resizes don't change the
    // cache key and don't cause a reload or a full-resolution memory warning.
    final bool needsLayoutBuilder =
        (widget.width == null && _frozenCacheWidth == null) ||
        (widget.height == null && _frozenCacheHeight == null);

    if (needsLayoutBuilder) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0;
          final screenSize = MediaQuery.sizeOf(context);

          _frozenCacheWidth ??=
              ((constraints.maxWidth.isFinite
                          ? constraints.maxWidth
                          : screenSize.width) *
                      dpr)
                  .round();
          _frozenCacheHeight ??=
              ((constraints.maxHeight.isFinite
                          ? constraints.maxHeight
                          : screenSize.height) *
                      dpr)
                  .round();

          return _buildContent(context);
        },
      );
    }

    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    final fallbackWidget = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.4,
        ),
        borderRadius: widget.borderRadius ?? BorderRadius.circular(Sizes.p8),
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
              size: (widget.width != null && widget.width! < 80) ? 20 : 32,
              color: context.colorScheme.onSurfaceVariant.withValues(
                alpha: 0.6,
              ),
            ),
            if ((widget.width == null || widget.width! >= 100) &&
                (widget.height == null || widget.height! >= 80)) ...[
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

    final image = switch (widget.source) {
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
                width: widget.width,
                height: widget.height,
                fit: widget.fit,
                placeholder: (context, url) =>
                    widget.placeholder ?? const LoadingCircle(),
                errorWidget: (context, url, error) {
                  _brokenUrls.add(url.trim());
                  return fallbackWidget;
                },
                memCacheWidth: _frozenCacheWidth,
                memCacheHeight: _frozenCacheHeight,
                maxWidthDiskCache: _frozenCacheWidth,
                maxHeightDiskCache: _frozenCacheHeight,
              ),
      LocalImageSource(:final path) =>
        path?.isEmpty ?? true
            ? fallbackWidget
            : (path!.startsWith('assets/')
                  ? Image.asset(
                      key: ValueKey(path),
                      path,
                      width: widget.width,
                      height: widget.height,
                      fit: widget.fit,
                      cacheWidth: _frozenCacheWidth,
                      cacheHeight: _frozenCacheHeight,
                      errorBuilder: (context, error, stackTrace) =>
                          fallbackWidget,
                    )
                  : Image.file(
                      key: ValueKey(path),
                      File(path),
                      width: widget.width,
                      height: widget.height,
                      fit: widget.fit,
                      cacheWidth: _frozenCacheWidth,
                      cacheHeight: _frozenCacheHeight,
                      errorBuilder: (context, error, stackTrace) =>
                          fallbackWidget,
                    )),
    };

    final tag = widget.heroTag ?? widget.source.hashCode.toString();

    final content = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(Sizes.p8),
      ),
      child: Hero(
        tag: tag,
        // Keep the original image visible during the hero flight instead of
        // showing an empty placeholder in its grid position.
        placeholderBuilder: (context, heroSize, child) => child,
        child: image,
      ),
    );

    if (widget.enableFullScreenOnTap) {
      return GestureDetector(
        onTap: () => _showFullScreenImage(context),
        child: content,
      );
    }

    return content;
  }
}
