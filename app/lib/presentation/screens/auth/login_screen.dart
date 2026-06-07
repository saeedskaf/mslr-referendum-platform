// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mslr/domain/services/user_services.dart';
import 'package:mslr/presentation/components/btn_custom.dart';
import 'package:mslr/presentation/components/form_field_custom.dart';
import 'package:mslr/presentation/components/text_custom.dart';
import 'package:mslr/presentation/helpers/modal_loading.dart';
import 'package:mslr/presentation/helpers/show_message.dart';
import 'package:mslr/presentation/helpers/validate_form.dart';
import 'package:mslr/presentation/themes/colors_custom.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

      final result = await userServices.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      LoadingModal.dismiss(context);

      if (result['success']) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/voter-dashboard',
            (route) => false, // Remove all previous routes
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

                // Title
                const TextCustom(
                  text: 'Welcome Back!',
                  fontSize: 32,
                  color: ColorsCustom.primaryColor,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 8),

                // Subtitle
                const TextCustom(
                  text: 'Sign in to continue voting',
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w400,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 40),

                // Email Field
                FormFieldFrave(
                  controller: _emailController,
                  hintText: 'Enter your email',
                  label: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: validators.emailValidator.call,
                ),
                const SizedBox(height: 20),

                // Password Field
                FormFieldFrave(
                  controller: _passwordController,
                  hintText: 'Enter your password',
                  label: 'Password',
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: validators.passwordValidator.call,
                  onSubmitted: (_) => _handleLogin(),
                ),
                const SizedBox(height: 30),

                // Login Button
                BtnFrave(
                  text: 'Login',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 55,
                  color: ColorsCustom.primaryColor,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 20),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const TextCustom(
                      text: "Don't have an account? ",
                      fontSize: 14,
                      color: Colors.black54,
                      textAlign: TextAlign.center,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/register');
                      },
                      child: const TextCustom(
                        text: 'Register',
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
