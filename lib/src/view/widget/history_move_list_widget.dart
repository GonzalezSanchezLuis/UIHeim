import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/model/move/history_moving_model.dart';
import 'package:holi/src/view/screens/move/move_details_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HistoryMoveList extends StatelessWidget {
  const HistoryMoveList({
    super.key,
    required this.moves,
  });

  final List<HistoryMovingModel> moves;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: moves.length,
      padding: EdgeInsets.only(bottom: 20.h),
      itemBuilder: (context, index) {
        final move = moves[index];
        final String originalAddress = move.origin;
        final List<String> parts = originalAddress.split(',');
        final String reducedOriginAddress = parts.take(1).join(',').trim();

        final String destinationAddress = move.destination;
        final List<String> partsDestination = destinationAddress.split(',');
        final String reducedDestinationAddress = partsDestination.take(1).join(',').trim();

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MoveDetailsView(
                  moveId: move.moveId,
                ),
              ),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 5,
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8..h),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusBadge(move.status),
                  SizedBox(height: 18.h),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: move.avatar.startsWith('http') ? NetworkImage(move.avatar) : AssetImage(move.avatar) as ImageProvider,
                        radius: 22.r,
                      ),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              move.name,
                              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              move.enrollVehicle,
                              style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.colorcards,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.all(10.w),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 7,
                          child: _buildLocationColumn('Origen', reducedOriginAddress),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Icon(Icons.arrow_right_alt, color: Colors.grey[400], size: 20.sp),
                        ),
                        Expanded(
                          flex: 4,
                          child: _buildLocationColumn('Destino', reducedDestinationAddress),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationColumn(String label, String address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, 
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
            color: const Color(0xFF002C2B),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          address,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 13.sp,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    // Definimos colores según el estado (puedes agregar más según tu modelo)
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'completada':
      case 'finalizada':
        backgroundColor = const Color(0xFFE8F5E9); // Verde muy claro
        textColor = const Color(0xFF2E7D32); // Verde oscuro
        break;
      case 'cancelada':
        backgroundColor = const Color(0xFFFFEBEE); // Rojo muy claro
        textColor = const Color(0xFFC62828); // Rojo oscuro
        break;
      case 'en curso':
      case 'proceso':
        backgroundColor = const Color(0xFFE3F2FD); // Azul muy claro
        textColor = const Color(0xFF1565C0); // Azul oscuro
        break;
      default:
        backgroundColor = Colors.grey[200]!;
        textColor = Colors.grey[800]!;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.r), // Bordes tipo "píldora"
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w800,
          fontSize: 10.sp,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
