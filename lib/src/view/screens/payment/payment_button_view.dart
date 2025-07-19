import 'package:flutter/material.dart';
import 'package:holi/src/model/payment/payment_model.dart';
import 'package:holi/src/viewmodels/payment/payment_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PaymentButtonView extends StatelessWidget {
  final PaymentModel paymentModel;

  const PaymentButtonView({super.key, required this.paymentModel});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 60),
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        "Pagar ahora",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
      ),
     onPressed: () async {
          final paymentVM = Provider.of<PaymentViewmodel>(context, listen: false);
          await paymentVM.startPayment(paymentModel);

          final urlString = paymentVM.checkoutUrl;
          print("🔗 URL generada: $urlString");


          if (urlString != null && await canLaunchUrlString(urlString)) {
            final launched = await launchUrlString(
              urlString,
              mode: LaunchMode.externalApplication,
            );

            if (!launched) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("No se pudo abrir el enlace de pago")),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("URL inválida o no se puede abrir")),
            );
          }
        }
    );
  }
}
