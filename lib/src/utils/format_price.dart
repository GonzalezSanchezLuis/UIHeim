import 'package:intl/intl.dart';

String formatPriceToHundreds(String rawPrice) {
  final double price = double.tryParse(rawPrice.replaceAll(',', '')) ?? 0;

  // Truncar a centenas hacia abajo
  final int truncated = (price ~/ 100) * 100;

  final format = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '',
    decimalDigits: 0,
  );

  return '\$ ${format.format(truncated)} COP';
}

String formatPriceToHundredsDriver(String rawPrice) {
  final double price = double.tryParse(rawPrice.replaceAll(',', '')) ?? 0;

  // Truncar a centenas hacia abajo
  final int truncated = (price ~/ 100) * 100;

  final format = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '',
    decimalDigits: 0,
  );

  return 'COP \$ ${format.format(truncated)}';
}


String formatPriceMovingDetails(String price) {
final cleanPrice = price.replaceAll(RegExp(r'[^0-9.]'), '');
  double value = double.tryParse(cleanPrice) ?? 0;
  final formatter = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '',
    decimalDigits: 0,
  );

  return ' COP \$${formatter.format(value).trim()}';
}


