import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_welcome.dart';
import 'package:holi/src/view/screens/auth/create_account_view.dart';
import 'dart:async';
import 'package:holi/src/view/screens/auth/login_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      if (_currentPage < 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(_currentPage, duration: const Duration(microseconds: 600), curve: Curves.easeInOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) => setState(() {
                  _currentPage = page;
                }),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(2, (index) => _buildDot(index)),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 45.h,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginView()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                          ),
                          child:  Text(
                            "Iniciar sesión",
                            style: StyleFonts.textColorButton,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                        child: SizedBox(
                      height: 45.h,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CreateAccount()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFBC11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.r),
                          ),
                        ),
                        child: Text(
                          "Registrarme",
                          style: StyleFonts.textColorButton,
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      height: 8.h,
      width: _currentPage == index ? 20.w : 8.w,
      decoration: BoxDecoration(
        color: _currentPage == index ? const Color(0xFFFFBC11) : Colors.white24,
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}

Widget _buildPageContent({required String image, required String title, required String description}) {
  return Padding(
    padding: EdgeInsets.all(24.w),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(image, height: 220.h, fit: BoxFit.contain),
        SizedBox(height: 20.h),
        Text(
          title,
          style: StyleFonts.title,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 15.h),
        Text(
          description,
          style: StyleFonts.descriptions,
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
