import 'dart:ui';

import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:injectable/injectable.dart';

/// A Cubit that holds the keyboard visibility state.
/// It is updated by the root application shell to reuse the existing system observer.
@injectable
class KeyboardVisibilityCubit extends BaseCubit<bool> {
  KeyboardVisibilityCubit() : super(_isKeyboardOpen());

  void update() {
    final newValue = _isKeyboardOpen();
    if (state != newValue) {
      emit(newValue);
    }
  }

  static bool _isKeyboardOpen() {
    final views = PlatformDispatcher.instance.views;
    if (views.isEmpty) {
      return false;
    }
    final bottomInset = views.first.viewInsets.bottom;
    return bottomInset > 0;
  }
}
