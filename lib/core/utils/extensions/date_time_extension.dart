extension DateTimeExtension on DateTime {
  String formattedBrazilianDate({bool includeTime = false}) {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year${includeTime ? ' ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}' : ''}';
  }
}
