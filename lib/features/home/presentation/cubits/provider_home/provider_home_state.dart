part of 'provider_home_cubit.dart';

class ProviderHomeState extends BaseState {
  const ProviderHomeState({super.sections = const {}});

  const ProviderHomeState.empty() : super(sections: const {});

  ProviderHomeState copyWith({Map<SectionKey, SectionState>? sections}) {
    return ProviderHomeState(
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [sections];
}
