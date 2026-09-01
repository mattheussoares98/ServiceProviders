import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/animated_ellipsis.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

final class ObservedLoadingTarget {
  const ObservedLoadingTarget(this.cubit, {this.sections = const {}});

  /// Convenient constructor when only observing specific sections of a cubit.
  factory ObservedLoadingTarget.section(
    BaseCubit<BaseState> cubit,
    SectionKey section, {
    Set<SectionStatus> statuses = const {SectionStatus.running},
  }) => ObservedLoadingTarget(cubit, sections: {section: statuses});

  final BaseCubit<BaseState> cubit;

  /// Map of specific sections to the statuses that trigger loading for that section.
  final Map<SectionKey, Set<SectionStatus>> sections;

  bool get isLoading {
    for (final entry in sections.entries) {
      final sectionStatus = cubit.state.sections[entry.key];
      if (sectionStatus != null && entry.value.contains(sectionStatus)) {
        return true;
      }
    }

    return false;
  }
}

void observeLoading(
  List<ObservedLoadingTarget> targets, {
  String message = 'Aguarde',
}) {
  final context = useContext();
  final overlayEntry = useRef<OverlayEntry?>(null);

  void hide() {
    if (overlayEntry.value != null) {
      overlayEntry.value!.remove();
      overlayEntry.value = null;
    }
  }

  void show(OverlayState overlay) {
    if (overlayEntry.value != null || !overlay.mounted) return;
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
                  const SizedBox(width: Sizes.p16),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(child: BaseText(message)),
                        const AnimatedEllipsis(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry.value!);
  }

  useEffect(() {
    // Resolved once, while this element is guaranteed active. Looking the
    // overlay up later — from a cubit stream callback that can fire after the
    // widget was deactivated — throws "Looking up a deactivated widget's
    // ancestor is unsafe".
    final overlay = Overlay.of(context);
    var isDisposed = false;

    void sync() {
      if (isDisposed) return;
      final anyLoading = targets.any((t) => t.isLoading);
      if (anyLoading) {
        show(overlay);
      } else {
        hide();
      }
    }

    final subscriptions = targets
        .map((target) => target.cubit.stream.listen((_) => sync()))
        .toList();

    final anyLoading = targets.any((t) => t.isLoading);
    if (anyLoading) {
      // The effect runs during build, so the insert has to wait for the frame
      // to finish or it would mark the overlay dirty mid-build.
      WidgetsBinding.instance.addPostFrameCallback((_) => sync());
    }

    return () {
      isDisposed = true;
      for (final sub in subscriptions) {
        sub.cancel();
      }
      hide();
    };
  }, targets.map((t) => t.cubit).toList());
}
