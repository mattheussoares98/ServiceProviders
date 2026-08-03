import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/entities/sector_entity.dart';
import 'package:o_jogo_da_obra/features/sectors/presentation/cubits/sectors/sectors_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'sectors_state.dart';

@injectable
class SectorsCubit extends BaseCubit<SectorsState> {
  SectorsCubit({required SectorsCubitUseCases useCases})
      : _useCases = useCases,
        super(const SectorsState.initial());

  final SectorsCubitUseCases _useCases;

  Future<void> loadSectors(String companyId, {bool emitLoading = true}) async {
    if (emitLoading) {
      emit(state.copyWith(status: StateStatus.loading));
    }

    final result = await _useCases.getSectors(companyId);
    if (isClosed) return;

    if (result is SuccessState<List<SectorEntity>>) {
      emit(
        state.copyWith(
          status: StateStatus.loaded,
          sectors: result.data ?? [],
          annulErrorMessage: true,
        ),
      );
    } else {
      final message =
          result.message ?? 'Erro ao carregar setores'.hardcoded;
      emit(
        state.copyWith(status: StateStatus.loadingError, errorMessage: message),
      );
      showErrorToast(message);
    }
  }

  void selectSector(String? id) {
    if (id == null) {
      emit(state.copyWith(annulSelectedSector: true));
      return;
    }

    final sector = state.sectors
        .cast<SectorEntity?>()
        .firstWhere((e) => e?.id == id, orElse: () => null);

    if (sector != null) {
      emit(state.copyWith(selectedSector: sector));
    } else {
      emit(state.copyWith(annulSelectedSector: true));
    }
  }

  Future<bool> saveSector(SectorEntity sector, {bool isUpdate = false}) async {
    emit(state.copyWith(status: StateStatus.saving));

    final result = isUpdate
        ? await _useCases.updateSector(sector)
        : await _useCases.createSector(sector);
    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      emit(state.copyWith(status: StateStatus.loaded));
      await loadSectors(sector.companyId, emitLoading: false);
      return true;
    } else {
      final message =
          result.message ?? 'Erro ao salvar setor'.hardcoded;
      emit(
        state.copyWith(status: StateStatus.savingError, errorMessage: message),
      );
      showErrorToast(message);
      return false;
    }
  }

  Future<bool> deleteSector(String id, String companyId) async {
    emit(state.copyWith(status: StateStatus.deleting));

    final result = await _useCases.deleteSector(id);
    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      emit(state.copyWith(status: StateStatus.loaded));
      await loadSectors(companyId, emitLoading: false);
      return true;
    } else {
      final message =
          result.message ?? 'Erro ao excluir setor'.hardcoded;
      emit(
        state.copyWith(status: StateStatus.loadingError, errorMessage: message),
      );
      showErrorToast(message);
      return false;
    }
  }
}
