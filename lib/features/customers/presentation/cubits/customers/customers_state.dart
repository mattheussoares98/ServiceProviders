part of 'customers_cubit.dart';

class CustomersState extends BaseState {
  const CustomersState({
    required this.customers,
    this.hasCustomers = false,
    super.sections = const {},
  });

  const CustomersState.initial()
    : customers = const [],
      hasCustomers = false,
      super(sections: const {});

  final List<CustomerEntity> customers;
  final bool hasCustomers;

  CustomersState copyWith({
    List<CustomerEntity>? customers,
    bool? hasCustomers,
    Map<SectionKey, SectionState>? sections,
  }) {
    return CustomersState(
      customers: customers ?? this.customers,
      hasCustomers: hasCustomers ?? this.hasCustomers,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [customers, hasCustomers, sections];
}
