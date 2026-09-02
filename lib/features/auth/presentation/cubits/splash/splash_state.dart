part of 'splash_cubit.dart';

enum SplashRouteTarget { initial, acceptInvite, providerHome, home, login }

final class SplashState extends BaseState {
  const SplashState({this.target = SplashRouteTarget.initial, super.sections});

  final SplashRouteTarget target;

  SplashState copyWith({
    SplashRouteTarget? target,
    Map<SectionKey, SectionState>? sections,
  }) {
    return SplashState(
      target: target ?? this.target,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [target, sections];
}
