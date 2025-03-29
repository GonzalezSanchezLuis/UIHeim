import 'package:flutter/material.dart';

/*class ButtonRegister extends StatelessWidget {
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
        style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),
      ),
    );
  }
} */

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
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: const Text(
        "Entrar",
        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
