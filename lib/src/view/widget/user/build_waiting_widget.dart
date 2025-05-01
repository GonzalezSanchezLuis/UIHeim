import 'package:flutter/material.dart';

class WaitingForDriverWidget extends StatelessWidget {
  const WaitingForDriverWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:  [
            CircularProgressIndicator(color: Colors.amber),
            SizedBox(height: 20),
            Text(
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