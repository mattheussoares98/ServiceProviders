part of 'searchable_customer_picker_modal.dart';

class CustomerPickerResult {
  const CustomerPickerResult.selected(this.customer) : isClear = false;
  const CustomerPickerResult.cleared() : customer = null, isClear = true;

  final CustomerEntity? customer;
  final bool isClear;
}
