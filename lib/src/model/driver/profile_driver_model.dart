class ProfileDriverModel {
  String? fullName;
  String? document;
  String? phone;
  String? email;
  String? password;
  String? urlAvatarProfile;

  String? licenseNumber;
  String? vehicleType;
  String? enrollVehicle;

  ProfileDriverModel({
    this.fullName,
    this.document,
    this.phone,
    this.email,
    this.password,
    this.urlAvatarProfile,
     this.licenseNumber,
    this.vehicleType,
    this.enrollVehicle,
  });

  factory ProfileDriverModel.fromMap(Map<String, dynamic> map) {
    return ProfileDriverModel(
      fullName: map['fullName'],
      document: map['document'],
      phone: map['phone'],
      email: map['email'],
      urlAvatarProfile: map['urlAvatarProfile'],
      licenseNumber: map['licenseNumber'],
      vehicleType: map['vehicleType'],
      enrollVehicle: map['enrollVehicle'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'password': password,
      'urlAvatarProfile': urlAvatarProfile,
       'licenseNumber': licenseNumber,
      'vehicleType': vehicleType,
      'enrollVehicle': enrollVehicle,
    };
  }

  // Método copyWith
  ProfileDriverModel copyWith({
    String? fullName,
    String? document,
    String? phone,
    String? email,
    String? password,
    String? urlAvatarProfile,
    String? licenseNumber,
    String? vehicleType,
    String? enrollVehicle,
  }) {
    return ProfileDriverModel(
      fullName: fullName ?? this.fullName,
      document: document ?? this.document,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      urlAvatarProfile: urlAvatarProfile ?? this.urlAvatarProfile,
       licenseNumber: licenseNumber ?? this.licenseNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      enrollVehicle: enrollVehicle ?? this.enrollVehicle,
    );
  }
}
