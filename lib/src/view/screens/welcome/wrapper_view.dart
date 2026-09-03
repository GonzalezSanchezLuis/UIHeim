import 'package:flutter/material.dart';
import 'package:holi/src/service/auth/auth_service.dart';
import 'package:holi/src/view/screens/auth/login_view.dart';
import 'package:holi/src/view/screens/driver/home_driver_view.dart';
import 'package:holi/src/view/screens/user/home_user_view.dart';
import 'package:holi/src/view/screens/welcome/introducction_view.dart';
import 'package:holi/src/view/widget/logo/logo_widget.dart';
import 'package:holi/src/viewmodels/auth/sesion_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WrapperView extends StatefulWidget {
  const WrapperView({super.key});

  @override
  State<WrapperView> createState() => _WrapperViewState();
}

class _WrapperViewState extends State<WrapperView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSessionAndNavigate();
    });
  }

  Future<void> _checkSessionAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final sessionViewModel = Provider.of<SessionViewModel>(context, listen: false);
    final authService = AuthService();

    final userData = await authService.validateToken();
    if (!mounted) return;

    // Error de red: conservar sesión local si existe token + rol.
    if (userData != null && userData['_networkError'] == true) {
      debugPrint("⚠️ [Wrapper] Sin red al validar. Usando sesión local.");
      final localRole = sessionViewModel.role ?? prefs.getString('role');
      final localToken = sessionViewModel.token ?? prefs.getString('token');
      if (localToken != null && localRole != null) {
        _navigateByRole(localRole);
        return;
      }
      await _goToAuthFlow(prefs, sessionViewModel, clearSession: false);
      return;
    }

    if (userData != null && userData['role'] != null) {
      await sessionViewModel.updateSession(userData);
      if (!mounted) return;
      _navigateByRole(userData['role'] as String);
      return;
    }

    await _goToAuthFlow(prefs, sessionViewModel, clearSession: true);
  }

  Future<void> _goToAuthFlow(
    SharedPreferences prefs,
    SessionViewModel sessionViewModel, {
    required bool clearSession,
  }) async {
    if (clearSession) {
      await sessionViewModel.clearSession();
    }
    if (!mounted) return;

    final introSeen = prefs.getBool('intro_view') ?? false;
    if (!introSeen) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const IntroductionView()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginView()));
    }
  }

  void _navigateByRole(String role) {
    if (role == 'USER') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeUserView()));
    } else if (role == 'DRIVER') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeDriverView()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginView()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const LogoWidget();
  }
}
