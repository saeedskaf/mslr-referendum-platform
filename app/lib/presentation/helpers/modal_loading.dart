import 'package:flutter/material.dart';
import 'package:mslr/presentation/components/text_custom.dart';
import 'package:mslr/presentation/themes/colors_custom.dart';

class LoadingModal {
  static bool _isShowing = false;

  // Show loading modal
  static void show(BuildContext context, {String? message}) {
    if (_isShowing) return; // Prevent multiple modals

    _isShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black26,
      useRootNavigator: true,
      builder: (context) => PopScope(
        canPop: false, // Prevent back button dismiss
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 5,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: ColorsCustom.primaryColor,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 20),
                TextCustom(
                  text: message ?? 'Loading...',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) => _isShowing = false);
  }

  // Dismiss loading modal
  static void dismiss(BuildContext context) {
    if (_isShowing) {
      Navigator.of(context, rootNavigator: true).pop();
      _isShowing = false;
    }
  }
}
