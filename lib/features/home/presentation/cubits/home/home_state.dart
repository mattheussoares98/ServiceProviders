part of 'home_cubit.dart';

class HomeState extends BaseState {
  const HomeState({
    super.sections = const {},
  });

  const HomeState.empty()
    : super(sections: const {});

  HomeState copyWith({
    Map<SectionKey, SectionState>? sections,
  }) {
    return HomeState(
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [sections];
}
