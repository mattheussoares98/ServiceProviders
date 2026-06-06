import 'package:clean_architecture/features/assets/domain/repositories/assets_repository.dart';
import 'package:clean_architecture/features/attachments/domain/repositories/attachments_repository.dart';
import 'package:clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:clean_architecture/features/auth/domain/repositories/session_repository.dart';
import 'package:clean_architecture/features/categories/domain/repositories/categories_repository.dart';
import 'package:clean_architecture/features/checklists/domain/repositories/checklists_repository.dart';
import 'package:clean_architecture/features/locations/domain/repositories/locations_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAssetsRepository extends Mock implements AssetsRepository {}

class MockAttachmentsRepository extends Mock implements AttachmentsRepository {}

class MockChecklistsRepository extends Mock implements ChecklistsRepository {}

class MockCategoriesRepository extends Mock implements CategoriesRepository {}

class MockLocationsRepository extends Mock implements LocationsRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSessionRepository extends Mock implements SessionRepository {}
