
import 'package:flutter/material.dart';
import 'package:holi/src/theme/colors/app_theme.dart';
import 'package:holi/src/view/user/home_user.dart';
import 'package:holi/src/widget/button/button_account.dart';
import 'package:holi/src/utils/controllers/register_controller.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Clave para el formulario
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final RegisterController _registerController = RegisterController();

  // Variables de desplazamiento
  final double _emailYOffset = 100;
  final double _passwordYOffset = 180;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Atras",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => {Navigator.pop(context)},
        ),
      ),
      backgroundColor: AppTheme.colorbackgroundview,
      body: Padding(
        padding: const EdgeInsets.only(top: 180.0, left: 15.0, right: 15.0),
        child: Stack(
          // Usamos Stack para manejar la posición absoluta
          children: [
            const Positioned(
              top: 35,
              left: 15,
              child: Text(
                "Crea una cuenta en Holi",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Formulario para gestionar los inputs de manera optimizada
            Positioned(
              top: _emailYOffset,
              left: 10,
              right: 10,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: "Ingresa tu nombre completo",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black87, width: 2.0)),
                          floatingLabelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    const SizedBox(height: 20),

                    // Campo de correo
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: "Ingresa tu email",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black87, width: 2.0)),
                          floatingLabelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          )),

                    ),
                    const SizedBox(height: 20),
                    // Campo de contraseña
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: "Ingresa tu contraseña",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black87, width: 2.0)),
                          floatingLabelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          )),
                          
                    ),
                    const SizedBox(height: 20),
                    // Botón de login
                   ButtonAuth(formKey: _formKey, onPressed: _handleCreateAccount),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCreateAccount() async {
final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (_formKey.currentState!.validate()) {
      final messageError = await _registerController.registerUser(
        name: name,
        email: email,
        password: password,
      );

      if (messageError == null) {
        print("Registro exitoso, redirigiendo...");
        // Si no hay error, redirige al HomeUser
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeUser()),
        );
      } else {
        // Si hay un error, muestra un mensaje
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            messageError ?? "Algo salió mal",
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Por favor, completa todos los campos correctamente."),
      ));
    }
  } 

 

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
