import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sliding_toast/flutter_sliding_toast.dart';
import 'package:o_jogo_da_obra/core/constants/app_colors.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

abstract interface class ToastUtil {
  static final _navigationClient = NavigationUtil.I;
  static const _toastSetting = SlidingToastSetting(
    displayDuration: Duration(milliseconds: 6000),
    toastStartPosition: ToastPosition.top,
    toastAlignment: Alignment.topCenter,
  );
  static const _padding = EdgeInsets.all(Sizes.p12);
  static const _boxShadow = BoxShadow(
    color: AppColors.black05,
    spreadRadius: 1,
    blurRadius: 3,
  );

  static void showSuccess(String message, {Duration? duration}) {
    InteractiveToast.closeAllToast();
    InteractiveToast.slide(
      overlayState: _navigationClient.navigatorKey.currentState?.overlay,
      title: BaseText(message, color: Colors.black),
      trailing: const PlatformIcon(
        materialIcon: Icons.check_circle_rounded,
        cupertinoIcon: CupertinoIcons.check_mark_circled_solid,
        color: AppColors.green500,
        size: 20,
      ),
      toastSetting: _toastSetting.copyWith(displayDuration: duration),
      toastStyle: const ToastStyle(
        padding: _padding,
        progressBarColor: AppColors.green500,
        boxShadow: [_boxShadow],
      ),
    );
  }

  static void showError(String message, {Duration? duration}) {
    InteractiveToast.closeAllToast();
    InteractiveToast.slide(
      overlayState: _navigationClient.navigatorKey.currentState?.overlay,
      leading: kDebugMode
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: message));
              },
              child: const PlatformIcon(
                materialIcon: Icons.copy_rounded,
                cupertinoIcon: CupertinoIcons.doc_on_doc,
                color: AppColors.red600,
                size: 20,
              ),
            )
          : null,
      title: BaseText(message, color: AppColors.red600),
      trailing: const PlatformIcon(
        materialIcon: Icons.warning_rounded,
        cupertinoIcon: CupertinoIcons.exclamationmark_triangle_fill,
        color: AppColors.red600,
        size: 20,
      ),
      toastSetting: _toastSetting.copyWith(displayDuration: duration),
      toastStyle: const ToastStyle(
        padding: _padding,
        progressBarColor: AppColors.red600,
        boxShadow: [_boxShadow],
      ),
    );
  }

  /// Shows success or error message based on success and failure state
  static void showMessage<T>(DataState<T> dataState, {String message = ''}) {
    InteractiveToast.closeAllToast();
    if (dataState is! SuccessState) {
      showError(dataState.message!);
    } else if (message.isNotEmpty) {
      showSuccess(message);
    }
  }
}
