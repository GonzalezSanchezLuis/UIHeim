class AuthModel {
  int? userId;
  String? licenseNumber;
  String? vehicleType;
  String? enrollVehicle;

  AuthModel({this.userId,this.licenseNumber, this.vehicleType, this.enrollVehicle});

  factory AuthModel.fromMap(Map<String, dynamic> map) {
    return AuthModel(
      userId: map['userId'],
      licenseNumber: map['licenseNumber'],
      vehicleType: map['vehicleType'],
      enrollVehicle: map['enrollVehicle'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId':userId,
      'licenseNumber': licenseNumber,
      'vehicleType': vehicleType,
      'enrollVehicle': enrollVehicle,
    };
  }

  // Método copyWith
  AuthModel copyWith({
    int? userId,
    String? licenseNumber,
    String? vehicleType,
    String? enrollVehicle,
  }) {
    return AuthModel(
      userId: userId ?? this.userId,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      enrollVehicle: enrollVehicle ?? this.enrollVehicle,
    );
  }
}
