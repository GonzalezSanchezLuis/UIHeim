import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StyleFonts {
  static TextStyle get title => TextStyle(
    fontSize: 18.sp,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  static  TextStyle get descriptions => TextStyle(
    fontSize: 12.sp,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  static  TextStyle  get textColorButton => TextStyle(
    fontSize: 15.sp,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static  TextStyle get selectedLabelStyle =>  TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
