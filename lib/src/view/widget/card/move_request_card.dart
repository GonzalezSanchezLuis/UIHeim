import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holi/src/core/enums/move_type.dart';
import 'package:holi/src/core/extensions/move_type_extension.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_move.dart';
import 'package:holi/src/utils/format_price.dart';
import 'package:holi/src/viewmodels/driver/route_driver_viewmodel.dart';
import 'package:holi/src/viewmodels/move/accept_move_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_act/slide_to_act.dart';

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
      child: SafeArea(
        top: false,
        bottom: true,
        child: Column(
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
                Icon(Icons.circle, color: Colors.green, size: 12.sp), // Icono más pequeño e intuitivo
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

            // 🏁 DIRECCIÓN: DESTINO
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

            SizedBox(height: 4.h),
            const Divider(color: Colors.grey, thickness: 0.5),
            SizedBox(height: 4.h),

            // 👤 SECCIÓN CLIENTE Y TIMER
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
                        borderRadius: BorderRadius.circular(10.r),
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
      ),
    );
   
   /* return Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: SafeArea(
            top: false,
            bottom: true,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      'Pago con $paymentMethod',
                      style: TextStyle(color: Colors.white70, fontSize: 14.sp, letterSpacing: 0.5),
                    ),
                    Text(
                      formattedPrice,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.grey, thickness: 1),
              SizedBox(height: 5.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.circle,
                    color: Colors.green,
                    size: 20.sp,
                  ),
                  SizedBox(width: 5.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${moveData['distance'] ?? "Cargando..."} ${moveData['estimatedTimeOfArrival'] ?? "..."}',
                          style: StyleFontsMove.paragraphStyleMove,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          'Desde $reducedOriginAddress',
                                style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.circle,
                    color: Colors.blueAccent,
                    size: 20.sp,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${moveData['distanceToDestination'] ?? "Cargando..."} ${moveData['timeToDestination'] ?? "..."}',
                          style: StyleFontsMove.paragraphStyleMove,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Hasta ${moveData['destination']}',
                          style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 5.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_shipping_outlined, color: Colors.white, size: 18.sp),
                      SizedBox(width: 5.w),
                      Text(
                        'Carga ${typeOfMove.displayName}',
                        style: StyleFontsMove.paragraphStyleMove,
                      ),
                    ],
                  ),
                  
                ],
              ),

              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 25.w,
                        height: 25.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primarycolor, width: 2.w),
                        ),
                        child: CircleAvatar(
                          radius: 18.r,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: (moveData['avatarProfile'] != null && moveData['avatarProfile'].toString().isNotEmpty) ? NetworkImage(moveData['avatarProfile']) : null,
                          child: (moveData['avatarProfile'] == null || moveData['avatarProfile'].toString().isEmpty) ? Icon(Icons.person, size: 18.sp, color: Colors.black) : null,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        userName.isEmpty ? "Usuario" : userName,
                        style: StyleFontsMove.paragraphStyleMove,
                      ),
                    ],
                  ),
                  Consumer<RouteDriverViewmodel>(
                    builder: (context, viewModel, child) {
                      print(viewModel);
                      final int remainingTime = viewModel.remainingTime;
                      final Color borderColor = remainingTime > 10
                          ? Colors.green
                          : remainingTime > 5
                              ? Colors.yellow
                              : Colors.red;

                      return TweenAnimationBuilder<Color>(
                          tween: Tween<Color>(
                            begin: borderColor,
                            end: borderColor,
                          ),
                          duration: const Duration(microseconds: 500),
                          builder: (context, color, child) {
                            return Container(
                              width: 35.w,
                              height: 35.h,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primarycolor, border: Border.all(color: color ?? Colors.green, width: 4.w)),
                              alignment: Alignment.center,
                              child: Text(
                                '$remainingTime',
                                style: TextStyle(color: Colors.white, fontSize: 20.sp),
                              ),
                            );
                          });
                    },
                  ),
                ],
              ),

              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.only(bottom: 4.h), 
                child: Consumer<AcceptMoveViewmodel>(
                  builder: (context, acceptVM, child) {
                    return SizedBox(
                      width: double.infinity, 
                      height: 46.h, 
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.confirmationscolor,
                          disabledBackgroundColor: Colors.grey[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
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
                                height: 20.r,
                                width: 20.r,
                                child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                "Aceptar Carga",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              )
            ]))); */
  }
}
