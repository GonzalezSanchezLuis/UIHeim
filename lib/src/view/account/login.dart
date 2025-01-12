import 'package:flutter/material.dart';
import 'package:holi/src/theme/colors/app_theme.dart';
import 'package:holi/src/utils/controllers/auth_controller.dart';
import 'package:holi/src/view/user/home_user.dart';
import 'package:holi/src/widget/button/button_account.dart';
import 'package:holi/src/theme/fonts/style_fonts_account.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Controladores para los campos de texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Clave para el formulario
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();

  // Variables de desplazamiento
  final double _emailYOffset = 100;
  final double _passwordYOffset = 180;
  bool _isPasswordVisible = false;

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
        padding: const EdgeInsets.only(top: 250.0, left: 15.0, right: 15.0),
        child: Stack(
          // Usamos Stack para manejar la posición absoluta
          children: [
            const Positioned(
              top: 35,
              left: 15,
              child: Text(
                "Ingresar a mi cuenta de Holi",
                style: StyleFontsAccount.titleStyle,
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
                    // Campo de correo
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          labelText: "Ingresa tu correo electrónico",
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600]),
                          border: const OutlineInputBorder(),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black87, width: 2.0)),
                          floatingLabelStyle: const TextStyle(
                            color: Colors
                                .black, // Cambia este color al que prefieras
                            fontWeight:
                                FontWeight.bold, // Opcional, para resaltar
                          )),
                    ),
                    const SizedBox(height: 20),
                    // Campo de contraseña
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                          labelText: "Ingresa tu contraseña",
                          border: const OutlineInputBorder(),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black87, width: 2.0)),
                          floatingLabelStyle: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          )),
                    ),
                    const SizedBox(height: 20),
                    // Botón de login
                    ButtonAuth(formKey: _formKey, onPressed: _handleLogin),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (_formKey.currentState!.validate()) {
      final messageError = await _authController.login(email: email, password: password);

      if (messageError == null) {
        print("Redirigiendo");
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const HomeUser()));
      }else{
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
