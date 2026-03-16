import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; 
import 'package:holi/src/core/enums/move_type.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';

class ValidatedDropdownFormField extends StatefulWidget {
  final MoveType? value;
  final List<String> items;
  final String label;
  final void Function(MoveType?) onChanged;
  final String? Function(MoveType?) validator;

  const ValidatedDropdownFormField({
    Key? key,
    required this.value,
    required this.items,
    required this.label,
    required this.onChanged,
    required this.validator,
  }) : super(key: key);

  @override
  State<ValidatedDropdownFormField> createState() => _ValidatedDropdownFormFieldState();
}

class _ValidatedDropdownFormFieldState extends State<ValidatedDropdownFormField> {
  bool? isValid;

  void _validate(MoveType? value) {
    final result = widget.validator(value);
    setState(() {
      isValid = result == null;
    });
  }

  Color getBorderColor() {
    if (isValid == null) return Colors.grey.shade400; 
    return isValid! ? AppTheme.confirmationscolor : Colors.red.shade700;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<MoveType>(
      isExpanded: true,
      value: widget.value,
      dropdownColor: Colors.white,
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primarycolor, size: 24.w),
      elevation: 8,
      style: TextStyle(color: Colors.black, fontSize: 15.sp),
      borderRadius: BorderRadius.circular(12.r),

     

      validator: (value) {
        final result = widget.validator(value);
        setState(() {
          isValid = result == null;
        });
        return result;
      },
      onChanged: (newValue) {
        widget.onChanged(newValue);
        _validate(newValue);
      },
      items: MoveType.values.asMap().entries.map((entry) {
        int idx = entry.key;
        MoveType type = entry.value;
        String labelToShow = (idx < widget.items.length) ? widget.items[idx] : type.label;

        return DropdownMenuItem<MoveType>(
          value: type,
          child: Text(
            labelToShow,
            style: TextStyle(fontSize: 14.sp,),
            softWrap: true, // Adaptación para pantallas pequeñas
          ),
        );
      }).toList(),
     /* items: MoveType.values.map((type) => DropdownMenuItem(
                value: type,
                child: Text(
                  type.label,
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
                  softWrap: true,
                  maxLines: 2,
                ),
              ))
          .toList(), */

      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        filled: true,
        fillColor: Colors.white,

        // Bordes adaptables y estilizados
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: getBorderColor(), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppTheme.primarycolor, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: getBorderColor(), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
        ),

        floatingLabelStyle: TextStyle(
          color: AppTheme.primarycolor,
          fontWeight: FontWeight.bold,
          fontSize: 16.sp,
        ),
      ),
    );
  }
}
