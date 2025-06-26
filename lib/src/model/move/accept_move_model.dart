class AcceptMoveModel {
  final int driverId;


  AcceptMoveModel({required this.driverId});

  Map<String, dynamic> toJson() {
    return {
      'driverId': driverId,
    };
  }
}
