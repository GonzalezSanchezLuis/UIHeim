import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:holi/src/theme/colors/app_theme.dart';
import 'package:holi/src/widget/button/button.dart';

class JoinDriver extends StatelessWidget {
  const JoinDriver({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        title: const Text("Únete al equipo de conductores de Holi"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFff3d00), // Color principal
                      Color(0xFFd32f2f), // Un tono más oscuro
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    // Título principal
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Con DiDi Food, gana\nhasta \$630.000 por semana',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Ganancias semanales por ser nivel Leyenda',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Imagen SVG del repartidor
                    Center(
                      child: SvgPicture.asset(
                        'assets/images/background-driver.svg', // Cambia esta ruta por la imagen adecuada
                        height: 200,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              const SizedBox(height: 70),
              const Center(
                child: Text(
                  "Holi te acompaña",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(height: 30),
              // Sección de beneficios
              _buildFeatureCard(
                icon: Icons.headset_mic,
                title: 'Reportes de zonas de riesgo',
                description:
                    'Reporta zonas peligrosas para mejorar la seguridad de todos los conductores.',
              ),
              const SizedBox(height: 20),
              _buildFeatureCard(
                icon: Icons.favorite,
                title: 'Recibe atención personalizada',
                description:
                    'Nuestro equipo de soporte está disponible para ayudarte en todo momento.',
              ),
              const SizedBox(height: 20),
              buildRequirementsSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget reutilizable para las tarjetas de beneficios
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.green.shade100,
            radius: 30,
            child: Icon(icon, color: Colors.green, size: 30),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Nueva sección de requisitos
Widget buildRequirementsSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const Text(
        'Sólo necesitas',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildRequirementCard(
            icon: Icons.person,
            title: 'Ser mayor de\n18 años',
          ),
          const SizedBox(width: 10),
          _buildRequirementCard(
            icon: Icons.smartphone,
            title: 'Un teléfono\ninteligente',
          ),
          const SizedBox(width: 10),
          _buildRequirementCard(
            icon: Icons.download,
            title: 'Descargar\naplicación',
          ),
        ],
      ),
      const SizedBox(
        height: 30.0,
      ),
      const ButtonRegisterDriver(),
    ],
  );
}

// Widget para una tarjeta de requisito
Widget _buildRequirementCard({required IconData icon, required String title}) {
  return Container(
    width: 100,
    height: 120,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 30, color: Colors.black),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
      ],
    ),
  );
}
