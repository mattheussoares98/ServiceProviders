import 'package:clean_architecture/core/constants/app_colors.dart';
import 'package:clean_architecture/shared_ui/cubits/screen_observer/screen_observer_cubit.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:clean_architecture/shared_ui/utils/screen_util/screen_util.dart';
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
    Widget buildScaffold(BuildContext context) {
      Widget newChild = body;

      final effectivePadding = padding ??
          (observeScreenChanges
              ? _getHorizontalPadding()
              : ScreenUtil.I.pagePadding());

      if (isScrollable) {
        newChild = SingleChildScrollView(
          physics: scrollPhysics,
          padding: effectivePadding,
          child: body,
        );
      } else if (usePadding) {
        newChild = Padding(
          padding: effectivePadding,
          child: body,
        );
      }

      if (onRefresh != null) {
        newChild = RefreshIndicator(
          onRefresh: onRefresh!,
          color: AppColors.primary,
          backgroundColor: AppColors.white,
          strokeWidth: 2,
          edgeOffset: 100,
          child: newChild,
        );
      }

      PreferredSize? appBarWidget;
      if (appBar != null) {
        appBarWidget = PreferredSize(
          preferredSize: const Size(double.maxFinite, 50),
          child: appBar!,
        );
      }

      Widget? bottomNavigationWidget = bottomNavigationBar;
      if (bottomNavigationBar != null && useBottomNavigationPadding) {
        bottomNavigationWidget = Padding(
          padding: effectivePadding.copyWith(top: 0),
          child: bottomNavigationWidget,
        );
      }

      Widget scaffold = Scaffold(
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        appBar: appBarWidget,
        body: SafeArea(child: newChild),
        bottomNavigationBar: bottomNavigationWidget,
      );

      if (onPopInvokedWithResult != null) {
        scaffold = PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              return;
            }
            onPopInvokedWithResult?.call();
          },
          child: scaffold,
        );
      }

      if (showAnnotatedRegion) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: context.systemOverlayStyle,
          child: scaffold,
        );
      }

      return scaffold;
    }

    if (observeScreenChanges) {
      return BlocBuilder<ScreenObserverCubit, ScreenObserverState>(
        buildWhen: (previous, current) =>
            previous.screenTypeChanges != current.screenTypeChanges,
        builder: (context, state) {
          return buildScaffold(context);
        },
      );
    }

    return buildScaffold(context);
  }
}
