import 'package:flutter/material.dart';
import 'package:holi/src/theme/colors/app_theme.dart';
import 'package:holi/src/view/tearm/privacy_policy.dart';
import 'package:holi/src/view/tearm/tearm_and__condition.dart';

class Legal extends StatelessWidget {
  const Legal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        title: const Text("Centro de privacidad"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Vuelve a la pantalla anterior
          },
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            width: 450,
            height: 150,
            child: Card(
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
                      onTap: () => {
                          Navigator.push(context, MaterialPageRoute(builder: (context) =>const PrivacyPolicy()))
                      },
                      child: const Text(
                      "Politicas de Privacidad",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Colors.black54,
                        decoration: TextDecoration.underline
                    )
                    ),
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