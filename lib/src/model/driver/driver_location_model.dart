class DriverLocationModel {
  final double latitude;
  final double longitude;

  DriverLocationModel(this.latitude, this.longitude);

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude};
  }
}
