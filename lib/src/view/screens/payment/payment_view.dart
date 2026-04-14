import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/utils/format_price.dart';
import 'package:holi/src/view/screens/payment/payment_failed_view.dart';
import 'package:holi/src/view/screens/payment/payment_success_view.dart';
import 'package:holi/src/view/screens/payment/wava_payment_vew.dart';
import 'package:holi/src/view/screens/user/home_user_view.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/utils/format_price.dart';
import 'package:holi/src/view/screens/payment/wava_payment_vew.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PaymentView extends StatefulWidget {
  final Map<String, dynamic> paymentData;

  const PaymentView({super.key, required this.paymentData});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  bool _openingPayment = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Color _getPaymentColor() {
    final String paymentMethod = (widget.paymentData['paymentMethod'] ?? "nequi").toString().toLowerCase();
    if (paymentMethod == "nequi") {
      return const Color(0xFF7B1FA2);
    } else if (paymentMethod == "daviplata") {
      return const Color(0xFFE53935);
    }
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final String paymentMethod = widget.paymentData['paymentMethod'] ?? "N/A";
    final String paymentURL = widget.paymentData['paymentURL'] ?? "";
    final String origin = widget.paymentData['origin'] ?? "Origen no definido";
    final String destination = widget.paymentData['destination'] ?? "Destino no definido";
    final String distanceKm = widget.paymentData['distanceKm'] ?? "";
    final String durationMin = widget.paymentData['durationMin'] ?? "";

    List<String> partsOrigin = origin.split(',');
    String reducedOrigin = partsOrigin.take(2).join(',').trim();
    List<String> partsDestination = destination.split(',');
    String reducedDestination = partsDestination.take(2).join(',').trim();

    final dynamic amount = widget.paymentData['amount'];
    final double priceValue = amount != null ? (amount is num ? amount.toDouble() : double.tryParse(amount.toString()) ?? 0) : 0;
    String formattedPrice = formatPriceMovingDetails(priceValue.toString());
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Por seguridad, completa el pago para finalizar.", style: TextStyle(fontSize: 14.sp)),
            backgroundColor: Colors.redAccent,
          ),
        );
      },
      child: Scaffold(
        backgroundColor: AppTheme.colorbackgroundview,
        appBar: AppBar(
          title: Text("Resumen de Mudanza", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18.sp)),
          backgroundColor: Colors.black,
          centerTitle: true,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 22.sp),
                    SizedBox(height: 10.h),
                    Text(
                      "¡Mudanza Completada!",
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 25.h),
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                        side: BorderSide(color: Colors.grey.shade200, width: 1),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          children: [
                            _buildInfoRow(Icons.location_on_outlined, "Desde", reducedOrigin),
                            Divider(height: 30.h, color: Colors.grey.shade100),
                            _buildInfoRow(Icons.flag_outlined, "Hasta", reducedDestination),
                            Divider(height: 30.h, color: Colors.grey.shade100),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Total pagado", style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
                                Text(
                                  formattedPrice,
                                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            paymentMethod.toLowerCase().contains("daviplata") ? 'assets/images/daviplata.png' : 'assets/images/nequi.png',
                            width: 40.w,
                            height: 40.w,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            "Pago vía $paymentMethod",
                            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          const Icon(Icons.lock_outline, color: Colors.grey, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 30.h),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getPaymentColor(),
                  minimumSize: Size(double.infinity, 40.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  elevation: 0,
                ),
                onPressed: () async {
                  if (_openingPayment) return;
                  setState(() => _openingPayment = true);
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => WavaPaymentView(paymentUrl: paymentURL)));
                  if (mounted && result == 'success') {
                    _showFeedback(context, "¡Pago Exitoso!", "Tu mudanza ha sido finalizada correctamente.", Colors.green);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeUserView()),
                      (route) => false,
                    );
                  }
                
                  
                },
                child: _openingPayment
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Liberar pago al conductor",
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFeedback(BuildContext context, String title, String msg, Color color) {
    Flushbar(
      title: title,
      message: msg,
      backgroundColor: color,
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      margin: EdgeInsets.all(12.w),
      borderRadius: BorderRadius.circular(10.r),
    ).show(context);
  }

  // Widget auxiliar para las filas de información
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20.sp, color: AppTheme.primarycolor),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
              Text(
                value,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void startPayment(BuildContext context, String paymentUrl) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => WavaPaymentView(paymentUrl: paymentUrl))).then((_) => setState(() => _openingPayment = false));
  }
}
