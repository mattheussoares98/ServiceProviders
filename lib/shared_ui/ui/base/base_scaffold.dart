import 'package:clean_architecture/core/utils/platform_util.dart';
import 'package:clean_architecture/shared_ui/cubits/screen_observer/screen_observer_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_bottom_navigation_bar.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:clean_architecture/shared_ui/utils/screen_util/screen_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BaseScaffold extends StatelessWidget {
  const BaseScaffold({
    super.key,
    this.showAnnotatedRegion = false,
    this.onPopInvokedWithResult,
    this.resizeToAvoidBottomInset = false,
    this.appBar,
    this.onRefresh,
    this.isScrollable = true,
    this.scrollPhysics,
    this.padding,
    this.usePadding = true,
    required this.body,
    this.bottomNavigationBar,
    this.useBottomNavigationPadding = true,
    this.observeScreenChanges = false,
    this.bottomNavigationItems,
    this.bottomNavigationIndex,
    this.onBottomNavigationTap,
    this.drawer,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.safeAreaTop,
  });

  final bool showAnnotatedRegion;
  final void Function()? onPopInvokedWithResult;
  final bool? resizeToAvoidBottomInset;
  final Widget? appBar;
  final Future<void> Function()? onRefresh;
  final bool isScrollable;
  final ScrollPhysics? scrollPhysics;
  final EdgeInsets? padding;
  final bool usePadding;
  final Widget body;
  final Widget? bottomNavigationBar;
  final bool useBottomNavigationPadding;
  final bool observeScreenChanges;
  final List<BaseBottomNavigationBarItem>? bottomNavigationItems;
  final int? bottomNavigationIndex;
  final ValueChanged<int>? onBottomNavigationTap;
  final Widget? drawer;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool? safeAreaTop;

  @override
  Widget build(BuildContext context) {
    if (observeScreenChanges) {
      return BlocBuilder<ScreenObserverCubit, ScreenObserverState>(
        buildWhen: (previous, current) =>
            previous.screenTypeChanges != current.screenTypeChanges,
        builder: (context, state) {
          return _BaseScaffold(this);
        },
      );
    }

    return _BaseScaffold(this);
  }
}

class _BaseScaffold extends StatelessWidget {
  const _BaseScaffold(this.params);
  final BaseScaffold params;

  EdgeInsets _getHorizontalPadding() => EdgeInsets.symmetric(
    horizontal: ScreenUtil.I.getResponsiveValue(
      base: 24,
      screens: {
        {ScreenType.largeTablet}: 22.widthPart(),
        {ScreenType.desktop}: kIsWeb ? 32.5.widthPart() : 27.widthPart(),
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    Widget newChild = params.body;

    Widget? finalAppBar = params.appBar;

    if (params.onRefresh != null &&
        (PlatformUtil.isWeb || PlatformUtil.isDesktop)) {
      if (finalAppBar is BaseAppBar) {
        final refreshAction = BaseIconButton(
          onPressed: params.onRefresh,
          platformIcon: const PlatformIcon(
            materialIcon: Icons.refresh,
            cupertinoIcon: CupertinoIcons.refresh,
          ),
        );
        finalAppBar = finalAppBar.copyWith(
          actions: [
            ...?finalAppBar.actions,
            refreshAction,
          ].map((e) => FittedBox(child: e)).toList(),
        );
      }
    }

    final effectivePadding = params.usePadding
        ? params.padding ??
              (params.observeScreenChanges
                  ? _getHorizontalPadding()
                  : ScreenUtil.I.pagePadding().copyWith(
                      bottom: params.bottomNavigationBar == null ? null : 0,
                    ))
        : EdgeInsets.zero;

    if (params.isScrollable) {
      newChild = SingleChildScrollView(
        padding: effectivePadding,
        physics: params.scrollPhysics,
        child: params.body,
      );
    } else {
      newChild = Padding(padding: effectivePadding, child: params.body);
    }

    if (params.onRefresh != null) {
      newChild = RefreshIndicator(
        onRefresh: params.onRefresh!,
        backgroundColor: context.theme.colorScheme.surface,
        strokeWidth: 2,
        child: newChild,
      );
    }

    PreferredSizeWidget? appBarWidget;
    if (finalAppBar != null) {
      if (finalAppBar is PreferredSizeWidget) {
        if (context.isCupertino) {
          appBarWidget = PreferredSize(
            preferredSize: Size.fromHeight(
              finalAppBar.preferredSize.height +
                  MediaQuery.paddingOf(context).top,
            ),
            child: finalAppBar,
          );
        } else {
          appBarWidget = finalAppBar;
        }
      } else {
        appBarWidget = PreferredSize(
          preferredSize: const Size(double.maxFinite, 50),
          child: finalAppBar,
        );
      }
    }

    Widget? bottomNavigationWidget = params.bottomNavigationBar;
    if (bottomNavigationWidget == null &&
        params.bottomNavigationItems != null &&
        params.bottomNavigationIndex != null &&
        params.onBottomNavigationTap != null) {
      bottomNavigationWidget = BaseBottomNavigationBar(
        items: params.bottomNavigationItems!,
        currentIndex: params.bottomNavigationIndex!,
        onTap: params.onBottomNavigationTap!,
      );
    }

    Widget scaffold;

    if (context.isCupertino && params.drawer == null) {
      const cupertinoTabBarHeight = 49.0;
      var cupertinoBody = bottomNavigationWidget != null
          ? Padding(
              padding: const EdgeInsets.only(
                bottom: cupertinoTabBarHeight + Sizes.p8,
              ),
              child: newChild,
            )
          : newChild;

      cupertinoBody = SafeArea(
        top: params.safeAreaTop ?? finalAppBar == null,
        bottom: bottomNavigationWidget != null,
        child: cupertinoBody,
      );

      if (finalAppBar != null) {
        cupertinoBody = Column(
          children: [
            finalAppBar,
            Expanded(child: cupertinoBody),
          ],
        );
      }

      scaffold = CupertinoPageScaffold(
        resizeToAvoidBottomInset: params.resizeToAvoidBottomInset ?? true,
        child: cupertinoBody,
      );

      if (bottomNavigationWidget != null) {
        scaffold = Stack(
          children: [
            scaffold,
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(top: false, child: bottomNavigationWidget),
            ),
          ],
        );
      }

      if (params.floatingActionButton != null) {
        scaffold = Stack(
          children: [
            scaffold,
            Positioned(
              right: 16,
              bottom: bottomNavigationWidget != null
                  ? 49.0 + 16.0 + MediaQuery.paddingOf(context).bottom
                  : 16.0 + MediaQuery.paddingOf(context).bottom,
              child: params.floatingActionButton!,
            ),
          ],
        );
      }

      scaffold = Material(color: Colors.transparent, child: scaffold);
    } else {
      scaffold = Scaffold(
        resizeToAvoidBottomInset: params.resizeToAvoidBottomInset,
        appBar: appBarWidget,
        body: SafeArea(child: newChild),
        bottomNavigationBar: bottomNavigationWidget,
        drawer: params.drawer,
        floatingActionButton: params.floatingActionButton,
        floatingActionButtonLocation: params.floatingActionButtonLocation,
      );
    }

    if (params.onPopInvokedWithResult != null) {
      scaffold = PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            return;
          }
          params.onPopInvokedWithResult?.call();
        },
        child: scaffold,
      );
    }

    if (params.showAnnotatedRegion) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: context.systemOverlayStyle,
        child: scaffold,
      );
    }

    return scaffold;
  }
}
