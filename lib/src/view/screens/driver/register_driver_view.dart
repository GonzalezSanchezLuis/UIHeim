import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/view/screens/driver/home_driver_view.dart';
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
  final TextEditingController _typeVehicleController = TextEditingController();
  final TextEditingController _enrollVehicleController = TextEditingController();

  // Clave para el formulario
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final double _numberOfRoomsYOffset = 100;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        backgroundColor: AppTheme.colorbackgroundview,
        title: const Text(
          "Registrarme como conductor",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => {Navigator.pop(context)},
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0, left: 15.0, right: 15.0),
        child: Stack(
          children: [
            // Formulario para gestionar los inputs de manera optimizada
            Positioned(
              top: _numberOfRoomsYOffset,
              left: 10,
              right: 10,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _licenseController,
                      decoration: const InputDecoration(
                          labelText: "Licencia de conducir",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 2.0)),
                          floatingLabelStyle: TextStyle(
                            color: Colors.black, // Cambia este color al que prefieras
                            fontWeight: FontWeight.bold, // Opcional, para resaltar
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
                        controller: _typeVehicleController,
                        decoration: const InputDecoration(
                          labelText: "Tipo de vehículo",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 2.0)),
                          floatingLabelStyle: TextStyle(
                            color: Colors.black, // Cambia este color al que prefieras
                            fontWeight: FontWeight.bold, // Opcional, para resaltar
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
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 2.0)),
                            floatingLabelStyle: TextStyle(
                              color: Colors.black, // Cambia este color al que prefieras
                              fontWeight: FontWeight.bold, // Opcional, para resaltar
                            )),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Este campo es obligatorio';
                          }
                          return null;
                        }),

                    // Botón de login
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _handleRegisterDriver,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 60),
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "Enviar mis datos",
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleRegisterDriver() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      log("id del usuario actual $userId");

      final registerDriverViewModel = Provider.of<AuthViewModel>(context, listen: false);

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: No se encontró el ID del usuario")),
        );
        return;
      }



      final success = await registerDriverViewModel.registerDriver(
        userId,
        _licenseController.text.trim(), 
        _typeVehicleController.text.trim(), 
        _enrollVehicleController.text.trim(),
         
         );

      setState(() => _isLoading = false);

      if (success) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeDriverView()));
      } else {
        final error = registerDriverViewModel.errorMessage ?? "Algo salió mal";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _documentController.dispose();
    _licenseController.dispose();
    _typeVehicleController.dispose();
    _enrollVehicleController.dispose();
    super.dispose();
  }
}
