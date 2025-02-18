import 'dart:async';
import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/view/screens/welcome/introducction_view.dart';
import 'package:holi/src/view/widget/logo/logo_widget.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  _WelcomeViewState createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      // Navigate to the main app screen after 5 seconds
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const IntroductionView()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.colorbackgroundwelcome,
      body: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LogoWidget(),
          SizedBox(
            height: 20,
          )
        ],
      )),
    );
  }
}
