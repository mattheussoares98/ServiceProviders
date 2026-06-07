import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/attachments/data/models/responses/attachment_response_model.dart';
import 'package:clean_architecture/features/attachments/data/repositories/attachments_repository_impl.dart';
import 'package:clean_architecture/features/attachments/domain/entities/attachment_entity.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockInternetClient mockInternet;
  late MockAttachmentsRemoteDataSource mockRemoteDataSource;
  late MockAttachmentsLocalDataSource mockLocalDataSource;
  late AttachmentsRepositoryImpl repository;

  setUp(() {
    mockInternet = MockInternetClient();
    mockRemoteDataSource = MockAttachmentsRemoteDataSource();
    mockLocalDataSource = MockAttachmentsLocalDataSource();
    repository = AttachmentsRepositoryImpl(
      internet: mockInternet,
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );

    registerFallbackValue(
      AttachmentResponseModel.fromEntity(
        EntityFactory.makeAttachmentEntity(),
      ),
    );
  });

  final tAttachmentEntity = EntityFactory.makeAttachmentEntity();
  final tAttachmentModel = AttachmentResponseModel.fromEntity(tAttachmentEntity);
  final tAttachmentEntityList = EntityFactory.makeAttachmentEntityList();
  final tAttachmentModelList = tAttachmentEntityList
      .map((e) => AttachmentResponseModel.fromEntity(e))
      .toList();

  group('AttachmentsRepositoryImpl', () {
    test('getAttachmentsByWorkOrder should return list of attachments from local data source', () async {
      // Arrange
      final workOrderId = faker.guid.guid();
      when(() => mockLocalDataSource.getAttachmentsByWorkOrder(any()))
          .thenAnswer((_) async => SuccessState(data: tAttachmentModelList));

      // Act
      final result = await repository.getAttachmentsByWorkOrder(workOrderId);

      // Assert
      expect(result, isA<SuccessState<List<AttachmentEntity>>>());
      expect(result.data, equals(tAttachmentEntityList));
      verify(() => mockLocalDataSource.getAttachmentsByWorkOrder(workOrderId)).called(1);
    });

    test('createAttachment should return true when local save is successful', () async {
      // Arrange
      when(() => mockLocalDataSource.saveAttachment(any()))
          .thenAnswer((_) async => const SuccessState(data: true));

      // Act
      final result = await repository.createAttachment(tAttachmentEntity);

      // Assert
      expect(result, isA<SuccessState<bool>>());
      expect(result.data, isTrue);
      verify(() => mockLocalDataSource.saveAttachment(tAttachmentModel)).called(1);
    });

    test('deleteAttachment should return true when local delete is successful', () async {
      // Arrange
      final id = faker.guid.guid();
      when(() => mockLocalDataSource.deleteAttachment(any()))
          .thenAnswer((_) async => const SuccessState(data: true));

      // Act
      final result = await repository.deleteAttachment(id);

      // Assert
      expect(result, isA<SuccessState<bool>>());
      expect(result.data, isTrue);
      verify(() => mockLocalDataSource.deleteAttachment(id)).called(1);
    });
  });
}
