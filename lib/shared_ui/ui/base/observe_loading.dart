import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/loading_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void observeLoading(
  List<BaseCubit<BaseState>> cubits, {
  String message = 'Aguarde...',
}) {
  final context = useContext();
  final overlayEntry = useRef<OverlayEntry?>(null);

  void hide() {
    if (overlayEntry.value != null) {
      overlayEntry.value!.remove();
      overlayEntry.value = null;
    }
  }

  void show() {
    if (overlayEntry.value != null) return;
    FocusManager.instance.primaryFocus?.unfocus();

    overlayEntry.value = OverlayEntry(
      builder: (context) => PopScope(
        canPop: false,
        child: Material(
          color: Colors.black54,
          child: Center(
            child: AlertDialog(
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LoadingCircle(centered: false),
                  const SizedBox(width: 16),
                  Expanded(child: Text(message)),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry.value!);
  }

  useEffect(() {
    final subscriptions = cubits.map((cubit) {
      return cubit.stream.listen((state) {
        final anyLoading = cubits.any(
          (c) => c.state.status == StateStatus.loading,
        );
        if (anyLoading) {
          show();
        } else {
          hide();
        }
      });
    }).toList();

    final anyLoading = cubits.any((c) => c.state.status == StateStatus.loading);
    if (anyLoading) {
      show();
    }

    return () {
      for (final sub in subscriptions) {
        sub.cancel();
      }
      hide();
    };
  }, cubits);
}
