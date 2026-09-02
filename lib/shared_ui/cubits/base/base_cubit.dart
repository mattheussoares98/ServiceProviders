import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/client_mixin.dart';

enum SectionStatus { idle, running, error, success }

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

/// Default section keys available across all cubits.
enum BaseSections implements SectionKey { load }

/// Holds the status and optional error message for a specific section.
class SectionState extends Equatable {
  const SectionState({this.status = SectionStatus.idle, this.errorMessage});

  const SectionState.running() : this(status: SectionStatus.running);
  const SectionState.success() : this(status: SectionStatus.success);
  const SectionState.error([String? message])
    : this(status: SectionStatus.error, errorMessage: message);
  const SectionState.idle() : this(status: SectionStatus.idle);

  final SectionStatus status;
  final String? errorMessage;

  bool get isIdle => status == SectionStatus.idle;
  bool get isRunning => status == SectionStatus.running;
  bool get isError => status == SectionStatus.error;
  bool get isSuccess => status == SectionStatus.success;

  @override
  List<Object?> get props => [status, errorMessage];
}

abstract class BaseState extends Equatable {
  const BaseState({this.sections = const {}});

  /// Per-section states keyed by a cubit-defined [SectionKey] enum.
  /// Never modify directly — use BaseCubit.withSection.
  final Map<SectionKey, SectionState> sections;

  /// Returns the [SectionState] for [key], defaulting to [SectionState.idle] if absent.
  SectionState section(SectionKey key) => sections[key] ?? const SectionState();

  @override
  List<Object?> get props => [sections];
}

abstract class BaseCubit<T extends BaseState> extends Cubit<T>
    with ClientMixin {
  BaseCubit(super.initialState);

  /// Returns a **new** sections map with [key] set to [status] and optional [errorMessage].
  Map<SectionKey, SectionState> withSection(
    SectionKey key,
    SectionStatus status, {
    String? errorMessage,
  }) {
    return Map<SectionKey, SectionState>.from(state.sections)
      ..[key] = SectionState(status: status, errorMessage: errorMessage);
  }
}
