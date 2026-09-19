import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/sectors/data/data_sources/sectors_local_data_source.dart';
import 'package:o_jogo_da_obra/features/sectors/data/models/responses/sector_model.dart';

import '../../testing/mocks/factories/local_database_fixture.dart';
import '../../testing/mocks/factories/system_factory.dart';

void main() {
  late LocalDatabaseFixture fixture;
  SectorsLocalDataSourceImpl source() =>
      SectorsLocalDataSourceImpl(database: fixture.database);
  setUp(() => fixture = LocalDatabaseFixture());
  tearDown(() => fixture.dispose());

  test(
    'sector create, rename, and delete persist across connections',
    () async {
      final original = SystemFactory.makeSectorEntity().copyWith(
        name: 'Manutenção',
      );
      expect(
        (await source().saveSector(SectorModel.fromEntity(original))).data,
        isTrue,
      );
      await fixture.reopen();
      expect(
        (await source().getSectors(original.companyId)).data!.single.name,
        'Manutenção',
      );
      final updated = original.copyWith(
        name: 'Manutenção predial',
        updatedAt: DateTime.utc(2026, 9, 19),
      );
      expect(
        (await source().saveSector(SectorModel.fromEntity(updated))).data,
        isTrue,
      );
      await fixture.reopen();
      final row = (await source().getSectors(original.companyId)).data!.single;
      expect(row.id, original.id);
      expect(row.name, 'Manutenção predial');
      expect(row.updatedAt, updated.updatedAt);
      expect(row.createdAt, original.createdAt);
      expect((await source().deleteSector(original.id)).data, isTrue);
      await fixture.reopen();
      expect((await source().getSectors(original.companyId)).data, isEmpty);
    },
  );

  test('batch replay and deletion do not affect the other company', () async {
    final a = SystemFactory.makeSectorEntity().copyWith(name: 'Operações');
    final b = SystemFactory.makeSectorEntity().copyWith(name: 'Operações');
    final batch = [SectorModel.fromEntity(a), SectorModel.fromEntity(b)];
    expect((await source().saveSectors(batch)).data, isTrue);
    await fixture.reopen();
    expect((await source().saveSectors(batch)).data, isTrue);
    await fixture.reopen();
    expect((await source().getSectors(a.companyId)).data!.map((r) => r.id), [
      a.id,
    ]);
    expect((await source().getSectors(b.companyId)).data!.map((r) => r.id), [
      b.id,
    ]);
    expect((await source().deleteSector(a.id)).data, isTrue);
    await fixture.reopen();
    expect((await source().getSectors(a.companyId)).data, isEmpty);
    expect((await source().getSectors(b.companyId)).data!.single.id, b.id);
  });

  test(
    'a downloaded sector tombstone remains excluded after restart',
    () async {
      final sector = SystemFactory.makeSectorEntity().copyWith(
        deletedAt: DateTime.utc(2026, 9, 19),
      );
      expect(
        (await source().saveSectors([SectorModel.fromEntity(sector)])).data,
        isTrue,
      );
      await fixture.reopen();
      expect((await source().getSectors(sector.companyId)).data, isEmpty);
      expect(
        (await fixture.database.select(fixture.database.sectors).get())
            .single
            .deletedAt,
        isNotNull,
      );
    },
  );
}
