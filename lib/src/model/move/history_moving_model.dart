import 'package:holi/src/core/enums/status_of_the_move.dart';

class HistoryMovingModel {
  final int moveId;
  final String origin;
  final String destination;
  final String enrollVehicle;
  final String name;
  final String avatar;
  final String status;

  HistoryMovingModel({required this.moveId, required this.origin, required this.destination, required this.enrollVehicle, required this.name, required this.avatar, required this.status});

  factory HistoryMovingModel.fromJson(Map<String, dynamic> json) {
     final statusString = json['status'] as String? ?? 'MOVE_COMPLETE';

    final statusEnum = StatusOfTheMove.values.firstWhere(
      (e) => e.toString().split('.').last == statusString,
      orElse: () =>StatusOfTheMove.MOVE_FINISHED,
    );

    return HistoryMovingModel(
      moveId: json['moveId'] as int? ?? -1,
      origin: json['origin'] as String? ?? 'Sin Origen',
      destination: json['destination'] as String? ?? 'Sin Destino',
      status: statusEnum.label,
      enrollVehicle: json['enrollVehicle'] as String? ?? 'Sin Placa',
      name: json['name'] as String? ?? 'Conductor Desconocido',
      avatar: json['avatar'] as String? ?? 'assets/images/default_profile.png',
    );
  }
}
