import 'package:flutter/material.dart';
import 'package:holi/src/view/welcome/logo.dart';
import 'package:google_fonts/google_fonts.dart';

void main(){
  debugPrint = (String? message, {int? wrapWidth}) {};
  runApp(const App());
  
}

  class App extends StatelessWidget {
    const App({super.key});
    @override
    Widget build(BuildContext context) {
      final textTheme = Theme.of(context).textTheme;
      return MaterialApp(
        theme: ThemeData(
          textTheme: GoogleFonts.latoTextTheme(textTheme).copyWith(
            bodyMedium: GoogleFonts.ubuntu(textStyle: textTheme.bodyMedium),
          ),
        ),
       debugShowCheckedModeBanner:  false,
       home:  const WelcomeView(),
      );
    }
  }

