

import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';

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
        border: OutlineInputBorder(
          borderSide: BorderSide(color: getBorderColor(), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: getBorderColor(), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: getBorderColor(), width: 2),
        ),
        floatingLabelStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
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
