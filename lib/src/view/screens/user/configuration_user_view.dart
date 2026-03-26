import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_title.dart';
import 'package:holi/src/view/screens/about/about_view.dart';
import 'package:holi/src/view/screens/auth/login_view.dart';
import 'package:holi/src/view/screens/tearm/legal_view.dart';
import 'package:holi/src/view/screens/user/profile_view.dart';
import 'package:holi/src/service/auth/auth_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConfigurationUser extends StatefulWidget {
  const ConfigurationUser({super.key});

  @override
  _ConfigurationUserState createState() => _ConfigurationUserState();
}

class _ConfigurationUserState extends State<ConfigurationUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        backgroundColor: AppTheme.primarycolor,
        elevation: 2,
        title:  Text(
          "Configuración",
          style: StyleFontsTitle.titleStyle,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Legal()));
            },
          ),
          _buildSettingOption(
            title: "Acerca de",
            icon: Icons.info,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const About()));
            },
          ),
          SizedBox(
            height: 20.h,
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
