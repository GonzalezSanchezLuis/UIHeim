import 'package:flutter/material.dart';
import 'package:holi/src/model/payment/payment_model.dart';
import 'package:holi/src/service/payment/payment_service.dart';

class PaymentViewmodel extends ChangeNotifier {
  final PaymentService _paymentService = PaymentService();

  bool _isLoading = false;
  String? _checkoutUrl;

  bool get isLoading => _isLoading;
  String? get checkoutUrl => _checkoutUrl;

  Future<void> startPayment(PaymentModel paymentModel) async {
    _isLoading = true;
    notifyListeners();

    final url = await _paymentService.generatePaymentUrl(paymentModel);
    print("URL DE PAGO $url");
    _checkoutUrl = url;
    _isLoading = false;
    notifyListeners();
  }
}
