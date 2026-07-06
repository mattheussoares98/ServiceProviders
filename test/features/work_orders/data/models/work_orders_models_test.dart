import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/requests/task_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/requests/work_order_change_request_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/requests/work_order_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/task_response_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_change_request_response_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_history_response_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_response_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/task_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_change_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_history_entity.dart';

import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  group('WorkOrderRequestModel & WorkOrderResponseModel', () {
    final tEntity = EntityFactory.makeWorkOrderEntity();

    test('should be a subclass of WorkOrderEntity', () {
      final requestModel = WorkOrderRequestModel.fromEntity(tEntity);
      final responseModel = WorkOrderResponseModel.fromEntity(tEntity);
      expect(requestModel, isA<WorkOrderEntity>());
      expect(responseModel, isA<WorkOrderEntity>());
    });

    test('should map fromEntity, toJson, fromJson, and toEntity correctly', () {
      // fromEntity
      final requestModel = WorkOrderRequestModel.fromEntity(tEntity);
      final responseModel = WorkOrderResponseModel.fromEntity(tEntity);

      // toJson
      final requestJson = requestModel.toJson();
      final responseJson = responseModel.toJson();

      // fromJson
      final requestModelFromJson = WorkOrderRequestModel.fromJson(requestJson);
      final responseModelFromJson = WorkOrderResponseModel.fromJson(
        responseJson,
      );

      // toEntity
      expect(requestModelFromJson.toEntity(), tEntity);
      expect(responseModelFromJson.toEntity(), tEntity);
    });
  });

  group('TaskRequestModel & TaskResponseModel', () {
    final tEntity = EntityFactory.makeTaskEntity();

    test('should be a subclass of TaskEntity', () {
      final requestModel = TaskRequestModel.fromEntity(tEntity);
      final responseModel = TaskResponseModel.fromEntity(tEntity);
      expect(requestModel, isA<TaskEntity>());
      expect(responseModel, isA<TaskEntity>());
    });

    test('should map fromEntity, toJson, fromJson, and toEntity correctly', () {
      final requestModel = TaskRequestModel.fromEntity(tEntity);
      final responseModel = TaskResponseModel.fromEntity(tEntity);

      final requestJson = requestModel.toJson();
      final responseJson = responseModel.toJson();

      final requestModelFromJson = TaskRequestModel.fromJson(requestJson);
      final responseModelFromJson = TaskResponseModel.fromJson(responseJson);

      expect(requestModelFromJson.toEntity(), tEntity);
      expect(responseModelFromJson.toEntity(), tEntity);
    });
  });

  group(
    'WorkOrderChangeRequestRequestModel & WorkOrderChangeRequestResponseModel',
    () {
      final tEntity = EntityFactory.makeWorkOrderChangeRequestEntity();

      test('should be a subclass of WorkOrderChangeRequestEntity', () {
        final requestModel = WorkOrderChangeRequestRequestModel.fromEntity(
          tEntity,
        );
        final responseModel = WorkOrderChangeRequestResponseModel.fromEntity(
          tEntity,
        );
        expect(requestModel, isA<WorkOrderChangeRequestEntity>());
        expect(responseModel, isA<WorkOrderChangeRequestEntity>());
      });

      test(
        'should map fromEntity, toJson, fromJson, and toEntity correctly',
        () {
          final requestModel = WorkOrderChangeRequestRequestModel.fromEntity(
            tEntity,
          );
          final responseModel = WorkOrderChangeRequestResponseModel.fromEntity(
            tEntity,
          );

          final requestJson = requestModel.toJson();
          final responseJson = responseModel.toJson();

          final requestModelFromJson =
              WorkOrderChangeRequestRequestModel.fromJson(requestJson);
          final responseModelFromJson =
              WorkOrderChangeRequestResponseModel.fromJson(responseJson);

          expect(requestModelFromJson.toEntity(), tEntity);
          expect(responseModelFromJson.toEntity(), tEntity);
        },
      );
    },
  );

  group('WorkOrderHistoryResponseModel', () {
    final tEntity = EntityFactory.makeWorkOrderHistoryEntity();

    test('should be a subclass of WorkOrderHistoryEntity', () {
      final responseModel = WorkOrderHistoryResponseModel.fromEntity(tEntity);
      expect(responseModel, isA<WorkOrderHistoryEntity>());
    });

    test('should map fromEntity, toJson, fromJson, and toEntity correctly', () {
      final responseModel = WorkOrderHistoryResponseModel.fromEntity(tEntity);
      final responseJson = responseModel.toJson();
      final responseModelFromJson = WorkOrderHistoryResponseModel.fromJson(
        responseJson,
      );

      expect(responseModelFromJson.toEntity(), tEntity);
    });
  });
}
