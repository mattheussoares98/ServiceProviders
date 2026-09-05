import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/services/file_service.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/audit_logs/audit_log_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_order_history/work_order_history_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/extensions/audit_change_ui_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'work_order_history_state.dart';

@injectable
class WorkOrderHistoryCubit extends BaseCubit<WorkOrderHistoryState> {
  WorkOrderHistoryCubit({
    required WorkOrderHistoryCubitUseCases useCases,
    required FileService fileService,
  }) : _useCases = useCases,
       _fileService = fileService,
       super(const WorkOrderHistoryState.initial());

  final WorkOrderHistoryCubitUseCases _useCases;
  final FileService _fileService;

  Future<void> loadHistory(
    String workOrderId, {
    bool showLoading = true,
  }) async {
    if (showLoading) {
      emit(
        state.copyWith(
          sections: withSection(BaseSections.load, SectionStatus.running),
        ),
      );
    }

    final dataState = await _useCases.getWorkOrderHistory(workOrderId);
    if (isClosed) return;

    if (dataState is SuccessState<List<AuditLogEntity>>) {
      final history = dataState.data ?? [];
      final filteredHistory = _computeFilteredHistory(
        history: history,
        startDate: state.startDate,
        endDate: state.endDate,
        searchQuery: state.searchQuery,
      );
      emit(
        state.copyWith(
          history: history,
          filteredHistory: filteredHistory,
          sections: withSection(BaseSections.load, SectionStatus.success),
        ),
      );
    } else {
      if (showLoading) {
        emit(
          state.copyWith(
            sections: withSection(
              BaseSections.load,
              SectionStatus.error,
              errorMessage: dataState.message,
            ),
          ),
        );
      } else {
        showDataStateToast(dataState);
      }
    }
  }

  void setDateRange({DateTime? startDate, DateTime? endDate}) {
    final filteredHistory = _computeFilteredHistory(
      history: state.history,
      startDate: startDate,
      endDate: endDate,
      searchQuery: state.searchQuery,
    );
    emit(
      state.copyWith(
        startDate: startDate,
        endDate: endDate,
        filteredHistory: filteredHistory,
        annulStartDate: startDate == null,
        annulEndDate: endDate == null,
      ),
    );
  }

  void setSearchQuery(String? query) {
    final cleanQuery = query?.trim().isEmpty == true ? null : query?.trim();
    final filteredHistory = _computeFilteredHistory(
      history: state.history,
      startDate: state.startDate,
      endDate: state.endDate,
      searchQuery: cleanQuery,
    );
    emit(
      state.copyWith(
        searchQuery: cleanQuery,
        filteredHistory: filteredHistory,
        annulSearchQuery: cleanQuery == null,
      ),
    );
  }

  void clearSearchQuery() {
    final filteredHistory = _computeFilteredHistory(
      history: state.history,
      startDate: state.startDate,
      endDate: state.endDate,
    );
    emit(
      state.copyWith(filteredHistory: filteredHistory, annulSearchQuery: true),
    );
  }

  void clearDateFilter() {
    final filteredHistory = _computeFilteredHistory(
      history: state.history,
      searchQuery: state.searchQuery,
    );
    emit(
      state.copyWith(
        filteredHistory: filteredHistory,
        annulStartDate: true,
        annulEndDate: true,
      ),
    );
  }

  Future<void> openAttachmentUrl(String url) async {
    final result = await _fileService.openFile(url);
    if (result is! SuccessState<bool>) {
      showDataStateToast(result);
    }
  }

  List<AuditLogEntity> _computeFilteredHistory({
    required List<AuditLogEntity> history,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) {
    final query = searchQuery?.trim().toLowerCase();

    return history.where((item) {
      if (startDate != null || endDate != null) {
        final itemDate = item.createdAt;

        if (startDate != null && endDate != null) {
          final start = DateTime(
            startDate.year,
            startDate.month,
            startDate.day,
          );
          final end = DateTime(
            endDate.year,
            endDate.month,
            endDate.day,
            23,
            59,
            59,
            999,
          );
          final inRange =
              (itemDate.isAfter(start) || itemDate.isAtSameMomentAs(start)) &&
              (itemDate.isBefore(end) || itemDate.isAtSameMomentAs(end));
          if (!inRange) return false;
        } else if (startDate != null) {
          final start = DateTime(
            startDate.year,
            startDate.month,
            startDate.day,
          );
          if (itemDate.isBefore(start)) return false;
        } else if (endDate != null) {
          final end = DateTime(
            endDate.year,
            endDate.month,
            endDate.day,
            23,
            59,
            59,
            999,
          );
          if (itemDate.isAfter(end)) return false;
        }
      }

      if (query != null && query.isNotEmpty) {
        return _matchesQuery(item, query);
      }

      return true;
    }).toList();
  }

  bool _matchesQuery(AuditLogEntity item, String query) {
    if (item.displayTitle.toLowerCase().contains(query)) return true;
    if (item.action.toLowerCase().contains(query)) return true;
    if (item.entityType.label.toLowerCase().contains(query)) return true;
    if (item.summary?.toLowerCase().contains(query) ?? false) return true;

    final metadata = item.metadata;
    if (metadata != null) {
      if (metadata.fileName?.toLowerCase().contains(query) ?? false) {
        return true;
      }
      if (metadata.fileType?.toLowerCase().contains(query) ?? false) {
        return true;
      }
      if (metadata.reason?.toLowerCase().contains(query) ?? false) {
        return true;
      }
      if (metadata.eventType?.toLowerCase().contains(query) ?? false) {
        return true;
      }
      if (metadata.status?.toLowerCase().contains(query) ?? false) {
        return true;
      }
      if (metadata.reviewObservation?.toLowerCase().contains(query) ?? false) {
        return true;
      }
    }

    for (final change in item.changes) {
      if (change.field.toLowerCase().contains(query)) return true;
      if (change.label?.toLowerCase().contains(query) ?? false) return true;
      if (change.localizedLabel.toLowerCase().contains(query)) return true;
      if (change.oldValue?.toLowerCase().contains(query) ?? false) return true;
      if (change.newValue?.toLowerCase().contains(query) ?? false) return true;
      if (change.oldDisplay?.toLowerCase().contains(query) ?? false) {
        return true;
      }
      if (change.newDisplay?.toLowerCase().contains(query) ?? false) {
        return true;
      }
      if (change.localizedOldValue?.toLowerCase().contains(query) ?? false) {
        return true;
      }
      if (change.localizedNewValue?.toLowerCase().contains(query) ?? false) {
        return true;
      }
    }

    return false;
  }
}
