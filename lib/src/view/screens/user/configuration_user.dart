import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/view/screens/about/about.dart';
import 'package:holi/src/service/auth/login._service.dart';
import 'package:holi/src/view/screens/configuration/legal.dart';
import 'package:holi/src/view/screens/user/profile.dart';
import 'package:holi/src/service/auth/auth_service.dart';

class ConfigurationUser extends StatefulWidget {
  const ConfigurationUser({super.key});

  @override
  _ConfigurationUserState createState() => _ConfigurationUserState();
}

class _ConfigurationUserState extends State<ConfigurationUser> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        title: const Text(
          "Configuración",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Vuelve a la pantalla anterior
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 16),
        children: [
          _buildSettingOption(
            title: "Mi perfil",
            onTap: () {
              // Acción al presionar esta opción
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileView()));
            },
          ),
          _buildSettingOption(
            title: "Legal",
            onTap: () {
              // Acción al presionar esta opción
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Legal()));
            },
          ),
          _buildSettingOption(
            title: "Privacidad",
            onTap: () {
              // Acción al presionar esta opción
            },
          ),
          _buildSettingOption(
            title: "Acerca de",
            onTap: () {
              // Acción al presionar esta opción
              Navigator.push(context, MaterialPageRoute(builder: (context) => const About()));
            },
          ),
          _buildSettingOption(
            title: "Cerrar sesión",
            onTap: () async {
              final isLoggedOut = await _authService.logout();
              if (isLoggedOut) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                  (route) => false,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Error al cerrar sesión")),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Widget para cada opción
  Widget _buildSettingOption({required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
