import 'package:flutter/material.dart';
import 'package:mslr/presentation/components/text_custom.dart';
import 'package:mslr/presentation/themes/colors_custom.dart';

class BtnFrave extends StatelessWidget {
  final String text;
  final Color color;
  final Color? borderColor;
  final double borderWidth;
  final double height;
  final double width;
  final double borderRadius;
  final Color textColor;
  final FontWeight fontWeight;
  final double fontSize;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final bool enabled;

  const BtnFrave({
    super.key,
    required this.text,
    this.color = ColorsCustom.primaryColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.height = 50,
    this.width = double.infinity,
    this.borderRadius = 12.0,
    this.textColor = Colors.white,
    this.fontWeight = FontWeight.w600,
    this.fontSize = 16,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.padding,
    this.elevation,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = !enabled || onPressed == null || isLoading;
    final Color effectiveColor = isDisabled ? Colors.grey.shade300 : color;
    final Color effectiveTextColor = isDisabled
        ? Colors.grey.shade500
        : textColor;

    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveColor,
          foregroundColor: effectiveTextColor,
          elevation: elevation ?? (isDisabled ? 0 : 2),
          shadowColor: ColorsCustom.primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: borderColor != null
                ? BorderSide(
                    color: isDisabled ? Colors.grey.shade300 : borderColor!,
                    width: borderWidth,
                  )
                : BorderSide.none,
          ),
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade500,
        ),
        onPressed: isDisabled ? null : onPressed,
        child: _buildButtonContent(effectiveTextColor),
      ),
    );
  }

  Widget _buildButtonContent(Color effectiveTextColor) {
    if (isLoading) {
      return _buildLoadingIndicator(effectiveTextColor);
    }

    if (icon != null) {
      return _buildButtonWithIcon(effectiveTextColor);
    }

    return _buildTextOnly(effectiveTextColor);
  }

  Widget _buildLoadingIndicator(Color color) {
    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  Widget _buildButtonWithIcon(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon!,
        const SizedBox(width: 8),
        Flexible(child: _buildTextOnly(color)),
      ],
    );
  }

  Widget _buildTextOnly(Color color) {
    return TextCustom(
      text: text,
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      textAlign: TextAlign.center,
      maxLines: 1,
      textOverflow: TextOverflow.ellipsis,
    );
  }
}
