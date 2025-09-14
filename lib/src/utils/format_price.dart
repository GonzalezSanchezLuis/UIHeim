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

  return '\$ ${format.format(truncated)} COP';
}


String formatPriceMovingDetails(String rawPrice) {
    // Convertir a número y llevar de centavos a unidades
  final double price = (double.tryParse(rawPrice.replaceAll(',', '')) ?? 0) / 100;

  // Truncar a centenas hacia abajo
  final int truncated = (price ~/ 100) * 100;

  final format = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '',
    decimalDigits: 0,
  );

  return '\$ ${format.format(truncated)} COP';
}


