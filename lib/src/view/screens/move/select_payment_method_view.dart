import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:holi/src/core/theme/fonts/style_fonts_title.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SelectPaymentMethod extends StatefulWidget {
  final String initialMethod;
  const SelectPaymentMethod({super.key, required this.initialMethod});

  @override
  _SelectPaymentMethodState createState() => _SelectPaymentMethodState();
}

class _SelectPaymentMethodState extends State<SelectPaymentMethod> {
  String selectedMethod = 'Nequi';
 
@override
  void initState() {
    super.initState();
    selectedMethod = widget.initialMethod; 
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorbackgroundview,
      appBar: AppBar(
        backgroundColor: AppTheme.primarycolor,
        title: Text("Selecciona un metodo de pago",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18.sp
            )),
        leading: IconButton(
          icon:  Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white, size: 20.sp,),
          onPressed: () => {Navigator.pop(context)},
        ),
      ),
      body: Padding(       
        padding:  EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             SizedBox(height: 30.h,),
             Text(
              "Selecciona tu método  de pago favorito.",
              style:  TextStyle(color: Colors.black,fontSize: 22.sp),
              
            ),
                SizedBox( height: 20.h,),
            _buildPaymentOption('Nequi', 'assets/images/nequi.png'),
            SizedBox(height: 10.h),
            _buildPaymentOption('Daviplata', 'assets/images/daviplata.png'),
          //  _buildPaymentOption('Tarjeta crédito/débito', 'assets/images/cards.png'),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, String assetPath) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: selectedMethod == title ? Colors.black : Colors.grey.shade300,
          width: 2.w,
        ),
      ),
      child: RadioListTile<String>(
        value: title,
        groupValue: selectedMethod,
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        onChanged: (value) {
          setState(() {
            selectedMethod = value!;
          });
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) Navigator.pop(context, value);
          });
        },
        title: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 219, 203, 203),
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                ),
                Image.asset(assetPath, width: 32.w, height: 32.h),
              ],
            ),
            SizedBox(width: 15.w),
            Text(title, style:  TextStyle(fontSize: 16.sp)),
          ],
        ),
        activeColor: Colors.black,
      ),
    );
  }
}
