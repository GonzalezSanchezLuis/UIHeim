import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';

class DriverProfileView extends StatelessWidget {
  final String name;
  final String phone;
  final String imageAsset;
  final double rating;
  final int tripCount;
  final List<String> securityChecks;

  const DriverProfileView({
    Key? key,
    required this.name,
    required this.phone,
    required this.imageAsset,
    required this.rating,
    required this.tripCount,
    required this.securityChecks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        title: const Text("Perfil del Conductor", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        backgroundColor: Colors.black,
         leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Foto del conductor
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage(imageAsset),
              backgroundColor: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),

            // Nombre
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            // Teléfono
            Text(
              phone,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 24),
                const SizedBox(width: 5),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  '($tripCount viajes)',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Verificaciones de seguridad
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Verificaciones de seguridad",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ...securityChecks.map((check) => ListTile(
                  leading: const Icon(Icons.verified, color: Colors.green),
                  title: Text(check),
                )),
          ],
        ),
      ),
    );
  }
}
