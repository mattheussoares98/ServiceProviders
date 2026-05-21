import 'package:clean_architecture/core/clients/local/local_storage_client.dart';
import 'package:clean_architecture/core/constants/local_db_keys.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

part 'theme_state.dart';

@injectable
class ThemeCubit extends BaseCubit<ThemeState> {
  ThemeCubit(this._localStorageClient)
    : super(const ThemeState(themeMode: ThemeMode.system)) {
    _loadThemeMode();
  }

  final LocalStorageClient _localStorageClient;

  void _loadThemeMode() {
    final savedMode = _localStorageClient.getString(LocalDbKey.themeMode.key);
    if (savedMode != null) {
      final mode = ThemeMode.values.firstWhere(
        (e) => e.name == savedMode,
        orElse: () => ThemeMode.system,
      );
      emit(ThemeState(themeMode: mode, status: StateStatus.loaded));
    } else {
      emit(
        const ThemeState(
          themeMode: ThemeMode.system,
          status: StateStatus.loaded,
        ),
      );
    }
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    emit(ThemeState(themeMode: mode, status: StateStatus.loading));
    await _localStorageClient.setString(LocalDbKey.themeMode.key, mode.name);
    emit(ThemeState(themeMode: mode, status: StateStatus.loaded));
  }
}
