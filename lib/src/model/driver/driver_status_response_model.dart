class DriverStatusResponse {
  final String status;

  DriverStatusResponse({required this.status});

  factory DriverStatusResponse.fromJson(Map<String, dynamic> json) {
    return DriverStatusResponse(
      status: json['status'],
    );
  }
}
