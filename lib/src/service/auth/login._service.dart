import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/service/auth/auth_service.dart';
import 'package:holi/src/view/screens/driver/home_driver.dart';
import 'package:holi/src/view/screens/support/support.dart';
import 'package:holi/src/view/screens/user/home_user.dart';
import 'package:holi/src/view/widget/button/button_account.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_account.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final double _emailYOffset = 100;
  final double _passwordYOffset = 180;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      body: Stack(
        children: [
          Positioned(
            top: 60,
            left: 15,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Support()));
              },
              child: Image.asset(
                'assets/images/support.png',
                width: 30,
                height: 30,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 450.0, left: 15.0, right: 15.0),
            child: Stack(
              children: [
                const Positioned(
                  top: 35,
                  left: 15,
                  child: Text(
                    "Ingresar a mi cuenta de Holi",
                    style: StyleFontsAccount.titleStyle,
                  ),
                ),
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
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Ingresa tu correo electrónico",
                            labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[600]),
                            border: const OutlineInputBorder(),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black87, width: 2.0),
                            ),
                            floatingLabelStyle: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: "Ingresa tu contraseña",
                            border: const OutlineInputBorder(),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black87, width: 2.0),
                            ),
                            floatingLabelStyle: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ButtonAuth(formKey: _formKey, onPressed: _handleLogin),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (_formKey.currentState!.validate()) {
      final messageError = await _authService.login(email: email, password: password);

      if (messageError == null) {
        final prefs = await SharedPreferences.getInstance();
        final role = prefs.getString('role');

        if (role == "USER") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeUser()),
          );
        } else if (role == "DRIVER") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeDriver()), // Asegúrate de tener esta pantalla
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              messageError ?? "Algo salió mal",
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
