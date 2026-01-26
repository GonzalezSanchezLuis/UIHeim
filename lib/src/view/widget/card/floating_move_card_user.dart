import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';

class FloatingMoveCardUser extends  StatefulWidget {

  final Map<String, dynamic> moveData;
  const FloatingMoveCardUser({super.key,required this.moveData});

  @override
  State<FloatingMoveCardUser > createState() => _FloatingMoveCardUserSate();
}

class _FloatingMoveCardUserSate extends State<FloatingMoveCardUser> with SingleTickerProviderStateMixin {
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
   final originRaw = moveData['origin'];
    final destinationRaw = moveData['destination'];

 
   final String reducedOrigin = originRaw.toString().split(',').take(2).join(',').trim();
    final String reducedDestination = destinationRaw.toString().split(',').take(2).join(',').trim();

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
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Desde $reducedOrigin',
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
                    'Hasta $reducedDestination',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
   
