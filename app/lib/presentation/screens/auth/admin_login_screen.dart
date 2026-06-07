// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:mslr/domain/services/user_services.dart';
import 'package:mslr/presentation/components/btn_custom.dart';
import 'package:mslr/presentation/components/form_field_custom.dart';
import 'package:mslr/presentation/components/text_custom.dart';
import 'package:mslr/presentation/helpers/modal_loading.dart';
import 'package:mslr/presentation/helpers/show_message.dart';
import 'package:mslr/presentation/helpers/validate_form.dart';
import 'package:mslr/presentation/themes/colors_custom.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      LoadingModal.show(context, message: 'Signing in...');

      final result = await userServices.adminLogin(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      LoadingModal.dismiss(context);

      if (result['success']) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/admin-dashboard',
            (route) => false,
          );
        }
      } else {
        ShowMessage.error(context, result['message']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final validators = FormValidators(context);

    return Scaffold(
      backgroundColor: ColorsCustom.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Admin Icon
                Center(
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: ColorsCustom.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      size: 60,
                      color: ColorsCustom.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Title
                const TextCustom(
                  text: 'Election Commission',
                  fontSize: 32,
                  color: ColorsCustom.primaryColor,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Subtitle
                const TextCustom(
                  text: 'Admin Portal',
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w400,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Email Field
                FormFieldFrave(
                  controller: _emailController,
                  hintText: 'Enter admin email',
                  label: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: validators.emailValidator.call,
                ),
                const SizedBox(height: 20),

                // Password Field
                FormFieldFrave(
                  controller: _passwordController,
                  hintText: 'Enter admin password',
                  label: 'Password',
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: validators.passwordValidator.call,
                  onSubmitted: (_) => _handleLogin(),
                ),
                const SizedBox(height: 30),

                // Login Button
                BtnFrave(
                  text: 'Sign In',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 55,
                  color: ColorsCustom.primaryColor,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 20),

                // Voter Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const TextCustom(
                      text: "Not an admin? ",
                      fontSize: 14,
                      color: Colors.black54,
                      textAlign: TextAlign.center,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const TextCustom(
                        text: 'Voter Login',
                        fontSize: 14,
                        color: ColorsCustom.primaryColor,
                        fontWeight: FontWeight.w600,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
