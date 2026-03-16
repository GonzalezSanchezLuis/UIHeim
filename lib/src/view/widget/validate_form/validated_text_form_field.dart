import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ValidatedTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;
  final void Function(String)? onChanged;
  final Widget? suffixIcon;

  const ValidatedTextFormField({
    Key? key,
    required this.controller,
    required this.label,
    required this.validator,
    this.onChanged,
    this.suffixIcon,
  }) : super(key: key);

  @override
  State<ValidatedTextFormField> createState() => _ValidatedTextFormFieldState();
}

class _ValidatedTextFormFieldState extends State<ValidatedTextFormField> {
  bool? isValid;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validate);
  }

  void _validate() {
    final result = widget.validator(widget.controller.text);
    setState(() {
      isValid = result == null;
    });
  }

  Color getBorderColor() {
    if (isValid == null) return Colors.black87;
    return isValid! ? AppTheme.confirmationscolor : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      onChanged: (value) {
        if (widget.onChanged != null) widget.onChanged!(value);
        _validate();
      },
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: widget.suffixIcon,
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: getBorderColor(), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: getBorderColor(), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: getBorderColor(), width: 2),
        ),
        floatingLabelStyle:  TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 14.sp,
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validate);
    super.dispose();
  }
}
