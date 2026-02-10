class DriverDataModel {
  final String name;
  final String phone;
  final String urlAvatar;

  DriverDataModel({required this.name, required this.phone, required this.urlAvatar});

  factory DriverDataModel.fromJson(Map<String, dynamic> json) {
    return DriverDataModel(name: json['name'] ?? '', 
    phone: json['phone'] ?? '', 
    urlAvatar: json['urlAvatar'] ?? '');
  }
}
