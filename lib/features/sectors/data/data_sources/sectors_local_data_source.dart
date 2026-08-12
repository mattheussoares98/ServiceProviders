import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/handlers/error_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/sectors/data/models/responses/sector_model.dart';

abstract interface class SectorsLocalDataSource {
  FutureList<SectorModel> getSectors(String companyId);
  FutureBool saveSector(SectorModel sector);
  FutureBool saveSectors(List<SectorModel> sectors);
  FutureBool deleteSector(String id);
}

@LazySingleton(as: SectorsLocalDataSource)
final class SectorsLocalDataSourceImpl implements SectorsLocalDataSource {
  SectorsLocalDataSourceImpl({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  @override
  FutureList<SectorModel> getSectors(String companyId) {
    return ErrorHandler.execute(() async {
      final query = _database.select(_database.sectors)
        ..where((t) => t.companyId.equals(companyId) & t.deletedAt.isNull());
      final rows = await query.get();

      final list = rows
          .map(
            (row) => SectorModel(
              id: row.id,
              companyId: row.companyId,
              name: row.name,
              createdAt: row.createdAt,
              updatedAt: row.updatedAt,
              deletedAt: row.deletedAt,
            ),
          )
          .toList();

      return SuccessState(data: list);
    });
  }

  @override
  FutureBool saveSector(SectorModel sector) {
    return ErrorHandler.execute(() async {
      await _database
          .into(_database.sectors)
          .insertOnConflictUpdate(
            SectorsCompanion(
              id: Value(sector.id),
              companyId: Value(sector.companyId),
              name: Value(sector.name),
              createdAt: Value(sector.createdAt),
              updatedAt: Value(sector.updatedAt),
              deletedAt: Value(sector.deletedAt),
            ),
          );
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool saveSectors(List<SectorModel> sectors) {
    return ErrorHandler.execute(() async {
      await _database.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _database.sectors,
          sectors
              .map(
                (sector) => SectorsCompanion(
                  id: Value(sector.id),
                  companyId: Value(sector.companyId),
                  name: Value(sector.name),
                  createdAt: Value(sector.createdAt),
                  updatedAt: Value(sector.updatedAt),
                  deletedAt: Value(sector.deletedAt),
                ),
              )
              .toList(),
        );
      });
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool deleteSector(String id) {
    return ErrorHandler.execute(() async {
      final now = DateTime.now();
      await (_database.update(_database.sectors)..where((t) => t.id.equals(id)))
          .write(SectorsCompanion(deletedAt: Value(now)));
      return const SuccessState(data: true);
    });
  }
}
