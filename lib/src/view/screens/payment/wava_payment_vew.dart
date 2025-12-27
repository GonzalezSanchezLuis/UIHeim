import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/view/screens/user/home_user_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WavaPaymentView extends StatelessWidget {
  final String paymentUrl;

  const WavaPaymentView({super.key, required this.paymentUrl});

  @override
  Widget build(BuildContext context) {
    // Definimos el controlador de la Webview
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('Navegación iniciada a: $url');

            // 🚨 1. Monitorear la URL para el patrón de retorno de WAVA
            if (url.startsWith('heim://pay') || url.contains('status=')) {
              // 2. Extraer los parámetros de la URL
              final uri = Uri.parse(url);
              final paymentStatus = uri.queryParameters['status'];
              if (paymentStatus == "SUCCES") {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeUserView()),
                  (Route<dynamic> route) => false,
                );
              } else {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeUserView()),
                  (Route<dynamic> route) => false,
                );
              }
            }
          },
          onPageFinished: (String url) {
            // Se puede usar para ocultar un indicador de carga
          },
        ),
      )
      ..loadRequest(Uri.parse(paymentUrl)); 

    return Scaffold(
       backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
         backgroundColor: AppTheme.primarycolor,
        title: const Text("Pago de Mudanza",
         style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
        ),
        
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
