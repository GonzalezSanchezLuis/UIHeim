import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';

class FloatingMoveCardWrapper extends StatefulWidget {
  final Map<String, dynamic> moveData;

  const FloatingMoveCardWrapper({super.key, required this.moveData});

  @override
  State<FloatingMoveCardWrapper> createState() => _FloatingMoveCardWrapperState();
}

class _FloatingMoveCardWrapperState extends State<FloatingMoveCardWrapper> with SingleTickerProviderStateMixin {
  double _opacity = 0.0;
  Offset _offset = const Offset(0, 0.2);

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _opacity = 1.0;
        _offset = Offset.zero;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: _opacity,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 400),
        offset: _offset,
        curve: Curves.easeOut,
        child: _buildFloatingMoveCard(context, widget.moveData),
      ),
    );
  }

  Widget _buildFloatingMoveCard(BuildContext context, Map<String, dynamic> moveData) {
    String originalAddress = moveData['origin'];
    List<String> parts = originalAddress.split(',');
    String reduced = parts.take(2).join(',').trim();
    final String userName = (moveData['fullName'] ?? moveData['userName'])?.toString() ?? '';

    String destinationAddress = moveData['destination'];
    List<String> partsDestination = destinationAddress.split(',');
    String reducedDestination = partsDestination.take(2).join(',').trim();

    return Card(
      color: Colors.black.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: AppTheme.primarycolor, width: 2),
      ),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 25),
                SizedBox(width: 10),
                Text(
                  'Aceptado',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.grey[800],
                  backgroundImage: (moveData['avatarProfile'] != null && moveData['avatarProfile'].toString().isNotEmpty) ? NetworkImage(moveData['avatarProfile']) : null,
                  child: (moveData['avatarProfile'] == null || moveData['avatarProfile'].toString().isEmpty) ? const Icon(Icons.person, size: 30, color: Colors.white) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Vamos por $userName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reduced,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.circle, color: Colors.blueAccent, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reducedDestination,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.location_on, color: Colors.green, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tu presencia mantiene el viaje en marcha.',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
