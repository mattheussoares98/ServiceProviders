import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/requests/area_request_model.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/responses/area_model.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/responses/location_model.dart';
import 'package:o_jogo_da_obra/features/locations/data/repositories/locations_repository_impl.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/factories/asset_factory.dart';

// Oracle: .agents/rules/feature.md requires mirror failures to propagate and
// forbids unsynchronized local-only success without a supported replay queue.
void main() {
  late MockInternetClient internet;
  late MockLocationsRemoteDataSource remote;
  late MockLocationsLocalDataSource local;
  late LocationsRepositoryImpl repository;
  final location = AssetFactory.makeLocationEntity();
  final area = AssetFactory.makeAreaEntity().copyWith(
    companyId: location.companyId,
    locationId: location.id,
  );
  final locationModel = LocationModel.fromEntity(location);
  final areaModel = AreaModel.fromEntity(area);
  final cacheFailure = FailureState<bool>(
    message: 'disk full',
    statusCode: 507,
  );

  setUpAll(() {
    registerFallbackValue(locationModel);
    registerFallbackValue(areaModel);
    registerFallbackValue(AreaRequestModel.fromEntity(area));
  });
  setUp(() {
    internet = MockInternetClient();
    remote = MockLocationsRemoteDataSource();
    local = MockLocationsLocalDataSource();
    repository = LocationsRepositoryImpl(
      internet: internet,
      remoteDataSource: remote,
      localDataSource: local,
    );
    when(
      () => remote.createLocation(any()),
    ).thenAnswer((_) async => SuccessState(data: locationModel));
    when(
      () => remote.updateLocation(any()),
    ).thenAnswer((_) async => SuccessState(data: locationModel));
    when(
      () => remote.deleteLocation(any()),
    ).thenAnswer((_) async => SuccessState.nil);
    when(
      () => remote.createArea(any()),
    ).thenAnswer((_) async => SuccessState(data: areaModel));
    when(
      () => remote.updateArea(any()),
    ).thenAnswer((_) async => SuccessState(data: areaModel));
    when(
      () => remote.deleteArea(any()),
    ).thenAnswer((_) async => SuccessState.nil);
  });

  final operations = <String, Future<DataState<bool>> Function()>{
    'create location': () => repository.createLocation(location),
    'update location': () => repository.updateLocation(location),
    'delete location': () => repository.deleteLocation(location.id),
    'create area': () => repository.createArea(area),
    'update area': () => repository.updateArea(area),
    'delete area': () => repository.deleteArea(area.id),
  };
  for (final operation in operations.entries) {
    test(
      '${operation.key}: a failed local mirror must not report success',
      () async {
        when(() => internet.isConnected).thenReturn(true);
        when(
          () => local.saveLocation(any()),
        ).thenAnswer((_) async => cacheFailure);
        when(
          () => local.deleteLocation(any()),
        ).thenAnswer((_) async => cacheFailure);
        when(() => local.saveArea(any())).thenAnswer((_) async => cacheFailure);
        when(
          () => local.deleteArea(any()),
        ).thenAnswer((_) async => cacheFailure);
        final result = await operation.value();
        expect(result, isA<FailureState<bool>>());
        expect(result.message, 'disk full');
        expect(result.statusCode, 507);
      },
    );

    test(
      '${operation.key}: offline write without replay support must fail',
      () async {
        when(() => internet.isConnected).thenReturn(false);
        when(
          () => local.saveLocation(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => local.deleteLocation(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => local.saveArea(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => local.deleteArea(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        final result = await operation.value();
        verifyZeroInteractions(remote);
        expect(
          result,
          isA<FailureState<bool>>(),
          reason:
              'Locations and areas have no SyncEntityType/replay path. Local-only success can disappear on the next server refresh.',
        );
      },
    );
  }

  test(
    'server denial preserves metadata and never writes the location cache',
    () async {
      when(() => internet.isConnected).thenReturn(true);
      when(() => remote.updateLocation(any())).thenAnswer(
        (_) async => FailureState<LocationModel>(
          message: 'denied',
          statusCode: 403,
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            data: {'code': '42501'},
          ),
        ),
      );
      final result = await repository.updateLocation(location);
      expect(result, isA<FailureState<bool>>());
      expect(result.statusCode, 403);
      expect(result.response?.data, {'code': '42501'});
      verifyZeroInteractions(local);
    },
  );

  test(
    'server denial preserves metadata and never writes the area cache',
    () async {
      when(() => internet.isConnected).thenReturn(true);
      when(() => remote.updateArea(any())).thenAnswer(
        (_) async => FailureState<AreaModel>(
          message: 'denied',
          statusCode: 403,
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            data: {'code': '42501'},
          ),
        ),
      );
      final result = await repository.updateArea(area);
      expect(result, isA<FailureState<bool>>());
      expect(result.statusCode, 403);
      expect(result.response?.data, {'code': '42501'});
      verifyZeroInteractions(local);
    },
  );
}
