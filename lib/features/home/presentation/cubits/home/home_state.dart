part of 'home_cubit.dart';

class HomeState extends BaseState {
  const HomeState({
    super.status,
    super.errorMessage,
    super.sections = const {},
  });

  const HomeState.empty()
    : super(status: DataStatus.initial, sections: const {});

  HomeState copyWith({
    DataStatus? status,
    String? errorMessage,
    Map<SectionKey, SectionStatus>? sections,
  }) {
    return HomeState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, sections];
}
