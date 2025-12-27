class WalletModel {
  final int driverId;
  final double availableBalance; 
  final double pendingBalance;
  final DateTime? lastPaymentDate;
  final DateTime nextPaymentDate;

  WalletModel({
    required this.driverId,
    required this.availableBalance, 
    required this.pendingBalance,
    this.lastPaymentDate,
    required this.nextPaymentDate,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    final String? lastDateStr = json['lastPaymentDate'];

   
    final rawAvailableBalance = json['availableBalance']; 
    final rawPendingBalance = json['pendingBalance'];

    double parsedAvailableBalance = 0.00;
    if (rawAvailableBalance is num) {
      parsedAvailableBalance = rawAvailableBalance.toDouble();
    } else if (rawAvailableBalance is String) {
      parsedAvailableBalance = double.tryParse(rawAvailableBalance) ?? 0.00;
    }

    double parsedPendingBalance = 0.00;
    if (rawPendingBalance is num) {
      parsedPendingBalance = rawPendingBalance.toDouble();
    } else if (rawPendingBalance is String) {
      parsedPendingBalance = double.tryParse(rawPendingBalance) ?? 0.00;
    }

    return WalletModel(
      driverId: json['driverId'] as int,
      availableBalance: parsedAvailableBalance, 
      pendingBalance: parsedPendingBalance, 
      lastPaymentDate: lastDateStr != null ? DateTime.parse(lastDateStr) : null,
      nextPaymentDate: DateTime.parse(json['nextPaymentDate']),
    );
  }
}
