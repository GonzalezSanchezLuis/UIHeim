import 'dart:convert';
import 'package:holi/src/model/payment/wallet_model.dart';
import 'package:http/http.dart' as http;
import 'package:holi/config/app_config.dart';

class WalletService {

  Future<WalletModel?> fetchEarning(int driverId) async {

    final url = Uri.parse('$apiBaseUrl/payments/$driverId/earning');

    try {
      final response = await http.get(
        url,
        // No necesitas headers si no envías un body, pero puedes dejarlos para autenticación futura
        // headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer YOUR_TOKEN_HERE'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print("DATA $data");
        return WalletModel.fromJson(data);
      } else {
        print('Error del servidor (${response.statusCode}): ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error de red al obtener ganancias: $e');
      return null;
    }
  }
}
