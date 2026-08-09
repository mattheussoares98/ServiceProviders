import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/client_mixin.dart';

/// A Cubit that holds the keyboard visibility state.
/// It is updated by the root application shell to reuse the existing system observer.
@injectable
class KeyboardVisibilityCubit extends Cubit<bool> with ClientMixin {
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
