import 'package:flutter/material.dart';
import 'package:mslr/presentation/components/btn_custom.dart';
import 'package:mslr/presentation/components/text_custom.dart';
import 'package:mslr/presentation/themes/colors_custom.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsCustom.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // App Title
              const TextCustom(
                text: 'MSLR',
                fontSize: 56,
                color: ColorsCustom.primaryColor,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Subtitle
              const TextCustom(
                text: 'My Shangri-La Referendum',
                fontSize: 20,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),

              // Section Title
              const TextCustom(
                text: 'Choose Account Type',
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Voter Login Button
              BtnFrave(
                text: 'Voter Login',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 55,
                color: ColorsCustom.primaryColor,
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
              ),

              const SizedBox(height: 16),

              // Voter Register Button
              BtnFrave(
                text: 'Register as Voter',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 55,
                color: Colors.white,
                textColor: ColorsCustom.primaryColor,
                borderColor: ColorsCustom.primaryColor,
                borderWidth: 2,
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
              ),

              const SizedBox(height: 32),

              // Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.grey[400], thickness: 1),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextCustom(
                      text: 'OR',
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Colors.grey[400], thickness: 1),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Admin Login Button
              BtnFrave(
                text: 'Election Commission Login',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 55,
                color: Colors.black87,
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pushNamed(context, '/admin-login');
                },
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
