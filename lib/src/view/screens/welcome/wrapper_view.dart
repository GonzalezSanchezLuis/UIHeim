import 'package:flutter/material.dart';
import 'package:holi/src/view/screens/auth/login_view.dart';
import 'package:holi/src/view/screens/welcome/introducction_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WrapperView extends StatelessWidget {
  const WrapperView({super.key});

  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final bool intoView = prefs.getBool('intro_view') ?? false;

    if (intoView) {
      return const LoginView();
    } else {
      return const IntroductionView();
    }
  }
    @override
    Widget build(BuildContext context) {
      return FutureBuilder<Widget>(
          future: _getInitialScreen(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return snapshot.data!;
            }
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(),),
            );
          });
    }
  }
