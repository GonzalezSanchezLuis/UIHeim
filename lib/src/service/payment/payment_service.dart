import 'package:holi/src/model/payment/payment_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:holi/config/app_config.dart';

class PaymentService {
    Future<String?> generatePaymentUrl(PaymentModel request) async {
    final url = Uri.parse('$apiBaseUrl/generate');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['checkoutUrl'];
      } else {
        print('Error del servidor: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error de red: $e');
      return null;
    }
  }
}