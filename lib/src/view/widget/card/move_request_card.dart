import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holi/src/core/enums/move_type.dart';
import 'package:holi/src/core/extensions/move_type_extension.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/utils/format_price.dart';
import 'package:holi/src/viewmodels/driver/route_driver_viewmodel.dart';
import 'package:holi/src/viewmodels/travel/accept_move_viewmodel.dart';
import 'package:provider/provider.dart';

class MoveRequestCard extends StatelessWidget {
  final Map<String, dynamic> moveData;
  final Function(Map<String, dynamic>) onMoveAccepted;

  const MoveRequestCard({
    super.key,
    required this.moveData,
    required this.onMoveAccepted,
  });

  String getOriginInfo() {
    final distance = moveData['distance'];
    final eta = moveData['estimatedTimeOfArrival'];
    if (distance != null && eta != null) {
      return '(Origen) $distance ($eta)';
    } else {
      return '(Origen) Información en camino...';
    }
  }

  String getDestinationInfo() {
    final distance = moveData['distanceToDestination'];
    final eta = moveData['timeToDestination'];
    if (distance != null && eta != null) {
      return '(Destino) $distance ($eta)';
    } else {
      return '(Destino) Información en camino...';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dynamic priceRaw = moveData['price'];
    final double priceValue = priceRaw != null ? (priceRaw is num ? priceRaw.toDouble() : double.tryParse(priceRaw.toString()) ?? 0) : 0;
    final String formattedPrice = formatPriceToHundredsDriver(priceValue.toString());
    final String userName = (moveData['fullName'] ?? moveData['userName'])?.toString() ?? '';
    print("USERNAME DESDE MOVEDATA $userName");

    final String originalAddress = moveData['origin'] ?? '';
    final List<String> parts = originalAddress.split(',');
    final String reducedOriginAddress = parts.take(2).join(',').trim();

    final String destinationAddress = moveData['destination'] ?? '';
    final List<String> destParts = destinationAddress.split(',');
    final String reducedDestAddress = destParts.take(2).join(',').trim();

    final String paymentMethod = moveData['paymentMethod'];

    final String typeOfMoveStr = moveData['typeOfMove'] ?? '';
    final typeOfMove = MoveType.values.firstWhere(
      (e) => e.value == typeOfMoveStr,
      orElse: () => MoveType.XPRESS,
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: const BoxDecoration(color: Colors.black),
      child: Column(
        // Se eliminó el widget SafeArea aquí.
        // El widget Positioned padre en home_driver_view.dart ya maneja el safe area inferior.
        // Añadir otro SafeArea(bottom: true) aquí causaría un padding redundante y un posible desbordamiento.
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedPrice,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Pago con $paymentMethod',
                    style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_shipping_outlined, color: Colors.white, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      typeOfMove.displayName,
                      style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 6.h),
          const Divider(color: Colors.grey, thickness: 0.5),
          SizedBox(height: 4.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.circle, color: Colors.green, size: 12.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '${moveData['distance'] ?? "0 km"} (${moveData['estimatedTimeOfArrival'] ?? "0 min"}) • $reducedOriginAddress',
                  style: TextStyle(color: Colors.white, fontSize: 12.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: 6.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.circle, color: Colors.blueAccent, size: 12.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '${moveData['distanceToDestination'] ?? "0 km"} (${moveData['timeToDestination'] ?? "0 min"}) • $reducedDestAddress',
                  style: TextStyle(color: Colors.white, fontSize: 12.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.person, color: Colors.white, size: 12.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Recibe ${moveData['addressee'] ?? ""} ',
                  style: TextStyle(color: Colors.white, fontSize: 12.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.phone, color: Colors.white, size: 12.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Telefono ${moveData['recipientPhoneNumber'] ?? ""} ',
                  style: TextStyle(color: Colors.white, fontSize: 12.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: 4.h),
          const Divider(color: Colors.grey, thickness: 0.5),
          SizedBox(height: 4.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 10.r, // Ultra compacto
                    backgroundColor: Colors.grey[800],
                    backgroundImage: (moveData['avatarProfile'] != null && moveData['avatarProfile'].toString().isNotEmpty) ? NetworkImage(moveData['avatarProfile']) : null,
                    child: (moveData['avatarProfile'] == null || moveData['avatarProfile'].toString().isEmpty) ? Icon(Icons.person, size: 10.sp, color: Colors.white) : null,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    userName.isEmpty ? "Usuario" : userName,
                    style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                  ),
                ],
              ),
              Consumer<RouteDriverViewmodel>(
                builder: (context, viewModel, child) {
                  final int remainingTime = viewModel.remainingTime;
                  final Color borderColor = remainingTime > 10
                      ? Colors.green
                      : remainingTime > 5
                          ? Colors.yellow
                          : Colors.red;

                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: borderColor.withOpacity(0.15),
                      border: Border.all(color: borderColor, width: 1.5.w),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      '${remainingTime}s',
                      style: TextStyle(color: borderColor, fontSize: 13.sp, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // 🔘 BOTÓN DE ACCIÓN
          Consumer<AcceptMoveViewmodel>(
            builder: (context, acceptVM, child) {
              return SizedBox(
                width: double.infinity,
                height: 40.h, // Altura optimizada
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.confirmationscolor,
                    disabledBackgroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    elevation: 0,
                  ),
                  onPressed: acceptVM.isLoading
                      ? null
                      : () async {
                          final routeVM = Provider.of<RouteDriverViewmodel>(context, listen: false);
                          final moveId = int.tryParse(moveData['moveId'].toString()) ?? 0;
                          final success = await acceptVM.acceptMove(moveId);

                          if (success) {
                            routeVM.stopTimer();
                            onMoveAccepted(moveData);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Error al aceptar la carga')),
                            );
                          }
                        },
                  child: acceptVM.isLoading
                      ? SizedBox(
                          height: 18.r,
                          width: 18.r,
                          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          "ACEPTAR CARGA",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
