import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_title.dart';
import 'package:url_launcher/url_launcher.dart';

class Support extends StatelessWidget {
  const Support({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        backgroundColor: AppTheme.primarycolor,
        title: const Text(
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
              const SizedBox(height: 30),
              const Text(
                "Bienvenido a soporte",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const Text(
                "¿En qué podemos ayudarte hoy?",
                style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 155, 149, 149)),
              ),
              const SizedBox(height: 20),
              _buildPaymentOption("assets/images/whatsapp.svg", "Envianos un mensaje por WhatsApp", context),
              _buildPaymentOption("assets/images/email.svg", "Dejanos un email", context),
              const SizedBox(height: 30),
              const Divider(thickness: 1),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String imagePath, String method, BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
          leading: SvgPicture.asset(imagePath, width: 25, height: 25),
          title: Text(method),
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
  final whatsappUrl = Uri.parse("whatsapp://send?phone=3217181031&text=Hola");
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
  final Uri emailUri = Uri(scheme: 'mailto', path: 'luisrbn10@outlook.es', queryParameters: {'subject': 'Soporte con'});

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
