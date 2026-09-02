import 'dart:async';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/configurations/domain/entities/configurations_entity.dart';
import 'package:o_jogo_da_obra/features/configurations/presentation/cubits/configurations/configurations_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'configurations_state.dart';

@injectable
class ConfigurationsCubit extends BaseCubit<ConfigurationsState> {
  ConfigurationsCubit({required ConfigurationsCubitUseCases useCases})
    : _useCases = useCases,
      super(const ConfigurationsState.initial());

  final ConfigurationsCubitUseCases _useCases;

  Future<void> loadConfigurations() async {
    emit(
      state.copyWith(
        sections: withSection(BaseSections.load, SectionStatus.running),
      ),
    );
    final result = await _useCases.getConfigurations();
    if (result is SuccessState<ConfigurationsEntity>) {
      emit(
        state.copyWith(
          configurations: result.data,
          sections: withSection(BaseSections.load, SectionStatus.success),
        ),
      );
    } else if (result is FailureState<ConfigurationsEntity>) {
      emit(
        state.copyWith(
          sections: withSection(
            BaseSections.load,
            SectionStatus.error,
            errorMessage: result.message,
          ),
        ),
      );
    }
  }

  void togglePushNotifications(bool enabled) {
    emit(
      state.copyWith(
        configurations: state.configurations.copyWith(
          pushNotificationsEnabled: enabled,
        ),
      ),
    );
    unawaited(_useCases.saveConfigurations(enabled));
  }

  void updateThemeMode(ThemeMode mode) {
    emit(
      state.copyWith(
        configurations: state.configurations.copyWith(themeMode: mode.name),
      ),
    );
    unawaited(_useCases.saveThemeMode(mode.name));
  }

  Future<void> clearAppCache() async {
    emit(
      state.copyWith(
        sections: withSection(BaseSections.load, SectionStatus.running),
      ),
    );
    await _useCases.clearAppCache();
    emit(
      state.copyWith(
        configurations: const ConfigurationsEntity(
          pushNotificationsEnabled: true,
          themeMode: 'system',
          systemNotificationsEnabled: true,
        ),
        sections: withSection(BaseSections.load, SectionStatus.success),
      ),
    );
    await replaceAllRoute(const LoginRoute());
  }
}
