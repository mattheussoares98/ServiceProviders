import 'package:clean_architecture/core/clients/local/local_storage_client.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/configurations/domain/entities/configurations_entity.dart';
import 'package:clean_architecture/features/configurations/presentation/cubits/configurations/configurations_cubit_use_cases.dart';
import 'package:clean_architecture/routing/routes.gr.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

part 'configurations_state.dart';

@injectable
class ConfigurationsCubit extends BaseCubit<ConfigurationsState> {
  ConfigurationsCubit({
    required ConfigurationsCubitUseCases useCases,
    required LocalStorageClient localStorageClient,
  }) : _useCases = useCases,
       _localStorageClient = localStorageClient,
       super(const ConfigurationsState.initial()) {
    _loadThemeMode();
  }

  final ConfigurationsCubitUseCases _useCases;
  final LocalStorageClient _localStorageClient;

  void _loadThemeMode() {
    final savedMode = _localStorageClient.getThemeMode();
    emit(
      state.copyWith(
        configurations: state.configurations.copyWith(themeMode: savedMode),
      ),
    );
  }

  Future<void> loadConfigurations() async {
    emit(state.copyWith(status: StateStatus.loading));
    final result = await _useCases.getConfigurations();
    if (result is SuccessState<ConfigurationsEntity>) {
      emit(
        state.copyWith(configurations: result.data, status: StateStatus.loaded),
      );
    } else if (result is FailureState<ConfigurationsEntity>) {
      emit(
        state.copyWith(status: StateStatus.loadingError, errorMessage: result.message),
      );
    }
  }

  Future<void> togglePushNotifications(bool enabled) async {
    emit(state.copyWith(status: StateStatus.loading));
    final result = await _useCases.saveConfigurations(enabled);
    if (result is SuccessState<bool> && result.data == true) {
      emit(
        state.copyWith(
          configurations: state.configurations.copyWith(
            pushNotificationsEnabled: enabled,
          ),
          status: StateStatus.loaded,
        ),
      );
    } else {
      emit(state.copyWith(status: StateStatus.loadingError));
    }
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    emit(state.copyWith(status: StateStatus.loading));
    await _localStorageClient.saveThemeMode(mode.name);
    emit(
      state.copyWith(
        configurations: state.configurations.copyWith(themeMode: mode.name),
        status: StateStatus.loaded,
      ),
    );
  }

  Future<void> clearAppCache() async {
    emit(state.copyWith(status: StateStatus.loading));
    await _localStorageClient.clearAll();
    emit(
      state.copyWith(
        configurations: const ConfigurationsEntity(
          pushNotificationsEnabled: true,
          themeMode: 'system',
        ),
        status: StateStatus.loaded,
      ),
    );
    await replaceAllRoute(const LoginRoute());
  }
}
