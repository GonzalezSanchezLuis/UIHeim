class FcmTokenRequestModel {
  final String token;
  final int ownerId;
  final String ownerType;

  FcmTokenRequestModel({
    required this.token,
    required this.ownerId,
    required this.ownerType
  });

  // Convertir a un mapa JSON para la solicitud HTTP
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'ownerId': ownerId,
      'ownerType':ownerType,
    };
  }
}
