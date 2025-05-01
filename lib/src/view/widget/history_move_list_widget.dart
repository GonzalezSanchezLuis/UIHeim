import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/view/screens/move/move_detail_view.dart';

class HistoryMoveList extends StatelessWidget {
  const HistoryMoveList({
    super.key,
    required this.moves,
  });

  final List<Map<String, dynamic>> moves;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: moves.length,
      itemBuilder: (context, index) {
        final move = moves[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MoveDetail(),
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
                    move['header'] ?? 'Sin Información',
                    style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(move['image']),
                        radius: 24,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            move['user'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            move['plate'],
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
                              move['origin'],
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
                              move['destination'],
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
