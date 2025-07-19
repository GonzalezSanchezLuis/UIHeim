class PaymentModel {
  final String name;
  final String description;
  final String currency;
  final String invoice;
  final String amount;
  final String email;
  final String method;

  PaymentModel({
    required this.name,
    required this.description,
    required this.currency,
    required this.invoice,
    required this.amount,
    required this.email,
    required this.method,
  });

  Map<String, dynamic> toJson() =>{
        'name': name,
        'description': description,
        'currency': currency,
        'invoice': invoice,
        'amount': amount,
        'email': email,
        'method': method,
      };
  }

