import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_title.dart';
import 'package:holi/src/view/screens/tearm/privacy_policy_view.dart';
import 'package:holi/src/view/screens/tearm/tearm_and_condition_view.dart';

class Legal extends StatelessWidget {
  const Legal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        backgroundColor: AppTheme.primarycolor,
        title: const Text("Centro de privacidad",style:  StyleFontsTitle.titleStyle,),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white,),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            width: 450,
            height: 150,
            child: Card(
              color: AppTheme.colorcards,
              margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Alinear al inicio
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TearmAndCondition(),
                          ),
                        );
                      },
                      child: const Text(
                        "Términos y condiciones de uso",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Colors.black54,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyView()))},
                      child: const Text("Politicas de Privacidad",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: Colors.black54, decoration: TextDecoration.underline)),
                    ) // Separación entre textos
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
