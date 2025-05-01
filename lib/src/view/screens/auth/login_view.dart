import 'package:holi/src/viewmodels/fcm/fcm_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/service/auth/auth_service.dart';
import 'package:holi/src/view/screens/driver/home_driver_view.dart';
import 'package:holi/src/view/screens/support/support_view.dart';
import 'package:holi/src/view/screens/user/home_user_view.dart';
import 'package:holi/src/view/widget/button/button_account_widget.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_account.dart';
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
  final AuthService _authService = AuthService();

  bool _isPasswordVisible = false;
  bool _isLoading = false; // Estado de carga

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: _isLoading ? Colors.black : AppTheme.colorbackgroundview,
      body: Stack(
        children: [
          if (!_isLoading) ...[
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            String email = '';
                            return AlertDialog(  
                              backgroundColor: Colors.black,                          
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              
                              content:  SizedBox(
                                width: 300.0,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const  Text('Recuperar contraseña',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),),

                                       const SizedBox(height: 10.0,),
                                    TextField(
                                onChanged: (value) => email = value,
                                decoration: const InputDecoration(
                                  labelText: 'Ingresa tu correo electrónico',
                                  border: OutlineInputBorder(),
                                  focusedBorder:  OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white, width: 2.0),
                                  ),
                                  floatingLabelStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                
                              ),

                                  ],
                                ),
                              ),
                              
                              
                              
                              actions: [
                                TextButton(
                                  child:  Text('Cancelar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                  onPressed: () => Navigator.of(context).pop(),
                                   style: TextButton.styleFrom(backgroundColor: AppTheme.thirdcolor2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                                ),
                                ElevatedButton(
                                  child: const Text('Confirmar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                                   style: TextButton.styleFrom(backgroundColor: AppTheme.secondarycolor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),

                                  onPressed: () {
                                    // Lógica de recuperación aquí
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
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



            Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                reverse: true,
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Ingresar a mi cuenta de Heim",
                      style: StyleFontsAccount.titleStyle,
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: "Ingresa tu correo electrónico",
                              border:  OutlineInputBorder(),
                              focusedBorder:  OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black87, width: 2.0)),
                                 floatingLabelStyle:  TextStyle(
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
                  ],
                ),
              ),
            ),
          ],

          // Indicador de carga (pantalla negra con loading)
          if (_isLoading) const Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      ),
    );
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

      setState(() {
        _isLoading = true; // Activar loader
      });

      final messageError = await _authService.login(email: email, password: password);

      if (messageError == null) {
        final prefs = await SharedPreferences.getInstance();
        final role = prefs.getString('role');
        final userId = prefs.getInt('userId');

        if (userId != null && role != null) {
          final fcmViewModel = FcmViewModel();
          await fcmViewModel.initFcm(userId, role);
        }

        if (role == "USER") {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeUser()));
        } else if (role == "DRIVER") {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeDriver()));
        }
      } else {
        setState(() {
          _isLoading = false; // Desactivar loader si hay error
        });

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
