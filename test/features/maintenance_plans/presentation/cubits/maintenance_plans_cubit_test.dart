import 'package:bloc_test/bloc_test.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/maintenance_plan_entity.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/presentation/cubits/maintenance_plans/maintenance_plans_cubit.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/presentation/cubits/maintenance_plans/maintenance_plans_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/factories/maintenance_plan_factory.dart';
import '../../../../../testing/mocks/use_case_mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetActiveCompanyIdUseCase mockGetActiveCompanyId;
  late MockGetMaintenancePlansUseCase mockGetMaintenancePlans;
  late MockGetMaintenancePlanByIdUseCase mockGetMaintenancePlanById;
  late MockCreateMaintenancePlanUseCase mockCreateMaintenancePlan;
  late MockUpdateMaintenancePlanUseCase mockUpdateMaintenancePlan;
  late MockDeleteMaintenancePlanUseCase mockDeleteMaintenancePlan;
  late MockCalculateNextDueDateUseCase mockCalculateNextDueDate;
  late MockGenerateMaintenancePlanWorkOrderUseCase
  mockGenerateMaintenancePlanWorkOrder;
  late MockNavigationClient mockNavigationClient;
  late MaintenancePlansCubitUseCases useCases;
  late MaintenancePlansCubit cubit;

  final tCompanyId = faker.guid.guid();
  final tPlan = MaintenancePlanFactory.makeMaintenancePlanEntity();
  final tPlans = MaintenancePlanFactory.makeMaintenancePlanEntityList();

  setUpAll(() {
    registerFallbackValue(MaintenancePlanFactory.makeMaintenancePlanEntity());
  });

  setUp(() {
    mockGetActiveCompanyId = MockGetActiveCompanyIdUseCase();
    mockGetMaintenancePlans = MockGetMaintenancePlansUseCase();
    mockGetMaintenancePlanById = MockGetMaintenancePlanByIdUseCase();
    mockCreateMaintenancePlan = MockCreateMaintenancePlanUseCase();
    mockUpdateMaintenancePlan = MockUpdateMaintenancePlanUseCase();
    mockDeleteMaintenancePlan = MockDeleteMaintenancePlanUseCase();
    mockCalculateNextDueDate = MockCalculateNextDueDateUseCase();
    mockGenerateMaintenancePlanWorkOrder =
        MockGenerateMaintenancePlanWorkOrderUseCase();
    mockNavigationClient = MockNavigationClient();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    when(() => mockGetActiveCompanyId.call()).thenReturn(tCompanyId);

    useCases = MaintenancePlansCubitUseCases(
      getActiveCompanyId: mockGetActiveCompanyId,
      getMaintenancePlans: mockGetMaintenancePlans,
      getMaintenancePlanById: mockGetMaintenancePlanById,
      createMaintenancePlan: mockCreateMaintenancePlan,
      updateMaintenancePlan: mockUpdateMaintenancePlan,
      deleteMaintenancePlan: mockDeleteMaintenancePlan,
      calculateNextDueDate: mockCalculateNextDueDate,
      generateMaintenancePlanWorkOrder: mockGenerateMaintenancePlanWorkOrder,
    );

    cubit = MaintenancePlansCubit(useCases: useCases);
  });

  tearDown(GetIt.I.reset);

  group('MaintenancePlansCubit Tests', () {
    test('initial state has empty plans and no selection', () {
      expect(cubit.state.maintenancePlans, isEmpty);
      expect(cubit.state.selectedMaintenancePlan, isNull);
      expect(cubit.state.activePlans, isEmpty);
      expect(cubit.state.plansWithErrors, isEmpty);
    });

    group('loadMaintenancePlans', () {
      blocTest<MaintenancePlansCubit, MaintenancePlansState>(
        'should emit running and success section states when loading succeeds',
        build: () {
          when(
            () => mockGetMaintenancePlans.call(tCompanyId),
          ).thenAnswer((_) async => SuccessState(data: tPlans));
          return cubit;
        },
        act: (c) => c.loadMaintenancePlans(),
        expect: () => [
          isA<MaintenancePlansState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.running(),
          ),
          isA<MaintenancePlansState>()
              .having(
                (s) => s.sections[BaseSections.load],
                'sections[load]',
                const SectionState.success(),
              )
              .having((s) => s.maintenancePlans, 'maintenancePlans', tPlans),
        ],
        verify: (_) {
          verify(() => mockGetMaintenancePlans.call(tCompanyId)).called(1);
        },
      );

      blocTest<MaintenancePlansCubit, MaintenancePlansState>(
        'should emit running and error section states when loading fails',
        build: () {
          when(
            () => mockGetMaintenancePlans.call(tCompanyId),
          ).thenAnswer((_) async => FailureState(message: 'Error loading'));
          return cubit;
        },
        act: (c) => c.loadMaintenancePlans(),
        expect: () => [
          isA<MaintenancePlansState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.running(),
          ),
          isA<MaintenancePlansState>().having(
            (s) => s.sections[BaseSections.load],
            'sections[load]',
            const SectionState.error('Error loading'),
          ),
        ],
      );
    });

    group('selectMaintenancePlan', () {
      blocTest<MaintenancePlansCubit, MaintenancePlansState>(
        'should select plan when valid id is passed',
        seed: () => MaintenancePlansState(maintenancePlans: tPlans),
        build: () => cubit,
        act: (c) => c.selectMaintenancePlan(tPlans.first.id),
        expect: () => [
          isA<MaintenancePlansState>().having(
            (s) => s.selectedMaintenancePlan,
            'selectedMaintenancePlan',
            tPlans.first,
          ),
        ],
      );

      blocTest<MaintenancePlansCubit, MaintenancePlansState>(
        'should clear selected plan when null is passed',
        seed: () => MaintenancePlansState(
          maintenancePlans: tPlans,
          selectedMaintenancePlan: tPlans.first,
        ),
        build: () => cubit,
        act: (c) => c.selectMaintenancePlan(null),
        expect: () => [
          isA<MaintenancePlansState>().having(
            (s) => s.selectedMaintenancePlan,
            'selectedMaintenancePlan',
            isNull,
          ),
        ],
      );
    });

    group('saveMaintenancePlan', () {
      blocTest<MaintenancePlansCubit, MaintenancePlansState>(
        'should call createMaintenancePlan and reload when plan is new',
        build: () {
          when(
            () => mockCreateMaintenancePlan.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetMaintenancePlans.call(tCompanyId),
          ).thenAnswer((_) async => SuccessState(data: [tPlan]));
          return cubit;
        },
        act: (c) => c.saveMaintenancePlan(tPlan),
        expect: () => [
          isA<MaintenancePlansState>().having(
            (s) => s.sections[MaintenancePlansSections.save],
            'sections[save]',
            const SectionState.running(),
          ),
          isA<MaintenancePlansState>().having(
            (s) => s.sections[MaintenancePlansSections.save],
            'sections[save]',
            const SectionState.success(),
          ),
          isA<MaintenancePlansState>()
              .having(
                (s) => s.sections[BaseSections.load],
                'sections[load]',
                const SectionState.success(),
              )
              .having((s) => s.maintenancePlans, 'maintenancePlans', [tPlan]),
        ],
        verify: (_) {
          verify(() => mockCreateMaintenancePlan.call(tPlan)).called(1);
          verify(() => mockGetMaintenancePlans.call(tCompanyId)).called(1);
        },
      );

      blocTest<MaintenancePlansCubit, MaintenancePlansState>(
        'should call updateMaintenancePlan and reload when plan exists',
        seed: () => MaintenancePlansState(maintenancePlans: [tPlan]),
        build: () {
          when(
            () => mockUpdateMaintenancePlan.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetMaintenancePlans.call(tCompanyId),
          ).thenAnswer((_) async => SuccessState(data: [tPlan]));
          return cubit;
        },
        act: (c) => c.saveMaintenancePlan(tPlan),
        expect: () => [
          isA<MaintenancePlansState>().having(
            (s) => s.sections[MaintenancePlansSections.save],
            'sections[save]',
            const SectionState.running(),
          ),
          isA<MaintenancePlansState>().having(
            (s) => s.sections[MaintenancePlansSections.save],
            'sections[save]',
            const SectionState.success(),
          ),
          isA<MaintenancePlansState>()
              .having(
                (s) => s.sections[BaseSections.load],
                'sections[load]',
                const SectionState.success(),
              )
              .having((s) => s.maintenancePlans, 'maintenancePlans', [tPlan]),
        ],
        verify: (_) {
          verify(() => mockUpdateMaintenancePlan.call(tPlan)).called(1);
          verify(() => mockGetMaintenancePlans.call(tCompanyId)).called(1);
        },
      );

      blocTest<MaintenancePlansCubit, MaintenancePlansState>(
        'should emit error when save fails',
        build: () {
          when(
            () => mockCreateMaintenancePlan.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Save failed'));
          return cubit;
        },
        act: (c) => c.saveMaintenancePlan(tPlan),
        expect: () => [
          isA<MaintenancePlansState>().having(
            (s) => s.sections[MaintenancePlansSections.save],
            'sections[save]',
            const SectionState.running(),
          ),
          isA<MaintenancePlansState>().having(
            (s) => s.sections[MaintenancePlansSections.save],
            'sections[save]',
            const SectionState.error('Save failed'),
          ),
        ],
      );

      blocTest<MaintenancePlansCubit, MaintenancePlansState>(
        'should emit error without calling use cases when locationId is null',
        build: () => cubit,
        act: (c) =>
            c.saveMaintenancePlan(tPlan.copyWith(annulLocationId: true)),
        expect: () => [
          isA<MaintenancePlansState>().having(
            (s) => s.sections[MaintenancePlansSections.save],
            'sections[save]',
            const SectionState.error('Selecione um LOCAL para o plano'),
          ),
        ],
        verify: (_) {
          verifyNever(() => mockCreateMaintenancePlan.call(any()));
          verifyNever(() => mockUpdateMaintenancePlan.call(any()));
        },
      );
    });

    group('toggleActive', () {
      blocTest<MaintenancePlansCubit, MaintenancePlansState>(
        'should toggle isActive property and call updateMaintenancePlan',
        build: () {
          when(
            () => mockUpdateMaintenancePlan.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(() => mockGetMaintenancePlans.call(tCompanyId)).thenAnswer(
            (_) async => SuccessState(data: [tPlan.copyWith(isActive: false)]),
          );
          return cubit;
        },
        act: (c) => c.toggleActive(tPlan),
        expect: () => [
          isA<MaintenancePlansState>().having(
            (s) => s.sections[MaintenancePlansSections.toggleActive],
            'sections[toggleActive]',
            const SectionState.running(),
          ),
          isA<MaintenancePlansState>().having(
            (s) => s.sections[MaintenancePlansSections.toggleActive],
            'sections[toggleActive]',
            const SectionState.success(),
          ),
          isA<MaintenancePlansState>()
              .having(
                (s) => s.sections[BaseSections.load],
                'sections[load]',
                const SectionState.success(),
              )
              .having(
                (s) => s.maintenancePlans.first.isActive,
                'isActive',
                false,
              ),
        ],
        verify: (_) {
          verify(
            () => mockUpdateMaintenancePlan.call(
              any(
                that: isA<MaintenancePlanEntity>().having(
                  (p) => p.isActive,
                  'isActive',
                  !tPlan.isActive,
                ),
              ),
            ),
          ).called(1);
        },
      );

      blocTest<MaintenancePlansCubit, MaintenancePlansState>(
        'should emit error when toggleActive fails',
        build: () {
          when(
            () => mockUpdateMaintenancePlan.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Toggle failed'));
          return cubit;
        },
        act: (c) => c.toggleActive(tPlan),
        expect: () => [
          isA<MaintenancePlansState>().having(
            (s) => s.sections[MaintenancePlansSections.toggleActive],
            'sections[toggleActive]',
            const SectionState.running(),
          ),
          isA<MaintenancePlansState>().having(
            (s) => s.sections[MaintenancePlansSections.toggleActive],
            'sections[toggleActive]',
            const SectionState.error('Toggle failed'),
          ),
        ],
      );
    });

    group('deleteMaintenancePlan', () {
      blocTest<MaintenancePlansCubit, MaintenancePlansState>(
        'should delete plan and reload plans on success',
        seed: () => MaintenancePlansState(
          maintenancePlans: [tPlan],
          selectedMaintenancePlan: tPlan,
        ),
        build: () {
          when(
            () => mockDeleteMaintenancePlan.call(tPlan.id),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetMaintenancePlans.call(tCompanyId),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (c) => c.deleteMaintenancePlan(tPlan.id),
        expect: () => [
          isA<MaintenancePlansState>().having(
            (s) => s.sections[MaintenancePlansSections.delete],
            'sections[delete]',
            const SectionState.running(),
          ),
          isA<MaintenancePlansState>()
              .having(
                (s) => s.sections[MaintenancePlansSections.delete],
                'sections[delete]',
                const SectionState.success(),
              )
              .having(
                (s) => s.selectedMaintenancePlan,
                'selectedMaintenancePlan',
                isNull,
              )
              .having((s) => s.maintenancePlans, 'maintenancePlans', isEmpty),
          isA<MaintenancePlansState>()
              .having(
                (s) => s.sections[BaseSections.load],
                'sections[load]',
                const SectionState.success(),
              )
              .having((s) => s.maintenancePlans, 'maintenancePlans', isEmpty),
        ],
        verify: (_) {
          verify(() => mockDeleteMaintenancePlan.call(tPlan.id)).called(1);
          verify(() => mockGetMaintenancePlans.call(tCompanyId)).called(1);
        },
      );

      blocTest<MaintenancePlansCubit, MaintenancePlansState>(
        'should emit error when deletion fails',
        build: () {
          when(
            () => mockDeleteMaintenancePlan.call(tPlan.id),
          ).thenAnswer((_) async => FailureState(message: 'Delete failed'));
          return cubit;
        },
        act: (c) => c.deleteMaintenancePlan(tPlan.id),
        expect: () => [
          isA<MaintenancePlansState>().having(
            (s) => s.sections[MaintenancePlansSections.delete],
            'sections[delete]',
            const SectionState.running(),
          ),
          isA<MaintenancePlansState>().having(
            (s) => s.sections[MaintenancePlansSections.delete],
            'sections[delete]',
            const SectionState.error('Delete failed'),
          ),
        ],
      );
    });

    group('generateWorkOrder', () {
      final tWoId = faker.guid.guid();

      blocTest<MaintenancePlansCubit, MaintenancePlansState>(
        'should emit running and success when generateWorkOrder succeeds',
        build: () {
          when(
            () => mockGenerateMaintenancePlanWorkOrder.call(tPlan.id),
          ).thenAnswer((_) async => SuccessState(data: tWoId));
          when(
            () => mockGetMaintenancePlans.call(tCompanyId),
          ).thenAnswer((_) async => SuccessState(data: [tPlan]));
          return cubit;
        },
        act: (c) => c.generateWorkOrder(tPlan.id),
        expect: () => [
          isA<MaintenancePlansState>().having(
            (s) => s.sections[MaintenancePlansSections.generateWorkOrder],
            'sections[generateWorkOrder]',
            const SectionState.running(),
          ),
          isA<MaintenancePlansState>().having(
            (s) => s.sections[MaintenancePlansSections.generateWorkOrder],
            'sections[generateWorkOrder]',
            const SectionState.success(),
          ),
          isA<MaintenancePlansState>()
              .having(
                (s) => s.sections[BaseSections.load],
                'sections[load]',
                const SectionState.success(),
              )
              .having((s) => s.maintenancePlans, 'maintenancePlans', [tPlan]),
        ],
        verify: (_) {
          verify(
            () => mockGenerateMaintenancePlanWorkOrder.call(tPlan.id),
          ).called(1);
          verify(() => mockGetMaintenancePlans.call(tCompanyId)).called(1);
        },
      );

      blocTest<MaintenancePlansCubit, MaintenancePlansState>(
        'should emit error when generateWorkOrder fails',
        build: () {
          when(
            () => mockGenerateMaintenancePlanWorkOrder.call(tPlan.id),
          ).thenAnswer((_) async => FailureState(message: 'Generate failed'));
          return cubit;
        },
        act: (c) => c.generateWorkOrder(tPlan.id),
        expect: () => [
          isA<MaintenancePlansState>().having(
            (s) => s.sections[MaintenancePlansSections.generateWorkOrder],
            'sections[generateWorkOrder]',
            const SectionState.running(),
          ),
          isA<MaintenancePlansState>().having(
            (s) => s.sections[MaintenancePlansSections.generateWorkOrder],
            'sections[generateWorkOrder]',
            const SectionState.error('Generate failed'),
          ),
        ],
      );
    });

    group('filter getters', () {
      test('activePlans and plansWithErrors compute correctly', () {
        final activePlan = tPlan.copyWith(isActive: true, annulLastError: true);
        final inactivePlan = tPlan.copyWith(
          isActive: false,
          lastError: 'Failed generation',
        );

        final state = MaintenancePlansState(
          maintenancePlans: [activePlan, inactivePlan],
        );

        expect(state.activePlans, [activePlan]);
        expect(state.plansWithErrors, [inactivePlan]);
      });
    });

    group('VAL-047 & VAL-048 regression tests', () {
      blocTest<MaintenancePlansCubit, MaintenancePlansState>(
        'VAL-047: rejects whitespace-only title without invoking create use case',
        build: () {
          when(
            () => mockGetMaintenancePlans.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          when(
            () => mockCreateMaintenancePlan.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          return cubit;
        },
        act: (c) async {
          final result = await c.saveMaintenancePlan(
            tPlan.copyWith(title: '   '),
          );
          expect(result, isFalse);
        },
        expect: () => [
          isA<MaintenancePlansState>().having(
            (s) => s.sections[MaintenancePlansSections.save],
            'save section',
            const SectionState.error(),
          ),
        ],
        verify: (_) {
          verifyNever(() => mockCreateMaintenancePlan.call(any()));
        },
      );

      blocTest<MaintenancePlansCubit, MaintenancePlansState>(
        'VAL-048: rejects non-positive intervalValue or negative leadTimeDays without invoking create use case',
        build: () {
          when(
            () => mockGetMaintenancePlans.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          when(
            () => mockCreateMaintenancePlan.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          return cubit;
        },
        act: (c) async {
          final result = await c.saveMaintenancePlan(
            tPlan.copyWith(intervalValue: 0, leadTimeDays: -1),
          );
          expect(result, isFalse);
        },
        expect: () => [
          isA<MaintenancePlansState>().having(
            (s) => s.sections[MaintenancePlansSections.save],
            'save section',
            const SectionState.error(),
          ),
        ],
        verify: (_) {
          verifyNever(() => mockCreateMaintenancePlan.call(any()));
        },
      );
    });
  });
}
