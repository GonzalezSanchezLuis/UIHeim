import 'package:flutter/material.dart';
import 'package:holi/src/view/user/home_user.dart';

class ButtonRegister extends StatelessWidget {
  const ButtonRegister({
    super.key,
    required GlobalKey<FormState> formKey,
  }) : _formKey = formKey;

  final GlobalKey<FormState> _formKey;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState?.validate() ?? false) {
          // Procesar el login
        }
      },
      style: ElevatedButton.styleFrom( 
        minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 60),                   
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        "Registrarme",
        style: TextStyle(color: Colors.white,fontSize: 20),
      ),
    );
  }
}

class buttonLogin extends StatelessWidget {
  const buttonLogin({
    super.key,
    required GlobalKey<FormState> formKey,
  }) : _formKey = formKey;

  final GlobalKey<FormState> _formKey;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState?.validate() ?? false) {
         Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const HomeUser()));
          // Procesar el login
        }
      },
      style: ElevatedButton.styleFrom( 
        minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 60),                   
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        "Iniciar sesión",
        style: TextStyle(color: Colors.white,fontSize: 20),
      ),
    );
  }
}
