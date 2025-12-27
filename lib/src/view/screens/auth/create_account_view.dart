import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/view/screens/tearm/privacy_policy_view.dart';
import 'package:holi/src/view/screens/tearm/tearm_and_condition_view.dart';
import 'package:holi/src/view/screens/user/home_user_view.dart';
import 'package:holi/src/view/widget/button/button_account_widget.dart';
import 'package:holi/src/service/auth/auth_service.dart';
import 'package:holi/src/viewmodels/auth/auth_viewmodel.dart';
import 'package:holi/src/viewmodels/fcm/fcm_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final AuthService _authService = AuthService();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Variables de desplazamiento
  final double _emailYOffset = 100;
  final double _passwordYOffset = 180;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isLoading ? Colors.black : AppTheme.colorbackgroundview,
      appBar: AppBar(
        backgroundColor: _isLoading ? Colors.black : AppTheme.colorbackgroundview,
        title: const Text(
          "Atras",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => {Navigator.pop(context)},
        ),
      ),
      // backgroundColor: AppTheme.colorbackgroundview,
      body: Padding(
        padding: const EdgeInsets.only(top: 110.0, left: 15.0, right: 15.0),
        child: Stack(
          children: [
            const Positioned(
              top: 35,
              left: 15,
              child: Text(
                "Crea una cuenta en Heim",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
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
                      controller: _nameController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: "Ingresa tu nombre completo",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 1.0)),
                          floatingLabelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: "Ingresa tu email",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 1.0)),
                          floatingLabelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
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

                          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 1.0)),
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
                          )),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                          child: Text.rich(
                            TextSpan(
                              text: "Al registrarte aceptas nuestros ",
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
                                const TextSpan(text: "."),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 15),
                        ButtonAuth(formKey: _formKey, onPressed: _handleCreateAccount),
                      ],
                    )
                  ],
                ),
              ),
            ),
            if (_isLoading)
              Positioned.fill(
                  child: Container(
                color: Colors.black,
                child: const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)),
              ))
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
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
          Flushbar(
          title: 'Error',
          message: 'Por favor, debes completar todos los campos correctamente.',
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
        return;
      }
      if (mounted) setState(() => _isLoading = true);
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

      try {
        final success = await authViewModel.registerUser(name, email, password);
        if (success) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('intro_view', true);
          final role = prefs.getString('role');
          final userId = prefs.getInt('userId');

          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeUserView()));

          if (userId != null && role != null) {
            final fcmViewModel = FcmViewModel();
            await fcmViewModel.initFcm(userId, role);
          }
        } else {
          if (mounted) setState(() => _isLoading = false);

          final error = authViewModel.errorMessage ?? "Algo salió mal";
          Flushbar(
            title: 'Error',
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
        if (mounted) setState(() => _isLoading = false);
        Flushbar(
          title: 'Error',
          message: "Error de conexión. Inténtalo de nuevo.",
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
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
