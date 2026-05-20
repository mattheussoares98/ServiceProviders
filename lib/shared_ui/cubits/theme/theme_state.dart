part of 'theme_cubit.dart';

class ThemeState extends BaseState {
  const ThemeState({required this.themeMode, super.status});
  final ThemeMode themeMode;

  @override
  List<Object?> get props => [themeMode, status];
}
