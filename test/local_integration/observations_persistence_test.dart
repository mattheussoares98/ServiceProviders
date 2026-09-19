import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_order_observations_local_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_observation_model.dart';

import '../../testing/mocks/factories/local_database_fixture.dart';
import '../../testing/mocks/factories/service_provider_factory.dart';
import '../../testing/mocks/factories/work_order_factory.dart';

void main() {
  late LocalDatabaseFixture fixture;
  WorkOrderObservationsLocalDataSourceImpl source() =>
      WorkOrderObservationsLocalDataSourceImpl(database: fixture.database);
  setUp(() => fixture = LocalDatabaseFixture());
  tearDown(() => fixture.dispose());

  test(
    'observation content, edit, and deletion persist after reopening',
    () async {
      final observation = WorkOrderFactory.makeWorkOrderObservationEntity()
          .copyWith(content: 'Inspeção:\nPeça "A" — óleo baixo');
      expect(
        (await source().saveObservation(
          WorkOrderObservationModel.fromEntity(observation),
        )).data,
        isTrue,
      );
      await fixture.reopen();
      final original = (await source().getObservations(
        observation.workOrderId,
      )).data!.single;
      expect(original.content, observation.content);
      expect(original.authorId, observation.authorId);
      final changed = observation.copyWith(
        content: 'Óleo completado',
        updatedAt: DateTime.utc(2026, 9, 19),
      );
      expect(
        (await source().saveObservation(
          WorkOrderObservationModel.fromEntity(changed),
        )).data,
        isTrue,
      );
      await fixture.reopen();
      final row = (await source().getObservations(
        observation.workOrderId,
      )).data!.single;
      expect(row.id, observation.id);
      expect(row.content, changed.content);
      expect(row.updatedAt, changed.updatedAt);
      expect((await source().deleteObservation(observation.id)).data, isTrue);
      await fixture.reopen();
      expect(
        (await source().getObservations(observation.workOrderId)).data,
        isEmpty,
      );
    },
  );

  test(
    'server batch replay does not duplicate or leak observations to other orders',
    () async {
      final a = WorkOrderFactory.makeWorkOrderObservationEntity();
      final b = WorkOrderFactory.makeWorkOrderObservationEntity();
      final batch = [
        WorkOrderObservationModel.fromEntity(a),
        WorkOrderObservationModel.fromEntity(b),
      ];
      expect((await source().saveObservations(batch)).data, isTrue);
      await fixture.reopen();
      expect((await source().saveObservations(batch)).data, isTrue);
      await fixture.reopen();
      expect(
        (await source().getObservations(a.workOrderId)).data!.single.id,
        a.id,
      );
      expect(
        (await source().getObservations(b.workOrderId)).data!.single.id,
        b.id,
      );
      expect((await source().getObservationsByWorkOrderIds([])).data, isEmpty);
      expect((await source().deleteObservation(a.id)).data, isTrue);
      await fixture.reopen();
      expect(
        (await source().getObservations(b.workOrderId)).data!.single.id,
        b.id,
      );
    },
  );

  test(
    'provider-authored observation retains provider identity without an internal author',
    () async {
      final providerId =
          ServiceProviderFactory.makeServiceProviderProfileEntity().id;
      final original = WorkOrderObservationModel.fromEntity(
        WorkOrderFactory.makeWorkOrderObservationEntity(),
      );
      final providerResponse = WorkOrderObservationModel.fromJson({
        ...original.toJson(),
        'author_id': null,
        'author_provider_profile_id': providerId,
          'provider_author': const {'name': 'Prestador de teste'},
      });
      expect((await source().saveObservation(providerResponse)).data, isTrue);
      await fixture.reopen();
      final row = (await source().getObservations(
        original.workOrderId,
      )).data!.single;
      expect(row.authorId, isNull);
      expect(row.authorProviderProfileId, providerId);
      expect(row.authorName, 'Prestador de teste');
    },
  );
}
