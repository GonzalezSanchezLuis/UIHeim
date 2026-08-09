import 'package:holi/src/core/enums/status_of_the_move.dart';

class HistoryMovingModel {
  final int moveId;
  final String origin;
  final String destination;
  final String enrollVehicle;
  final DateTime? scheduledTime; // Añadido el campo para la fecha programada
  final String name;
  final String avatar;
  final String status;

  HistoryMovingModel({
    required this.moveId, 
    required this.origin, 
    required this.destination, 
    required this.enrollVehicle, 
    required this.name, 
    required this.avatar, 
    required this.status,
    required this.scheduledTime
    });

  factory HistoryMovingModel.fromJson(Map<String, dynamic> json) {
    final String rawStatus = json['status'] as String? ?? 'MOVE_COMPLETE'; // Mantener el nombre de la variable
    String displayStatus;

    if (rawStatus == 'SCHEDULED') {
      displayStatus = 'programada'; 
    } else {
      // Usa la lógica existente para otros estados
      final statusEnum = StatusOfTheMove.values.firstWhere(
        (e) => e.toString().split('.').last == rawStatus,
        orElse: () => StatusOfTheMove.MOVE_FINISHED,
      );
      displayStatus = statusEnum.label;
    }

    final String? scheduledTimeString = json['scheduledTime'] as String?;
    final DateTime? parsedScheduledTime = scheduledTimeString != null ? DateTime.parse(scheduledTimeString) : null;

    return HistoryMovingModel(
      moveId: json['moveId'] as int? ?? -1,
      origin: json['origin'] as String? ?? 'Sin Origen',
      destination: json['destination'] as String? ?? 'Sin Destino',
      status: displayStatus,
      scheduledTime: parsedScheduledTime, 
      enrollVehicle: json['enrollVehicle'] as String? ?? 'Sin asignar',
      name: json['name'] as String? ?? 'Conductor no asigando',
      avatar: json['avatar'] as String? ?? 'assets/images/default_profile.png',
    );
  }
}
