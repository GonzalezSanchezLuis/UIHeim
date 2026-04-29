import 'dart:developer';
import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_title.dart';
import 'package:holi/src/service/fcm/firebase_messaging_service.dart';
import 'package:holi/src/view/screens/driver/home_driver_view.dart';
import 'package:holi/src/view/screens/tearm/privacy_policy_view.dart';
import 'package:holi/src/view/screens/tearm/tearm_and_condition_view.dart';
import 'package:holi/src/viewmodels/auth/auth_viewmodel.dart';
import 'package:holi/src/viewmodels/fcm/fcm_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegisterDriver extends StatefulWidget {
  const RegisterDriver({super.key});

  @override
  _RegisterDriverState createState() => _RegisterDriverState();
}

class _RegisterDriverState extends State<RegisterDriver> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _documentController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _licenseCategoryController = TextEditingController();
  final TextEditingController _typeVehicleController = TextEditingController();
  final TextEditingController _enrollVehicleController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final double _numberOfRoomsYOffset = 100;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.colorbackgroundview,
        appBar: AppBar(
          backgroundColor: AppTheme.primarycolor,
          title:  Text(
            "Únete a la tribu de conductores",
            style: StyleFontsTitle.titleStyle,
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 22.sp,
            ),
            onPressed: () => {Navigator.pop(context)},
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),
                  _buildField(
                      controller: _phoneController,
                      label: "Número de teléfono",
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'El teléfono es obligatorio';
                        if(!RegExp(r'^3[0-9]{9}$').hasMatch(value)) return 'Ingresa un celular válido (10 dígitos)';
                      }),
                  SizedBox(height: 20.h),
                  _buildField(
                    controller:_documentController, 
                    label:  "Número de documento",
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'El documento es obligatorio';
                      if (!RegExp(r'^[0-9]{7,10}$').hasMatch(value)) return 'Documento inválido';
                      return null;
                    },
                    ),
                  SizedBox(height: 20.h),

                  _buildField(
                    controller: _licenseController,
                    label: "Licencia de conducir",
                    keyboardType: TextInputType.visiblePassword, // Permite letras y números
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'La licencia es obligatoria';
                      if (value.length < 5) return 'Número de licencia demasiado corto';
                      if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value.trim())) {
                        return 'No uses puntos, comas ni espacios';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 20.h),
                  _buildField(
                    controller: _licenseCategoryController,
                    label: "Categoría (Ej: C2, B2)",
                    textCapitalization: TextCapitalization.characters, 
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'La categoría es obligatoria';
                      // RegEx para formatos como A1, B2, C3, etc.
                      if (!RegExp(r'^[ABC][1-3]$').hasMatch(value.trim().toUpperCase())) {
                        return 'Formato inválido (Ej: C1, C2)';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),
                  _buildField(
                    controller: _typeVehicleController,
                    label: "Tipo de vehículo (Ej: Turbo, NHR)",
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'El tipo de vehículo es obligatorio';
                      if (value.length < 3) return 'Ingresa una descripción válida';
                      if (RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                        return 'Escribe el nombre del tipo de vehículo';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),
                  _buildField(
                    controller :_enrollVehicleController,
                    label: "Placas del vehículo",
                    validator: (value){
                      if (value == null || value.isEmpty) return 'La placa es obligatoria';
                        if (!RegExp(r'^[A-Z]{3}[0-9]{3}$|^[A-Z]{3}[0-9]{2}[A-Z]{1}$').hasMatch(value.toUpperCase())) {
                          return 'Formato inválido (Ej: ABC123)';
                        }
                        return null;
                    }),
                  SizedBox(height: 30.h),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                        child: Text.rich(
                          TextSpan(
                            text: "Al registrarte, aceptas nuestras reglas de juego ",
                            style: TextStyle(fontSize: 11.sp, color: Colors.black54),
                            children: [
                              TextSpan(
                                text: "Términos y Condiciones",
                                style: const TextStyle(
                                  color: Colors.black,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    print("Navegar a TÉRMINOS");
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const TearmAndCondition()));
                                    // Aquí pones tu Navigator.push o launchUrl
                                  },
                              ),
                              const TextSpan(text: " y "),
                              TextSpan(
                                text: "cómo cuidamos tu información",
                                style: const TextStyle(
                                  color: Colors.black,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    print("Navegar a PRIVACIDAD");
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyView()));
                                  
                                  },
                              ),
                              const TextSpan(
                                text: ".En Heim no solo movemos cajas, movemos la confianza de la gente. Por eso, nos tomamos hasta 5 días para validar que eres el aliado que nuestra tribu necesita. Te avisaremos en cuanto estés listo para rodar.",
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 20.w),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegisterDriver,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 60.h),
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 24.h,
                                width: 24.h,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Empezar a ser un aliado",
                                style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: TextStyle(fontSize: 15.sp),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.black87, width: 1.5),
        ),
        floatingLabelStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 14.sp,
        ),
      ),
      validator: validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Este campo es obligatorio';
            }
            return null;
          },
    );
  }

  void _handleRegisterDriver() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getInt('userId');
        const  role = 'DRIVER';

        log("id del usuario actual $userId");

        final registerDriverViewModel = Provider.of<AuthViewModel>(context, listen: false);

        if (userId == null) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error: No se encontró el ID del usuario")),
          );
          return;
        }
        final fcmToken = await FirebaseMessaging.instance.getToken();
        
        final success = await registerDriverViewModel.registerDriver(
          userId: userId,
          document: _documentController.text.trim(),
          phone: _phoneController.text.trim(),
          licenseNumber: _licenseController.text.trim(),
          licenseCategory: _licenseCategoryController.text.trim(),
          vehicleType: _typeVehicleController.text.trim(),
          enrollVehicle: _enrollVehicleController.text.trim(),
          fcmToken:fcmToken!,
          role: role

        );

        setState(() => _isLoading = false);

        if (success) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('role', 'DRIVER');

          _showFlushbar('Todo salio bien', 'Hemos registrado tus datos con éxito.', AppTheme.confirmationscolor, Icons.check_circle_outline);
          setState(() => _isLoading = false);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeDriverView()));
        } else {
          setState(() => _isLoading = false);
          final error = registerDriverViewModel.errorMessage ?? "Algo salió mal";
          _showFlushbar('Hubo un error', error, AppTheme.warningcolor, Icons.error_outline);
        }
      } catch (e) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showFlushbar(String title, String message, Color color, IconData icon) {
    Flushbar(
      title: title,
      message: message,
      backgroundColor: color,
      icon: Icon(icon, size: 28.sp, color: Colors.white),
      borderRadius: BorderRadius.circular(12.r),
      margin: EdgeInsets.all(12.w),
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  @override
  void dispose() {
    _documentController.dispose();
    _phoneController.dispose();
    _licenseCategoryController.dispose();
    _licenseController.dispose();
    _typeVehicleController.dispose();
    _enrollVehicleController.dispose();
    super.dispose();
  }
}
