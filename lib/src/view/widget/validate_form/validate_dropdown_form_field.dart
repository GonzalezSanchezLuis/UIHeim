
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _validate(widget.value);
  }

  void _validate(MoveType? value) {
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
    return DropdownButtonFormField<MoveType>(
      value: widget.value,
      validator: (value) {
        final result = widget.validator(value);
        setState(() {
          isValid = result == null;
        });
        return result;
      },
      onChanged: ( newValue) {
        widget.onChanged(newValue);
        _validate(newValue);
      },
      items: MoveType.values .map((type) => DropdownMenuItem(value: type,child: Text(type.label),)).toList(),
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
