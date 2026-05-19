import 'dart:ui';

import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:flutter/material.dart';

/// PERFORMANCE: This manager uses the Overlay API to create an accessory bar
/// that floats above the keyboard. It is isolated from the main widget tree
/// to prevent full-page repaints during keyboard animations.
class OverlayManager {
  OverlayEntry? _currentEntry;

  // PERFORMANCE: Constant height allows for stable scrollPadding calculations.
  static const double accessoryBarHeight = 44;

  // PERFORMANCE: Adding a safe margin constant to ensure fields scroll
  // well above the interactive area of the accessory bar.
  static const double safeScrollMargin = 36;

  /// Helper to get the total padding required for scrollable views to clear the overlay.
  static double get totalAccessoryHeight =>
      accessoryBarHeight + safeScrollMargin;

  /// Shows an iOS-style 'Done' bar above the keyboard.
  void showDoneBar({
    required BuildContext context,
    required FocusNode? focusNode,
    required VoidCallback onDone,
  }) {
    hide();

    final overlay = Overlay.of(context);

    _currentEntry = OverlayEntry(
      builder: (context) {
        // PERFORMANCE: MediaQuery.viewInsetsOf is optimized to only trigger
        // rebuilds of the OverlayEntry when the keyboard height changes.
        final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;

        return Positioned(
          bottom: keyboardHeight,
          left: 0,
          right: 0,
          child: RepaintBoundary(
            child: ClipRect(
              child: BackdropFilter(
                // PERFORMANCE: Sigma 10 provides a natural frosted look without heavy GPU cost
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: accessoryBarHeight,
                  // PERFORMANCE: Using semi-transparent grey/white to match iOS native look
                  // color: Colors.white.withAlpha(200),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.black.withAlpha(25),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        key: const ValueKey('done_btn_'),
                        onPressed: onDone,
                        // PERFORMANCE: Blue SF Pro style font for iOS consistency
                        child: Text(
                          'OK'.hardcoded,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF007AFF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_currentEntry!);
  }

  void hide() {
    if (_currentEntry != null) {
      _currentEntry?.remove();
      _currentEntry = null;
    }
  }
}
