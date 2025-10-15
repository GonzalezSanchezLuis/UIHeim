class WalletModel {
  final int driverId;
  final double currentEarnedBalance; 
  final DateTime? lastPaymentDate; 
  final DateTime nextPaymentDate;


  WalletModel({
    required this.driverId,
    required this.currentEarnedBalance,
    this.lastPaymentDate, // Puede ser nulo
    required this.nextPaymentDate,

  });

  // Constructor de fábrica para crear el objeto desde el JSON de la API
  factory WalletModel.fromJson(Map<String, dynamic> json) {
    // Parseo de fechas: la API devuelve YYYY-MM-DD
    // El campo lastPaymentDate es opcional (puede ser null)
    final String? lastDateStr = json['lastPaymentDate'];
    final rawBalance = json['currentEarnedBalance'];

    double parsedBalance;

    if (rawBalance is String) {
      parsedBalance = double.tryParse(rawBalance) ?? 0.00;
    } else if (rawBalance is num) {
      // Si viene como número (int o double), conviértelo a double
      parsedBalance = rawBalance.toDouble();
    } else {
      parsedBalance = 0.00;
    }
    return WalletModel(
      driverId: json['driverId'] as int,
      currentEarnedBalance: parsedBalance,
      lastPaymentDate: lastDateStr != null ? DateTime.parse(lastDateStr) : null,
      nextPaymentDate: DateTime.parse(json['nextPaymentDate']),
    );
  }
}
