
import 'package:flutter/material.dart';

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
        return Card(           
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
                Text(move['header'] ?? 'Sin Información',style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 10,),
                // Encabezado
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
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Información de origen y destino
                Container(  
                  decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(10),
                    
                  ),                 
                   padding: const EdgeInsets.all(8.0),                    
                  child:Row(                                                         
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Origen
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
                    // Destino
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
        );
      },
    );
  }
}