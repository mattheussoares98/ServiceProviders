import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/handlers/error_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/customers/data/models/responses/customer_model.dart';

abstract interface class CustomersLocalDataSource {
  FutureList<CustomerModel> getCustomers(String companyId);
  FutureData<CustomerModel> getCustomerById(String id);
  FutureBool saveCustomer(CustomerModel customer);
  FutureBool saveCustomers(List<CustomerModel> customers);
  FutureBool deleteCustomer(String id);
}

@LazySingleton(as: CustomersLocalDataSource)
final class CustomersLocalDataSourceImpl implements CustomersLocalDataSource {
  CustomersLocalDataSourceImpl({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  @override
  FutureList<CustomerModel> getCustomers(String companyId) {
    return ErrorHandler.execute(() async {
      final query = _database.select(_database.customers)
        ..where((t) => t.companyId.equals(companyId) & t.deletedAt.isNull());
      final rows = await query.get();

      final list = rows
          .map(
            (row) => CustomerModel(
              id: row.id,
              companyId: row.companyId,
              name: row.name,
              document: row.document,
              contactName: row.contactName,
              contactEmail: row.contactEmail,
              contactPhone: row.contactPhone,
              address: row.address,
              number: row.number,
              complement: row.complement,
              neighborhood: row.neighborhood,
              city: row.city,
              state: row.state,
              postalCode: row.postalCode,
              notes: row.notes,
              isActive: row.isActive,
              createdAt: row.createdAt.toUtc(),
              updatedAt: row.updatedAt.toUtc(),
              deletedAt: row.deletedAt?.toUtc(),
            ),
          )
          .toList();

      return SuccessState(data: list);
    });
  }

  @override
  FutureData<CustomerModel> getCustomerById(String id) {
    return ErrorHandler.execute(() async {
      final query = _database.select(_database.customers)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull());
      final row = await query.getSingleOrNull();

      if (row == null) {
        return FailureState(message: 'Cliente não encontrado');
      }

      return SuccessState(
        data: CustomerModel(
          id: row.id,
          companyId: row.companyId,
          name: row.name,
          document: row.document,
          contactName: row.contactName,
          contactEmail: row.contactEmail,
          contactPhone: row.contactPhone,
          address: row.address,
          number: row.number,
          complement: row.complement,
          neighborhood: row.neighborhood,
          city: row.city,
          state: row.state,
          postalCode: row.postalCode,
          notes: row.notes,
          isActive: row.isActive,
          createdAt: row.createdAt.toUtc(),
          updatedAt: row.updatedAt.toUtc(),
          deletedAt: row.deletedAt?.toUtc(),
        ),
      );
    });
  }

  @override
  FutureBool saveCustomer(CustomerModel customer) {
    return ErrorHandler.execute(() async {
      await _database
          .into(_database.customers)
          .insertOnConflictUpdate(_toCompanion(customer));
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool saveCustomers(List<CustomerModel> customers) {
    return ErrorHandler.execute(() async {
      await _database.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _database.customers,
          customers.map(_toCompanion).toList(),
        );
      });
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool deleteCustomer(String id) {
    return ErrorHandler.execute(() async {
      final query = _database.update(_database.customers)
        ..where((t) => t.id.equals(id));
      await query.write(
        CustomersCompanion(deletedAt: Value(DateTime.now().toUtc())),
      );
      return const SuccessState(data: true);
    });
  }

  CustomersCompanion _toCompanion(CustomerModel customer) {
    return CustomersCompanion(
      id: Value(customer.id),
      companyId: Value(customer.companyId),
      name: Value(customer.name),
      document: Value(customer.document),
      contactName: Value(customer.contactName),
      contactEmail: Value(customer.contactEmail),
      contactPhone: Value(customer.contactPhone),
      address: Value(customer.address),
      number: Value(customer.number),
      complement: Value(customer.complement),
      neighborhood: Value(customer.neighborhood),
      city: Value(customer.city),
      state: Value(customer.state),
      postalCode: Value(customer.postalCode),
      notes: Value(customer.notes),
      isActive: Value(customer.isActive),
      createdAt: Value(customer.createdAt.toUtc()),
      updatedAt: Value(customer.updatedAt.toUtc()),
      deletedAt: Value(customer.deletedAt?.toUtc()),
    );
  }
}
