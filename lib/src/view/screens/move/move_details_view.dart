import 'package:flutter/material.dart';
import 'package:holi/src/core/enums/payment_status.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_title.dart';
import 'package:holi/src/utils/format_date.dart';
import 'package:holi/src/utils/format_price.dart';
import 'package:holi/src/utils/reduced_address.dart';
import 'package:holi/src/viewmodels/move/moving_details_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        title: Text(
          "Detalles del servicio",
          style: StyleFontsTitle.titleStyle,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 18.sp,
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
                child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Text(
                "Error: ${viewModel.errorMessage}",
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ));
          }

          final moveData = viewModel.movingDetails;
          if (moveData == null) {
            return Center(
              child: Text(
                "No se encontraron datos de la mudanza.",
                style: TextStyle(fontSize: 16.sp, color: Colors.black),
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
          final transactionalNumber = moveData['transactionalNumber'] ?? 'N/A';
          final statusStr = moveData['paymentStatus'] ?? 'FALIED';

          final status = PaymentStatus.values.firstWhere(
            (e) => e.value == statusStr,
            orElse: () => PaymentStatus.PAID,
          );
          final bool isApproved = status == PaymentStatus.PAID;

          final reducedOrigin = reducedAddress(origin);
          final reducedDestination = reducedAddress(destination);

          final price = formatPriceMovingDetails(serviceCost);
          final priceSubtotal = formatPriceMovingDetails(subtotal);
          final priceTotalAmount = formatPriceMovingDetails(totalAmount);
          final rawDate = moveData["movingDate"] ?? "N/A";
          final format = formatDate(rawDate);

          return ListView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            children: [
              SizedBox(height: 20.h),
              _buildSectionHeader('Información general'),
              _buildRow("Fecha", format),
              _buildRowTansaction("Referencia de pago N°", transactionalNumber),
              _buildDivider(),
              _buildSectionHeader('Resumen de pago'),
              _buildRow('Costo del servicio', price),
              _buildRow('Subtotal', priceSubtotal),
              _buildRow('Total a pagar', priceTotalAmount, isBold: true),
              _buildRow('Metodo de pago', paymentMethod),
              _buildRowIsApproved("Estado del pago", isApproved),
              // _buildRow('Pago', 'aprobado'),
              _buildDivider(),
              _buildSectionHeader('Detalles técnicos'),
              _buildRow('Tipo de vehículo', typeOfVehicle),
              _buildRow('Tamaño de la mudanza', typeOfMove),

              _buildDivider(),

              _buildSectionHeader('Ruta de mudanza'),
              _buildRow("Origen", reducedOrigin),
              SizedBox(height: 5.h),
              _buildRow("Destino", reducedDestination),

              _buildDivider(),
              _buildSectionHeader('Tu conductor'),
              _buildRow("Nombre", driverName),
              SizedBox(height: 40.h),
            ],
          );
        },
      ),
    );
  }
}

Widget _buildDivider() {
  return Divider(color: Colors.grey.withOpacity(0.3), thickness: 1, height: 30.h);
}

Widget _buildSectionHeader(String title) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 10.h),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF002C2B),
        letterSpacing: 1.2,
      ),
    ),
  );
}

Widget _buildRow(String label, String value, {bool isBold = false}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 6.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Alinea al techo si hay varias líneas (clave para direcciones)
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.black54,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildRowTansaction(String label, int value, {bool isBold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(
          value.toString(),
          style: TextStyle(fontSize: 15, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    ),
  );
}

Widget _buildRowIsApproved(String label, bool isApproved) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 6.h),
    child:   Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(fontSize: 14.sp,)),
      // The status badge Container.
      Container(
        padding:  EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isApproved ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isApproved ? Colors.green : Colors.red,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isApproved ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: isApproved ? Colors.green : Colors.red,
              size: 14.sp,
            ),
             SizedBox(width: 5.w),
            Text(
              isApproved ? 'Aprobado' : 'Rechazado',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: isApproved ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    ],
  ),);


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
