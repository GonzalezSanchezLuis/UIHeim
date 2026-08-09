import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/view/screens/travel/driver_information_view.dart';
import 'package:holi/src/viewmodels/driver/driver_data_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverInfoCard extends StatelessWidget {
  final int driverId;
  final String enrollVehicle;
  final String driverImageUrl;
  final String vehicleImageUrl;
  final String phone;
  final String nameDriver;
  final String vehicleType;
  final String accountNumber;
  final double amount;

  const DriverInfoCard({
    super.key,
    required this.driverId,
    required this.enrollVehicle,
    required this.driverImageUrl,
    required this.vehicleImageUrl,
    required this.phone,
    required this.nameDriver,
    required this.vehicleType,
    required this.accountNumber,
    required this.amount,
  });

  String get _formattedAmount =>
      '\$${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

  bool get _hasAccountNumber => accountNumber.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final double avatarRadius = 18.r;
    final double callButtonSize = 40.w;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  '${enrollVehicle.toUpperCase()} • ${vehicleType.toUpperCase()}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              CircleAvatar(
                radius: avatarRadius,
                backgroundColor: Colors.grey.shade200,
                child: ClipOval(
                  child: Image.asset(
                    vehicleImageUrl,
                    width: avatarRadius * 2,
                    height: avatarRadius * 2,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: avatarRadius,
                backgroundColor: Colors.grey.shade800,
                backgroundImage: driverImageUrl.isNotEmpty ? NetworkImage(driverImageUrl) : null,
                child: driverImageUrl.isEmpty
                    ? Icon(Icons.person, size: 22.sp, color: Colors.white)
                    : null,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider(
                          create: (_) => DriverDataViewmodel(),
                          child: DriverInformationView(driverId: driverId),
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$nameDriver ya va en camino',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14.sp,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              SizedBox(
                width: callButtonSize,
                height: callButtonSize,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppTheme.thirdcolor1,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 18.sp,
                    onPressed: () => launchUrl(Uri.parse('tel:$phone')),
                    icon: Icon(FontAwesomeIcons.phone, color: Colors.black, size: 18.sp),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          _PaymentSection(
            hasAccountNumber: _hasAccountNumber,
            accountNumber: accountNumber,
            formattedAmount: _formattedAmount,
          ),
        ],
      ),
    );
  }
}

class _PaymentSection extends StatelessWidget {
  final bool hasAccountNumber;
  final String accountNumber;
  final String formattedAmount;

  const _PaymentSection({
    required this.hasAccountNumber,
    required this.accountNumber,
    required this.formattedAmount,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompact = constraints.maxWidth < 300.w;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.grey.shade800, width: 1),
          ),
          child: isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _accountBlock(context),
                    SizedBox(height: 8.h),
                    _amountBlock(alignEnd: false),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _accountBlock(context)),
                    SizedBox(width: 8.w),
                    _amountBlock(alignEnd: true),
                  ],
                ),
        );
      },
    );
  }

  Widget _accountBlock(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasAccountNumber)
          Text(
            'Paga al cargar en origen vía Nequi:',
            style: TextStyle(color: Colors.grey, fontSize: 11.sp),
          ),
        if (hasAccountNumber) SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: Text(
                hasAccountNumber ? accountNumber : 'Coordina el pago con el conductor',
                style: TextStyle(
                  color: hasAccountNumber ? Colors.white : Colors.amberAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: hasAccountNumber ? 14.sp : 12.sp,
                  letterSpacing: hasAccountNumber ? 1.0 : 0,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasAccountNumber) ...[
              SizedBox(width: 6.w),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: accountNumber));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Número de Nequi copiado',
                        style: TextStyle(fontSize: 13.sp),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Icon(Icons.copy, size: 16.sp, color: AppTheme.thirdcolor1),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _amountBlock({required bool alignEnd}) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Valor Total',
          style: TextStyle(color: Colors.grey, fontSize: 11.sp),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            formattedAmount,
            style: TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
              fontSize: 17.sp,
            ),
          ),
        ),
      ],
    );
  }
}
