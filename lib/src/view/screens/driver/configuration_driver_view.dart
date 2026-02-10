import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_title.dart';
import 'package:holi/src/service/auth/auth_service.dart';
import 'package:holi/src/view/screens/about/about_view.dart';
import 'package:holi/src/view/screens/auth/login_view.dart';
import 'package:holi/src/view/screens/driver/vehicle_information.dart';
import 'package:holi/src/view/screens/tearm/legal_view.dart';
import 'package:holi/src/view/screens/driver/profile_view.dart';
import 'package:holi/src/view/screens/tearm/tearm_and_condition_view.dart';


class ConfigurationDriver extends StatefulWidget {
  const ConfigurationDriver({super.key});

  @override
  _ConfigurationDriverState createState() => _ConfigurationDriverState();
}

class _ConfigurationDriverState extends State<ConfigurationDriver> {

    final AuthService _authService = AuthService();

    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
         backgroundColor: AppTheme.primarycolor,
        title: const Text(
          "Configuración",
          style: StyleFontsTitle.titleStyle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,color: Colors.white,),
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
            icon: Icons.person,
            onTap: () {
              // Acción al presionar esta opción
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileView()));
            },
          ),
           _buildSettingOption(
            title: "Info del vehículo",
            icon: Icons.car_rental,
            onTap: () {
              // Acción al presionar esta opción
              Navigator.push(context, MaterialPageRoute(builder: (context) => const VehicleInformation()));
            },
          ),
          _buildSettingOption(
            title: "Legal",
            icon: Icons.gavel,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Legal()));
            },
          ),
          _buildSettingOption(
            title: "Privacidad",
            icon:  Icons.privacy_tip,
            onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => const TearmAndCondition()));
            },
          ),
          _buildSettingOption(
            title: "Acerca de",
            icon: Icons.info,
            onTap: () {
              // Acción al presionar esta opción
              Navigator.push(context, MaterialPageRoute(builder: (context) => const About()));
            },
          ),

         _buildSettingOption(
            title: "Cerrar sesión",
            icon: Icons.logout,
            onTap: () async {
              final isLoggedOut = await _authService.logout();
              if (isLoggedOut) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginView()),
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
  Widget _buildSettingOption({required String title, required VoidCallback onTap, required IconData icon}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          child: Row(
            children: [      
              Icon(icon,color: Colors.grey[700]),
              const SizedBox(width: 12,),
              Expanded(child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ), ),
             
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
