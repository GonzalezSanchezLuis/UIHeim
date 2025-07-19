import 'package:holi/src/model/payment/payment_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
class PaymentService {
    Future<String?> generatePaymentUrl(PaymentModel request) async {
    //final url = Uri.parse('http://192.168.20.49:8080/api/v1/payments/generate');
    final url = Uri.parse('https://6a6c5b4b2ba5.ngrok-free.app/api/v1/payments/generate');

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