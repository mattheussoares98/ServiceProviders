part of 'provider_home_cubit.dart';

class ProviderHomeState extends BaseState {
  const ProviderHomeState({super.status, super.errorMessage});

  const ProviderHomeState.empty() : super(status: DataStatus.initial);

  ProviderHomeState copyWith({DataStatus? status, String? errorMessage}) {
    return ProviderHomeState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
