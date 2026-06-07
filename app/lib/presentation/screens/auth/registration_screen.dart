// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:mslr/domain/services/user_services.dart';
import 'package:mslr/presentation/components/btn_custom.dart';
import 'package:mslr/presentation/components/form_field_custom.dart';
import 'package:mslr/presentation/components/qr_scanner.dart';
import 'package:mslr/presentation/components/text_custom.dart';
import 'package:mslr/presentation/helpers/modal_loading.dart';
import 'package:mslr/presentation/helpers/show_message.dart';
import 'package:mslr/presentation/helpers/validate_form.dart';
import 'package:mslr/presentation/themes/colors_custom.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _sccController = TextEditingController();
  final _userServices = UserServices();

  DateTime? _selectedDate;

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _sccController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Select your date of birth',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ColorsCustom.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _scanQRCode() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

    if (!mounted) return;

    if (result != null && result.isNotEmpty) {
      setState(() {
        _sccController.text = result.toUpperCase();
      });
      ShowMessage.success(context, 'SCC scanned successfully');
    }
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      // Check if date is selected
      if (_selectedDate == null) {
        ShowMessage.error(context, 'Please select your date of birth');
        return;
      }

      // Validate age (18+)
      final validators = FormValidators(context);
      final formattedDate = _formatDateForApi(_selectedDate!);
      final ageError = validators.validateAge(formattedDate);

      if (ageError != null) {
        ShowMessage.error(context, ageError);
        return;
      }

      // Show loading
      LoadingModal.show(context, message: 'Creating your account...');

      // Call API
      final result = await _userServices.registerClient(
        email: _emailController.text.trim(),
        fullName: _fullNameController.text.trim(),
        dateOfBirth: formattedDate,
        password: _passwordController.text,
        scc: _sccController.text.trim().toUpperCase(),
      );

      // Dismiss loading
      LoadingModal.dismiss(context);

      if (result['success']) {
        // Success
        ShowMessage.success(context, result['message']);

        // Navigate to login
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        // Error
        ShowMessage.error(context, result['message']);
      }
    }
  }

  String _formatDateForApi(DateTime date) {
    // Format: YYYY-MM-DD
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateForDisplay(DateTime date) {
    // Format: DD/MM/YYYY
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
                  text: 'Create Account',
                  fontSize: 32,
                  color: ColorsCustom.primaryColor,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 8),

                // Subtitle
                const TextCustom(
                  text: 'Register to participate in referendums',
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w400,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 30),

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

                // Full Name Field
                FormFieldFrave(
                  controller: _fullNameController,
                  hintText: 'Enter your full name',
                  label: 'Full Name',
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  validator: validators.fullNameValidator.call,
                ),
                const SizedBox(height: 20),

                // Date of Birth Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TextCustom(
                      text: 'Date of Birth',
                      color: ColorsCustom.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextCustom(
                              text: _selectedDate == null
                                  ? 'Select your date of birth'
                                  : _formatDateForDisplay(_selectedDate!),
                              fontSize: 15,
                              color: _selectedDate == null
                                  ? Colors.grey.shade400
                                  : Colors.black87,
                              textAlign: TextAlign.left,
                            ),
                            Icon(
                              Icons.calendar_today,
                              color: ColorsCustom.primaryColor,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Password Field
                FormFieldFrave(
                  controller: _passwordController,
                  hintText: 'Enter your password',
                  label: 'Password',
                  isPassword: true,
                  textInputAction: TextInputAction.next,
                  validator: validators.passwordValidator.call,
                ),
                const SizedBox(height: 20),

                // Confirm Password Field
                FormFieldFrave(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm your password',
                  label: 'Confirm Password',
                  isPassword: true,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    return validators.passwordMatchValidator(
                      _passwordController.text,
                      value,
                    );
                  },
                ),
                const SizedBox(height: 20),

                // SCC Field with QR Scanner
                FormFieldFrave(
                  controller: _sccController,
                  hintText: 'Enter your 10-character SCC',
                  label: 'Shangri-La Citizen Code (SCC)',
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  maxLength: 10,
                  validator: validators.sccValidator.call,
                  onChanged: (value) {
                    // Auto convert to uppercase
                    _sccController.value = _sccController.value.copyWith(
                      text: value.toUpperCase(),
                      selection: TextSelection.collapsed(offset: value.length),
                    );
                  },
                  suffixWidget: GestureDetector(
                    onTap: _scanQRCode,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ColorsCustom.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner,
                        color: ColorsCustom.primaryColor,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // SCC Info Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ColorsCustom.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: ColorsCustom.primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: ColorsCustom.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextCustom(
                          text:
                              'Your SCC can be found on your Council tax letter or scan the QR code',
                          fontSize: 12,
                          color: ColorsCustom.primaryColor,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Register Button
                BtnFrave(
                  text: 'Register',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 55,
                  color: ColorsCustom.primaryColor,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 20),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const TextCustom(
                      text: "Already have an account? ",
                      fontSize: 14,
                      color: Colors.black54,
                      textAlign: TextAlign.center,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const TextCustom(
                        text: 'Login',
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
