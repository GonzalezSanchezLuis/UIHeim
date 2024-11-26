import 'package:flutter/material.dart';
import 'package:holi/src/theme/colors/app_theme.dart';
import 'package:holi/src/widget/history_move_list.dart';

class HistoryMove extends StatefulWidget {
  const HistoryMove({Key? key}) : super(key: key);

  @override
  _HistoryMoveState createState() => _HistoryMoveState();
}

class _HistoryMoveState extends State<HistoryMove> {
  // Simulando datos provenientes de una base de datos
  final List<Map<String, dynamic>> moves = [
    {
      'status': 'Servicio Completado',
      'user': 'Luis Gonzalez',
      'plate': 'ABC 123',
      'origin': 'Cr 13a bis 50b 09',
      'destination': 'Av. Siempre Viva 742',
      'image': 'assets/images/profile.jpg',
      'header': 'Mudanza Completada',
    },
    {
      'status': 'Servicio Completado',
      'user': 'Maria Lopez',
      'plate': 'XYZ 456',
      'origin': 'Cl 50 No 30A',
      'destination': 'Calle 100 con 15',
      'image': 'assets/images/profile.jpg',
      'header': 'Mudanza Completada',
    },
    {
      'status': 'Servicio Completado',
      'user': 'Carlos Perez',
      'plate': 'DEF 789',
      'origin': 'Cra 45 No 22',
      'destination': 'Calle 80 No 10',
      'image': 'assets/images/profile.jpg',
      'header': 'Mudanza Completada',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mudanzas'),
        backgroundColor: Colors.white,
      ),
      backgroundColor: AppTheme.colorbackgroundview,
      body: HistoryMoveList(moves: moves),
    );
  }
}
