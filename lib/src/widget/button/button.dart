import 'package:flutter/material.dart';
import 'package:holi/src/view/driver/home_driver.dart';
import 'package:holi/src/view/driver/register_driver.dart';
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

class ButtonRegisterDriver extends StatelessWidget {
  const ButtonRegisterDriver({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push((context), MaterialPageRoute(builder: (context)=> const RegisterDriver()));
      },
      style: ElevatedButton.styleFrom(
        minimumSize:
            Size(MediaQuery.of(context).size.width * 0.9, 60),
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        "Registrarme",
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}