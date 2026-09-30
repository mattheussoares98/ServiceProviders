import 'package:faker/faker.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/customers/data/data_sources/customers_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/customers/data/models/responses/customer_model.dart';

import '../../../testing/mocks/factories/customer_factory.dart';
import '../core/integration_config.dart';
import '../core/integration_data_tracker.dart';

/// Helper for getting or creating Customers in integration tests.
class CustomerIntegrationHelper {
  const CustomerIntegrationHelper._();

  /// Returns an existing active customer or creates a new `[IT]`-prefixed one.
  static Future<CustomerModel> getOrCreateCustomer(
    CustomersRemoteDataSource remote,
    String companyId,
  ) async {
    if (IntegrationConfig.useExistingData) {
      final result = await remote.getCustomers(companyId);
      if (result is SuccessState<List<CustomerModel>> &&
          (result.data?.isNotEmpty ?? false)) {
        return result.data!.first;
      }
    }

    final entity = CustomerFactory.makeCustomerEntity().copyWith(
      id: faker.guid.guid(),
      companyId: companyId,
      name: IntegrationConfig.testName(faker.company.name()),
      isActive: true,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    final model = CustomerModel.fromEntity(entity);
    final result = await remote.createCustomer(model);
    final created = (result as SuccessState<CustomerModel>).data!;
    IntegrationDataTracker.instance.track('customers', created.id);
    return created;
  }
}
