import 'package:flutter/material.dart';
import 'package:holi/src/view/screens/user/home_user_view.dart';

class PaymentSuccessView extends StatefulWidget {
  const PaymentSuccessView({super.key});

  @override
  State<PaymentSuccessView> createState() => _PaymentSuccessViewState();
}

class _PaymentSuccessViewState extends State<PaymentSuccessView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const HomeUserView()), (Route<dynamic> route) => false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 100),
            SizedBox(height: 20),
            Text(
              "¡Pago exitoso!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
