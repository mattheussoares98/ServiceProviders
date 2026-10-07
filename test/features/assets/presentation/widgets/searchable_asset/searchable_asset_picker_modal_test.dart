import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_entity.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/widgets/searchable_asset/searchable_asset_picker_modal.dart';

import '../../../../../../testing/mocks/factories/asset_factory.dart';

void main() {
  Widget buildWidget({
    required List<AssetEntity> assets,
    String? selectedAssetId,
    String? selectedCustomerId,
    ValueChanged<AssetEntity?>? onSelected,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SearchableAssetPickerModal(
          assets: assets,
          selectedAssetId: selectedAssetId,
          selectedCustomerId: selectedCustomerId,
          onSelected: onSelected,
        ),
      ),
    );
  }

  testWidgets(
    'renders grouped sections (Equipamentos do Cliente and Equipamentos Gerais) when selectedCustomerId is provided',
    (tester) async {
      final customerAsset = AssetFactory.makeAssetEntity().copyWith(
        id: 'asset-cust-1',
        name: 'Torno CNC Cliente',
        customerId: 'cust-1',
      );
      final genericAsset = AssetFactory.makeAssetEntity().copyWith(
        id: 'asset-gen-1',
        name: 'Gerador Geral',
        annulCustomerId: true,
      );
      final otherCustomerAsset = AssetFactory.makeAssetEntity().copyWith(
        id: 'asset-cust-2',
        name: 'Prensa Outro Cliente',
        customerId: 'cust-2',
      );

      await tester.pumpWidget(
        buildWidget(
          assets: [customerAsset, genericAsset, otherCustomerAsset],
          selectedCustomerId: 'cust-1',
        ),
      );

      expect(find.text('Equipamentos do Cliente'), findsOneWidget);
      expect(find.text('Torno CNC Cliente'), findsOneWidget);

      expect(find.text('Equipamentos Gerais'), findsOneWidget);
      expect(find.text('Gerador Geral'), findsOneWidget);

      expect(find.text('Prensa Outro Cliente'), findsNothing);
    },
  );

  testWidgets(
    'renders empty message under customer section when customer has no specific assets',
    (tester) async {
      final genericAsset = AssetFactory.makeAssetEntity().copyWith(
        id: 'asset-gen-1',
        name: 'Gerador Geral',
        annulCustomerId: true,
      );

      await tester.pumpWidget(
        buildWidget(assets: [genericAsset], selectedCustomerId: 'cust-1'),
      );

      expect(find.text('Equipamentos do Cliente'), findsOneWidget);
      expect(
        find.text('Nenhum equipamento específico para este cliente'),
        findsOneWidget,
      );
      expect(find.text('Equipamentos Gerais'), findsOneWidget);
      expect(find.text('Gerador Geral'), findsOneWidget);
    },
  );

  testWidgets(
    'renders only Equipamentos Gerais when selectedCustomerId is null and all assets are generic',
    (tester) async {
      final genericAsset1 = AssetFactory.makeAssetEntity().copyWith(
        id: 'asset-gen-1',
        name: 'Gerador 1',
        annulCustomerId: true,
      );
      final genericAsset2 = AssetFactory.makeAssetEntity().copyWith(
        id: 'asset-gen-2',
        name: 'Compressor 2',
        annulCustomerId: true,
      );

      await tester.pumpWidget(
        buildWidget(assets: [genericAsset1, genericAsset2]),
      );

      expect(find.text('Equipamentos do Cliente'), findsNothing);
      expect(find.text('Equipamentos Gerais'), findsOneWidget);
      expect(find.text('Gerador 1'), findsOneWidget);
      expect(find.text('Compressor 2'), findsOneWidget);
    },
  );

  testWidgets(
    'filters assets in real-time across name, code, model, and manufacturer',
    (tester) async {
      final asset1 = AssetFactory.makeAssetEntity().copyWith(
        id: 'a1',
        name: 'Compressor Parafuso',
        code: 'CMP-99',
        model: 'Atlas-100',
        manufacturer: 'Atlas Copco',
        annulCustomerId: true,
      );
      final asset2 = AssetFactory.makeAssetEntity().copyWith(
        id: 'a2',
        name: 'Bomba Centrífuga',
        code: 'BMB-50',
        model: 'Vortex-Pro',
        manufacturer: 'Schneider',
        annulCustomerId: true,
      );

      await tester.pumpWidget(buildWidget(assets: [asset1, asset2]));

      expect(find.text('Compressor Parafuso'), findsOneWidget);
      expect(find.text('Bomba Centrífuga'), findsOneWidget);

      final searchFieldFinder = find.byKey(
        const ValueKey('SearchableAssetPickerSearchField'),
      );

      // Search by code
      await tester.enterText(searchFieldFinder, 'CMP-99');
      await tester.pump();
      expect(find.text('Compressor Parafuso'), findsOneWidget);
      expect(find.text('Bomba Centrífuga'), findsNothing);

      // Search by manufacturer
      await tester.enterText(searchFieldFinder, 'Schneider');
      await tester.pump();
      expect(find.text('Compressor Parafuso'), findsNothing);
      expect(find.text('Bomba Centrífuga'), findsOneWidget);

      // Search by model
      await tester.enterText(searchFieldFinder, 'Atlas-100');
      await tester.pump();
      expect(find.text('Compressor Parafuso'), findsOneWidget);
      expect(find.text('Bomba Centrífuga'), findsNothing);

      // Search nonexistent
      await tester.enterText(searchFieldFinder, 'XYZ999');
      await tester.pump();
      expect(find.text('Compressor Parafuso'), findsNothing);
      expect(find.text('Bomba Centrífuga'), findsNothing);
      expect(find.text('Nenhum equipamento encontrado'), findsOneWidget);
    },
  );

  testWidgets(
    'clear selection button triggers onSelected(null) when selectedAssetId is provided',
    (tester) async {
      final asset1 = AssetFactory.makeAssetEntity().copyWith(
        id: 'a1',
        name: 'Compressor 1',
        annulCustomerId: true,
      );

      AssetEntity? selectedResult;
      var onSelectedCalled = false;

      await tester.pumpWidget(
        buildWidget(
          assets: [asset1],
          selectedAssetId: 'a1',
          onSelected: (asset) {
            onSelectedCalled = true;
            selectedResult = asset;
          },
        ),
      );

      final clearButtonFinder = find.byKey(
        const ValueKey('SearchableAssetPickerClearButton'),
      );
      expect(clearButtonFinder, findsOneWidget);

      await tester.tap(clearButtonFinder);
      await tester.pump();

      expect(onSelectedCalled, isTrue);
      expect(selectedResult, isNull);
    },
  );

  testWidgets(
    'clear selection button is disabled when selectedAssetId is null',
    (tester) async {
      final asset1 = AssetFactory.makeAssetEntity().copyWith(
        id: 'a1',
        name: 'Compressor 1',
        annulCustomerId: true,
      );

      var onSelectedCalled = false;

      await tester.pumpWidget(
        buildWidget(
          assets: [asset1],
          onSelected: (_) => onSelectedCalled = true,
        ),
      );

      final clearButtonFinder = find.byKey(
        const ValueKey('SearchableAssetPickerClearButton'),
      );
      await tester.tap(clearButtonFinder);
      await tester.pump();

      expect(onSelectedCalled, isFalse);
    },
  );

  testWidgets('tapping an asset invokes onSelected with that asset', (
    tester,
  ) async {
    final asset1 = AssetFactory.makeAssetEntity().copyWith(
      id: 'a1',
      name: 'Compressor 1',
      annulCustomerId: true,
    );

    AssetEntity? selectedResult;

    await tester.pumpWidget(
      buildWidget(
        assets: [asset1],
        onSelected: (asset) => selectedResult = asset,
      ),
    );

    final tileFinder = find.byKey(const ValueKey('AssetTile_a1'));
    expect(tileFinder, findsOneWidget);

    await tester.tap(tileFinder);
    await tester.pump();

    expect(selectedResult, equals(asset1));
  });

  testWidgets('renders large list of 100+ items without layout errors', (
    tester,
  ) async {
    final largeAssetList = List<AssetEntity>.generate(
      120,
      (i) => AssetFactory.makeAssetEntity().copyWith(
        id: 'asset-$i',
        name: 'Equipamento $i',
        annulCustomerId: true,
      ),
    );

    await tester.pumpWidget(buildWidget(assets: largeAssetList));

    expect(find.text('Equipamentos Gerais'), findsOneWidget);
    expect(find.text('Equipamento 0'), findsOneWidget);
  });
}
