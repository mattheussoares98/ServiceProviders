import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/requests/task_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/requests/work_order_change_request_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/task_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_change_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_history_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/task_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_change_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_history_entity.dart';

import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  group('WorkOrderModel & WorkOrderModel', () {
    final tEntity = EntityFactory.makeWorkOrderEntity();

    test('should be a subclass of WorkOrderEntity', () {
      final responseModel = WorkOrderModel.fromEntity(tEntity);
      expect(responseModel, isA<WorkOrderEntity>());
    });

    test('should map fromEntity, toJson, fromJson, and toEntity correctly', () {
      final responseModel = WorkOrderModel.fromEntity(tEntity);
      final responseJson = responseModel.toJson();
      final responseModelFromJson = WorkOrderModel.fromJson(responseJson);

      final resultEntity = responseModelFromJson.toEntity();
      expect(resultEntity.id, tEntity.id);
      expect(resultEntity.companyId, tEntity.companyId);
      expect(resultEntity.title, tEntity.title);
      expect(resultEntity.priority, tEntity.priority);
      expect(resultEntity.status, tEntity.status);
      expect(resultEntity.type, tEntity.type);
      expect(
        responseModelFromJson.serviceProviderCompanyId,
        tEntity.serviceProviderCompanyId,
      );
      expect(
        responseModelFromJson.providerProfileId,
        tEntity.providerProfileId,
      );
      expect(responseModelFromJson.openedBy, tEntity.openedBy);
      expect(resultEntity.advanceWarningSentAt, tEntity.advanceWarningSentAt);
      expect(resultEntity.lastEscalationLevel, tEntity.lastEscalationLevel);
      expect(resultEntity.lastEscalationAt, tEntity.lastEscalationAt);
    });
  });

  group('TaskRequestModel & TaskModel', () {
    final tEntity = EntityFactory.makeTaskEntity();

    test('should be a subclass of TaskEntity', () {
      final requestModel = TaskRequestModel.fromEntity(tEntity);
      final responseModel = TaskModel.fromEntity(tEntity);
      expect(requestModel, isA<TaskEntity>());
      expect(responseModel, isA<TaskEntity>());
    });

    test('should map fromEntity, toJson, fromJson, and toEntity correctly', () {
      final requestModel = TaskRequestModel.fromEntity(tEntity);
      final responseModel = TaskModel.fromEntity(tEntity);

      final requestJson = requestModel.toJson();
      final responseJson = responseModel.toJson();

      final requestModelFromJson = TaskRequestModel.fromJson(requestJson);
      final responseModelFromJson = TaskModel.fromJson(responseJson);

      expect(requestModelFromJson.toEntity(), tEntity);
      expect(responseModelFromJson.toEntity(), tEntity);
    });
  });

  group('WorkOrderChangeRequestRequestModel & WorkOrderChangeRequestModel', () {
    final tEntity = EntityFactory.makeWorkOrderChangeRequestEntity();

    test('should be a subclass of WorkOrderChangeRequestEntity', () {
      final requestModel = WorkOrderChangeRequestRequestModel.fromEntity(
        tEntity,
      );
      final responseModel = WorkOrderChangeRequestModel.fromEntity(tEntity);
      expect(requestModel, isA<WorkOrderChangeRequestEntity>());
      expect(responseModel, isA<WorkOrderChangeRequestEntity>());
    });

    test('should map fromEntity, toJson, fromJson, and toEntity correctly', () {
      final requestModel = WorkOrderChangeRequestRequestModel.fromEntity(
        tEntity,
      );
      final responseModel = WorkOrderChangeRequestModel.fromEntity(tEntity);

      final requestJson = requestModel.toJson();
      final responseJson = responseModel.toJson();

      final requestModelFromJson = WorkOrderChangeRequestRequestModel.fromJson(
        requestJson,
      );
      final responseModelFromJson = WorkOrderChangeRequestModel.fromJson(
        responseJson,
      );

      expect(requestModelFromJson.toEntity(), tEntity);
      expect(responseModelFromJson.toEntity(), tEntity);
    });
  });

  group('WorkOrderHistoryModel', () {
    final tEntity = EntityFactory.makeWorkOrderHistoryEntity();

    test('should be a subclass of WorkOrderHistoryEntity', () {
      final responseModel = WorkOrderHistoryModel.fromEntity(tEntity);
      expect(responseModel, isA<WorkOrderHistoryEntity>());
    });

    test('should map fromEntity, toJson, fromJson, and toEntity correctly', () {
      final responseModel = WorkOrderHistoryModel.fromEntity(tEntity);
      final responseJson = responseModel.toJson();
      final responseModelFromJson = WorkOrderHistoryModel.fromJson(
        responseJson,
      );

      expect(responseModelFromJson.toEntity(), tEntity);
    });
  });
}
