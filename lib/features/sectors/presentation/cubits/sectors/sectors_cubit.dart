import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/entities/sector_entity.dart';
import 'package:o_jogo_da_obra/features/sectors/presentation/cubits/sectors/sectors_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:uuid/uuid.dart';

part 'sectors_state.dart';

enum SectorsSections implements SectionKey { save, delete }

@injectable
class SectorsCubit extends BaseCubit<SectorsState> {
  SectorsCubit({required SectorsCubitUseCases useCases})
    : _useCases = useCases,
      super(const SectorsState.initial());

  final SectorsCubitUseCases _useCases;

  Future<void> loadSectors({bool emitLoading = true}) async {
    final companyId = _useCases.getActiveCompanyId();

    if (emitLoading) {
      emit(state.copyWith(status: DataStatus.loading));
    }

    final result = await _useCases.getSectors(companyId);
    if (isClosed) return;

    if (result is SuccessState<List<SectorEntity>>) {
      emit(
        state.copyWith(
          status: DataStatus.loaded,
          sectors: result.data ?? [],
          annulErrorMessage: true,
        ),
      );
    } else {
      final message = result.message ?? 'Erro ao carregar setores'.hardcoded;
      emit(
        state.copyWith(status: DataStatus.loadingError, errorMessage: message),
      );
      showErrorToast(message);
    }
  }

  void selectSector(String? id) {
    if (id == null) {
      emit(state.copyWith(annulSelectedSector: true));
      return;
    }

    final sector = state.sectors.cast<SectorEntity?>().firstWhere(
      (e) => e?.id == id,
      orElse: () => null,
    );

    if (sector != null) {
      emit(state.copyWith(selectedSector: sector));
    } else {
      emit(state.copyWith(annulSelectedSector: true));
    }
  }

  Future<bool> saveSector({String? id, required String name}) async {
    emit(
      state.copyWith(
        sections: withSection(SectorsSections.save, SectionStatus.running),
      ),
    );

    final isUpdate = id != null;
    final now = DateTime.now();
    final companyId = _useCases.getActiveCompanyId();

    final existingSector = isUpdate
        ? state.sectors.cast<SectorEntity?>().firstWhere(
            (e) => e?.id == id,
            orElse: () => null,
          )
        : null;

    final sector = SectorEntity(
      id: id ?? const Uuid().v4(),
      companyId: companyId,
      name: name.trim(),
      createdAt: existingSector?.createdAt ?? now,
      updatedAt: now,
      deletedAt: null,
    );

    final result = isUpdate
        ? await _useCases.updateSector(sector)
        : await _useCases.createSector(sector);
    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      emit(
        state.copyWith(
          sections: withSection(SectorsSections.save, SectionStatus.success),
        ),
      );
      await loadSectors(emitLoading: false);
      return true;
    } else {
      final message = result.message ?? 'Erro ao salvar setor'.hardcoded;
      emit(
        state.copyWith(
          sections: withSection(SectorsSections.save, SectionStatus.error),
        ),
      );
      showErrorToast(message);
      return false;
    }
  }

  Future<bool> deleteSector(String id) async {
    emit(
      state.copyWith(
        sections: withSection(SectorsSections.delete, SectionStatus.running),
      ),
    );

    final result = await _useCases.deleteSector(id);
    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      final updatedSectors = state.sectors.where((s) => s.id != id).toList();
      emit(
        state.copyWith(
          sectors: updatedSectors,
          sections: withSection(SectorsSections.delete, SectionStatus.success),
        ),
      );
      await loadSectors(emitLoading: false);
      return true;
    } else {
      final message = result.message ?? 'Erro ao excluir setor'.hardcoded;
      emit(
        state.copyWith(
          sections: withSection(SectorsSections.delete, SectionStatus.error),
        ),
      );
      showErrorToast(message);
      return false;
    }
  }

  Future<void> navigateToCreateUpdateSector({SectorEntity? sector}) async {
    await pushRoute(CreateUpdateSectorRoute(sector: sector));
    await loadSectors(emitLoading: false);
  }
}
