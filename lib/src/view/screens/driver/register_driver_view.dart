import 'dart:developer';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/view/screens/driver/home_driver_view.dart';
import 'package:holi/src/view/screens/tearm/privacy_policy_view.dart';
import 'package:holi/src/view/screens/tearm/tearm_and_condition_view.dart';
import 'package:holi/src/viewmodels/auth/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterDriver extends StatefulWidget {
  const RegisterDriver({super.key});

  @override
  _RegisterDriverState createState() => _RegisterDriverState();
}

class _RegisterDriverState extends State<RegisterDriver> {
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
        title: const Text(
          "Registrarme como conductor",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
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
                    TextFormField(
                      controller: _documentController,
                      decoration: const InputDecoration(
                          labelText: "Número de documento",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 1.0)),
                          floatingLabelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          )),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _licenseController,
                      decoration: const InputDecoration(
                          labelText: "Licencia de conducir",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 1.0)),
                          floatingLabelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          )),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                        controller: _licenseCategoryController,
                        decoration: const InputDecoration(
                          labelText: "Categoria autorizada de licencia",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 1.0)),
                          floatingLabelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Este campo es obligatorio';
                          }
                          return null;
                        }),
                    const SizedBox(height: 20),
                    TextFormField(
                        controller: _typeVehicleController,
                        decoration: const InputDecoration(
                          labelText: "Tipo de vehículo",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 1.0)),
                          floatingLabelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Este campo es obligatorio';
                          }
                          return null;
                        }),
                    const SizedBox(height: 20),
                    TextFormField(
                        controller: _enrollVehicleController,
                        decoration: const InputDecoration(
                            labelText: "Placas del vehículo",
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 1.0)),
                            floatingLabelStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            )),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Este campo es obligatorio';
                          }
                          return null;
                        }),
                    const SizedBox(height: 20),
                    Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                            child: Text.rich(
                              TextSpan(
                                text: "Al registrarte como conductor aceptas nuestros ",
                                style: const TextStyle(fontSize: 13, color: Colors.black54),
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
                                    text: "Política de Privacidad",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        print("Navegar a PRIVACIDAD");
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyView()));
                                        // Aquí pones tu Navigator.push o launchUrl
                                      },
                                  ),
                                  const TextSpan(text: ". La validación de tu cuenta y antecedentes puede tardar hasta 5 días hábiles. Recibirás una notificación cuando tu perfil esté activo."),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 15),
                          ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegisterDriver,
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 60),
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isLoading ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ):
                          const Text(
                            "Enviar mis datos",
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ],
                      )
                  ],
                ),
              ),
        ),
      )
      
    );
  }

  void _handleRegisterDriver() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getInt('userId');

        log("id del usuario actual $userId");

        final registerDriverViewModel = Provider.of<AuthViewModel>(context, listen: false);

        if (userId == null) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error: No se encontró el ID del usuario")),
          );
          return;
        }

        final success = await registerDriverViewModel.registerDriver(
          userId,
          _documentController.text.trim(),
          _licenseController.text.trim(),
          _licenseCategoryController.text.trim(),
          _typeVehicleController.text.trim(),
          _enrollVehicleController.text.trim(),
        );

        setState(() => _isLoading = false);

        if (success) {
          Flushbar(
            title: 'Todo salio bien',
            message: 'Hemos registrado tus datos con éxito.',
            backgroundColor: AppTheme.confirmationscolor,
            icon: const Icon(
              Icons.check_circle_outline,
              size: 28.0,
              color: Colors.white,
            ),
            borderRadius: BorderRadius.circular(8),
            margin: const EdgeInsets.all(8),
            duration: const Duration(seconds: 3),
            flushbarPosition: FlushbarPosition.TOP,
          ).show(context);
          setState(() => _isLoading = false);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeDriverView()));
        } else {
          setState(() => _isLoading = false);
          final error = registerDriverViewModel.errorMessage ?? "Algo salió mal";
          Flushbar(
            title: 'Hubo un error',
            message: error,
            backgroundColor: AppTheme.warningcolor,
            icon: const Icon(
              Icons.error_outline,
              size: 28.0,
              color: Colors.white,
            ),
            borderRadius: BorderRadius.circular(8),
            margin: const EdgeInsets.all(8),
            duration: const Duration(seconds: 3),
            flushbarPosition: FlushbarPosition.TOP,
          ).show(context);
        }
      } catch (e) {
        setState(() => _isLoading = false);
      }
      
    }
  }

  @override
  void dispose() {
    _documentController.dispose();
    _licenseCategoryController.dispose();
    _licenseController.dispose();
    _typeVehicleController.dispose();
    _enrollVehicleController.dispose();
    super.dispose();
  }
}
