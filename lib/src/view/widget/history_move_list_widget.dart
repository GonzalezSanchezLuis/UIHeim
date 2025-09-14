import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/model/move/history_moving_model.dart';
import 'package:holi/src/view/screens/move/move_details_view.dart';

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
                builder: (context) =>   MoveDetailsView(moveId: move.moveId,
                  /*moveData: {
                    'serviceCost': 70000.0,
                    'subtotal': 70000.0,
                    'totalAmount': 242.00,
                    'paymentMethod': 'Transferencia bancaria',
                    'vehicleType': 'NPR',
                    'tripSize': 'Pequeño',
                  },*/
                ),
              ),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 5,
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 Text(
                   move.status,
                   style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w700),
                 ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: move.avatar.startsWith('http') ? NetworkImage(move.avatar) : AssetImage(move.avatar) as ImageProvider,
                        radius: 24,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            move.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            move.enrollVehicle,
                            style: TextStyle(
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      color:AppTheme.colorcards,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Origen',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              reducedOriginAddress,
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Destino',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              reducedDestinationAddress,
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ],
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
}
