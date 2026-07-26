import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/assets/domain/repositories/assets_repository.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/repositories/attachments_repository.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/auth_repository.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';
import 'package:o_jogo_da_obra/features/categories/domain/repositories/categories_repository.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/repositories/checklists_repository.dart';
import 'package:o_jogo_da_obra/features/company/domain/repositories/company_repository.dart';
import 'package:o_jogo_da_obra/features/configurations/domain/repositories/configurations_repository.dart';
import 'package:o_jogo_da_obra/features/locations/domain/repositories/locations_repository.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/repositories/maintenance_plans_repository.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/repositories/service_provider_repository.dart';
import 'package:o_jogo_da_obra/features/users/domain/repositories/users_repository.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/pause_repository.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/sla_repository.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/work_orders_repository.dart';

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

class MockConfigurationsRepository extends Mock
    implements ConfigurationsRepository {}

class MockServiceProviderRepository extends Mock
    implements ServiceProviderRepository {}

class MockSlaRepository extends Mock implements SlaRepository {}

class MockPauseRepository extends Mock implements PauseRepository {}
