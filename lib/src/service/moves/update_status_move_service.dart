import 'dart:convert';
import 'package:holi/src/core/enums/status_of_the_move.dart';
import 'package:holi/src/model/move/move_status_update_model.dart';
import 'package:http/http.dart' as http;

class UpdateStatusMoveService {
  // final String _baseUrl = "http://192.168.20.49:8080/api/v1";
  final String _baseUrl = "https://c2dafcfb21f9.ngrok-free.app/api/v1/move";

  Future<void> updateMoveStatus(MoveStatusUpdateModel data, StatusOfTheMove status) async {
    late String endpoint;

    switch (status) {
      case StatusOfTheMove.DRIVER_ARRIVED:
        endpoint = 'driver-arrived';
        break;

        case StatusOfTheMove.MOVING_STARTED:
        endpoint = 'start';
        break;

        case StatusOfTheMove.MOVE_COMPLETE:
        endpoint = 'complete';
        break;

        default:
        throw Exception('Estado no soportado');
    }

    final url = Uri.parse('$_baseUrl/$endpoint');

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el estado del viaje: ${response.body}');
    }
  }

  Future<String> getStatus(int moveId) async {
    final url = Uri.parse('$_baseUrl/get-status/$moveId');

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Error al obtener el estado de la mudanza');
    }

    return response.body.replaceAll('"', ''); 
  }

}
