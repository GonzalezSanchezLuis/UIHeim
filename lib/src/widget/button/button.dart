import 'package:flutter/material.dart';
class Button extends StatelessWidget {
  const Button({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        minimumSize:
            Size(MediaQuery.of(context).size.width * 0.9, 60),
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        "Actualizar cuenta",
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}