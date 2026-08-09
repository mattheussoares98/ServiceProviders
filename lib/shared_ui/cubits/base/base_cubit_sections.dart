import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart'
    show BaseStateView;

/// Provides section-scoped state helpers for any [BaseCubit].
///
/// Import this file in cubits that need to emit [StateStatus] changes for
/// specific named sections without affecting the global [BaseState.status].
///
/// ## Usage
///
/// 1. Define a [SectionKey] enum in your cubit file:
/// ```dart
/// enum MyFeatureSection implements SectionKey { details, relatedItems }
/// ```
///
/// 2. Emit section status changes via [withSection]:
/// ```dart
/// emit(state.copyWith(
///   sections: withSection(MyFeatureSection.details, StateStatus.loading),
/// ));
/// ```
///
/// 3. Wrap your widget with [BaseStateView] and pass the `sectionKey`:
/// ```dart
/// BaseStateView<MyCubit, MyState, MyData>(
///   sectionKey: MyFeatureSection.details,
///   ...
/// )
/// ```
extension BaseCubitSections<T extends BaseState> on BaseCubit<T> {
  /// Returns a **new** sections map with [key] set to [status].
  ///
  /// Pass the result to your state's `copyWith(sections: ...)`.
  /// This is the only sanctioned way to update [BaseState.sections].
  Map<SectionKey, StateStatus> withSection(SectionKey key, StateStatus status) {
    return Map<SectionKey, StateStatus>.from(state.sections)..[key] = status;
  }
}
