import 'package:flutter/material.dart';
import '../theme/color_palette.dart';

class AnimatedInput extends StatefulWidget {
  final String label;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onFieldSubmitted;

  const AnimatedInput({
    super.key,
    required this.label,
    this.prefixIcon,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onFieldSubmitted,
  });

  @override
  State<AnimatedInput> createState() => _AnimatedInputState();
}

class _AnimatedInputState extends State<AnimatedInput> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && _isObscured,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      onFieldSubmitted: widget.onFieldSubmitted,
      style: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppPalette.textPrimaryDark
            : AppPalette.textPrimaryLight,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _isObscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppPalette.textSecondaryLight,
                ),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              )
            : null,
      ),
    );
  }
}
