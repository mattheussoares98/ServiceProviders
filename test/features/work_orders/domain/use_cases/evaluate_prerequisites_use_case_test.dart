import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/work_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/prerequisite_step.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/evaluate_prerequisites_use_case.dart';

void main() {
  const useCase = EvaluatePrerequisitesUseCase();

  group('EvaluatePrerequisitesUseCase', () {
    group('internalOnly workType', () {
      test('when zero locations, requires location step as pending', () {
        final result = useCase(
          const EvaluatePrerequisitesParams(
            workType: WorkType.internalOnly,
            locationsCount: 0,
            areasCount: 0,
            customersCount: 0,
          ),
        );

        expect(result.steps.length, 3);
        expect(result.steps[0].type, PrerequisiteType.location);
        expect(result.steps[0].isCompleted, isFalse);
        expect(result.steps[0].isOptional, isFalse);

        expect(result.steps[1].type, PrerequisiteType.area);
        expect(result.steps[1].isCompleted, isFalse);
        expect(result.steps[1].isOptional, isTrue);

        expect(result.steps[2].type, PrerequisiteType.asset);
        expect(result.steps[2].isCompleted, isFalse);
        expect(result.steps[2].isOptional, isTrue);

        expect(result.hasPendingRequiredPrerequisites, isTrue);
        expect(result.allCompleted, isFalse);
        expect(result.nextPendingStep?.type, PrerequisiteType.location);
      });

      test('when location is present, required prerequisite is satisfied', () {
        final result = useCase(
          const EvaluatePrerequisitesParams(
            workType: WorkType.internalOnly,
            locationsCount: 1,
            areasCount: 0,
            customersCount: 0,
          ),
        );

        expect(result.steps[0].isCompleted, isTrue);
        expect(result.hasPendingRequiredPrerequisites, isFalse);
        expect(result.nextPendingStep?.type, PrerequisiteType.area);
      });

      test('when all are present, allCompleted is true', () {
        final result = useCase(
          const EvaluatePrerequisitesParams(
            workType: WorkType.internalOnly,
            locationsCount: 2,
            areasCount: 3,
            customersCount: 0,
            assetsCount: 5,
          ),
        );

        expect(result.steps.every((s) => s.isCompleted), isTrue);
        expect(result.allCompleted, isTrue);
        expect(result.hasPendingRequiredPrerequisites, isFalse);
        expect(result.nextPendingStep, isNull);
      });
    });

    group('serviceProviderOnly workType', () {
      test('when zero customers, requires customer step as pending', () {
        final result = useCase(
          const EvaluatePrerequisitesParams(
            workType: WorkType.serviceProviderOnly,
            locationsCount: 0,
            areasCount: 0,
            customersCount: 0,
          ),
        );

        expect(result.steps.length, 2);
        expect(result.steps[0].type, PrerequisiteType.customer);
        expect(result.steps[0].isCompleted, isFalse);
        expect(result.steps[0].isOptional, isFalse);

        expect(result.steps[1].type, PrerequisiteType.asset);
        expect(result.steps[1].isOptional, isTrue);

        expect(result.hasPendingRequiredPrerequisites, isTrue);
        expect(result.nextPendingStep?.type, PrerequisiteType.customer);
      });

      test('when customer is present, required prerequisite is satisfied', () {
        final result = useCase(
          const EvaluatePrerequisitesParams(
            workType: WorkType.serviceProviderOnly,
            locationsCount: 0,
            areasCount: 0,
            customersCount: 1,
          ),
        );

        expect(result.steps[0].isCompleted, isTrue);
        expect(result.hasPendingRequiredPrerequisites, isFalse);
        expect(result.nextPendingStep?.type, PrerequisiteType.asset);
      });
    });

    group('hybrid workType', () {
      test('when neither location nor customer exists, step 1 is pending', () {
        final result = useCase(
          const EvaluatePrerequisitesParams(
            workType: WorkType.hybrid,
            locationsCount: 0,
            areasCount: 0,
            customersCount: 0,
          ),
        );

        expect(result.steps.length, 3);
        expect(result.steps[0].isCompleted, isFalse);
        expect(result.steps[0].isOptional, isFalse);
        expect(result.hasPendingRequiredPrerequisites, isTrue);
      });

      test('when location is present, first step is satisfied', () {
        final result = useCase(
          const EvaluatePrerequisitesParams(
            workType: WorkType.hybrid,
            locationsCount: 1,
            areasCount: 0,
            customersCount: 0,
          ),
        );

        expect(result.steps[0].isCompleted, isTrue);
        expect(result.hasPendingRequiredPrerequisites, isFalse);
      });

      test('when customer is present, first step and customer step are satisfied', () {
        final result = useCase(
          const EvaluatePrerequisitesParams(
            workType: WorkType.hybrid,
            locationsCount: 0,
            areasCount: 0,
            customersCount: 1,
          ),
        );

        expect(result.steps[0].isCompleted, isTrue);
        expect(result.steps[1].isCompleted, isTrue);
        expect(result.hasPendingRequiredPrerequisites, isFalse);
      });
    });

    group('permissions reflection', () {
      test('reflects lack of permission on steps', () {
        final result = useCase(
          const EvaluatePrerequisitesParams(
            workType: WorkType.internalOnly,
            locationsCount: 0,
            areasCount: 0,
            customersCount: 0,
            hasLocationCreatePermission: false,
            hasAssetCreatePermission: false,
          ),
        );

        expect(result.steps[0].canPerformAction, isFalse);
        expect(result.steps[1].canPerformAction, isFalse);
        expect(result.steps[2].canPerformAction, isFalse);
      });
    });
  });
}
