import 'package:collection/collection.dart';

enum WorkType {
  internalOnly('internal_only'),
  serviceProviderOnly('service_provider_only'),
  hybrid('hybrid');

  const WorkType(this.code);
  final String code;

  /// Whether this work type supports own locations / facilities.
  bool get supportsOwnLocations =>
      this == WorkType.internalOnly || this == WorkType.hybrid;

  /// Whether this work type supports external customers.
  bool get supportsCustomers =>
      this == WorkType.serviceProviderOnly || this == WorkType.hybrid;

  /// Whether a work order strictly requires selecting a customer.
  bool get requiresCustomer => this == WorkType.serviceProviderOnly;

  /// Whether a work order strictly requires selecting an internal location.
  bool get requiresLocation => this == WorkType.internalOnly;

  /// Whether this company can hire external service providers.
  bool get canHireServiceProviders => this != WorkType.serviceProviderOnly;

  /// Whether this work type is internal only.
  bool get isInternalOnly => this == WorkType.internalOnly;

  /// Whether this work type is service provider only.
  bool get isServiceProviderOnly => this == WorkType.serviceProviderOnly;

  /// Whether this work type is hybrid.
  bool get isHybrid => this == WorkType.hybrid;

  /// Whether this type can upgrade to [target].
  bool canUpgradeTo(WorkType target) => switch ((this, target)) {
    (WorkType.internalOnly, WorkType.hybrid) => true,
    (WorkType.serviceProviderOnly, WorkType.hybrid) => true,
    _ => false,
  };

  static WorkType? fromCode(String? code) =>
      WorkType.values.firstWhereOrNull((e) => e.code == code);
}
