import 'package:flutter/material.dart';
class ButtonAuth extends StatelessWidget {
  const ButtonAuth({
    super.key,
    required GlobalKey<FormState> formKey,
    required this.onPressed,
  }) : _formKey = formKey;

  final GlobalKey<FormState> _formKey;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 60),
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        "Continuar",
        style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
      ),
    );
  }
}
