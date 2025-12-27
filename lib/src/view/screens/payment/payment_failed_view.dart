import 'package:flutter/material.dart';

class PaymentFailedView extends StatelessWidget {
  const PaymentFailedView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.error, color: Colors.red, size: 100),
            SizedBox(height: 20),
            Text(
              "Pago fallido",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
