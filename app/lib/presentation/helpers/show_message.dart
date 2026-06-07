import 'package:flutter/material.dart';
import 'package:mslr/presentation/components/text_custom.dart';
import 'package:mslr/presentation/themes/colors_custom.dart';

class ShowMessage {
  // Show custom message
  static void show(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: TextCustom(text: message, color: Colors.white, fontSize: 14),
        backgroundColor: backgroundColor ?? ColorsCustom.primaryColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        action: action,
      ),
    );
  }

  // Show success message (green)
  static void success(BuildContext context, String message) {
    show(context, message, backgroundColor: ColorsCustom.secondaryColor);
  }

  // Show error message (red)
  static void error(BuildContext context, String message) {
    show(context, message, backgroundColor: ColorsCustom.errorColor);
  }

  // Show info message (blue)
  static void info(BuildContext context, String message) {
    show(context, message, backgroundColor: ColorsCustom.primaryColor);
  }

  // Show warning message (orange)
  static void warning(BuildContext context, String message) {
    show(context, message, backgroundColor: Colors.orange);
  }
}
