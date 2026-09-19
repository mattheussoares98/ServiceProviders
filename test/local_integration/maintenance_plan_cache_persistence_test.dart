import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/data/data_sources/maintenance_plans_local_data_source.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/data/models/responses/maintenance_plan_model.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/interval_unit.dart';

import '../../testing/mocks/factories/local_database_fixture.dart';
import '../../testing/mocks/factories/maintenance_plan_factory.dart';

// This covers the existing cache source, not server scheduling or generation.
// The current maintenance-plan repository itself is online-only.
void main() {
  late LocalDatabaseFixture fixture;
  MaintenancePlansLocalDataSourceImpl source() =>
      MaintenancePlansLocalDataSourceImpl(database: fixture.database);
  setUp(() => fixture = LocalDatabaseFixture());
  tearDown(() => fixture.dispose());

  test('plan schedule changes and nullable clears survive reopening', () async {
    final plan = MaintenancePlanFactory.makeMaintenancePlanEntity().copyWith(
      nextDueDate: DateTime.utc(2026, 10, 15, 9),
      lastError: 'Previous generation failed',
    );
    expect(
      (await source().savePlan(MaintenancePlanModel.fromEntity(plan))).data,
      isTrue,
    );
    await fixture.reopen();
    var row = (await source().getPlanById(plan.id)).data!;
    expect(row.nextDueDate, DateTime.utc(2026, 10, 15, 9));
    expect(row.lastError, 'Previous generation failed');
    expect(row.lastGeneratedWorkOrderId, plan.lastGeneratedWorkOrderId);
    final changed = plan.copyWith(
      title: 'Inspeção semanal',
      intervalUnit: IntervalUnit.weeks,
      intervalValue: 2,
      dayOfWeek: 3,
      annulDayOfMonth: true,
      annulMonthOfYear: true,
      annulDescription: true,
      annulAssignedToId: true,
      annulLastError: true,
      isActive: false,
      price: 0,
    );
    expect(
      (await source().savePlan(MaintenancePlanModel.fromEntity(changed))).data,
      isTrue,
    );
    await fixture.reopen();
    row = (await source().getPlanById(plan.id)).data!;
    expect(row.title, changed.title);
    expect(row.intervalUnit, IntervalUnit.weeks);
    expect(row.intervalValue, 2);
    expect(row.dayOfWeek, 3);
    expect(row.dayOfMonth, isNull);
    expect(row.monthOfYear, isNull);
    expect(row.description, isNull);
    expect(row.assignedToId, isNull);
    expect(row.lastError, isNull);
    expect(row.isActive, isFalse);
    expect(row.price, 0);
    expect(row.lastGeneratedWorkOrderId, plan.lastGeneratedWorkOrderId);
  });

  test(
    'replayed plan cache remains scoped to its company and respects deletion',
    () async {
      final a = MaintenancePlanFactory.makeMaintenancePlanEntity();
      final b = MaintenancePlanFactory.makeMaintenancePlanEntity();
      final batch = [
        MaintenancePlanModel.fromEntity(a),
        MaintenancePlanModel.fromEntity(b),
      ];
      expect((await source().savePlans(batch)).data, isTrue);
      await fixture.reopen();
      expect((await source().savePlans(batch)).data, isTrue);
      await fixture.reopen();
      expect((await source().getPlans(a.companyId)).data!.single.id, a.id);
      expect((await source().getPlans(b.companyId)).data!.single.id, b.id);
      expect((await source().deletePlan(a.id)).data, isTrue);
      await fixture.reopen();
      expect((await source().getPlans(a.companyId)).data, isEmpty);
      expect(
        await source().getPlanById(a.id),
        isA<FailureState<MaintenancePlanModel>>(),
      );
      expect((await source().getPlans(b.companyId)).data!.single.id, b.id);
    },
  );
}
