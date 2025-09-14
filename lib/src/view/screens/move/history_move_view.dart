import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/view/widget/history_move_list_widget.dart';
import 'package:holi/src/viewmodels/move/history_moving_viewmodel.dart';
import 'package:provider/provider.dart';

class HistoryMove extends StatefulWidget {
  const HistoryMove({super.key});

  @override
  _HistoryMoveState createState() => _HistoryMoveState();
}

class _HistoryMoveState extends State<HistoryMove> {
  @override
  void initState() {
    super.initState();
    // Llama al método para cargar los datos cuando la vista se inicializa
    // Asumiendo que el ID del conductor es 1, cámbialo según tu lógica de autenticación
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoryMovingViewmodel>(context, listen: false).loadMovingHistory(1);
    });
  }
  // Simulando datos provenientes de una base de datos
/* final List<Map<String, dynamic>> moves = [
    {
      'status': 'Servicio Completado',
      'user': 'Luis Gonzalez',
      'plate': 'ABC 123',
      'origin': 'Cr 13a bis 50b 09',
      'destination': 'Av. Siempre Viva 742',
      'image': 'assets/images/profile.jpg',
    },
    {
      'status': 'Servicio Completado',
      'user': 'Maria Lopez',
      'plate': 'XYZ 456',
      'origin': 'Cl 50 No 30A',
      'destination': 'Calle 100 con 15',
      'image': 'assets/images/profile.jpg',
    },
    {
      'status': 'Servicio Completado',
      'user': 'Carlos Perez',
      'plate': 'DEF 789',
      'origin': 'Cra 45 No 22',
      'destination': 'Calle 80 No 10',
      'image': 'assets/images/profile.jpg',
    },
  ];*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      body: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Consumer<HistoryMovingViewmodel>(builder: (context, viewmodel, child) {
            if (viewmodel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (viewmodel.errorMessage != null) {
              return Center(child: Text('Error: ${viewmodel.errorMessage}'));
            } else if (viewmodel.movingHistory != null) {
              return HistoryMoveList(moves: viewmodel.movingHistory!);
            } else {
              return const Center(child: Text('No hay historial de mudanzas.'));
            }
          })

          //HistoryMoveList(moves: moves),
          ),
    );
  }
}
