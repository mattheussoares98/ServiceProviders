import 'package:clean_architecture/features/assets/domain/repositories/assets_repository.dart';
import 'package:clean_architecture/features/attachments/domain/repositories/attachments_repository.dart';
import 'package:clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:clean_architecture/features/auth/domain/repositories/session_repository.dart';
import 'package:clean_architecture/features/categories/domain/repositories/categories_repository.dart';
import 'package:clean_architecture/features/checklists/domain/repositories/checklists_repository.dart';
import 'package:clean_architecture/features/company/domain/repositories/company_repository.dart';
import 'package:clean_architecture/features/locations/domain/repositories/locations_repository.dart';
import 'package:clean_architecture/features/maintenance_plans/domain/repositories/maintenance_plans_repository.dart';
import 'package:clean_architecture/features/users/domain/repositories/users_repository.dart';
import 'package:clean_architecture/features/work_orders/domain/repositories/work_orders_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAssetsRepository extends Mock implements AssetsRepository {}

class MockAttachmentsRepository extends Mock implements AttachmentsRepository {}

class MockChecklistsRepository extends Mock implements ChecklistsRepository {}

class MockCategoriesRepository extends Mock implements CategoriesRepository {}

class MockCompanyRepository extends Mock implements CompanyRepository {}

class MockLocationsRepository extends Mock implements LocationsRepository {}

class MockMaintenancePlansRepository extends Mock
    implements MaintenancePlansRepository {}

class MockUsersRepository extends Mock implements UsersRepository {}

class MockWorkOrdersRepository extends Mock implements WorkOrdersRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSessionRepository extends Mock implements SessionRepository {}
