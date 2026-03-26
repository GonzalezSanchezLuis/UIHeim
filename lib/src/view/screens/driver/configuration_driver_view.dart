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
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        title: Text(
          "Configuración",
          style: StyleFontsTitle.titleStyle,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20.sp,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
        children: [
          _buildSettingOption(
            title: "Mi perfil",
            icon: Icons.person,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileView()));
            },
          ),
          _buildSettingOption(
            title: "Info del vehículo",
            icon: Icons.car_rental,
            onTap: () {
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
            icon: Icons.privacy_tip,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const TearmAndCondition()));
            },
          ),
          _buildSettingOption(
            title: "Acerca de",
            icon: Icons.info,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const About()));
            },
          ),
          _buildSettingOption(
            title: "Salir de la app",
             icon: Icons.logout_rounded,
            isDestructive: true,
            onTap: () async {
              _showLogoutDialog(context);
              /* final isLoggedOut = await _authService.logout();
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
              } */
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingOption({
    required String title,
    required VoidCallback onTap,
    required IconData icon,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: AppTheme.colorcards,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        margin: EdgeInsets.symmetric(vertical: 6.h),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 5.w),
          child: Row(
            children: [
              Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: isDestructive ? Colors.red.withOpacity(0.1) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    icon,
                    color: isDestructive ? Colors.red.withOpacity(0.1) : Colors.grey[800],
                    size: 22.sp,
                  )),
              SizedBox(
                width: 16.w,
              ),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDestructive ? Colors.red[700] : Colors.black87,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey[400],
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showLogoutDialog(BuildContext context) {
  final AuthService _authService = AuthService();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      title: Text("Abandonaras la app?", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
      content: Text("Tendrás que ingresar tus credenciales nuevamente.", style: TextStyle(fontSize: 14.sp)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar", style: TextStyle(color: Colors.black)),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            final isLoggedOut = await _authService.logout();
            if (isLoggedOut) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
                (route) => false,
              );
            }
          },
          child: const Text("Salir", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}

/*Widget _buildSettingOption({required String title, required VoidCallback onTap, required IconData icon}) {
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
} */
