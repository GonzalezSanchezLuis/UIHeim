import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:holi/src/view/screens/welcome/logo.dart';
import 'package:holi/src/viewmodels/user/profile_user_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  debugPrint = (String? message, {int? wrapWidth}) {};
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProfileViewModel()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          textTheme:
              GoogleFonts.latoTextTheme(Theme.of(context).textTheme).copyWith(
            bodyMedium: GoogleFonts.ubuntu(
                textStyle: Theme.of(context).textTheme.bodyMedium),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const WelcomeView(),
      ),
    );
  }
}
