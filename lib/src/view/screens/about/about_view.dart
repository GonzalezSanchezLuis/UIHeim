import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primarycolor,
      appBar: AppBar(
         backgroundColor: AppTheme.primarycolor,
        title: const Text('Acerca de Heim', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.white,),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
