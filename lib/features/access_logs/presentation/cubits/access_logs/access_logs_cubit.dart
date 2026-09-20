import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/access_log_entity.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/get_access_logs_request_entity.dart';
import 'package:o_jogo_da_obra/features/access_logs/presentation/cubits/access_logs/access_logs_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'access_logs_state.dart';

@injectable
class AccessLogsCubit extends BaseCubit<AccessLogsState> {
  AccessLogsCubit({required AccessLogsCubitUseCases useCases})
    : _useCases = useCases,
      super(const AccessLogsState.initial());

  final AccessLogsCubitUseCases _useCases;
  static const int _pageSize = 30;

  Future<void> loadInitialData({bool showLoading = true}) async {
    if (showLoading) {
      emit(
        state.copyWith(
          sections: withSection(BaseSections.load, SectionStatus.running),
        ),
      );
    }

    final companyId = _useCases.getActiveCompanyId.call();
    if (companyId.isEmpty) {
      emit(
        state.copyWith(
          sections: withSection(BaseSections.load, SectionStatus.success),
        ),
      );
      return;
    }

    final request = GetAccessLogsRequestEntity(
      companyId: companyId,
      startDate: state.startDate,
      endDate: state.endDate,
      userId: state.selectedUserId,
      limit: _pageSize,
    );

    final logsState = await _useCases.getAccessLogs.call(request);
    if (isClosed) return;

    final usersState = await _useCases.getUsers.call(companyId);
    final users = usersState is SuccessState<List<UserProfileEntity>>
        ? (usersState.data ?? [])
        : <UserProfileEntity>[];

    if (logsState is SuccessState<List<AccessLogEntity>>) {
      final logs = logsState.data ?? [];
      emit(
        state.copyWith(
          logs: logs,
          users: users,
          page: 0,
          hasReachedMax: logs.length < _pageSize,
          sections: withSection(BaseSections.load, SectionStatus.success),
        ),
      );
    } else {
      if (showLoading) {
        emit(
          state.copyWith(
            users: users,
            sections: withSection(
              BaseSections.load,
              SectionStatus.error,
              errorMessage: logsState.message,
            ),
          ),
        );
      } else {
        showDataStateToast(logsState);
      }
    }
  }

  Future<void> loadMore() async {
    if (state.hasReachedMax ||
        state.sections[BaseSections.load]?.status == SectionStatus.running) {
      return;
    }

    final companyId = _useCases.getActiveCompanyId.call();
    if (companyId.isEmpty) return;

    final nextPage = state.page + 1;
    final request = GetAccessLogsRequestEntity(
      companyId: companyId,
      startDate: state.startDate,
      endDate: state.endDate,
      userId: state.selectedUserId,
      limit: _pageSize,
      offset: nextPage * _pageSize,
    );

    final logsState = await _useCases.getAccessLogs.call(request);
    if (isClosed) return;

    if (logsState is SuccessState<List<AccessLogEntity>>) {
      final newLogs = logsState.data ?? [];
      final existingIds = state.logs.map((e) => e.id).toSet();
      final deduplicated = [
        ...state.logs,
        ...newLogs.where((e) => !existingIds.contains(e.id)),
      ];
      emit(
        state.copyWith(
          logs: deduplicated,
          page: nextPage,
          hasReachedMax: newLogs.length < _pageSize,
        ),
      );
    }
  }

  void setDateRange({DateTime? startDate, DateTime? endDate}) {
    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      emit(
        state.copyWith(
          startDate: startDate,
          endDate: endDate,
          sections: withSection(
            BaseSections.load,
            SectionStatus.error,
            errorMessage: 'A data inicial não pode ser posterior à data final'.hardcoded,
          ),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        startDate: startDate,
        endDate: endDate,
        annulStartDate: startDate == null,
        annulEndDate: endDate == null,
      ),
    );
    loadInitialData();
  }

  void setSelectedUser(String? userId) {
    emit(
      state.copyWith(
        selectedUserId: userId,
        annulSelectedUserId: userId == null,
      ),
    );
    loadInitialData();
  }

  void clearFilters() {
    emit(
      state.copyWith(
        annulStartDate: true,
        annulEndDate: true,
        annulSelectedUserId: true,
      ),
    );
    loadInitialData();
  }

  Future<void> refresh() async {
    await loadInitialData(showLoading: false);
  }
}
