import 'dart:convert';
import 'package:holi/src/model/onboarding/survey_model.dart';
import 'package:http/http.dart' as http;
import 'package:holi/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SurveyService {
  final String _baseUrl = apiBaseUrl;

  Future<bool> submitSurvey(SurveyModel survey) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/onboarding/register'),
        headers: {
          'Content-Type': 'application/json',
  
        },
        body: jsonEncode(survey.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await prefs.setBool('survey_completed', true);
        return true;
      }else if(response.statusCode == 400 || response.statusCode == 409 || response.body.contains("ya completó")){
        await prefs.setBool('survey_completed', true);
        return true;
      } else {
        print("❌ Error en respuesta del servidor: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error de red en SurveyService: $e");
      return false;
    }
  }
}
