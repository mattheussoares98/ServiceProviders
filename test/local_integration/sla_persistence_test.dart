import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/sla_policies/data/data_sources/sla_local_data_source.dart';
import 'package:o_jogo_da_obra/features/sla_policies/data/models/responses/sla_policy_model.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/entities/sla_applies_to.dart';

import '../../testing/mocks/factories/local_database_fixture.dart';
import '../../testing/mocks/factories/system_factory.dart';

void main() {
  late LocalDatabaseFixture fixture;
  SlaLocalDataSourceImpl source() =>
      SlaLocalDataSourceImpl(database: fixture.database);
  setUp(() => fixture = LocalDatabaseFixture());
  tearDown(() => fixture.dispose());

  test(
    'SLA creation, target/scope change, and deletion survive restart',
    () async {
      final original = SystemFactory.makeSlaPolicyEntity().copyWith(
        name: 'Urgente',
        targetHours: 4,
        appliesTo: SlaAppliesTo.both,
      );
      expect(
        (await source().saveSlaPolicy(
          SlaPolicyModel.fromEntity(original),
        )).data,
        isTrue,
      );
      await fixture.reopen();
      var row = (await source().getSlaPolicyById(original.id)).data!;
      expect(row.name, 'Urgente');
      expect(row.targetHours, 4);
      expect(row.appliesTo, SlaAppliesTo.both);
      final updated = original.copyWith(
        name: 'Prestador urgente',
        targetHours: 8,
        appliesTo: SlaAppliesTo.provider,
        updatedAt: DateTime.utc(2026, 9, 19),
      );
      expect(
        (await source().saveSlaPolicy(SlaPolicyModel.fromEntity(updated))).data,
        isTrue,
      );
      await fixture.reopen();
      row = (await source().getSlaPolicyById(original.id)).data!;
      expect(row.name, updated.name);
      expect(row.targetHours, 8);
      expect(row.appliesTo, SlaAppliesTo.provider);
      expect(row.updatedAt, updated.updatedAt);
      expect((await source().deleteSlaPolicy(original.id)).data, isTrue);
      await fixture.reopen();
      expect((await source().getSlaPolicies(original.companyId)).data, isEmpty);
      expect(
        await source().getSlaPolicyById(original.id),
        isA<FailureState<SlaPolicyModel>>(),
      );
    },
  );

  test(
    'each scope survives storage and replay without duplicate records',
    () async {
      final base = SystemFactory.makeSlaPolicyEntity();
      for (final scope in SlaAppliesTo.values) {
        final model = SlaPolicyModel.fromEntity(
          base.copyWith(appliesTo: scope),
        );
        expect((await source().saveSlaPolicy(model)).data, isTrue);
        await fixture.reopen();
        expect((await source().saveSlaPolicy(model)).data, isTrue);
        await fixture.reopen();
        expect(
          (await source().getSlaPolicies(
            base.companyId,
          )).data!.single.appliesTo,
          scope,
        );
      }
    },
  );

  test('company lists and deletion remain isolated after restarting', () async {
    final a = SystemFactory.makeSlaPolicyEntity();
    final b = SystemFactory.makeSlaPolicyEntity();
    expect(
      (await source().saveSlaPolicy(SlaPolicyModel.fromEntity(a))).data,
      isTrue,
    );
    expect(
      (await source().saveSlaPolicy(SlaPolicyModel.fromEntity(b))).data,
      isTrue,
    );
    await fixture.reopen();
    expect((await source().getSlaPolicies(a.companyId)).data!.single.id, a.id);
    expect((await source().getSlaPolicies(b.companyId)).data!.single.id, b.id);
    expect((await source().deleteSlaPolicy(a.id)).data, isTrue);
    await fixture.reopen();
    expect((await source().getSlaPolicies(a.companyId)).data, isEmpty);
    expect((await source().getSlaPolicies(b.companyId)).data!.single.id, b.id);
  });
}
