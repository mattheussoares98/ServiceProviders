import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/data/models/responses/maintenance_plan_model.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/data/repositories/maintenance_plans_repository_impl.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/maintenance_plan_entity.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/factories/maintenance_plan_factory.dart';
import '../../../../../testing/mocks/factories/work_order_factory.dart';

void main() {
  late MockInternetClient internet;
  late MockMaintenancePlansRemoteDataSource remote;
  late MaintenancePlansRepositoryImpl repository;
  final plan = MaintenancePlanFactory.makeMaintenancePlanEntity();
  final model = MaintenancePlanModel.fromEntity(plan);
  final response = Response<dynamic>(
    requestOptions: RequestOptions(path: '/test'),
    statusCode: 403,
    data: {'code': '42501'},
  );
  setUpAll(() => registerFallbackValue(model));
  setUp(() {
    internet = MockInternetClient();
    remote = MockMaintenancePlansRemoteDataSource();
    repository = MaintenancePlansRepositoryImpl(
      internet: internet,
      remoteDataSource: remote,
    );
    when(() => internet.isConnected).thenReturn(true);
  });

  test(
    'manual generation returns the server ID and invokes the server once',
    () async {
      final orderId = WorkOrderFactory.makeWorkOrderEntity().id;
      when(
        () => remote.generateWorkOrder(plan.id),
      ).thenAnswer((_) async => SuccessState(data: orderId));
      final result = await repository.generateWorkOrder(plan.id);
      expect(result, isA<SuccessState<String>>());
      expect(result.data, orderId);
      verify(() => remote.generateWorkOrder(plan.id)).called(1);
      verifyNoMoreInteractions(remote);
    },
  );

  test(
    'generation failure preserves details without automatically retrying',
    () async {
      final failure = FailureState<String>(
        message: 'denied',
        error: '42501',
        statusCode: 403,
        response: response,
      );
      when(
        () => remote.generateWorkOrder(plan.id),
      ).thenAnswer((_) async => failure);
      expect(await repository.generateWorkOrder(plan.id), same(failure));
      verify(() => remote.generateWorkOrder(plan.id)).called(1);
      verifyNoMoreInteractions(remote);
    },
  );

  test('offline generation never calls the server', () async {
    when(() => internet.isConnected).thenReturn(false);
    expect(
      await repository.generateWorkOrder(plan.id),
      isA<FailureState<String>>(),
    );
    verifyZeroInteractions(remote);
  });

  test(
    'plan detail uses the exact requested ID and maps the response',
    () async {
      when(
        () => remote.getPlanById(plan.id),
      ).thenAnswer((_) async => SuccessState(data: model));
      final result = await repository.getMaintenancePlanById(plan.id);
      expect(result, isA<SuccessState<MaintenancePlanEntity>>());
      expect(result.data, plan);
      verify(() => remote.getPlanById(plan.id)).called(1);
    },
  );

  test(
    'offline plan detail fails without reading a stale local cache',
    () async {
      when(() => internet.isConnected).thenReturn(false);
      expect(
        await repository.getMaintenancePlanById(plan.id),
        isA<FailureState<MaintenancePlanEntity>>(),
      );
      verifyZeroInteractions(remote);
    },
  );

  test('plan detail preserves permission failure metadata', () async {
    when(() => remote.getPlanById(plan.id)).thenAnswer(
      (_) async => FailureState<MaintenancePlanModel>(
        message: 'denied',
        error: '42501',
        statusCode: 403,
        response: response,
      ),
    );
    final result = await repository.getMaintenancePlanById(plan.id);
    expect(result, isA<FailureState<MaintenancePlanEntity>>());
    expect(result.statusCode, 403);
    expect(result.error, '42501');
    expect(result.response, same(response));
  });

  for (final create in [true, false]) {
    test(
      '${create ? 'create' : 'update'} cannot succeed with an empty server response',
      () async {
        when(() => remote.createPlan(any())).thenAnswer(
          (_) async => const SuccessState<MaintenancePlanModel>(data: null),
        );
        when(() => remote.updatePlan(any())).thenAnswer(
          (_) async => const SuccessState<MaintenancePlanModel>(data: null),
        );
        final result = create
            ? await repository.createMaintenancePlan(plan)
            : await repository.updateMaintenancePlan(plan);
        expect(result, isA<FailureState<bool>>());
      },
    );
  }

  final writes = <String, Future<DataState<bool>> Function()>{
    'create': () => repository.createMaintenancePlan(plan),
    'update': () => repository.updateMaintenancePlan(plan),
    'delete': () => repository.deleteMaintenancePlan(plan.id),
  };
  for (final write in writes.entries) {
    test(
      '${write.key} preserves server denial metadata for the caller',
      () async {
        final failure = FailureState<MaintenancePlanModel>(
          message: 'denied',
          error: '42501',
          statusCode: 403,
          response: response,
        );
        when(() => remote.createPlan(any())).thenAnswer((_) async => failure);
        when(() => remote.updatePlan(any())).thenAnswer((_) async => failure);
        when(() => remote.deletePlan(any())).thenAnswer(
          (_) async => FailureState<void>(
            message: 'denied',
            error: '42501',
            statusCode: 403,
            response: response,
          ),
        );
        final result = await write.value();
        expect(result, isA<FailureState<bool>>());
        expect(result.message, 'denied');
        expect(result.statusCode, 403);
        expect(result.error, '42501');
        expect(result.response, same(response));
      },
    );
  }
}
