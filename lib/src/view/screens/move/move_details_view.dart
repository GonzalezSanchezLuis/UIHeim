import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/utils/format_date.dart';
import 'package:holi/src/utils/format_price.dart';
import 'package:holi/src/utils/reduced_address.dart';
import 'package:holi/src/viewmodels/move/moving_details_viewmodel.dart';
import 'package:provider/provider.dart';

class MoveDetailsView extends StatefulWidget {
  final int moveId;
  const MoveDetailsView({super.key, required this.moveId});
  @override
  State<MoveDetailsView> createState() => _MoveDetailsState();
}

class _MoveDetailsState extends State<MoveDetailsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final movingDetailsViewModel = Provider.of<MovingDetailsViewmodel>(context, listen: false);
      await movingDetailsViewModel.showMovingDetails(widget.moveId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Detalles del cambio de domicilio",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<MovingDetailsViewmodel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primarycolor),
            );
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Text(
                "Error: ${viewModel.errorMessage}",
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          final moveData = viewModel.movingDetails;
          if (moveData == null) {
            return const Center(
              child: Text(
                "No se encontraron datos de la mudanza.",
                style: TextStyle(fontSize: 16, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            );
          }

          final serviceCost = (moveData['amount'] as double?)?.toStringAsFixed(2) ?? 'N/A';
          final subtotal = (moveData['amount'] as double?)?.toStringAsFixed(2) ?? 'N/A';
          final totalAmount = (moveData['amount'] as double?)?.toStringAsFixed(2) ?? 'N/A';
          final paymentMethod = moveData['paymentMethod'] ?? 'N/A';
          final origin = moveData['origin'] ?? 'N/A';
          final destination = moveData['destination'] ?? 'N/A';
          final driverName = moveData['driverName'] ?? 'N/A';
          final typeOfVehicle = moveData['typeOfVehicle'] ?? 'N/A';
          final typeOfMove = moveData['typeOfMove'] ?? 'N/A';

          final reducedOrigin = reducedAddress(origin);
          final reducedDestination = reducedAddress(destination);

          final price = formatPriceMovingDetails(serviceCost);
          final priceSubtotal = formatPriceMovingDetails(subtotal);
          final priceTotalAmount = formatPriceMovingDetails(totalAmount);
          final rawDate = moveData["movingDate"] ?? "N/A";
          final format = formatDate(rawDate);

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 80),
              _buildDivider(),
              _buildSectionHeader('Fecha'),
              _buildRow(format, ""),
              _buildDivider(),
              _buildSectionHeader('Resumen de pago'),
              _buildRow('Costo del servicio', price),
              _buildRow('Subtotal', priceSubtotal),
              _buildRow('Total a pagar', priceTotalAmount, isBold: true),
              _buildRow('Metodo de pago', paymentMethod),
              _buildRowIsApproved("Pago", true),
              // _buildRow('Pago', 'aprobado'),
              _buildDivider(),
              _buildSectionHeader('Otros'),
              _buildRow('Tipo de vehículo', typeOfVehicle),
              _buildRow('Tamaño de la mudanza', typeOfMove),
              _buildDivider(),
              _buildSectionHeader('Tu viaje'),
              _buildRow("Origen", ""),
              _buildRow(reducedOrigin, ""),
              _buildRow("Destino", ""),
              _buildRow(reducedDestination, ""),
              _buildDivider(),
              _buildSectionHeader('Conductor'),
              _buildRow(driverName, "")
            ],
          );
        },
      ),
    );
  }
}

Widget _buildDivider() {
  return const Divider(color: Colors.grey, thickness: 1, height: 20);
}

Widget _buildRow(String label, String value, {bool isBold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(
          value,
          style: TextStyle(fontSize: 15, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    ),
  );
}



Widget _buildRowIsApproved(String label, bool isApproved) {
  // Use a Row to align the label and the status badge.
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(fontSize: 16)),
      // The status badge Container.
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isApproved ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isApproved ? Colors.green : Colors.red,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isApproved ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: isApproved ? Colors.green : Colors.red,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              isApproved ? 'Aprobado' : 'Rechazado',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isApproved ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildSectionHeader(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Text(
      title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF002C2B)),
    ),
  );
}



/*Widget _buildTableHeader() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTableCell('Descripción', isHeader: true),
        _buildTableCell('Cant.', isHeader: true),
        _buildTableCell('Precio', isHeader: true),
      ],
    ),
  );
}*/

/*Widget _buildTableRow(String desc, String qty, String price) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTableCell(desc),
        _buildTableCell(qty),
        _buildTableCell(price),
      ],
    ),
  );
}*/

// Función para crear una celda de la tabla
/*Widget _buildTableCell(String text, {bool isHeader = false}) {
  return Expanded(
    child: Text(
      text,
      style: TextStyle(fontSize: 16, fontWeight: isHeader ? FontWeight.bold : FontWeight.normal),
    ),
  );
}*/
