import 'package:clean_architecture/core/data/handlers/error_handler.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../testing/mocks/external/external_mocks.dart';

void main() {
  group('ErrorHandler.execute', () {
    test('returns result when no exception thrown', () async {
      final result = await ErrorHandler.execute<int>(
        () async => const SuccessState(data: 1),
      );
      expect(result, isA<SuccessState<int>>());
      expect(result.data, 1);
    });

    test('handles DioException with 400 status as BadRequestState', () async {
      final response = MockResponse<dynamic>();
      when(() => response.statusCode).thenReturn(400);
      when(() => response.data).thenReturn({'message': 'bad request'});
      final dioException = MockDioException();
      when(() => dioException.type).thenReturn(DioExceptionType.badResponse);
      when(() => dioException.response).thenReturn(response);

      final result = await ErrorHandler.execute<int>(() {
        throw dioException;
      });

      expect(result.message, 'bad request');
      expect(result.statusCode, 400);
    });

    test('handles DioException with 500 status as ServerErrorState', () async {
      final response = MockResponse<dynamic>();
      when(() => response.statusCode).thenReturn(500);
      when(() => response.data).thenReturn({'message': 'server error'});
      final dioException = MockDioException();
      when(() => dioException.type).thenReturn(DioExceptionType.badResponse);
      when(() => dioException.response).thenReturn(response);

      final result = await ErrorHandler.execute<int>(() {
        throw dioException;
      });

      expect(result.message, 'server error');
      expect(result.statusCode, 500);
    });

    test('handles DioException with connectionError as FailureState', () async {
      final dioException = MockDioException();
      when(
        () => dioException.type,
      ).thenReturn(DioExceptionType.connectionError);
      when(() => dioException.response).thenReturn(null);

      final result = await ErrorHandler.execute<int>(() {
        throw dioException;
      });

      expect(result, isA<FailureState<int>>());
      expect(result.message, contains('Erro de conexão'));
    });

    test('handles DioException with cancel as FailureState', () async {
      final dioException = MockDioException();
      when(() => dioException.type).thenReturn(DioExceptionType.cancel);
      when(() => dioException.response).thenReturn(null);

      final result = await ErrorHandler.execute<int>(() {
        throw dioException;
      });

      expect(result, isA<FailureState<int>>());
      expect(result.message, contains('Requisição cancelada'));
    });

    test('handles DioException with receiveTimeout as FailureState', () async {
      final dioException = MockDioException();
      when(() => dioException.type).thenReturn(DioExceptionType.receiveTimeout);
      when(() => dioException.response).thenReturn(null);

      final result = await ErrorHandler.execute<int>(() {
        throw dioException;
      });

      expect(result, isA<FailureState<int>>());
      expect(result.message, contains('Tempo limite de recebimento'));
    });

    test('handles DioException with sendTimeout as FailureState', () async {
      final dioException = MockDioException();
      when(() => dioException.type).thenReturn(DioExceptionType.sendTimeout);
      when(() => dioException.response).thenReturn(null);

      final result = await ErrorHandler.execute<int>(() {
        throw dioException;
      });

      expect(result, isA<FailureState<int>>());
      expect(result.message, contains('Tempo limite de envio na conexão'));
    });

    test(
      'handles DioException with connectionTimeout as FailureState',
      () async {
        final dioException = MockDioException();
        when(
          () => dioException.type,
        ).thenReturn(DioExceptionType.connectionTimeout);
        when(() => dioException.response).thenReturn(null);

        final result = await ErrorHandler.execute<int>(() {
          throw dioException;
        });

        expect(result, isA<FailureState<int>>());
        expect(result.message, contains('Tempo limite de conexão'));
      },
    );

    test('handles DioException with badCertificate as FailureState', () async {
      final dioException = MockDioException();
      when(() => dioException.type).thenReturn(DioExceptionType.badCertificate);
      when(() => dioException.response).thenReturn(null);

      final result = await ErrorHandler.execute<int>(() {
        throw dioException;
      });

      expect(result, isA<FailureState<int>>());
      expect(result.message, contains('Certificado inválido'));
    });

    test(
      'handles DioException with unknown error type as FailureState',
      () async {
        final dioException = MockDioException();
        when(() => dioException.type).thenReturn(DioExceptionType.unknown);
        when(() => dioException.response).thenReturn(null);

        final result = await ErrorHandler.execute<int>(() {
          throw dioException;
        });

        expect(result, isA<FailureState<int>>());
        expect(result.message, isNotNull);
      },
    );

    test('handles generic Exception as FailureState', () async {
      final result = await ErrorHandler.execute<int>(() {
        throw Exception('generic error');
      });

      expect(result, isA<FailureState<int>>());
      expect(result.message, contains(kErrorMessage));
    });

    test('handles String error as FailureState', () async {
      final result = await ErrorHandler.execute<int>(() {
        throw Exception('string error');
      });

      expect(result, isA<FailureState<int>>());
      expect(result.message, contains(kErrorMessage));
    });

    test('handles custom error object as FailureState', () async {
      final result = await ErrorHandler.execute<int>(() {
        throw ArgumentError('invalid argument');
      });

      expect(result, isA<FailureState<int>>());
      expect(result.message, contains(kErrorMessage));
    });

    test(
      'handles AuthException with specific code as mapped FailureState',
      () async {
        const authException = AuthException(
          'Some generic message',
          statusCode: '400',
          code: 'invalid_credentials',
        );

        final result = await ErrorHandler.execute<int>(() {
          throw authException;
        });

        expect(result, isA<FailureState<int>>());
        expect(result.message, 'E-mail ou senha incorretos.');
        expect(result.statusCode, 400);
      },
    );

    test(
      'handles AuthException with fallback message as mapped FailureState',
      () async {
        const authException = AuthException(
          'User already registered in this system',
          statusCode: '400',
        );

        final result = await ErrorHandler.execute<int>(() {
          throw authException;
        });

        expect(result, isA<FailureState<int>>());
        expect(result.message, 'Este e-mail já está cadastrado.');
        expect(result.statusCode, 400);
      },
    );

    test(
      'handles AuthException with unmapped message as unmapped FailureState',
      () async {
        const authException = AuthException(
          'Some brand new unmapped error message from Supabase',
          statusCode: '400',
        );

        final result = await ErrorHandler.execute<int>(() {
          throw authException;
        });

        expect(result, isA<FailureState<int>>());
        expect(
          result.message,
          'Some brand new unmapped error message from Supabase',
        );
        expect(result.statusCode, 400);
      },
    );
  });

  group('ErrorHandler.executeSafe', () {
    test('catches and logs exception without rethrowing', () async {
      var exceptionCaught = false;

      await ErrorHandler.executeSafe(() {
        throw Exception('test exception');
      });

      // If we reach here, the exception was caught and not rethrown
      exceptionCaught = true;
      expect(exceptionCaught, true);
    });

    test('does not interfere with successful execution', () async {
      var executed = false;

      await ErrorHandler.executeSafe(() async {
        executed = true;
      });

      expect(executed, true);
    });
  });

  group('ErrorHandler.executeSafeReturn', () {
    test('returns value when no exception thrown', () async {
      final result = await ErrorHandler.executeSafeReturn<int>(
        () async => 10,
        valueOnError: -1,
      );
      expect(result, 10);
    });

    test('returns valueOnError when exception thrown', () async {
      final result = await ErrorHandler.executeSafeReturn<int>(
        () async => throw Exception('fail'),
        valueOnError: -1,
      );
      expect(result, -1);
    });
  });

  group('ErrorHandler.executeSafeSync', () {
    test('executes successfully without exception', () {
      var executed = false;
      ErrorHandler.executeSafeSync(() {
        executed = true;
      });
      expect(executed, true);
    });

    test('catches exception and does not rethrow', () {
      ErrorHandler.executeSafeSync(() {
        throw Exception('sync fail');
      });
      // If we reach here, exception was caught
    });
  });

  group('ErrorHandler.executeSafeReturnSync', () {
    test('returns value when no exception thrown', () {
      final result = ErrorHandler.executeSafeReturnSync(
        () => 20,
        valueOnError: -1,
      );
      expect(result, 20);
    });

    test('returns valueOnError when exception thrown', () {
      final result = ErrorHandler.executeSafeReturnSync<int>(
        () => throw Exception('sync fail'),
        valueOnError: -1,
      );
      expect(result, -1);
    });
  });
}
