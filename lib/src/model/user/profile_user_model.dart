// profile_model.dart
class ProfileModel {
  String? fullName;
  String? document;
  String? phone;
  String? email;
  String? password;
  String? urlAvatarProfile;

  ProfileModel({
    this.fullName,
    this.document,
    this.phone,
    this.email,
    this.password,
    this.urlAvatarProfile,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      fullName: map['fullName'],
      document: map['document'],
      phone: map['phone'],
      email: map['email'],
      urlAvatarProfile: map['urlAvatarProfile'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'document': document,
      'phone': phone,
      'email': email,
      'password': password,
      'urlAvatarProfile': urlAvatarProfile,
    };
  }

  // Método copyWith
  ProfileModel copyWith({
    String? fullName,
    String? document,
    String? phone,
    String? email,
    String? password,
    String? urlAvatarProfile,
  }) {
    return ProfileModel(
      fullName: fullName ?? this.fullName,
      document: document ?? this.document,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      urlAvatarProfile: urlAvatarProfile ?? this.urlAvatarProfile,
    );
  }
}
