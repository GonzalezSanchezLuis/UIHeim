import 'package:flutter/material.dart';
import 'package:holi/src/core/enums/status_of_the_move.dart';
import 'package:holi/src/core/helper/screen_helper.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/service/location/background_location_service.dart';
import 'package:holi/src/view/screens/travel/moving_summary_view.dart';
import 'package:holi/src/viewmodels/travel/finish_move_viewmodel.dart';
import 'package:holi/src/viewmodels/driver/driver_status_viewmodel.dart';
import 'package:holi/src/viewmodels/driver/route_driver_viewmodel.dart';
import 'package:holi/src/viewmodels/travel/update_status_move_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomMoveCard extends StatefulWidget {
  final int driverId;
  final int moveId;
  const BottomMoveCard({super.key, required this.driverId, required this.moveId});

  @override
  State<BottomMoveCard> createState() => _BottomMoveCardState();
}

class _BottomMoveCardState extends State<BottomMoveCard> {
  bool _isExpanded = false;
  StatusOfTheMove _statusOfTheMove = StatusOfTheMove.DRIVER_ARRIVED;

  @override
  void initState() {
    super.initState();
    _fetchCurrentMoveStatus();
  }

  void _fetchCurrentMoveStatus() async {
    final status = await Provider.of<UpdateStatusMoveViewmodel>(context, listen: false).getCurrentStatus(widget.moveId);

    if (mounted) {
      // 🌟 Protección esencial al actualizar estado tras una petición asíncrona
      setState(() {
        _statusOfTheMove = status;
        _isExpanded = true;
      });
    }
  }


  String _getTitleText() {
    switch (_statusOfTheMove) {
      case StatusOfTheMove.ASSIGNED:
        return 'Rumbo al punto de origen';
      case StatusOfTheMove.DRIVER_ARRIVED:
        return 'En el punto de encuentro';
      case StatusOfTheMove.MOVING_STARTED:
        return 'Viaje en progreso...';
      case StatusOfTheMove.MOVE_COMPLETE:
        return 'Llegamos al destino';
      case StatusOfTheMove.MOVE_FINISHED:
        return 'Servicio completado';
    }
  }

  @override
  Widget build(BuildContext context) {
    final updateStatusMoveViewmodel = Provider.of<UpdateStatusMoveViewmodel>(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 14.h,
        bottom: MediaQuery.paddingOf(context).bottom + 13.h,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r), 
          topRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // CABECERA COLAPSABLE
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              color: Colors.transparent, 
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                children: [
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 300),
                    turns: _isExpanded ? 0.5 : 0.0,
                    child: Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 24.sp),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _getTitleText(), 
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 5.h),

          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h), 
              child: Builder(
                builder: (context) {
                  if (!_isExpanded) return const SizedBox.shrink();
                  final double sliderHeight = 48.h;

                  switch (_statusOfTheMove) {
                    case StatusOfTheMove.ASSIGNED:
                    case StatusOfTheMove.DRIVER_ARRIVED:
                      return SlideAction(
                        height: sliderHeight,
                        borderRadius: 20.r,
                        sliderButtonIconSize: 16.sp,
                        onSubmit: () async {
                          await updateStatusMoveViewmodel.changeStatus(moveId: widget.moveId, driverId: widget.driverId, status: StatusOfTheMove.DRIVER_ARRIVED);
                          setState(() {
                            _statusOfTheMove = StatusOfTheMove.MOVING_STARTED;
                          });
                        },
                        child: Text(
                          'Desliza si llegaste al punto',
                          style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        outerColor: AppTheme.primarycolor,
                      );

                    case StatusOfTheMove.MOVING_STARTED:
                      return SlideAction(
                        height: sliderHeight,
                        borderRadius: 20.r,
                        sliderButtonIconSize: 16.sp,
                        onSubmit: () async {
                          await updateStatusMoveViewmodel.changeStatus(
                            moveId: widget.moveId,
                            driverId: widget.driverId,
                            status: StatusOfTheMove.MOVING_STARTED,
                          );
                          setState(() {
                            _statusOfTheMove = StatusOfTheMove.MOVE_COMPLETE;
                          });
                        },
                        text: 'Iniciar recorrido ',
                        textStyle: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold),
                        outerColor: AppTheme.confirmationscolor,
                      );

                    case StatusOfTheMove.MOVE_COMPLETE:
                      return SlideAction(
                        height: sliderHeight,
                        borderRadius: 20.r,
                        sliderButtonIconSize: 16.sp,
                        onSubmit: () async {
                          final finishMoveViewModel = Provider.of<FinishMoveViewmodel>(context, listen: false);

                          final success = await finishMoveViewModel.finishMove(
                            widget.moveId,
                            widget.driverId,
                          );
                          await BackgroundLocationService.stop();
                          WakelockPlus.disable();
                          await ScreenHelper.disableTravelMode();

                          if (mounted) {
                            await Provider.of<DriverStatusViewmodel>(context, listen: false).clearTripData();
                            Provider.of<RouteDriverViewmodel>(context, listen: false).handleMoveFinished();
                          }

                          if (success) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MovingSummaryView(moveId: widget.moveId),
                              ),
                            );
                          }
                        },
                        text: 'Finalizar recorrido',
                        textStyle: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold),
                        outerColor: AppTheme.warningcolor,
                      );

                    case StatusOfTheMove.MOVE_FINISHED:
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 50.sp),
                          SizedBox(height: 8.h),
                          Text(
                            "✅ Viaje finalizado con éxito",
                            style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
