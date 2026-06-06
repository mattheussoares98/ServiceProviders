import 'package:clean_architecture/features/assets/domain/repositories/assets_repository.dart';
import 'package:clean_architecture/features/attachments/domain/repositories/attachments_repository.dart';
import 'package:clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:clean_architecture/features/auth/domain/repositories/session_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAssetsRepository extends Mock implements AssetsRepository {}

class MockAttachmentsRepository extends Mock implements AttachmentsRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSessionRepository extends Mock implements SessionRepository {}
