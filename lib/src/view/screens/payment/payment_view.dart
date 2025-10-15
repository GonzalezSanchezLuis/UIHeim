import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/utils/format_price.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentView extends StatelessWidget {
  final Map<String, dynamic> paymentData;

  const PaymentView({super.key, required this.paymentData});

  Color _getPaymentColor() {
    final String paymentMethod = paymentData['paymentMethod'].toLowerCase();
    if (paymentMethod.toLowerCase() == "nequi") {
      return const Color(0xFF7B1FA2); // Morado
    } else if (paymentMethod.toLowerCase() == "daviplata") {
      return const Color(0xFFE53935); // Rojo
    }
    return Colors.orange; // Color por defecto
  }

  @override
  Widget build(BuildContext context) {
    final String paymentMethod = paymentData['paymentMethod'] ?? "N/A";

    final String paymentURL = paymentData['paymentURL'] ?? "";
    final String origin = paymentData['origin'] ?? "";
    final String destination = paymentData['destination'] ?? "";
    final String distanceKm = paymentData['distanceKm'] ?? "";
    final String durationMin = paymentData['durationMin'] ?? "";

    List<String> partsOrigin = origin.split(',');
    String reducedOrigin = partsOrigin.take(2).join(',').trim();

    List<String> partsDestination = destination.split(',');
    String reducedDestination = partsDestination.take(2).join(',').trim();

    final dynamic amount = paymentData['amount'];
    final double priceInPesos = (amount is num ? amount.toDouble() : 0.0) / 100;

    String formattedPrice = formatPriceToHundredsDriver(priceInPesos.toString());

    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        title: const Text(
          "Pago del cambio de domicilio",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 28),
                          SizedBox(width: 8),
                          Text(
                            "¡Mudanza finalizada!",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text("Origen: $reducedOrigin", style: const TextStyle(fontSize: 16)),
                      Text("Destino: $reducedDestination", style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        "Distancia: $distanceKm  | Tiempo: $durationMin ",
                        style: const TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                      const Divider(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total a pagar:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(
                            formattedPrice,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Método de pago:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          Row(
                            children: [
                              Image.asset(
                                paymentMethod.toLowerCase() == "daviplata" ? 'assets/images/daviplata.png' : 'assets/images/nequi.png',
                                width: 50,
                                height: 50,
                                color: _getPaymentColor(),
                              ),

                              const SizedBox(width: 5),
                              // Text("$paymentMethod "),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _getPaymentColor(),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () async {
                try {
                  final Uri uri = Uri.parse(paymentURL);
                  print("URL DE PAGO $uri");
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No se pudo abrir el enlace de pago.")),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Error al procesar el enlace de pago.")),
                  );
                }
              },
              icon: const Icon(Icons.payment, color: Colors.white),
              label: Text(
                "Pagar con $paymentMethod",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
