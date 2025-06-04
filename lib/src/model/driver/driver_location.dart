class DriverLocation {
  final double latitude;
  final double longitude;

  DriverLocation(this.latitude, this.longitude);

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude};
  }
}
