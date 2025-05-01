class FcmTokenRequestModel {
  final String token;
  final int userId;
  final String type;

  FcmTokenRequestModel({
    required this.token,
    required this.userId,
    required this.type
  });

  // Convertir a un mapa JSON para la solicitud HTTP
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'type':type,
      if(type.toUpperCase() == 'USER') 'user' :{'userId':userId},
      if(type.toUpperCase() == 'DRIVER') 'driver':{'driverId': userId}
    };
  }
}
