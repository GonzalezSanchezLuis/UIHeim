class MoveStatusUpdateModel {
  final int moveId;
  final int driverId;
  final DateTime timestamp;

  MoveStatusUpdateModel({
    required this.moveId,
    required this.driverId,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'moveId': moveId,
        'driverId': driverId,
        'timestamp': timestamp.toIso8601String(),
      };
}
