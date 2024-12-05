import 'package:flutter/material.dart';
import 'package:holi/src/theme/colors/app_theme.dart';
import 'package:holi/src/widget/button/button_account.dart';

class RequestVehicle extends StatefulWidget {
  const RequestVehicle({Key? key}) : super(key: key);

  @override
  _RequestVehicleState createState() => _RequestVehicleState();
}

class _RequestVehicleState extends State<RequestVehicle> {
  final TextEditingController _numberOfRoomsController =
      TextEditingController();
  final TextEditingController _sourceAddressController =
      TextEditingController();
  final TextEditingController _originAddressController =
      TextEditingController();

  // Clave para el formulario
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Variables de desplazamiento
  final double _numberOfRoomsYOffset = 100;
  final double _sourceAddressYOffset = 180;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        title: const Text("Solicitar vehículo"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => {Navigator.pop(context)},
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 100.0, left: 15.0, right: 15.0),
        child: Stack(
          // Usamos Stack para manejar la posición absoluta
          children: [
            const Positioned(
              top: 35,
              left: 15,
              child: Text(
                "Completa el formulario para solicitar un vehículo",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
                    // Campo de correo
                    TextFormField(
                      controller: _numberOfRoomsController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Número de de habitaciones",
                        border: OutlineInputBorder(),
                      ),
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return 'Por favor ingresa un email';
                      //   }
                      //   return null;
                      // },
                    ),
                    const SizedBox(height: 20),
                    // Campo de contraseña
                    TextFormField(
                      controller: _sourceAddressController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Dirección de origen",
                        border: OutlineInputBorder(),
                      ),
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return 'Por favor ingresa una contraseña';
                      //   }
                      //   return null;
                      // },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _originAddressController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Dirección de destino",
                        border: OutlineInputBorder(),
                      ),
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return 'Por favor ingresa una contraseña';
                      //   }
                      //   return null;
                      // },
                    ),
                    const SizedBox(height: 20),
                    // Botón de login
                    ElevatedButton(
                      onPressed: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RequestVehicle()))
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize:
                            Size(MediaQuery.of(context).size.width * 0.9, 60),
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Solicitar vehículo",
                        style: TextStyle(color: Colors.white, fontSize: 20),
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

  @override
  void dispose() {
    _numberOfRoomsController.dispose();
    _sourceAddressController.dispose();
    _originAddressController.dispose();
    super.dispose();
  }
}
