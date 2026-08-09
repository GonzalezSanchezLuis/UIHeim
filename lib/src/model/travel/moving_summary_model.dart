class MovingSummaryModel {
  final int moveId;
  final String origin;
  final String destination;
  final String distanceKm;
  final String durationMin;
  final String paymentMethod;
  final double amount;
  final String currency;
  final bool paymentCompleted;

  MovingSummaryModel({
    required this.moveId,
    required this.origin,
    required this.destination,
    required this.distanceKm,
    required this.durationMin,
    required this.paymentMethod,
    required this.amount,
    required this.currency,
    required this.paymentCompleted,
  });

  factory MovingSummaryModel.fromJson(Map<String, dynamic> json) {
     final rawMoveId = json['moveId'];
    final int moveId = (rawMoveId is int) ? rawMoveId : int.tryParse(rawMoveId.toString()) ?? 0;

    return MovingSummaryModel(
      moveId: json['moveId'],
        origin: json['origin'] ?? '',
        destination: json['destination'] ?? '',
        distanceKm: json['distance'] ?? '',
        durationMin: json['duration'] ?? '',
        paymentMethod: json['paymentMethod'] ?? '',
        amount: (json['amount'] ?? 0).toDouble(),
        currency: json['currency'] ?? 'COP',
        paymentCompleted: json['paymentCompleted'] ?? false,
    );
  }
}
