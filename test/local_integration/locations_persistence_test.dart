import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/locations/data/data_sources/locations_local_data_source.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/responses/area_model.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/responses/location_model.dart';

import '../../testing/mocks/factories/asset_factory.dart';
import '../../testing/mocks/factories/local_database_fixture.dart';

void main() {
  late LocalDatabaseFixture fixture;
  LocationsLocalDataSourceImpl source() =>
      LocationsLocalDataSourceImpl(database: fixture.database);
  setUp(() => fixture = LocalDatabaseFixture());
  tearDown(() => fixture.dispose());

  test(
    'LOC: create, reopen, update, clear nullable field, reopen, delete, reopen',
    () async {
      final original = AssetFactory.makeLocationEntity().copyWith(
        name: 'Oficina São José',
        complement: 'Bloco B',
      );
      expect(
        (await source().saveLocation(LocationModel.fromEntity(original))).data,
        isTrue,
      );
      await fixture.reopen();
      var rows = (await source().getLocations(original.companyId)).data!;
      expect(rows.single.id, original.id);
      expect(rows.single.name, 'Oficina São José');
      expect(rows.single.complement, 'Bloco B');
      final updated = original.copyWith(
        name: 'Oficina revisada',
        annulComplement: true,
      );
      expect(
        (await source().saveLocation(LocationModel.fromEntity(updated))).data,
        isTrue,
      );
      await fixture.reopen();
      rows = (await source().getLocations(original.companyId)).data!;
      expect(rows.single.name, 'Oficina revisada');
      expect(rows.single.complement, isNull);
      expect(rows.single.address, original.address);
      expect((await source().deleteLocation(original.id)).data, isTrue);
      await fixture.reopen();
      expect((await source().getLocations(original.companyId)).data, isEmpty);
    },
  );

  test(
    'AREA: create/update/delete survives independent database connections',
    () async {
      final location = AssetFactory.makeLocationEntity();
      final area = AssetFactory.makeAreaEntity().copyWith(
        locationId: location.id,
        companyId: location.companyId,
        name: 'Área técnica',
        floor: '2',
        description: 'Inspeção',
      );
      await source().saveLocation(LocationModel.fromEntity(location));
      expect(
        (await source().saveArea(AreaModel.fromEntity(area))).data,
        isTrue,
      );
      await fixture.reopen();
      var rows = (await source().getAreas(location.companyId)).data!;
      expect(rows.single.locationId, location.id);
      expect(rows.single.name, 'Área técnica');
      await source().saveArea(
        AreaModel.fromEntity(
          area.copyWith(
            name: 'Área revisada',
            annulFloor: true,
            annulDescription: true,
          ),
        ),
      );
      await fixture.reopen();
      rows = (await source().getAreas(location.companyId)).data!;
      expect(rows.single.name, 'Área revisada');
      expect(rows.single.floor, isNull);
      expect(rows.single.description, isNull);
      expect((await source().deleteArea(area.id)).data, isTrue);
      await fixture.reopen();
      expect((await source().getAreas(location.companyId)).data, isEmpty);
    },
  );

  test(
    'company-filtered location and area reads remain isolated after reopening',
    () async {
      final a = AssetFactory.makeLocationEntity();
      final b = AssetFactory.makeLocationEntity();
      final areaA = AssetFactory.makeAreaEntity().copyWith(
        companyId: a.companyId,
        locationId: a.id,
      );
      final areaB = AssetFactory.makeAreaEntity().copyWith(
        companyId: b.companyId,
        locationId: b.id,
      );
      await source().saveLocations([
        LocationModel.fromEntity(a),
        LocationModel.fromEntity(b),
      ]);
      await source().saveAreas([
        AreaModel.fromEntity(areaA),
        AreaModel.fromEntity(areaB),
      ]);
      await fixture.reopen();
      expect(
        (await source().getLocations(a.companyId)).data!.map((row) => row.id),
        [a.id],
      );
      expect(
        (await source().getLocations(b.companyId)).data!.map((row) => row.id),
        [b.id],
      );
      expect(
        (await source().getAreas(a.companyId)).data!.map((row) => row.id),
        [areaA.id],
      );
      expect(
        (await source().getAreas(b.companyId)).data!.map((row) => row.id),
        [areaB.id],
      );
    },
  );

  test('replaying an identical upsert does not duplicate a location', () async {
    final location = LocationModel.fromEntity(
      AssetFactory.makeLocationEntity(),
    );
    await source().saveLocation(location);
    await fixture.reopen();
    await source().saveLocation(location);
    await fixture.reopen();
    expect(
      (await source().getLocations(location.companyId)).data,
      hasLength(1),
    );
  });

  test('server soft-delete tombstones stay hidden after reopening', () async {
    final location = AssetFactory.makeLocationEntity().copyWith(
      deletedAt: DateTime.utc(2026, 9, 19),
    );
    final area = AssetFactory.makeAreaEntity().copyWith(
      companyId: location.companyId,
      locationId: location.id,
      deletedAt: DateTime.utc(2026, 9, 19),
    );
    await source().saveLocation(LocationModel.fromEntity(location));
    await source().saveArea(AreaModel.fromEntity(area));
    await fixture.reopen();
    expect((await source().getLocations(location.companyId)).data, isEmpty);
    expect((await source().getAreas(location.companyId)).data, isEmpty);
  });
}
