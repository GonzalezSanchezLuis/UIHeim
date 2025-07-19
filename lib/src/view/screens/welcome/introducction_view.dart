import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_welcome.dart';
import 'package:holi/src/view/screens/auth/create_account_view.dart';
import 'dart:async';

import 'package:holi/src/view/screens/auth/login_view.dart';


class IntroductionView extends StatefulWidget {
  const IntroductionView({super.key});

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
      _pageController.animateToPage(_currentPage, duration: const Duration(microseconds: 400), curve: Curves.easeInOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primarycolor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                _buildPageContent(
                  image: 'assets/images/intro1.svg',
                  title: "Mudarte ya no es un dolor de cabeza.",
                  description: "Puede ser tan fácil como pedir un taxi.",
                ),
                _buildPageContent(
                  image: 'assets/images/intro2.svg',
                  title: "Mudarte no debería doler",
                  description: "Nosotros lo hacemos fácil, rápido y sin complicaciones.",
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 200.0), // Mueve los botones hacia arriba
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Espacio igual entre los botones
              children: [
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Acción para el botón de Iniciar sesión
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginView()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Iniciar sesión",
                      style: StyleFonts.textColorButton,
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Acción para el botón de Registrarme
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreateAccount()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFBC11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Registrarme",
                      style: StyleFonts.textColorButton,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildPageContent({required String image, required String title, required String description}) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(image, height: 250, fit: BoxFit.contain),
        const SizedBox(height: 20),
        Text(
          title,
          style: StyleFonts.title,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          description,
          style: StyleFonts.descriptions,
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
