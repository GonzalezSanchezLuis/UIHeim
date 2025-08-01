import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/view/widget/button/button_widget.dart';

class JoinDriver extends StatelessWidget {
  const JoinDriver({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
           backgroundColor: AppTheme.primarycolor,
        title: const Text("Nos gustaria trabajar contigo", style: TextStyle(fontWeight: FontWeight.bold, color:  Colors.white),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,color: Colors.white,),
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
                      AppTheme.confirmationscolor,
                      AppTheme.primarycolor, 

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
                        'Tus ruedas, tus reglas, \nHaz que cada trayecto cuente.',
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
                        'Súmate hoy.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Imagen SVG del repartidor
                    Center(
                      child: SvgPicture.asset(
                        'assets/images/background-driver.svg',
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
                  "Que te ofrecemos",
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
                icon: Icons.monetization_on_sharp,
                title: '100%',
                description: 'Ganas el 100% de cada servicio que completes. Conduce sin comisiones. Tú ganas, tú decides.',
              ),
              const SizedBox(height: 20),
              _buildFeatureCard(
                icon: Icons.headset_mic_rounded,
                title: 'Estamos para ayudarte. Sin robots, sin esperar horas.',
                description: 'Nuestro equipo de soporte está disponible para ayudarte en todo momento.',
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
            icon: Icons.local_shipping,
            title: 'Vehiculo de\ncarga',
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
