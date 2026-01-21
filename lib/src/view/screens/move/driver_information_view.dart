import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/viewmodels/driver/driver_data_viewmodel.dart';
import 'package:provider/provider.dart';

class DriverInformationView extends StatefulWidget {
  final int driverId;

  const DriverInformationView({Key? key, required this.driverId}) : super(key: key);

  @override
  State<DriverInformationView> createState() => _DriverDataViewState();
}

class _DriverDataViewState extends State<DriverInformationView> {
  final List<String> _securityChecks = ["Identidad Validada", "Antecedentes Judiciales Limpios", "Vehículo Inspeccionado", "Seguro de Carga Activo"];

 @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverDataViewmodel>().loadDriverData(widget.driverId);
    });
  }


  @override
  Widget build(BuildContext context) {
    final viewmodel = context.watch<DriverDataViewmodel>();
     if (viewmodel.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.black));
    }
    if (viewmodel.errorMessage != null) {
      return Center(child: Text("Error: ${viewmodel.errorMessage}"));
    }
    if (viewmodel.driverDataModel == null) {
      return const Center(child: Text("No se encontraron datos."));
    }

    final profile = viewmodel.driverDataModel!;
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        title: const Text("Perfil del Conductor", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:  SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 1. TARJETA PRINCIPAL (Identidad)
                _buildProfileHeader(profile),

                const SizedBox(height: 24),

                // 2. INFORMACIÓN DEL VEHÍCULO (Simulada para MVP)
                //_buildSectionTitle("Información del Vehículo"),
                const SizedBox(height: 12),
              //  _buildVehicleCard("Foton Turbo 2.5", "PLACA: JKL-987"),

                const SizedBox(height: 24),

                // 3. VERIFICACIONES DE SEGURIDAD
                _buildSectionTitle("Verificaciones de Seguridad"),
                const Divider(height: 20),
                _buildSecurityList(),

                const SizedBox(height: 30),
              ],
            ),
          ),
        )
      
    );
  }

  Widget _buildProfileHeader(dynamic profile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar con borde
            CircleAvatar(
              radius: 53,
              backgroundColor: AppTheme.primarycolor,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(profile.urlAvatar),
              ),
            ),
            const SizedBox(height: 16),
            Text(profile.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(profile.phone, style: const TextStyle(fontSize: 15, color: Colors.grey)),
            const SizedBox(height: 16),

            // Calificación con RichText (Negrita parcial)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 6),
                  RichText(
                    text: const TextSpan(
                      text: '3.9 ', // Dato simulado
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      children: [
                        TextSpan(
                          text: '(10 servicios)',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(fontSize: 18, color: Colors.grey.shade800, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildVehicleCard(String model, String plate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.local_shipping_outlined, color: Colors.black, size: 30),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(model, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(plate, style: const TextStyle(fontSize: 14, color: Colors.grey, letterSpacing: 1.2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityList() {
    return Column(
      children: _securityChecks
          .map((check) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 22),
                    const SizedBox(width: 12),
                    Text(check, style: TextStyle(fontSize: 15, color: Colors.grey.shade700)),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
