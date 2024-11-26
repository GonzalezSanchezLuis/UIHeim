import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:holi/src/theme/colors/app_theme.dart';
import 'package:holi/src/view/account/create_account.dart';
import 'dart:async';

import 'package:holi/src/view/account/login.dart';

class IntroductionView extends StatefulWidget {
  const IntroductionView({Key? key}) : super(key: key);

  @override
  _IntroductionViewState createState() => _IntroductionViewState();
}

class _IntroductionViewState extends State<IntroductionView> {
  final PageController _pageController = PageController();
  late Timer _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(_currentPage,
          duration: const Duration(microseconds: 400), curve: Curves.easeInOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundwelcome,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                _buildPageContent(
                  image: 'assets/images/intro1.svg',
                  title: "Tu tiempo, nuestra prioridad",
                  description:
                      "Empieza a disfrutar de una mudanza rápida y sin complicaciones.",
                ),
                _buildPageContent(
                  image: 'assets/images/intro2.svg',
                  title: "Fácil y rápido",
                  description:
                      "Crea tu cuenta y accede a nuestros servicios personalizados.",
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Acción para el botón de Iniciar sesión
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const Login()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Iniciar sesión",
                      style: AppTheme.textcolorbuttomblack),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Acción para el botón de Registrarme
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const CreateAccount()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Registrarme",
                      style: AppTheme.textcolorbuttomblack),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildPageContent(
    {required String image,
    required String title,
    required String description}) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(image, height: 250, fit: BoxFit.contain),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          description,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
