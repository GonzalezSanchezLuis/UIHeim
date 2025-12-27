import 'dart:convert';
import 'package:holi/config/app_config.dart';
import 'package:holi/src/model/payment/payment_driver_account_model.dart';
import 'package:http/http.dart' as http;

class PaymentDriverAccountService {
  final url = Uri.parse('$apiBaseUrl/payment/driver/account');
  Future<PaymentDriverAccountModel?> savePaymentAccount(PaymentDriverAccountModel accountData) async {
    try {
      final bodyJson = json.encode(accountData.toJson());

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: bodyJson,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print("DATA recibida del backend (200 OK): $data");
        return PaymentDriverAccountModel.fromJson(data);
      } else {
        print('Error del servidor (${response.statusCode}): ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error de red al guardar la cuenta: $e');
      return null;
    }
  }

  Future<PaymentDriverAccountModel?> getDriverPaymentAccount(int driverId) async {
    final url = Uri.parse('$apiBaseUrl/payment/$driverId/getAccount');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return PaymentDriverAccountModel.fromJson(responseData);
      } else if (response.statusCode == 404) {
        print('Cuenta de pago no encontrada para el ID: $driverId');
        return null;
      } else {
        print('Error al obtener cuenta: ${response.statusCode}');
        print('Respuesta del servidor: ${response.body}');
        return null;
      }
    } catch (e) {

      print('Excepción de red al obtener cuenta: $e');
      return null;
    }
  }
}
