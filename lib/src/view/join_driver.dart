import 'package:flutter/material.dart';
import 'package:holi/src/theme/colors/app_theme.dart';

class JoinDriver extends StatelessWidget {
const JoinDriver({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(title: const Text("Únete al equipo de conductores de Holi"),
      leading: IconButton(icon: const Icon(Icons.arrow_back),onPressed: ()=>{
        Navigator.pop(context)
      },)
      )
    );
  }
}