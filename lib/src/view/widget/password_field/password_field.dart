import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PasswordFieldCard extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final bool isRequired;

  const PasswordFieldCard({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.isRequired = false,
  });

  @override
  State<PasswordFieldCard> createState() => _PasswordFieldCardState();
}

class _PasswordFieldCardState extends State<PasswordFieldCard> {
  bool _obscurePassword = true;
  final FocusNode _focusNode = FocusNode();

  @override
    void initState(){
        super.initState();
        _focusNode.addListener((){
          if(_focusNode.hasFocus){
              if(widget.controller.text == '••••••••••••'){
                  widget.controller.clear();
              }
          }else{
            if (widget.controller.text.isEmpty) {
              widget.controller.text = '••••••••••••';
            }
          }
        });
        
    }
  

  @override
  void dispose() {
    _focusNode.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.colorcards,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                widget.label,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                obscureText: _obscurePassword,
                style: TextStyle(fontSize: 13.sp,),
                onTap:(){
                  if (widget.controller.text == '••••••••••••') {
                    widget.controller.clear();
                  }
                },
                validator: (value) {
                  if (widget.isRequired && (value == null || value.trim().isEmpty)) {
                    return 'Obligatorio';
                  }

                  if (value != null && value.isNotEmpty && value != '••••••••••••') {
                    if (value.length < 8) {
                      return 'Mínimo 8 caracteres';
                    }
                    if (!RegExp(r'(?=.*[a-z])(?=.*[0-9])').hasMatch(value)) {
                      return 'Usa letras y números';
                    }
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(fontSize: 13.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Colors.black87, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Colors.black87, width: 2.0),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                      size: 18.sp,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
