import 'dart:developer';

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
  // final AuthService _authService = AuthService();

  bool _isPasswordVisible = false;
  bool _isLoading = false; // Estado de carga

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
                              enabledBorder:  OutlineInputBorder(
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
                            String email = '';
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
                                        onChanged: (value) => email = value,
                                        decoration: InputDecoration(
                                          labelText: 'Ingresa tu correo electrónico',
                                          errorText: passwordVM.errorMessage,
                                          border: const OutlineInputBorder(),
                                          focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.white, width: 2.0),
                                          ),
                                          enabledBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.white, width: 2.0),
                                          ),
                                          floatingLabelStyle: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: const TextStyle(color: Colors.white),
                                        keyboardType: TextInputType.emailAddress,
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                         
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: passwordVM.isLoading
                                                  ? null
                                                  : () async {
                                                      await passwordVM.resetPassword(email);
                                                    },
                                                 style: TextButton.styleFrom(
                                                backgroundColor: AppTheme.greenColors,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                              ),
                                              child: passwordVM.isLoading ? const CircularProgressIndicator() : const Text('Enviar mi email ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (passwordVM.successMessage != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 10),
                                          child: Text(passwordVM.successMessage!, style: const TextStyle(color: Colors.green)),
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
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ],

              // Indicador de carga (pantalla negra con loading)
              if (_isLoading) const Center(child: CircularProgressIndicator(color: Colors.white)),
            ])));
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (_formKey.currentState!.validate()) {
      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Por favor, ingresa tu correo y contraseña",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

      final success = await authViewModel.login(email, password);

      setState(() => _isLoading = false);

      if (success) {
        final prefs = await SharedPreferences.getInstance();
        final role = prefs.getString('role');
        final userId = prefs.getInt('userId');

      
        /* if (userId != null && role != null) {
          final fcmViewModel = FcmViewModel();
          await fcmViewModel.initFcm(userId, role);
        } */
       log("ROL OBTENIDO: $role");


        if (role == "USER") {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeUserView()));
        } else if (role == "DRIVER") {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeDriverView()));
        }
      } else {
        final error = authViewModel.errorMessage ?? "Algo salió mal";
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
