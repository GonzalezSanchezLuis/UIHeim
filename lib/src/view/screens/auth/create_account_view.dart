import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
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

  // Variables de desplazamiento
  final double _emailYOffset = 100;
  final double _passwordYOffset = 180;

  bool _isPasswordVisible = false;
  bool _isLoading = false; // Estado de carga

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.colorbackgroundview,
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
                "Crea una cuenta en Heim",
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
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 2.0)),
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
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 2.0)),
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
                      decoration: const InputDecoration(
                          labelText: "Ingresa tu contraseña",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 2.0)),
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
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Por favor, completa todos los campos correctamente.",
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

      final success = await authViewModel.registerUser(name, email, password);

      setState(() => _isLoading = false);

      if (success) {
        final prefs = await SharedPreferences.getInstance();
        final role = prefs.getString('role');
        final userId = prefs.getInt('userId');

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeUser()));

        if (userId != null && role != null) {
          final fcmViewModel = FcmViewModel();
          await fcmViewModel.initFcm(userId, role);
        }
      }else{
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
