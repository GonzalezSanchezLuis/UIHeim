import 'package:flutter/material.dart';
import 'package:holi/src/service/onboarding/survey_service.dart';
import 'package:holi/src/model/onboarding/survey_model.dart';

class OnboardingSurveyViewModel extends ChangeNotifier {
  final SurveyService _surveyService = SurveyService();

  // Estado de las preguntas
  String? selectedTransportNeed;
  String? selectedRegistrationReason;
  String? selectedBarrierReason;

  // Controladores para la opción "Otro"
  final TextEditingController otherTransportController = TextEditingController();
  final TextEditingController otherReasonController = TextEditingController();
  final TextEditingController otherBarrierController = TextEditingController();

  // Estados de UI
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setTransportNeed(String? value) {
    selectedTransportNeed = value;
    notifyListeners();
  }

  void setRegistrationReason(String? value) {
    selectedRegistrationReason = value;
    notifyListeners();
  }

  void setBarrierReason(String? value) {
    selectedBarrierReason = value;
    notifyListeners();
  }

  Future<bool> submitSurvey(int? userId) async {
    _errorMessage = null;

    final String transportNeed = selectedTransportNeed == 'Otro' ? otherTransportController.text.trim() : (selectedTransportNeed ?? '');

    final String registrationReason = selectedRegistrationReason == 'Otro' ? otherReasonController.text.trim() : (selectedRegistrationReason ?? '');

    final String barrierReason = selectedBarrierReason == 'Otro' ? otherBarrierController.text.trim() : (selectedBarrierReason ?? '');

    // Validación de campos requeridos
    if (transportNeed.isEmpty || registrationReason.isEmpty || barrierReason.isEmpty) {
      _errorMessage = 'Por favor responde todas las preguntas antes de continuar.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    final survey = SurveyModel(
      userId: userId,
      transportNeed: transportNeed,
      registrationReason: registrationReason,
      barrierReason: barrierReason,
    );

    final success = await _surveyService.submitSurvey(survey);

    _isLoading = false;
    if (!success) {
      _errorMessage = 'Ocurrió un error al guardar la encuesta. Inténtalo de nuevo.';
    }
    notifyListeners();

    return success;
  }

  @override
  void dispose() {
    otherTransportController.dispose();
    otherReasonController.dispose();
    otherBarrierController.dispose();
    super.dispose();
  }
}
