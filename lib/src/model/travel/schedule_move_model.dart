class ScheduleMoveModel {
  String? moveType;
  String? originAddress;
  String? destinationAddress;
  String? originLat;
  String? originLng;
  String? destinationLat;
  String? destinationLng;
  String? status;
  int? userId;
  int? driverId;
  DateTime? moveDate;

  ScheduleMoveModel({
    this.moveType,
    this.originAddress,
    this.destinationAddress,
    this.originLat,
    this.originLng,
    this.destinationLat,
    this.destinationLng,
    this.status,
    this.userId,
    this.driverId,
    this.moveDate
  });

  factory ScheduleMoveModel.fromMap(Map<String, dynamic> map) {
    return ScheduleMoveModel(
      moveType: map['moveType'],
      originAddress: map['originAddress'],
      destinationAddress: map['destinationAddress'],
      originLat: map['originLat'],
      originLng: map['originLng'],
      destinationLat: map['destinationLat'],
      destinationLng: map['destinationLng'],
      status: map['status'],
      userId: map['userId'],
      driverId: map['driverId'],
      moveDate: map['moveDate'],


    );
  }

  Map<String, dynamic> toMap() {
    return {
      'moveType': moveType,
      'originAddress': originAddress,
      'destinationAddress': destinationAddress,
      'originLat': originLat,
      'originLng': originLng,
      'destinationLat': destinationLat,
      'destinationLng': destinationLng,
      'status': status,
      'userId': userId,
      'driverId': driverId,
      'moveDate': moveDate,

    };
  }

  // Método copyWith
  ScheduleMoveModel copyWith({
      String? moveType,
      String? originAddress,
      String? destinationAddress,
      String? originLat,
      String? originLng,
      String? destinationLat,
      String? destinationLng,
      String? status,
      int? userId,
      int? driverId,
      DateTime? moveDate,
  }) {
    return ScheduleMoveModel(
      moveType: moveType ?? this.moveType,
      originAddress: originAddress ?? this.originAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      originLat: originLat ?? this.originLat,
      originLng: originLng ?? this.originLng,
      destinationLat: destinationLat ?? this.destinationLat,
      destinationLng: destinationLng ?? this.destinationLng,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      driverId: driverId ?? this.driverId,
      moveDate: moveDate ?? this.moveDate
    );
  }
}
