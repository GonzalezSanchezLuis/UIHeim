import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WaitingForDriverWidget extends StatelessWidget {
  const WaitingForDriverWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
        crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/Animation_searching.json',
              width: 70,
              height: 70,
              repeat: true,
            ),
            const SizedBox(height: 20),
            const Text(
              'Buscando un conductor confiable...',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

             const Text(
              'Esto puede tardar unos segundos. Mantente atento.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
