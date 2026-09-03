import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holi/src/view/screens/travel/calculate_price_view.dart';
import 'package:holi/src/viewmodels/auth/sesion_viewmodel.dart';
import 'package:holi/src/viewmodels/onboarding/onboarding_survey_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingSurveyView extends StatefulWidget {
  const OnboardingSurveyView({super.key});

  @override
  State<OnboardingSurveyView> createState() => _OnboardingSurveyScreenState();
}

class _OnboardingSurveyScreenState extends State<OnboardingSurveyView> {
  late final OnboardingSurveyViewModel _viewModel;

  final Color _primaryColor = const Color(0xFF4ADE80);
  final Color _cardColor = const Color(0xFF2A2A32);

  @override
  void initState() {
    super.initState();
    _viewModel = OnboardingSurveyViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleSurveySubmit() async {
    final sessionVM = Provider.of<SessionViewModel>(context, listen: false);

    final prefs = await SharedPreferences.getInstance();
    if (sessionVM.userId == null || sessionVM.userId == 0) {
      final storedUserId = prefs.getInt('userId');
      if (storedUserId != null && storedUserId != 0) {
        sessionVM.setUserId(storedUserId);
        debugPrint("💾 [OnboardingSurveyView] userId sincronizado desde SharedPreferences: $storedUserId");
      }
    }

    final success = await _viewModel.submitSurvey(sessionVM.userId);

    if (!mounted) return;

    if (success) {
      showModalBottomSheet(
        context: context,
        isDismissible: false,
        backgroundColor: const Color(0xFF060606),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext sheetContext) {
          return Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 12.h),
                Text(
                  "¡Listo! 🎁",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Tienes 20% de descuento en tu primer viaje con Heim.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  height: 40.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.confirmationscolor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CalculatePrice(),
                        ),
                        (route) => false,
                      );
                    },
                    child:  Text(
                      "Usar mi descuento",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 14.sp),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  width: double.infinity,
                  height: 44.h,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      Navigator.pop(context, true);
                    },
                    child: Text(
                      "Cerrar",
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),
                    
                  ),
                  
                ),
                 SizedBox(height: 5.h),
              ],
            ),
          );
        },
      );
    } else if (_viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage!),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: AppTheme.colorbackgroundview,
          appBar: AppBar(
            title: const Text(
              "Queremos entender mejor tus envíos",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 22.sp,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            elevation: 0,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pregunta 1
                  _buildQuestionCard(
                    title: "¿Qué necesitas transportar con Heim?",
                    options: const [
                      "Entregar mercancía a mis clientes",
                      "Recoger mercancía o pedidos",
                      "Mover mercancía entre puntos de mi negocio",
                      "Transportar mercancía desde un proveedor",
                      "Otro",
                    ],
                    selectedValue: _viewModel.selectedTransportNeed,
                    otherController: _viewModel.otherTransportController,
                    onChanged: (value) => _viewModel.setTransportNeed(value),
                  ),
                  SizedBox(height: 20.h),

                  // Pregunta 2
                  _buildQuestionCard(
                    title: "¿Qué buscabas cuando te registraste en Heim?",
                    options: const [
                      "Necesitaba un vehículo en ese momento",
                      "Estaba buscando opciones",
                      "Quería conocer cómo funciona",
                      "Me recomendaron Heim",
                      "Otro",
                    ],
                    selectedValue: _viewModel.selectedRegistrationReason,
                    otherController: _viewModel.otherReasonController,
                    onChanged: (value) => _viewModel.setRegistrationReason(value),
                  ),
                  SizedBox(height: 20.h),

                  // Pregunta 3
                  _buildQuestionCard(
                    title: "¿Qué te ha impedido realizar tu primer viaje?",
                    options: const [
                      "El precio",
                      "No encontré el vehículo que necesitaba",
                      "No lo necesitaba todavía",
                      "No entendí cómo solicitarlo",
                      "Todavía no me siento seguro usando el servicio",
                      "Otro",
                    ],
                    selectedValue: _viewModel.selectedBarrierReason,
                    otherController: _viewModel.otherBarrierController,
                    onChanged: (value) => _viewModel.setBarrierReason(value),
                  ),
                  SizedBox(height: 30.h),

                  SizedBox(
                    width: double.infinity,
                    height: 40.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.confirmationscolor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      onPressed: _viewModel.isLoading ? null : _handleSurveySubmit,
                      child: _viewModel.isLoading
                          ? SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: const CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Continuar",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionCard({
    required String title,
    required List<String> options,
    required String? selectedValue,
    required TextEditingController otherController,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12.sp),
          ...options.map((option) {
            final bool isSelected = selectedValue == option;
            return Column(
              children: [
                GestureDetector(
                  onTap: () => onChanged(option),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black26.withOpacity(0.15) : Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.white12,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isSelected ? Colors.white : Colors.grey,
                          size: 20.sp,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 12.sp,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (option == 'Otro' && isSelected) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: TextField(
                      controller: otherController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Escribe tu respuesta...",
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                        filled: true,
                        fillColor: Colors.black45,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: _primaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }
}
