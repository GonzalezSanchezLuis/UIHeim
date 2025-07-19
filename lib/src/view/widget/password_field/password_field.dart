import 'package:flutter/material.dart';
import 'package:holi/src/core/theme/colors/app_theme.dart';

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

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.colorcards,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                widget.label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: widget.controller,
                obscureText: _obscurePassword,
                validator: widget.isRequired
                    ? (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      }
                    : null,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black87, width: 2.0),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black87, width: 2.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
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
