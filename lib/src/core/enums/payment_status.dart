enum PaymentStatus { CREATED, PROCESSING, PAID, FAILED, EXPIRED }

extension PaymentStatusText on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.CREATED:
        return 'Pendiente de pago';
      case PaymentStatus.PROCESSING:
        return 'Procesando';
      case PaymentStatus.PAID:
        return 'Pagado';
      case PaymentStatus.FAILED:
        return "Fallido";
      case PaymentStatus.EXPIRED:
        return "ago expirado";
    }
  }

  String get value => name;
}
