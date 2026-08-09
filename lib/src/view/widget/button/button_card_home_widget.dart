import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:holi/src/core/enums/connection_status.dart';
import 'package:holi/src/core/enums/move_type.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/view/screens/travel/calculate_price_view.dart';
import 'package:holi/src/service/auth/auth_service.dart';
import 'package:holi/src/view/screens/auth/login_view.dart';
import 'package:holi/src/view/widget/card/card_schedule_travel.dart';
import 'package:holi/src/viewmodels/driver/driver_status_viewmodel.dart';
import 'package:holi/src/viewmodels/location/location_viewmodel.dart';
import 'package:holi/src/viewmodels/travel/confirm_move_viewmodel.dart';
import 'package:provider/provider.dart';

class ButtonCalculatePrice extends StatelessWidget {
  const ButtonCalculatePrice({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CalculatePrice()));
      },
      style: ElevatedButton.styleFrom(
        minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 60),
        backgroundColor: const Color(0xFFFFBC11),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        "¡Comencemos!",
        style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class ButtonLogOut extends StatelessWidget {
  ButtonLogOut({
    super.key,
  });
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final navigator = Navigator.of(context, rootNavigator: true);
        final isLoggedOut = await _authService.logout();
        if (!context.mounted) return;
        if (isLoggedOut) {
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginView()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error al cerrar sesión")),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 50),
        backgroundColor: AppTheme.warningcolor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: const Text(
        "Cerrar sesión",
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}

class ConnectButton extends StatelessWidget {
  final Function(LatLng) onConnected;

  const ConnectButton({super.key, required this.onConnected});

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverStatusViewmodel>(
      builder: (context, provider, _) {
        // Determina el color del botón
        final Color buttonBackgroundColor = provider.isLoading ? AppTheme.confirmationscolor.withOpacity(0.6) : AppTheme.confirmationscolor;

        final Widget buttonChild = provider.isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    "Conectando...",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : const Text(
                'Conectarme',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              );

        return ElevatedButton(
          onPressed: () async {
            if (!provider.isLoading) {
              LatLng? newLocation = await provider.connectDriverViewmodel(context);
              if (newLocation != null) {
                onConnected(newLocation);
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonBackgroundColor,
            minimumSize: Size(MediaQuery.of(context).size.width * 0.7, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: SizedBox(
            height: 40,
            child: Center(
              child: buttonChild,
            ),
          ),
        );
      },
    );
  }
}

class DisconnectButton extends StatelessWidget {
  const DisconnectButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverStatusViewmodel>(
      builder: (context, provider, _) {
        if (provider.connectionStatus != ConnectionStatus.CONNECTED) {
          return const SizedBox.shrink();
        }

        final Color buttonBackgroundColor = provider.isLoading ? AppTheme.warningcolor.withOpacity(0.6) : AppTheme.warningcolor;

        return ElevatedButton(
          onPressed: () {
            if (!provider.isLoading) {
              provider.disconnectDriverViewmodel();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonBackgroundColor,
            minimumSize: Size(MediaQuery.of(context).size.width * 0.7, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: SizedBox(
            height: 40.h,
            child: Center(
              child: provider.isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24.w,
                          height: 24.h,
                          child: const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 3,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Text(
                          "Desconectando...",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      "Desconectarme",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}

class ConfirmButton extends StatelessWidget {
  final String calculatedPrice;
  final String distanceKm;
  final String duration;
  final MoveType? typeOfMove;
  final String estimatedTime;
  final List<LatLng> route;
  final LocationViewModel locationViewModel;
  final VoidCallback onConfirmed;
  final double? originLat;
  final double? originLng;
  final double? destinationLat;
  final double? destinationLng;
  final String? originAddressText;
  final String? destinationAddressText;
  final String? paymentMethod;
  final String? accessType;
  final int userId;
  final String? buttonText;
  final DateTime? scheduledTravel;
  final String? addressee;
  final String? recipientPhoneNumber;
  const ConfirmButton({
    required this.calculatedPrice,
    required this.distanceKm,
    required this.duration,
    required this.typeOfMove,
    required this.estimatedTime,
    required this.route,
    required this.locationViewModel,
    required this.onConfirmed,
    required this.userId,
    this.originLat,
    this.originLng,
    this.destinationLat,
    this.destinationLng,
    this.originAddressText,
    this.destinationAddressText,
    this.paymentMethod,
    this.accessType,
    this.buttonText,
    this.scheduledTravel,
    this.addressee,
    this.recipientPhoneNumber,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    print("🛠️ DEBUG BOTÓN: Origin=$originAddressText | Dest=$destinationAddressText | originLat=$originLat originLng=$originLng");
    final viewModel = Provider.of<ConfirmMoveViewModel>(context, listen: false);
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 100.h,
        child: ElevatedButton(
          onPressed: viewModel.isLoading
              ? null
              : () async {
                  final result = await viewModel.confirmMove(
                      context: context,
                      typeOfMove: typeOfMove!,
                      calculatedPrice: calculatedPrice,
                      distanceKm: distanceKm,
                      duration: duration,
                      estimatedTime: estimatedTime,
                      route: route,
                      locationViewModel: locationViewModel,
                      originLat: originLat,
                      originLng: originLng,
                      destinationLat: destinationLat,
                      destinationLng: destinationLng,
                      originAddressText: originAddressText,
                      destinationAddressText: destinationAddressText,
                      paymentMethod: paymentMethod,
                      accessType: accessType,
                      scheduledTravel: scheduledTravel,
                      addressee: addressee,
                      recipientPhoneNumber: recipientPhoneNumber,
                      userId: userId);
                  onConfirmed();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.urgentcolor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: viewModel.isLoading
              ? const CircularProgressIndicator(color: Colors.black)
              : Text(
                  buttonText ?? "Confirmar y continuar",
                  style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold),
                ),
        ));
  }
}

Future<void> showScheduleTravelModal({
  required BuildContext context,
  VoidCallback? onModalOpen,
  VoidCallback? onModalClose,
  ValueChanged<DateTime>? onDateSelected,
}) {
  final navigator = Navigator.of(context);
  onModalOpen?.call();
  return Future.delayed(const Duration(milliseconds: 80), () {
    return showModalBottomSheet<DateTime>(
      context: navigator.context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.35),
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 420),
        reverseDuration: Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInOutCubic,
      ),
      builder: (BuildContext sheetContext) {
        return Container(
          height: MediaQuery.of(sheetContext).size.height * 0.2,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
          ),
          child: const CardScheduleTravel(),
        );
      },
    ).then((selectedDate) {
      if (selectedDate != null) {
        onDateSelected?.call(selectedDate);
      }
    }).whenComplete(() {
      onModalClose?.call();
    });
  });
}

class ScheduleTravelButton extends StatelessWidget {
  final VoidCallback? onModalOpen;
  final VoidCallback? onModalClose;
  final ValueChanged<DateTime>? onDateSelected;

  const ScheduleTravelButton({
    super.key,
    this.onModalOpen,
    this.onModalClose,
    this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        height: 45.h,
        child: ElevatedButton(
          onPressed: () {
            showScheduleTravelModal(
              context: context,
              onModalOpen: onModalOpen,
              onModalClose: onModalClose,
              onDateSelected: onDateSelected,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.confirmationscolor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            "Programar para después",
            style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ));
  }
}
