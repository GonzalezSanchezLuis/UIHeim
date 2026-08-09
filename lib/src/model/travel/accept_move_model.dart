class AcceptMoveModel {
  final int driverId;
  final int moveId;

  AcceptMoveModel({required this.driverId, required this.moveId});

  Map<String, dynamic> toJson() {
    return {
      'driverId': driverId,
      'moveId': moveId
    };
  }
}
