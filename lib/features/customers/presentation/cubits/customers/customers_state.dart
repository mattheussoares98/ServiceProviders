part of 'customers_cubit.dart';

class CustomersState extends BaseState {
  const CustomersState({required this.customers, super.sections = const {}});

  const CustomersState.initial()
    : customers = const [],
      super(sections: const {});

  final List<CustomerEntity> customers;

  CustomersState copyWith({
    List<CustomerEntity>? customers,
    Map<SectionKey, SectionState>? sections,
  }) {
    return CustomersState(
      customers: customers ?? this.customers,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [customers, sections];
}
