import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';

class MoveDetail extends StatelessWidget {
  const MoveDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        title: const Text(
          "Detalles del cambio de domicilio",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => {Navigator.pop(context)},
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            _buildDivider(),

            // Datos del Cliente
            _buildSectionHeader('Fecha'),
            _buildRow('10-01-25 - 02:03 P.M', ""),
            _buildDivider(),

            // Detalle de la compra
            _buildSectionHeader('Resumen de pago'),
            _buildRow('Costo del servicio', "\$ 70.000 COP"),
            _buildRow('Subtotal', "\$ 70.000 COP"),
            _buildRow('Total a pagar', '\$242.00', isBold: true),
            _buildRow('Metodo de pago', "Transferencia bancaria"),
            _buildDivider(),

            // Total
            _buildSectionHeader('Otros'),
            _buildRow('Tipo de vehículo', 'NPR'),
            _buildRow('Tamaño del viaje', 'Pequeño'),
            _buildDivider(),

            // Mensaje Final
            /*const Center(
              child: Text(
                '¡Gracias por su compra!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}

Widget _buildDivider() {
  return const Divider(color: Colors.grey, thickness: 1, height: 20);
}

// Función para crear una fila de datos
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

Widget _buildSectionHeader(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Text(
      title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF002C2B)),
    ),
  );
}

Widget _buildTableHeader() {
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
}

Widget _buildTableRow(String desc, String qty, String price) {
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
}

// Función para crear una celda de la tabla
Widget _buildTableCell(String text, {bool isHeader = false}) {
  return Expanded(
    child: Text(
      text,
      style: TextStyle(fontSize: 16, fontWeight: isHeader ? FontWeight.bold : FontWeight.normal),
    ),
  );
}
