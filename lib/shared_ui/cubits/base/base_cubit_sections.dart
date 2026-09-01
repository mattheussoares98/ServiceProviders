import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart'
    show BaseStateView;

/// Provides section-scoped state helpers for any [BaseCubit].
///
/// Import this file in cubits that need to emit [SectionStatus] changes for
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
///   sections: withSection(MyFeatureSection.details, SectionStatus.loading),
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
  //TODO change to mixin and use inside the cubits
  /// Returns a **new** sections map with [key] set to [status].
  ///
  /// Pass the result to your state's `copyWith(sections: ...)`.
  /// This is the only sanctioned way to update [BaseState.sections].
  Map<SectionKey, SectionStatus> withSection(
    SectionKey key,
    SectionStatus status,
  ) {
    return Map<SectionKey, SectionStatus>.from(state.sections)..[key] = status;
  }
}
