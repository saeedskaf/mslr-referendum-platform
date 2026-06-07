// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mslr/data/local_secure/secure_storage.dart';
import 'package:mslr/presentation/components/text_custom.dart';
import 'package:mslr/presentation/themes/colors_custom.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  _navigateToNext() async {
    // Show splash for 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Check if user is logged in
    final isLoggedIn = await secureStorage.isLoggedIn();

    if (!isLoggedIn) {
      // No user logged in, go to welcome screen
      Navigator.pushReplacementNamed(context, '/welcome');
      return;
    }

    // User is logged in, determine if admin or voter
    final userData = await secureStorage.getUserData();
    final userName = userData['name'];

    if (userName == 'Election Commission') {
      // Admin user
      Navigator.pushReplacementNamed(context, '/admin-dashboard');
    } else {
      // Regular voter
      Navigator.pushReplacementNamed(context, '/voter-dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsCustom.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const TextCustom(
              text: 'MSLR',
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const TextCustom(
              text: 'My Shangri-La Referendum',
              fontSize: 18,
              color: Colors.white70,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
