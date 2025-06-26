
import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';

class ValidatedDropdownFormField extends StatefulWidget {
  final String? value;
  final List<String> items;
  final String label;
  final void Function(String?) onChanged;
  final String? Function(String?) validator;

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

  @override
  void initState() {
    super.initState();
    _validate(widget.value);
  }

  void _validate(String? value) {
    final result = widget.validator(value);
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
    return DropdownButtonFormField<String>(
      value: widget.value,
      validator: (value) {
        final result = widget.validator(value);
        setState(() {
          isValid = result == null;
        });
        return result;
      },
      onChanged: (String? newValue) {
        widget.onChanged(newValue);
        _validate(newValue);
      },
      items: widget.items.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
      decoration: InputDecoration(
        labelText: widget.label,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: getBorderColor(), width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: getBorderColor(), width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: getBorderColor(), width: 2.0),
        ),
        floatingLabelStyle: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
