import 'package:flutter/material.dart';
import 'package:holi/src/theme/colors/app_theme.dart';
class About extends StatelessWidget {
const About({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        title: const Text('Acerca de Holi'),
        leading: IconButton(icon: const Icon(Icons.arrow_back),onPressed: () => Navigator.pop(context),),
      ),
     
    );
  }
}