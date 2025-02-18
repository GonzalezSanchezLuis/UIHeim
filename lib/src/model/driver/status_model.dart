class StatusModel {
  String? status;
  int ? driverId;

  StatusModel({
    this.status, 
    this.driverId});

    factory StatusModel.fromMap(Map<String, dynamic> map){
      return StatusModel(
        status: map['status'],
        driverId: map['driverId']
      );
    }

      Map<String, dynamic> toMap() {
    return {
      'status': status,
      'driverId': driverId,

    };
  }

   // Método copyWith
  StatusModel copyWith({
    String? status,
    int? driverId,
  }) {
    return StatusModel(
      status: status ?? this.status,
      driverId: driverId ?? this.driverId,

    );
  }
}
