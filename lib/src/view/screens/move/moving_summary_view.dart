import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/utils/format_price.dart';
import 'package:holi/src/view/screens/driver/home_driver_view.dart';
import 'package:holi/src/viewmodels/move/moving_summary_viewmodel.dart';
import 'package:provider/provider.dart';

class MovingSummaryView extends StatefulWidget {
  final int moveId;
  const MovingSummaryView({super.key, required this.moveId});

  @override
  State<MovingSummaryView> createState() => _MovingSummaryViewState();
}

class _MovingSummaryViewState extends State<MovingSummaryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovingSummaryViewmodel>(context, listen: false).loadMovingSummary(widget.moveId);
    });
  }

  // Helper method to build info rows with bold labels
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        title: const Text(
          "Resumen del cambio de domicilio",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
    
        backgroundColor: Colors.black,
      ),
      body: Consumer<MovingSummaryViewmodel>(
        builder: (context, viewmodel, child) {
          if (viewmodel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (viewmodel.errorMessage != null) {
            return Center(child: Text("Error: ${viewmodel.errorMessage}"));
          } else if (viewmodel.movingSummary != null) {
            final summary = viewmodel.movingSummary!;
            final String paymentMethod = summary.paymentMethod.toLowerCase();

              Color _getPaymentColor() {
              final String paymentMethod = summary.paymentMethod.toLowerCase();
              if (paymentMethod.toLowerCase() == "nequi") {
                return const Color(0xFF7B1FA2); // Morado
              } else if (paymentMethod.toLowerCase() == "daviplata") {
                return const Color(0xFFE53935); // Rojo
              }
              return Colors.orange; // Color por defecto
            }


            List<String> partsOrigin = summary.origin.split(',');
            String reducedOrigin = partsOrigin.take(2).join(',').trim();

            List<String> partsDestination = summary.destination.split(',');
            String reducedDestination = partsDestination.take(2).join(',').trim();

          
            String formattedPrice = formatPriceMovingDetails(summary.amount.toString());

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
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
                              "Distancia: ${summary.distanceKm} | Tiempo: ${summary.durationMin}",
                              style: const TextStyle(fontSize: 15, color: Colors.grey),
                            ),
                            const Divider(height: 30),
                            // Total to pay and payment method
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
                                ],
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                 decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1), // Fondo muy sutil
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.orange), // Borde de color
                                ),
                                child : Row(
                                  children: [
                                  const   Icon(Icons.pending_actions, color: Colors.orange),
                                   const  SizedBox(width: 8),
                                     Text(
                                  summary.paymentCompleted ? "Pago Completado" : "Pago Pendiente",
                                  style: const TextStyle(fontSize: 16, color: Colors.white),
                                ),
                                  ],
                                )
                                
                                
                               
                             /*   backgroundColor: summary.paymentCompleted ? AppTheme.confirmationscolor : Colors.orange,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),*/
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // "Finalizar" button container at the bottom
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  child: SafeArea(
                    child:ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const HomeDriverView()),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          "Finalizar",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  
               
                ),
              ],
            );
          } else {
            return const Center(
              child: Text("No se pudo cargar el resumen de la mudanza."),
            );
          }
        },
      ),
    );
  }
}
