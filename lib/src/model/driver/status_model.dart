class StatusModel {
  String? status;

  StatusModel({
    this.status, 
    });

    factory StatusModel.fromMap(Map<String, dynamic> map){
      return StatusModel(
        status: map['status'],
      );
    }

      Map<String, dynamic> toMap() {
    return {
      'status': status,

    };
  }

   // Método copyWith
  StatusModel copyWith({
    String? status,
    int? driverId,
  }) {
    return StatusModel(
      status: status ?? this.status,

    );
  }
}
