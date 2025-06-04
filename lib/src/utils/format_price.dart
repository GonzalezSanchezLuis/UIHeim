import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

String formatPrice(Decimal price) {
  final format = NumberFormat.currency(symbol: "COP", locale: "es_CO");
  return format.format(price.toDouble());
}
