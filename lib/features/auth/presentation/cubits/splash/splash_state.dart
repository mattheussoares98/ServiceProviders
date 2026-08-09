part of 'splash_cubit.dart';

enum SplashRouteTarget { initial, acceptInvite, providerHome, home, login }

final class SplashState extends BaseState {
  const SplashState({this.target = SplashRouteTarget.initial});

  final SplashRouteTarget target;

  SplashState copyWith({SplashRouteTarget? target}) {
    return SplashState(target: target ?? this.target);
  }

  @override
  List<Object?> get props => [target];
}
