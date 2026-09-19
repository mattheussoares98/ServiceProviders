import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/auth_repository.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSessionRepository extends Mock implements SessionRepository {}
