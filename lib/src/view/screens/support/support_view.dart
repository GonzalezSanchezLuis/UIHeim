import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_title.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Support extends StatelessWidget {
  const Support({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        backgroundColor: AppTheme.primarycolor,
        title: Text(
          "Atras",
          style:  StyleFontsTitle.titleStyle,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               SizedBox(height: 30.sp),
               Text(
                "Bienvenido a soporte",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
              ),
               Text(
                "¿En qué podemos ayudarte hoy?",
                style: TextStyle(fontSize: 14.sp, color: Color.fromARGB(255, 155, 149, 149)),
              ),
               SizedBox(height: 20.h),
              _buildPaymentOption("assets/images/whatsapp.svg", "Envianos un mensaje por WhatsApp", context),
              _buildPaymentOption("assets/images/email.svg", "Dejanos un email", context),
               SizedBox(height: 30.h),
              const Divider(thickness: 1),
               SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String imagePath, String method, BuildContext context) {
    return Card(
      elevation: 2,
      margin:  EdgeInsets.symmetric(vertical: 8.h),
      child: ListTile(
          leading: SvgPicture.asset(imagePath, width: 30.w, height: 30.w),
          title: Text(method,style: TextStyle(fontSize: 15.sp),),
          onTap: () {
            if (method == "Envianos un mensaje por WhatsApp") {
              _openWhatsApp(context);
            } else {
              _sendEmail(context);
            }
          }),
    );
  }
}

Future<void> _openWhatsApp(BuildContext context) async {
  String mensaje = "Hola equipo Heim, estoy listo para mover mi hogar. ¿Me dan una mano con unos detalles?";
  String encodedMensaje = Uri.encodeComponent(mensaje);

  final whatsappUrl = Uri.parse("whatsapp://send?phone=3337603630&text=$encodedMensaje");
  final whatsappWeb = Uri.parse("https://wa.me/3227603630");

  try {
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    } else if (await canLaunchUrl(whatsappWeb)) {
      await launchUrl(whatsappWeb);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("WhatsApp no está instalado en este dispositivo.")));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ocurrió un error al intentar abrir WhatsApp.")));
  }
}

Future<void> _sendEmail(BuildContext context) async {
  final Uri emailUri = Uri(scheme: 'mailto', path: 'hola@heimapp.com.co', queryParameters: {'subject': 'Soporte con'});

  try {
    bool launched = await launchUrl(emailUri, mode: LaunchMode.externalApplication);

    if (!launched) {
      _showFlushbar(context, 'No se encontró una aplicación de correo instalada.', AppTheme.warningcolor);
    }
  } catch (e) {
    debugPrint("Error abriendo el email $e");
    _showFlushbar(context, 'No se pudo abrir el correo.', AppTheme.warningcolor);
  }
}

void _showFlushbar(BuildContext context, String message, Color color) {
  Flushbar(
    message: message,
    backgroundColor: color,
    duration: const Duration(seconds: 3),
    flushbarPosition: FlushbarPosition.TOP,
    borderRadius: BorderRadius.circular(8),
    margin: const EdgeInsets.all(8),
    icon: Icon(
      color == AppTheme.confirmationscolor ? Icons.check_circle : Icons.error_outline,
      color: Colors.white,
    ),
  ).show(context);
}
