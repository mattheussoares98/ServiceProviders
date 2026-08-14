import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/attachments/data/data_sources/attachments_local_data_source.dart';
import 'package:o_jogo_da_obra/features/attachments/data/models/responses/attachment_model.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/upload_status.dart';

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
    await database
        .into(database.companies)
        .insert(
          CompaniesCompanion.insert(
            id: companyId,
            name: faker.company.name(),
            isActive: const Value(true),
          ),
        );

    // 2. UserProfile
    await database
        .into(database.userProfiles)
        .insert(
          UserProfilesCompanion.insert(
            id: userId,
            companyId: companyId,
            name: faker.person.name(),
            email: faker.internet.email(),
            isActive: const Value(true),
          ),
        );

    // 3. Location
    await database
        .into(database.locations)
        .insert(
          LocationsCompanion.insert(
            id: locationId,
            companyId: companyId,
            name: faker.company.name(),
            isActive: const Value(true),
          ),
        );

    // 4. Area
    await database
        .into(database.areas)
        .insert(
          AreasCompanion.insert(
            id: areaId,
            locationId: locationId,
            companyId: companyId,
            name: faker.company.name(),
          ),
        );

    // 5. Asset
    await database
        .into(database.assets)
        .insert(
          AssetsCompanion.insert(
            id: assetId,
            companyId: companyId,
            areaId: areaId,
            name: faker.company.name(),
          ),
        );

    // 6. WorkOrder
    await database
        .into(database.workOrders)
        .insert(
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

  final tAttachmentEntity = EntityFactory.makeAttachmentEntity().copyWith(
    lastAccessedAt: DateTime.utc(2026),
  );
  final tAttachmentModel = AttachmentModel.fromEntity(tAttachmentEntity);

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
      final getResult = await dataSource.getAttachmentsByWorkOrder(
        tAttachmentModel.workOrderId,
      );

      // Assert Get List
      expect(getResult, isA<SuccessState<List<AttachmentModel>>>());
      expect(getResult.data, hasLength(1));
      expect(getResult.data!.first, equals(tAttachmentModel));
    });

    test(
      'should soft-delete an attachment and verify it is not returned',
      () async {
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
        final deleteResult = await dataSource.deleteAttachment(
          tAttachmentModel.id,
        );

        // Assert Delete
        expect(deleteResult, isA<SuccessState<bool>>());
        expect(deleteResult.data, isTrue);

        // Act: Get
        final getResult = await dataSource.getAttachmentsByWorkOrder(
          tAttachmentModel.workOrderId,
        );

        // Assert Get: Should be empty
        expect(getResult, isA<SuccessState<List<AttachmentModel>>>());
        expect(getResult.data, isEmpty);
      },
    );

    group('getAttachment', () {
      test('should return correct attachment when it exists', () async {
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

        // Act
        final result = await dataSource.getAttachment(tAttachmentModel.id);

        // Assert
        expect(result, isA<SuccessState<AttachmentModel?>>());
        expect(result.data, equals(tAttachmentModel));
      });

      test('should return null when attachment does not exist', () async {
        // Act
        final result = await dataSource.getAttachment(faker.guid.guid());

        // Assert
        expect(result, isA<SuccessState<AttachmentModel?>>());
        expect(result.data, null);
      });
    });

    group('Cache methods', () {
      test('touchLastAccessed should update the lastAccessedAt time', () async {
        await insertDependencies(
          companyId: tAttachmentModel.companyId,
          userId: tAttachmentModel.uploadedById,
          locationId: faker.guid.guid(),
          areaId: faker.guid.guid(),
          assetId: faker.guid.guid(),
          workOrderId: tAttachmentModel.workOrderId,
        );
        await dataSource.saveAttachment(tAttachmentModel);

        final result = await dataSource.touchLastAccessed(tAttachmentModel.id);
        expect(result, isA<SuccessState<void>>());

        final updated = await dataSource.getAttachment(tAttachmentModel.id);
        expect(updated.data?.lastAccessedAt, isNotNull);
      });

      test(
        'getTotalSandboxBytes should sum file sizes of attachments with localPath',
        () async {
          await insertDependencies(
            companyId: tAttachmentModel.companyId,
            userId: tAttachmentModel.uploadedById,
            locationId: faker.guid.guid(),
            areaId: faker.guid.guid(),
            assetId: faker.guid.guid(),
            workOrderId: tAttachmentModel.workOrderId,
          );

          final att1 = tAttachmentModel.copyWith(
            id: 'att1',
            localPath: 'path1.jpg',
            fileSizeBytes: 100,
          );
          final att2 = tAttachmentModel.copyWith(
            id: 'att2',
            localPath: 'path2.jpg',
            fileSizeBytes: 200,
          );
          final att3 = tAttachmentModel.copyWith(
            id: 'att3',
            annulLocalPath: true,
            fileSizeBytes: 300,
          ); // no localPath

          await dataSource.saveAttachment(AttachmentModel.fromEntity(att1));
          await dataSource.saveAttachment(AttachmentModel.fromEntity(att2));
          await dataSource.saveAttachment(AttachmentModel.fromEntity(att3));

          final sizeResult = await dataSource.getTotalSandboxBytes();
          expect(sizeResult, isA<SuccessState<int>>());
          expect(sizeResult.data, 300); // 100 + 200
        },
      );

      test(
        'getUploadedOrderedByLastAccess should only return uploaded attachments with localPath ordered by lastAccessedAt',
        () async {
          await insertDependencies(
            companyId: tAttachmentModel.companyId,
            userId: tAttachmentModel.uploadedById,
            locationId: faker.guid.guid(),
            areaId: faker.guid.guid(),
            assetId: faker.guid.guid(),
            workOrderId: tAttachmentModel.workOrderId,
          );

          final now = DateTime.now();
          final att1 = tAttachmentModel.copyWith(
            id: 'att1',
            localPath: 'path1.jpg',
            uploadStatus: UploadStatus.uploaded,
            lastAccessedAt: now.subtract(const Duration(minutes: 5)),
          );
          final att2 = tAttachmentModel.copyWith(
            id: 'att2',
            localPath: 'path2.jpg',
            uploadStatus: UploadStatus.uploaded,
            lastAccessedAt: now.subtract(const Duration(minutes: 10)), // oldest
          );
          final att3 = tAttachmentModel.copyWith(
            id: 'att3',
            localPath: 'path3.jpg',
            uploadStatus: UploadStatus.pending, // pending, should not return
            lastAccessedAt: now,
          );

          await dataSource.saveAttachment(AttachmentModel.fromEntity(att1));
          await dataSource.saveAttachment(AttachmentModel.fromEntity(att2));
          await dataSource.saveAttachment(AttachmentModel.fromEntity(att3));

          final listResult = await dataSource.getUploadedOrderedByLastAccess();
          expect(listResult, isA<SuccessState<List<AttachmentModel>>>());
          expect(listResult.data, hasLength(2));
          expect(listResult.data![0].id, 'att2'); // oldest accessed first
          expect(listResult.data![1].id, 'att1');
        },
      );
    });
  });
}
