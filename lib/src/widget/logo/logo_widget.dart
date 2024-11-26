import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
const LogoWidget({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Image.asset('assets/images/logo.png',width: 400,height: 400,
    fit: BoxFit.contain,);
  }
}