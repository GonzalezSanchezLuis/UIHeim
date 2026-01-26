import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:holi/src/core/enums/move_type.dart';
import 'package:holi/src/core/extensions/move_type_extension.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_move.dart';
import 'package:holi/src/utils/format_price.dart';
import 'package:holi/src/viewmodels/driver/route_driver_viewmodel.dart';
import 'package:holi/src/viewmodels/move/accept_move_viewmodel.dart';
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
    final String userName = (moveData['fullName']?? moveData['userName'])?.toString() ?? '';
    print("USERNAME DESDE MOVEDATA $userName");

    final String originalAddress = moveData['origin'] ?? '';
    final List<String> parts = originalAddress.split(',');
    final String reducedOriginAddress = parts.take(3).join(',').trim();

    final String typeOfMoveStr = moveData['typeOfMove'] ?? '';
    final typeOfMove = MoveType.values.firstWhere(
      (e) => e.value == typeOfMoveStr,
      orElse: () => MoveType.PEQUENA,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.monetization_on, color: Colors.white),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  'Pago con ${moveData['paymentMethod']}',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              Expanded(
                child: Text(
                  formattedPrice,
                  style: const TextStyle(color: Colors.white, fontSize: 23),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.grey, thickness: 1),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.circle, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${moveData['distance'] ?? "Cargando..."} ${moveData['estimatedTimeOfArrival'] ?? "..."}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                     'Desde $reducedOriginAddress',
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.circle, color: Colors.blueAccent),
              const SizedBox(width: 8),
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
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              )
            ],
          ),

          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text(
                'Mudanza ${typeOfMove.displayName}',
                style: StyleFontsMove.paragraphStyleMove,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primarycolor, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: (moveData['avatarProfile'] != null && moveData['avatarProfile'].toString().isNotEmpty) ? NetworkImage(moveData['avatarProfile']) : null,
                      child: (moveData['avatarProfile'] == null || moveData['avatarProfile'].toString().isEmpty) ? const Icon(Icons.person, size: 20, color: Colors.black) : null,
                    ),
                  ),
                  const SizedBox(width: 8),
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
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primarycolor, border: Border.all(color: color ?? Colors.green, width: 4)),
                          alignment: Alignment.center,
                          child: Text(
                            '$remainingTime',
                            style: const TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        );
                      });
                },
              ),
            ],
          ),

          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final acceptMoveViewModel = Provider.of<AcceptMoveViewmodel>(context, listen: false);
              final routeVM = Provider.of<RouteDriverViewmodel>(context, listen: false);

             // routeVM.stopTimer();

              final moveId = int.tryParse(moveData['moveId'].toString()) ?? 0;
              print("ID DE LA MUDANZA $moveId");

              final result = await acceptMoveViewModel.acceptMove(moveId);

              if (result) {
                routeVM.stopTimer();
                onMoveAccepted(moveData);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error al aceptar la mudanza')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 50),
              backgroundColor: AppTheme.confirmationscolor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Aceptar mudanza',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
          ),
        ],
      ),
    );
  }
}
