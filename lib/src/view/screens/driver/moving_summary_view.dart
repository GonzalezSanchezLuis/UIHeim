import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.colorbackgroundview,
        appBar: AppBar(
          title: const Text("Resumen del viaje", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Colors.black,
        ),
        body: Consumer<MovingSummaryViewmodel>(builder: (context, viewmodel, child) {
          if (viewmodel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (viewmodel.errorMessage != null) {
            return Center(
              child: Text("Error: ${viewmodel.errorMessage}"),
            );
          } else if (viewmodel.movingSummary != null) {
            final summary = viewmodel.movingSummary!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Destalles del viaje ",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      _buildInfoRow(
                        "Origen", summary.origin
                      ),
                      _buildInfoRow("Destino", summary.destination),
                      _buildInfoRow("Distancia", summary.distanceKm),
                      _buildInfoRow("Duracion", summary.durationMin),
                      const Divider(
                        height: 30,
                      ),
                      const Text(
                        "Pago",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      _buildInfoRow("Metodo", summary.paymentMethod),
                      _buildInfoRow("Costo total", "\$${summary.amount.toStringAsFixed(2)} COP"),
                      const SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Chip(
                          label: Text(
                           summary.paymentCompleted ? "Pago Completado" : "⌛ Pago Pendiente",
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          backgroundColor: summary.paymentCompleted ? AppTheme.confirmationscolor : Colors.orange,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context, MaterialPageRoute(builder: (_) => const HomeDriverView()));
                            },
                            child: const Text(
                              "Finalizar",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            )),
                      )
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Center(
              child: Text("No se pudo cargar el resumen de la mudanza."),
            );
          }
        }));
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
