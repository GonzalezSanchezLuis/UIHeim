import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WaitingForDriverWidget extends StatelessWidget {
  const WaitingForDriverWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/Animation_searching.json',
              width: 70,
              height: 70,
              repeat: true,
            ),
            const SizedBox(height: 20),
            const Text(
              'Estamos buscando el vehículo adecuado',
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
