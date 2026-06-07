import 'package:clean_architecture/core/clients/local/drift/app_database.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/attachments/data/data_sources/attachments_local_data_source.dart';
import 'package:clean_architecture/features/attachments/data/models/responses/attachment_response_model.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late AppDatabase database;
  late AttachmentsLocalDataSourceImpl dataSource;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = AttachmentsLocalDataSourceImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> insertDependencies({
    required String companyId,
    required String userId,
    required String locationId,
    required String areaId,
    required String assetId,
    required String workOrderId,
  }) async {
    // 1. Company
    await database.into(database.companies).insert(
          CompaniesCompanion.insert(
            id: companyId,
            name: faker.company.name(),
            isActive: const Value(true),
          ),
        );

    // 2. UserProfile
    await database.into(database.userProfiles).insert(
          UserProfilesCompanion.insert(
            id: userId,
            companyId: companyId,
            name: faker.person.name(),
            email: faker.internet.email(),
            isActive: const Value(true),
          ),
        );

    // 3. Location
    await database.into(database.locations).insert(
          LocationsCompanion.insert(
            id: locationId,
            companyId: companyId,
            name: faker.company.name(),
            isActive: const Value(true),
          ),
        );

    // 4. Area
    await database.into(database.areas).insert(
          AreasCompanion.insert(
            id: areaId,
            locationId: locationId,
            companyId: companyId,
            name: faker.company.name(),
          ),
        );

    // 5. Asset
    await database.into(database.assets).insert(
          AssetsCompanion.insert(
            id: assetId,
            companyId: companyId,
            areaId: areaId,
            name: faker.company.name(),
          ),
        );

    // 6. WorkOrder
    await database.into(database.workOrders).insert(
          WorkOrdersCompanion.insert(
            id: workOrderId,
            companyId: companyId,
            assetId: Value(assetId),
            locationId: locationId,
            createdById: userId,
            title: faker.company.name(),
            priority: const Value('medium'),
            status: const Value('open'),
            type: const Value('corrective'),
          ),
        );
  }

  final tAttachmentEntity = EntityFactory.makeAttachmentEntity();
  final tAttachmentModel = AttachmentResponseModel.fromEntity(tAttachmentEntity);

  group('AttachmentsLocalDataSourceImpl', () {
    test('should save an attachment and successfully retrieve it', () async {
      // Arrange
      await insertDependencies(
        companyId: tAttachmentModel.companyId,
        userId: tAttachmentModel.uploadedById,
        locationId: faker.guid.guid(),
        areaId: faker.guid.guid(),
        assetId: faker.guid.guid(),
        workOrderId: tAttachmentModel.workOrderId,
      );

      // Act: Save
      final saveResult = await dataSource.saveAttachment(tAttachmentModel);

      // Assert Save
      expect(saveResult, isA<SuccessState<bool>>());
      expect(saveResult.data, isTrue);

      // Act: Get
      final getResult = await dataSource.getAttachmentsByWorkOrder(tAttachmentModel.workOrderId);

      // Assert Get List
      expect(getResult, isA<SuccessState<List<AttachmentResponseModel>>>());
      expect(getResult.data, hasLength(1));
      expect(getResult.data!.first, equals(tAttachmentModel));
    });

    test('should soft-delete an attachment and verify it is not returned', () async {
      // Arrange
      await insertDependencies(
        companyId: tAttachmentModel.companyId,
        userId: tAttachmentModel.uploadedById,
        locationId: faker.guid.guid(),
        areaId: faker.guid.guid(),
        assetId: faker.guid.guid(),
        workOrderId: tAttachmentModel.workOrderId,
      );
      await dataSource.saveAttachment(tAttachmentModel);

      // Act: Delete
      final deleteResult = await dataSource.deleteAttachment(tAttachmentModel.id);

      // Assert Delete
      expect(deleteResult, isA<SuccessState<bool>>());
      expect(deleteResult.data, isTrue);

      // Act: Get
      final getResult = await dataSource.getAttachmentsByWorkOrder(tAttachmentModel.workOrderId);

      // Assert Get: Should be empty
      expect(getResult, isA<SuccessState<List<AttachmentResponseModel>>>());
      expect(getResult.data, isEmpty);
    });
  });
}
