import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mslr/presentation/components/text_custom.dart';
import 'package:mslr/presentation/themes/colors_custom.dart';

class FormFieldFrave extends StatefulWidget {
  static const double defaultBorderRadius = 12.0;
  static const EdgeInsets defaultContentPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 16.0,
  );

  final TextEditingController? controller;
  final String? hintText;
  final String? prefix;
  final bool isPassword;
  final TextInputType keyboardType;
  final int maxLine;
  final bool readOnly;
  final double borderRadius;
  final ImageIcon? icon;
  final VoidCallback? onPressed;
  final FormFieldValidator<String>? validator;
  final String? label;
  final Widget? suffixWidget;
  final TextInputAction? textInputAction;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final bool enabled;
  final String? initialValue;

  const FormFieldFrave({
    super.key,
    this.controller,
    this.hintText,
    this.prefix,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.maxLine = 1,
    this.readOnly = false,
    this.borderRadius = defaultBorderRadius,
    this.icon,
    this.onPressed,
    this.validator,
    this.label,
    this.suffixWidget,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.inputFormatters,
    this.maxLength,
    this.enabled = true,
    this.initialValue,
  });

  @override
  FormFieldFraveState createState() => FormFieldFraveState();
}

class FormFieldFraveState extends State<FormFieldFrave> {
  bool _obscureText = true;
  bool _isFocused = false;
  late FocusNode _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = widget.focusNode ?? FocusNode();
    _internalFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    } else {
      _internalFocusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _internalFocusNode.hasFocus;
    });
  }

  // Styles
  TextStyle get _inputStyle => GoogleFonts.cairo(
    color: widget.enabled ? Colors.black87 : Colors.grey.shade500,
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  TextStyle get _hintStyle => GoogleFonts.cairo(
    color: Colors.grey.shade400,
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );

  // Borders
  OutlineInputBorder get _baseBorder => OutlineInputBorder(
    borderRadius: BorderRadius.circular(widget.borderRadius),
    borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
  );

  OutlineInputBorder get _focusedBorder => OutlineInputBorder(
    borderSide: const BorderSide(color: ColorsCustom.primaryColor, width: 2.0),
    borderRadius: BorderRadius.circular(widget.borderRadius),
  );

  OutlineInputBorder get _errorBorder => OutlineInputBorder(
    borderSide: const BorderSide(color: ColorsCustom.errorColor, width: 1.5),
    borderRadius: BorderRadius.circular(widget.borderRadius),
  );

  OutlineInputBorder get _disabledBorder => OutlineInputBorder(
    borderRadius: BorderRadius.circular(widget.borderRadius),
    borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
  );

  EdgeInsets get _contentPadding => FormFieldFrave.defaultContentPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          TextCustom(
            text: widget.label!,
            color: ColorsCustom.primaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          style: _inputStyle,
          obscureText: widget.isPassword && _obscureText,
          maxLines: widget.isPassword ? 1 : widget.maxLine,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          keyboardType: widget.keyboardType,
          decoration: _buildInputDecoration(),
          textAlignVertical: _getTextAlignVertical(),
          validator: widget.validator,
          cursorColor: ColorsCustom.primaryColor,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          focusNode: _internalFocusNode,
          autofocus: widget.autofocus,
          inputFormatters: widget.inputFormatters,
          maxLength: widget.maxLength,
          buildCounter: widget.maxLength != null
              ? (
                  context, {
                  required currentLength,
                  required isFocused,
                  maxLength,
                }) => TextCustom(
                  text: '$currentLength/${maxLength ?? ''}',
                  fontSize: 12,
                  color: Colors.grey.shade600,
                )
              : null,
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: widget.enabled ? Colors.white : Colors.grey.shade50,
      border: _baseBorder,
      focusedBorder: _focusedBorder,
      enabledBorder: _baseBorder,
      errorBorder: _errorBorder,
      focusedErrorBorder: _errorBorder,
      disabledBorder: _disabledBorder,
      contentPadding: _contentPadding,
      hintText: widget.hintText,
      hintStyle: _hintStyle,
      suffixIcon: _buildSuffixIcon(),
      prefixIcon: _buildPrefixIcon(),
      errorStyle: GoogleFonts.cairo(
        color: ColorsCustom.errorColor,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      errorMaxLines: 2,
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.suffixWidget != null) {
      return widget.suffixWidget;
    }

    if (widget.isPassword) {
      return _buildPasswordVisibilityToggle();
    }

    if (widget.icon != null) {
      return _buildCustomIcon();
    }

    return null;
  }

  Widget? _buildPrefixIcon() {
    if (widget.prefix != null) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          "${widget.prefix} | ",
          style: _inputStyle.copyWith(color: Colors.grey.shade600),
        ),
      );
    }

    return null;
  }

  Widget _buildPasswordVisibilityToggle() {
    return GestureDetector(
      onTap: _togglePasswordVisibility,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Icon(
          _obscureText
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: _isFocused ? ColorsCustom.primaryColor : Colors.grey.shade400,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildCustomIcon() {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ColorsCustom.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(100),
        ),
        child: widget.icon,
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  TextAlignVertical _getTextAlignVertical() {
    return widget.isPassword ? TextAlignVertical.center : TextAlignVertical.top;
  }
}
