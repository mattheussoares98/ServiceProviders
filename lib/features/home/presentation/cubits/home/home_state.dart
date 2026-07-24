part of 'home_cubit.dart';

class HomeState extends BaseState {
  const HomeState({super.status, super.errorMessage});

  const HomeState.empty() : super(status: StateStatus.initial);

  HomeState copyWith({StateStatus? status, String? errorMessage}) {
    return HomeState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
