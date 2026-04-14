import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class WavaPaymentView extends StatefulWidget {
  final String paymentUrl;

  const WavaPaymentView({super.key, required this.paymentUrl});

  @override
  State<WavaPaymentView> createState() => _WavaPaymentViewState();
}

class _WavaPaymentViewState extends State<WavaPaymentView> with WidgetsBindingObserver {
  bool _handled = false;
  bool _isResumed = true;

  late final WebViewController controller;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('Navegación iniciada a: $url');
            final uri = Uri.parse(url);


            if (!_handled && _isResumed &&  uri.queryParameters.containsKey('status')) {
              _handled = true;
              final paymentStatus = uri.queryParameters['status'];
              if (paymentStatus == "SUCCESS") {
                Navigator.pop(context, 'success');
              } else {
                Navigator.pop(context, 'failed');
              }
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isResumed = state == AppLifecycleState.resumed;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        backgroundColor: AppTheme.primarycolor,
        title: const Text("Pago de Mudanza", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
     body: WebViewWidget(controller: controller),
     bottomNavigationBar: Container(
        padding: EdgeInsets.all(16.w),
        color: Colors.white,
        child: ElevatedButton(
          
          onPressed: () => Navigator.pop(context, 'success'),         
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primarycolor,
           minimumSize: Size(double.infinity, 40.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
          
          child:  Text("Finalizar y volver", style: TextStyle(color: Colors.white, fontSize: 14.sp,fontWeight: FontWeight.bold)),
        ),
      ),

    );
  }
}
