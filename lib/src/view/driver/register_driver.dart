import 'package:flutter/material.dart';
import 'package:holi/src/theme/colors/app_theme.dart';
import 'package:holi/src/view/driver/home_driver.dart';
class RegisterDriver extends StatefulWidget {
  const RegisterDriver({ Key? key }) : super(key: key);

  @override
  _RegisterDriverState createState() => _RegisterDriverState();
}

class _RegisterDriverState extends State<RegisterDriver> {

   final TextEditingController _numberOfRoomsController =
      TextEditingController();
  final TextEditingController _sourceAddressController =
      TextEditingController();
  final TextEditingController _originAddressController =
      TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  // Clave para el formulario
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final double _numberOfRoomsYOffset = 100;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        title: const Text("Registrarme como conductor"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => {Navigator.pop(context)},
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0, left: 15.0, right: 15.0),
        child: Stack(
          // Usamos Stack para manejar la posición absoluta
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
                    // Campo de correo
                    TextFormField(
                      controller: _numberOfRoomsController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
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
                        labelText: "Documento",
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
                        labelText: "Telefono",
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
                      controller: _dateController,
                      readOnly:
                          true, // Evita que el usuario escriba directamente
                      decoration: const InputDecoration(
                        labelText: "Licencia ",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Botón de login
                    ElevatedButton(
                      onPressed: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomeDriver()))
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
                        "Enviar mis datos",
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
    _dateController.dispose();
    super.dispose();
  }
}