import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';

class PaymentView extends StatelessWidget {
  final String origin = "Calle 23 #45-12";
  final String destination = "Carrera 7 #92-11";
  final double distanceKm = 8.5;
  final int durationMin = 17;
  final double totalAmount = 15800;
  final String paymentMethod = "Daviplata"; // Cambia a "Daviplata" para probar
  final String paymentInfo = "Tel. ****9821";

  const PaymentView({super.key});

  Color _getPaymentColor() {
    if (paymentMethod.toLowerCase() == "nequi") {
      return const Color(0xFF7B1FA2); // Morado
    } else if (paymentMethod.toLowerCase() == "daviplata") {
      return const Color(0xFFE53935); // Rojo
    }
    return Colors.orange; // Color por defecto
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        title: const Text(
          "Pago del viaje",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
                            "¡Viaje finalizado!",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text("Origen: $origin", style: const TextStyle(fontSize: 16)),
                      Text("Destino: $destination", style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        "Distancia: ${distanceKm} km | Tiempo: ${durationMin} min",
                        style: const TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                      const Divider(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total a pagar:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(
                            "\$${totalAmount.toStringAsFixed(0)} COP",
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
                              Icon(
                                paymentMethod == "daviplata" ? Icons.account_balance_wallet : Icons.account_balance,
                                color: _getPaymentColor(),
                              ),
                              const SizedBox(width: 5),
                              Text("$paymentMethod ($paymentInfo)"),
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Aquí iría la lógica para abrir el enlace de pago Wava")),
                );
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
