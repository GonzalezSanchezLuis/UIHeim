class PaymentDriverAccountModel {
  final int driverId;
  final String paymentMethod;
  final String accountNumber;

  PaymentDriverAccountModel({
    required this.driverId,
    required this.paymentMethod,
    required this.accountNumber,
  });

  factory PaymentDriverAccountModel.fromJson(Map<String, dynamic> json) {
    return PaymentDriverAccountModel(
     driverId: (json['driverId'] as int?) ?? 0,
      paymentMethod: json['paymentMethod'] as String,
      accountNumber: json['accountNumber'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driverId': driverId,
      'paymentMethod': paymentMethod,
      'accountNumber': accountNumber,
    };
  }
}
