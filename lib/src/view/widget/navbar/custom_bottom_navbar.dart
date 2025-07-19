import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12, top: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildItem(icon: Icons.home_filled, label: 'Inicio', index: 0),
              _buildItem(icon: FontAwesomeIcons.truckFront, label: 'Mudarme', index: 1),
              _buildItem(icon: Icons.history_toggle_off_rounded, label: 'Historial', index: 2),
              _buildItem(icon: Icons.supervised_user_circle, label: 'Perfil', index: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String label,
    required int index,
    double size = 24,
  }) {
    final isSelected = index == currentIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: isSelected
              ? BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: size, color: isSelected ? Colors.amber : const Color(0xFF8E8E8E)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.amber : const Color(0xFF8E8E8E),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
