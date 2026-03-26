import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_title.dart';
import 'package:holi/src/view/widget/button/button_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JoinDriver extends StatelessWidget {
  const JoinDriver({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
           backgroundColor: AppTheme.primarycolor,
        title: Text("Nos gustaria trabajar contigo", style: StyleFontsTitle.titleStyle,),
        leading: IconButton(
          icon:  Icon(Icons.arrow_back_ios_rounded,color: Colors.white,size: 20.w,),
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
                     SizedBox(height: 50.h),
                    // Título principal
                     Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Text(
                        'Para los que eligen el camino propio En Heim, tú no trabajas para una app, la app trabaja para ti.',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24.sp,
                        ),
                      ),
                    ),
                     SizedBox(height: 20.h),
                     Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Text(
                        'No buscamos a cualquiera. Buscamos a los mejores conductores de Bogotá.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                   SizedBox(height: 20.w),

                    // Imagen SVG del repartidor
                    Center(
                      child: SvgPicture.asset(
                        'assets/images/background-driver.svg',
                        height: 180.h,
                      ),
                    ),
                     SizedBox(height: 20.h),
                  ],
                ),
              ),
               SizedBox(height: 40.h),
               Center(
                child: Text(
                  "Por qué los mejores nos eligen.",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
               SizedBox(height: 25.h),
              // Sección de beneficios
              _buildFeatureCard(
                icon: Icons.monetization_on_sharp,
                title: 'Tus primeros pasos van por nuestra cuenta',
                description: 'Queremos que pruebes la libertad de Heim sin pagar un solo peso. Tus primeras 4 rutas son totalmente gratis para ti. Sin letras pequeñas.',
              ),
               SizedBox(height: 15.h),
              _buildFeatureCard(
                icon: Icons.headset_mic_rounded,
                title: 'Gente real, respaldando a gente real.',
                description: 'Sabemos lo que es estar en la calle. Por eso, aquí no hablas con algoritmos. Tienes un equipo humano que te conoce y te responde',
              ),
               SizedBox(height: 30.h),
              buildRequirementsSection(),
               SizedBox(height: 40.h),
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
      margin:  EdgeInsets.symmetric(horizontal: 20.w),
      padding:  EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
            radius: 25.r,
            child: Icon(icon, color: Colors.green, size: 25.r),
          ),
            SizedBox(height: 10.h),
          Text(
            title,
            style:  TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
           SizedBox(height: 8.h),
          Text(
            description,
            style: TextStyle(
              fontSize: 13.sp,
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
  return Container(
    width: double.infinity,
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
       Text(
        '¿Eres uno de los nuestros?',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
       SizedBox(height: 20.h),
     Center(
          child: SingleChildScrollView( // Por si la pantalla es muy pequeña, que no rompa
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRequirementCard(icon: Icons.person, title: '+18 años'),
                SizedBox(width: 10.w), // Espacio adaptable entre tarjetas
                _buildRequirementCard(icon: Icons.smartphone, title: 'Un teléfono\ninteligente'),
                SizedBox(width: 10.w),
                _buildRequirementCard(icon: Icons.local_shipping, title: 'Vehiculo de\ncarga'),
              ],
            ),
          ),
     ),
    /*  Row(
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
      ),*/
       SizedBox(height: 30.h,),
      const ButtonRegisterDriver(),
      
    ],
    )
  );
}

// Widget para una tarjeta de requisito
Widget _buildRequirementCard({required IconData icon, required String title}) {
  return Container(
    width: 100.w,
    height: 110.h,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 28.r, color: Colors.black),
          SizedBox(height: 8.h),
        Text(
          title,
          textAlign: TextAlign.center,
          style:  TextStyle(fontSize: 12.sp, color: Colors.black),
        ),
      ],
    ),
  );
}
