class PasswordResertModel {
  final String email;

  PasswordResertModel({required this.email});

  Map<String, String> toJson() => {'email': email};
}
