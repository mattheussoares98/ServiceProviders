import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/customers/domain/entities/customer_entity.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/cubits/customers/customers_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/address_entity.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:uuid/uuid.dart';

part 'customers_state.dart';

enum CustomersSections implements SectionKey { save, delete, loadAddressByCep }

@injectable
class CustomersCubit extends BaseCubit<CustomersState> {
  CustomersCubit({required CustomersCubitUseCases useCases})
    : _useCases = useCases,
      super(const CustomersState.initial());

  final CustomersCubitUseCases _useCases;

  Future<void> loadCustomers({bool emitLoading = true}) async {
    final companyId = _useCases.getActiveCompanyId();

    if (emitLoading) {
      emit(
        state.copyWith(
          sections: withSection(BaseSections.load, SectionStatus.running),
        ),
      );
    }

    final results = await Future.wait([
      _useCases.getCustomers(companyId),
      _useCases.hasCustomers(companyId),
    ]);
    if (isClosed) return;

    final result = results[0] as DataState<List<CustomerEntity>>;
    final hasCustomersResult = results[1] as DataState<bool>;

    final hasCustomers =
        hasCustomersResult is SuccessState<bool> &&
        (hasCustomersResult.data ?? false);

    if (result is SuccessState<List<CustomerEntity>>) {
      emit(
        state.copyWith(
          customers: result.data ?? [],
          hasCustomers: hasCustomers,
          sections: withSection(BaseSections.load, SectionStatus.success),
        ),
      );
    } else {
      emit(
        state.copyWith(
          hasCustomers: hasCustomers,
          sections: withSection(
            BaseSections.load,
            SectionStatus.error,
            errorMessage: result.message,
          ),
        ),
      );
      showDataStateToast(result);
    }
  }

  Future<bool> saveCustomer({
    required String? id,
    required String name,
    String? document,
    String? contactName,
    String? contactEmail,
    String? contactPhone,
    String? address,
    String? number,
    String? complement,
    String? neighborhood,
    String? city,
    String? stateAddress,
    String? postalCode,
    String? notes,
    bool isActive = true,
    DateTime? createdAt,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      final message = 'Nome do cliente não pode ser vazio'.hardcoded;
      emit(
        state.copyWith(
          sections: withSection(
            CustomersSections.save,
            SectionStatus.error,
            errorMessage: message,
          ),
        ),
      );
      showErrorToast(message);
      return false;
    }

    final cleanDoc = document?.replaceAll(RegExp(r'\D'), '');
    if (cleanDoc != null && cleanDoc.isNotEmpty) {
      if (cleanDoc.length != 11 && cleanDoc.length != 14) {
        final message =
            'Documento inválido. Informe CPF (11 dígitos) ou CNPJ (14 dígitos)'
                .hardcoded;
        emit(
          state.copyWith(
            sections: withSection(
              CustomersSections.save,
              SectionStatus.error,
              errorMessage: message,
            ),
          ),
        );
        showErrorToast(message);
        return false;
      }

      final isDuplicate = state.customers.any(
        (c) =>
            c.document != null &&
            c.document!.replaceAll(RegExp(r'\D'), '') == cleanDoc &&
            c.id != id,
      );
      if (isDuplicate) {
        final message = 'Já existe um cliente com este documento'.hardcoded;
        emit(
          state.copyWith(
            sections: withSection(
              CustomersSections.save,
              SectionStatus.error,
              errorMessage: message,
            ),
          ),
        );
        showErrorToast(message);
        return false;
      }
    }

    emit(
      state.copyWith(
        sections: withSection(CustomersSections.save, SectionStatus.running),
      ),
    );

    final isUpdate = id != null;
    final now = DateTime.now();
    final companyId = _useCases.getActiveCompanyId();

    final customer = CustomerEntity(
      id: id ?? const Uuid().v4(),
      companyId: companyId,
      name: trimmedName,
      document: (cleanDoc?.isEmpty ?? true) ? null : cleanDoc,
      contactName: contactName?.trimToNull(),
      contactEmail: contactEmail?.trimToNull(),
      contactPhone: contactPhone?.trimToNull(),
      address: address?.trimToNull(),
      number: number?.trimToNull(),
      complement: complement?.trimToNull(),
      neighborhood: neighborhood?.trimToNull(),
      city: city?.trimToNull(),
      state: stateAddress?.trimToNull(),
      postalCode: postalCode?.trimToNull(),
      notes: notes?.trimToNull(),
      isActive: isActive,
      createdAt: createdAt ?? now,
      updatedAt: now,
    );

    final result = isUpdate
        ? await _useCases.updateCustomer(customer)
        : await _useCases.createCustomer(customer);

    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      final updatedCustomers = isUpdate
          ? state.customers
                .map((c) => c.id == customer.id ? customer : c)
                .toList()
          : [...state.customers, customer];
      emit(
        state.copyWith(
          customers: updatedCustomers,
          sections: withSection(CustomersSections.save, SectionStatus.success),
        ),
      );
      await loadCustomers(emitLoading: false);
      return true;
    } else {
      if (isClosed) return false;
      emit(
        state.copyWith(
          sections: withSection(CustomersSections.save, SectionStatus.error),
        ),
      );
      showDataStateToast(result);
      return false;
    }
  }

  Future<bool> deleteCustomer(String id) async {
    emit(
      state.copyWith(
        sections: withSection(CustomersSections.delete, SectionStatus.running),
      ),
    );

    final result = await _useCases.deleteCustomer(id);
    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      final updatedCustomers = state.customers
          .where((customer) => customer.id != id)
          .toList();
      emit(
        state.copyWith(
          customers: updatedCustomers,
          sections: withSection(
            CustomersSections.delete,
            SectionStatus.success,
          ),
        ),
      );
      await loadCustomers(emitLoading: false);
      return true;
    } else {
      if (isClosed) return false;
      emit(
        state.copyWith(
          sections: withSection(CustomersSections.delete, SectionStatus.error),
        ),
      );
      showDataStateToast(result);
      return false;
    }
  }

  Future<AddressEntity?> getAddressByCep(String cep) async {
    final cleanCep = cep.replaceAll(RegExp(r'\D'), '');
    if (cleanCep.length != 8) return null;

    emit(
      state.copyWith(
        sections: withSection(
          CustomersSections.loadAddressByCep,
          SectionStatus.running,
        ),
      ),
    );

    final dataState = await _useCases.getAddressByCep(cleanCep);
    if (isClosed) return null;

    if (dataState is SuccessState<AddressEntity>) {
      emit(
        state.copyWith(
          sections: withSection(
            CustomersSections.loadAddressByCep,
            SectionStatus.success,
          ),
        ),
      );
      return dataState.data;
    } else {
      emit(
        state.copyWith(
          sections: withSection(
            CustomersSections.loadAddressByCep,
            SectionStatus.error,
          ),
        ),
      );
      showDataStateToast(dataState);
      return null;
    }
  }

  Future<void> navigateToCreateUpdateCustomer({
    CustomerEntity? customer,
  }) async {
    await pushRoute(CreateUpdateCustomerRoute(customer: customer));
  }

  void popRoute() {
    popRouteAdaptively();
  }
}
