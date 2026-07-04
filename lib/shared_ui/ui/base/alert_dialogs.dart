import 'package:clean_architecture/core/utils/platform_util.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const kDialogDefaultKey = Key('dialog-default-key');

/// Generic function to show a platform-aware Material or Cupertino dialog
Future<bool?> showAlertDialog({
  required BuildContext context,
  required String title,
  String? contentText,
  Widget? contentWidget,
  String? cancelActionText,
  String defaultActionText = 'OK',
  VoidCallback? onOkPressed,
  List<Widget>? actions,
}) {
  return showDialog<bool>(
    context: context,
    // Only make the dialog dismissible if there is a cancel button
    barrierDismissible: cancelActionText != null,
    builder: (context) => AlertDialog.adaptive(
      key: kDialogDefaultKey,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: BaseText(title)),
          if (kDebugMode && (contentText?.isNotEmpty ?? false))
            IconButton(
              onPressed: () =>
                  Clipboard.setData(ClipboardData(text: contentText!)),
              icon: const PlatformIcon(
                cupertinoIcon: CupertinoIcons.doc_on_clipboard,
                materialIcon: Icons.copy,
              ),
            ),
        ],
      ),
      content:
          contentWidget ??
          (contentText != null
              ? SingleChildScrollView(child: BaseText(contentText))
              : null),
      actions:
          actions ??
          (PlatformUtil.isCupertino
              ? <Widget>[
                  if (cancelActionText != null)
                    CupertinoDialogAction(
                      child: BaseText(cancelActionText),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  CupertinoDialogAction(
                    child: BaseText(defaultActionText),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      onOkPressed?.call();
                    },
                  ),
                ]
              : <Widget>[
                  if (cancelActionText != null)
                    TextButton(
                      child: BaseText(cancelActionText),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  TextButton(
                    child: BaseText(defaultActionText),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      onOkPressed?.call();
                    },
                  ),
                ]),
    ),
  );
}

/// Generic function to show a platform-aware Material or Cupertino error dialog
Future<bool?> showExceptionAlertDialog({
  required BuildContext context,
  required String title,
  required dynamic exception,
}) => showAlertDialog(
  context: context,
  title: title,
  contentText: exception.toString(),
);
