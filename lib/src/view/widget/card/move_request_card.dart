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

  MoveRequestCard({
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

  final GlobalKey<SlideActionState> _acceptKey = GlobalKey<SlideActionState>();
  @override
  Widget build(BuildContext context) {
    final dynamic priceRaw = moveData['price'];
    final double priceValue = priceRaw != null ? (priceRaw is num ? priceRaw.toDouble() : double.tryParse(priceRaw.toString()) ?? 0) : 0;
    final String formattedPrice = formatPriceToHundredsDriver(priceValue.toString());
    final String userName = (moveData['fullName'] ?? moveData['userName'])?.toString() ?? '';
    print("USERNAME DESDE MOVEDATA $userName");

    final String originalAddress = moveData['origin'] ?? '';
    final List<String> parts = originalAddress.split(',');
    final String reducedOriginAddress = parts.take(3).join(',').trim();
    final String paymentMethod = moveData['paymentMethod'];

    final String typeOfMoveStr = moveData['typeOfMove'] ?? '';
    final typeOfMove = MoveType.values.firstWhere(
      (e) => e.value == typeOfMoveStr,
      orElse: () => MoveType.PEQUENA,
    );

    final String accessType = moveData['accessType']?.toString().toUpperCase() ?? 'NO ESPECIFICADO';
    final bool hasElevator = accessType == 'ASCENSOR';
    final bool isStairs = accessType == 'ESCALERAS';
    final bool firstFloor = accessType == 'CALLE';

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 8.h),
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
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Desde $reducedOriginAddress',
                          style: StyleFontsMove.paragraphStyleMove,
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
                        'Mudanza ${typeOfMove.displayName}',
                        style: StyleFontsMove.paragraphStyleMove,
                      ),
                    ],
                  ),
                  if (accessType != 'NO ESPECIFICADO')
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: firstFloor ? Colors.green.withOpacity(0.2) : (isStairs ? Colors.orange.withOpacity(0.2) : Colors.blue.withOpacity(0.2)),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: firstFloor ? Colors.green : (isStairs ? Colors.orange : Colors.blueAccent),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                firstFloor ? Icons.home_work_outlined : (hasElevator ? Icons.elevator_outlined : Icons.stairs_outlined),
                                color: firstFloor ? Colors.greenAccent : (hasElevator ? Colors.blueAccent : Colors.orange),
                                size: 18.sp,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                accessType,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              /* Row(
                children: [
                  Icon(Icons.local_shipping_outlined, color: Colors.white, size: 18.sp),
                  SizedBox(width: 5.w),
                  Text(
                    'Mudanza ${typeOfMove.displayName}',
                    style: StyleFontsMove.paragraphStyleMove,
                  ),
                ],
              ),*/

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
              SizedBox(height: 5.w),
              Row(
                children: [
                  SizedBox(width: 4.w),
               Expanded(
                    child: Consumer<AcceptMoveViewmodel>(
                      builder: (context, acceptVM, child) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.confirmationscolor,
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 50.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            elevation: 0,
                          ),
                          // Si está cargando, deshabilitamos el botón para evitar doble clic
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
                                      const SnackBar(content: Text('Error al aceptar la mudanza')),
                                    );
                                  }
                                },
                          child: acceptVM.isLoading
                              ? SizedBox(
                                  height: 20.h,
                                  width: 20.h,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "Aceptar",
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,

                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                  
                ],
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom > 0 ? 8.h : 0),
            ])));
  }
}
