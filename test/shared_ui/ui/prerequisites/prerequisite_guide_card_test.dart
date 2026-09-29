import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/prerequisite_step.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/prerequisites/prerequisite_guide_card.dart';

void main() {
  group('PrerequisiteGuideCard', () {
    testWidgets('renders all steps with completion status and optional badge', (
      tester,
    ) async {
      final steps = [
        const PrerequisiteStep(
          type: PrerequisiteType.location,
          title: 'Cadastrar local',
          description: 'Locais físicos para manutenção.',
          actionLabel: 'Cadastrar Local',
          isCompleted: true,
        ),
        const PrerequisiteStep(
          type: PrerequisiteType.area,
          title: 'Cadastrar área',
          description: 'Subdivisões do local.',
          actionLabel: 'Cadastrar Área',
          isCompleted: false,
          isOptional: true,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrerequisiteGuideCard(
              title: 'Primeiros passos',
              subtitle: 'Complete as etapas',
              steps: steps,
            ),
          ),
        ),
      );

      expect(find.text('Primeiros passos'), findsOneWidget);
      expect(find.text('Complete as etapas'), findsOneWidget);
      expect(find.text('Cadastrar local'), findsOneWidget);
      expect(find.text('Cadastrar área'), findsOneWidget);
      expect(find.text('Opcional'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.text('Cadastrar Área'), findsOneWidget);
    });

    testWidgets('renders locked badge when user cannot perform action', (
      tester,
    ) async {
      final steps = [
        const PrerequisiteStep(
          type: PrerequisiteType.location,
          title: 'Cadastrar local',
          description: 'Locais físicos para manutenção.',
          actionLabel: 'Cadastrar Local',
          isCompleted: false,
          canPerformAction: false,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrerequisiteGuideCard(
              steps: steps,
            ),
          ),
        ),
      );

      expect(
        find.text('Aguardando administrador cadastrar'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.text('Cadastrar Local'), findsNothing);
    });

    testWidgets('triggers onAction callback when action button is tapped', (
      tester,
    ) async {
      PrerequisiteType? tappedType;

      final steps = [
        const PrerequisiteStep(
          type: PrerequisiteType.customer,
          title: 'Cadastrar cliente',
          description: 'Clientes externos.',
          actionLabel: 'Cadastrar Cliente',
          isCompleted: false,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrerequisiteGuideCard(
              steps: steps,
              onAction: (type) => tappedType = type,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Cadastrar Cliente'));
      await tester.pump();

      expect(tappedType, PrerequisiteType.customer);
    });
  });
}
