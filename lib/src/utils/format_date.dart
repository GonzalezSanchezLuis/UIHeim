import 'package:intl/intl.dart';

String formatDate(String isoDate) {
  final dateTime = DateTime.parse(isoDate);
  final formatter = DateFormat("dd-MM-yy - hh:mm a", "es");

  var formated = formatter.format(dateTime);
  return formated;
}
