import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/client_mixin.dart';

enum StateStatus {
  initial,
  loading,
  loadingError,
  loaded,
  noInternet,
  deleting,
  deletingError,
  saving,
  savingError,
}

/// Marker interface for section keys.
///
/// Each cubit that needs scoped section states defines its own enum implementing
/// this interface. Keys are passed to [BaseState.sections].
///
/// ```dart
/// enum MyFeatureSection implements SectionKey { details, relatedItems }
/// ```
abstract interface class SectionKey {
  const SectionKey();
}

abstract class BaseState extends Equatable {
  const BaseState({
    this.status = StateStatus.initial,
    this.errorMessage,
    this.sections = const {},
  });

  final StateStatus status;
  final String? errorMessage;

  /// Per-section states keyed by a cubit-defined [SectionKey] enum.
  /// Never modify directly — use BaseCubit.withSection.
  final Map<SectionKey, StateStatus> sections;

  @override
  List<Object?> get props => [status, errorMessage, sections];
}

abstract class BaseCubit<T extends BaseState> extends Cubit<T>
    with ClientMixin {
  BaseCubit(super.initialState);
}
