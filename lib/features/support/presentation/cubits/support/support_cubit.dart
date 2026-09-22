import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/services/support_service.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'support_state.dart';

@injectable
class SupportCubit extends BaseCubit<SupportState> {
  SupportCubit({required SupportService supportService})
    : _supportService = supportService,
      super(const SupportState.initial());

  final SupportService _supportService;

  void init() {
    emit(
      state.copyWith(
        supportEmail: _supportService.supportEmail,
        isEmailAvailable: _supportService.isEmailConfigured,
      ),
    );
  }

  void updateDescription(String text) {
    emit(state.copyWith(userDescription: text));
  }

  Future<void> launchEmail() async {
    if (state.section(SupportSection.launch).isRunning) return;

    if (!state.isEmailAvailable) {
      emit(
        state.copyWith(
          sections: withSection(
            SupportSection.launch,
            SectionStatus.error,
            errorMessage: 'unconfigured_email',
          ),
        ),
      );
      return;
    }

    if (!state.hasValidDraft) {
      emit(
        state.copyWith(
          sections: withSection(
            SupportSection.launch,
            SectionStatus.error,
            errorMessage: 'invalid_description',
          ),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        sections: withSection(SupportSection.launch, SectionStatus.running),
      ),
    );

    final platformName = kIsWeb ? 'web' : defaultTargetPlatform.name;
    final result = await _supportService.launchSupportEmail(
      userDescription: state.userDescription,
      platformName: platformName,
    );

    if (isClosed) return;

    if (result.isSuccess) {
      emit(
        state.copyWith(
          sections: withSection(SupportSection.launch, SectionStatus.success),
        ),
      );
    } else {
      emit(
        state.copyWith(
          sections: withSection(
            SupportSection.launch,
            SectionStatus.error,
            errorMessage: result.errorMessage ?? 'launch_failed',
          ),
        ),
      );
    }
  }

  Future<void> copyText(String text) async {
    if (state.section(SupportSection.copy).isRunning) return;

    emit(
      state.copyWith(
        sections: withSection(SupportSection.copy, SectionStatus.running),
      ),
    );

    final result = await _supportService.copyToClipboard(text);
    if (isClosed) return;

    if (result.isSuccess) {
      emit(
        state.copyWith(
          lastCopiedText: text,
          sections: withSection(SupportSection.copy, SectionStatus.success),
        ),
      );
    } else {
      emit(
        state.copyWith(
          sections: withSection(
            SupportSection.copy,
            SectionStatus.error,
            errorMessage: result.errorMessage ?? 'copy_failed',
          ),
        ),
      );
    }
  }
}
