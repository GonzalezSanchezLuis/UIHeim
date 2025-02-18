import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  static const String cloudName = "dol3uoiib";
  static const String uploadPreset = "users_and_drivers";
  static const String apiUrl = "https://api.cloudinary.com/v1_1/$cloudName/image/upload";

  static Future<String?> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      if (response.statusCode == 200 && jsonResponse.containsKey('secure_url')) {
        return jsonResponse['secure_url'];
      } else {
        print("⚠️ Error al subir imagen: ${jsonResponse['error'] ?? 'Desconocido'}");
        return null;
      }
    } catch (e) {
      print("❌ Error al subir imagen: $e");
      return null;
    }
  }
}
