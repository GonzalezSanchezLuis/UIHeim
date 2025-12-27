import 'dart:developer';
import 'package:another_flushbar/flushbar.dart';
import 'package:holi/src/viewmodels/auth/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/view/screens/driver/home_driver_view.dart';
import 'package:holi/src/view/screens/support/support_view.dart';
import 'package:holi/src/view/screens/user/home_user_view.dart';
import 'package:holi/src/view/widget/button/button_account_widget.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_account.dart';
import 'package:holi/src/viewmodels/auth/password_reset_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final passwordVM = Provider.of<PasswordResetViewmodel>(context);

    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: _isLoading ? Colors.black : AppTheme.colorbackgroundview,
        body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(children: [
              if (!_isLoading) ...[
                Positioned.fill(
                  child: SingleChildScrollView(
                    physics: isKeyboardOpen ? const ClampingScrollPhysics() : const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 200),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!isKeyboardOpen) ...[
                            const Text(
                              "Ingresar a mi cuenta de Heim",
                              textAlign: TextAlign.center,
                              style: StyleFontsAccount.titleStyle,
                            ),
                            const SizedBox(height: 20),
                          ],
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: "Ingresa tu correo electrónico",
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black87, width: 2.0),
                              ),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 2.0)),
                              floatingLabelStyle: TextStyle(
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
                              enabledBorder: const OutlineInputBorder(
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
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: SafeArea(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Support()),
                            );
                          },
                          child: Image.asset(
                            'assets/images/support.png',
                            width: 30,
                            height: 30,
                          ),
                        ),
                        const SizedBox(width: 10),
                      GestureDetector(
                          onTap: () {
                            final TextEditingController emailController = TextEditingController();

                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              backgroundColor: AppTheme.primarycolor,
                              builder: (BuildContext context) {
                                final passwordVM = Provider.of<PasswordResetViewmodel>(context);

                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).viewInsets.bottom,
                                    left: 20,
                                    right: 20,
                                    top: 20,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Recuperar contraseña',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                                      ),
                                      const SizedBox(height: 10),
                                      TextFormField(
                                        controller: emailController,
                                        decoration: const InputDecoration(
                                          labelText: 'Ingresa tu correo electrónico',
                                          border: OutlineInputBorder(),
                                          focusedBorder:  OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.white, width: 2.0),
                                          ),
                                          enabledBorder:  OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.white, width: 2.0),
                                          ),
                                          floatingLabelStyle:  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                        style: const TextStyle(color: Colors.white),
                                        keyboardType: TextInputType.emailAddress,
                                      ),
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: passwordVM.isLoading
                                              ? null
                                              : () async {
                                                  String email = emailController.text.trim();
                                                  if (email.isEmpty || !email.contains('@')) {
                                                    _showFlushbar(context, "Por favor ingresa un correo válido", Colors.orange);
                                                    return;
                                                  }
                                                  await passwordVM.resetPassword(email);
                                                  if (passwordVM.successMessage != null) {
                                                    if (context.mounted) {
                                                      Navigator.pop(context);
                                                      _showFlushbar(context, passwordVM.successMessage!, AppTheme.confirmationscolor);
                                                    }
                                                  } else if (passwordVM.errorMessage != null) {
                                                    _showFlushbar(context, passwordVM.errorMessage!, Colors.red);
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.confirmationscolor,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                            padding: const EdgeInsets.symmetric(vertical: 18),
                                          ),
                                          child: passwordVM.isLoading
                                              ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                                )
                                              : const Text('Enviar mi email', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: const Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(color: Colors.black, fontSize: 14),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
              if (_isLoading) const Center(child: CircularProgressIndicator(color: Colors.white)),
            ])));
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (!_formKey.currentState!.validate()) return;

    if (email.isEmpty || password.isEmpty) {
      Flushbar(
        title: 'Error',
        message: 'Por favor, ingresa tu correo y contraseña',
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

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    try {
       if (mounted) setState(() => _isLoading = true);
      final response = await authViewModel.login(email, password);

     // if (mounted) setState(() => _isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('intro_view', true);
      final role = prefs.getString('role');

      log("ROL OBTENIDO: $role");

      if (role == "USER") {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeUserView()));
      } else if (role == "DRIVER") {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeDriverView()));
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      final error = authViewModel.errorMessage ?? "Correo o contraseña incorrectos.";

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
   /* finally {
      if (mounted) setState(() => _isLoading = false);
    }*/
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

void _showFlushbar(BuildContext context, String message, Color color) {
  Flushbar(
    message: message,
    backgroundColor: color,
    duration: const Duration(seconds: 3),
    flushbarPosition: FlushbarPosition.TOP, 
    borderRadius: BorderRadius.circular(8),
    margin: const EdgeInsets.all(8),
    icon: Icon(
      color == AppTheme.confirmationscolor ? Icons.check_circle : Icons.error_outline,
      color: Colors.white,
    ),
  ).show(context);
}
