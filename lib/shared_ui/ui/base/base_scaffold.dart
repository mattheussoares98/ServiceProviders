import 'package:clean_architecture/core/constants/app_colors.dart';
import 'package:clean_architecture/shared_ui/cubits/screen_observer/screen_observer_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_bottom_navigation_bar.dart';
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
    this.resizeToAvoidBottomInset,
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

    final effectivePadding = params.usePadding
        ? params.padding ??
              (params.observeScreenChanges
                  ? _getHorizontalPadding()
                  : ScreenUtil.I.pagePadding())
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
        color: AppColors.primary,
        backgroundColor: AppColors.white,
        strokeWidth: 2,
        edgeOffset: 100,
        child: newChild,
      );
    }

    PreferredSize? appBarWidget;
    if (params.appBar != null) {
      appBarWidget = PreferredSize(
        preferredSize: const Size(double.maxFinite, 50),
        child: params.appBar!,
      );
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

    if (bottomNavigationWidget != null &&
        params.useBottomNavigationPadding) {
      bottomNavigationWidget = Padding(
        padding: effectivePadding.copyWith(top: 0),
        child: bottomNavigationWidget,
      );
    }

    Widget scaffold;

    if (context.isCupertino) {
      var cupertinoBody = newChild;
      if (params.appBar != null) {
        cupertinoBody = Column(
          children: [
            params.appBar!,
            Expanded(child: newChild),
          ],
        );
      }

      scaffold = CupertinoPageScaffold(
        resizeToAvoidBottomInset: params.resizeToAvoidBottomInset ?? true,
        child: SafeArea(
          bottom: bottomNavigationWidget == null,
          child: cupertinoBody,
        ),
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

      scaffold = Material(color: Colors.transparent, child: scaffold);
    } else {
      scaffold = Scaffold(
        resizeToAvoidBottomInset: params.resizeToAvoidBottomInset,
        appBar: appBarWidget,
        body: SafeArea(child: newChild),
        bottomNavigationBar: bottomNavigationWidget,
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
