import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/view/screens/driver/home_driver_view.dart';
import 'package:holi/src/service/auth/auth_service.dart';

class RegisterDriver extends StatefulWidget {
  const RegisterDriver({super.key});

  @override
  _RegisterDriverState createState() => _RegisterDriverState();
}

class _RegisterDriverState extends State<RegisterDriver> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _documentController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _typeVehicleController = TextEditingController();
  final TextEditingController _enrollVehicleController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Clave para el formulario
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _registerDriver = AuthService();
  final double _numberOfRoomsYOffset = 100;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
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
                    TextFormField(
                      controller: _fullNameController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: "Nombre Completo",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 2.0)),
                          floatingLabelStyle: TextStyle(
                            color: Colors.black, // Cambia este color al que prefieras
                            fontWeight: FontWeight.bold, // Opcional, para resaltar
                          )),
                    ),

                    const SizedBox(height: 20),

                    // Campo de correo
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 2.0)),
                          floatingLabelStyle: TextStyle(
                            color: Colors.black, // Cambia este color al que prefieras
                            fontWeight: FontWeight.bold, // Opcional, para resaltar
                          )),
                    ),
                    const SizedBox(height: 20),
                    // Campo de contraseña
                    TextFormField(
                      controller: _documentController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: "Documento",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 2.0)),
                          floatingLabelStyle: TextStyle(
                            color: Colors.black, // Cambia este color al que prefieras
                            fontWeight: FontWeight.bold, // Opcional, para resaltar
                          )),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _phoneController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: "Telefono",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 2.0)),
                          floatingLabelStyle: TextStyle(
                            color: Colors.black, // Cambia este color al que prefieras
                            fontWeight: FontWeight.bold, // Opcional, para resaltar
                          )),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _licenseController,
                      decoration: const InputDecoration(
                          labelText: "Licencia ",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 2.0)),
                          floatingLabelStyle: TextStyle(
                            color: Colors.black, // Cambia este color al que prefieras
                            fontWeight: FontWeight.bold, // Opcional, para resaltar
                          )),
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
                          )),
                    ),

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
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                          labelText: "Contraseña",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 2.0)),
                          floatingLabelStyle: TextStyle(
                            color: Colors.black, // Cambia este color al que prefieras
                            fontWeight: FontWeight.bold, // Opcional, para resaltar
                          )),
                    ),
                    // Botón de login
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () => {
                        // _handleRegisterDriver()
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeDriver()))
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 60),
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
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
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final document = _documentController.text.trim();
    final phone = _phoneController.text.trim();
    final licenseNumber = _licenseController.text.trim();
    final vehicleType = _typeVehicleController.text.trim();
    final enrollVehicle = _enrollVehicleController.text.trim();
    final password = _passwordController.text.trim();

    if (_formKey.currentState!.validate()) {
      final messageError = await _registerDriver.registerDriver(
          name: fullName,
          email: email,
          document: document,
          phone: phone,
          licenseNumber: licenseNumber,
          vehicleType: vehicleType,
          enrollVehicle: enrollVehicle,
          password: password);

      if (messageError == null) {
        print("Redirigiendo");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeDriver()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              messageError ?? "Algo salio mal",
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red));
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _documentController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _typeVehicleController.dispose();
    _enrollVehicleController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
