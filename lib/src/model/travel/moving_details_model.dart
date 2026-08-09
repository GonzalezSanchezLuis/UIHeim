class MovingDetailsModel {
  final int moveId;
  final String origin;
  final String destination;
  final String distanceKm;
  final String durationMin;
  final String paymentMethod;
  final double amount;
  final String currency;
  final String paymentUrl;
  final bool paymentComplete;

  MovingDetailsModel({required this.moveId, required this.origin, required this.destination, required this.distanceKm, required this.durationMin, required this.paymentMethod, required this.amount, required this.currency, required this.paymentComplete, required this.paymentUrl});

  factory MovingDetailsModel.fromJson(Map<String, dynamic> json) {
    return MovingDetailsModel(
        moveId: json['movingId'],
        origin: json['origin'] ?? '',
        destination: json['destination'] ?? '',
        distanceKm: json['distance'] ?? '',
        durationMin: json['duration'] ?? '',
        paymentMethod: json['paymentMethod'] ?? '',
        amount: (json['amount'] ?? 0).toDouble(),
        currency: json['currency'] ?? 'COP',
        paymentComplete: json['paymentCompleted'] ?? false,
        paymentUrl: json['paymentUrl']);
  }
}
