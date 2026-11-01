import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../navigation/app_routes.dart';
import '../models/otp_screen_arguments.dart';
import '../models/registration_form_data.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_progress.dart';
import '../widgets/auth_text_field.dart';

class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  State<StudentRegistrationScreen> createState() =>
      _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cmsController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cmsController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _required(String? value, String field) {
    if (value == null || value.trim().isEmpty) return 'Enter your $field.';
    return null;
  }

  String? _validateEmail(String? value) {
    final required = _required(value, 'university email');
    if (required != null) return required;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!.trim())) {
      return 'Enter a valid university email.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Create a password.';
    if (value.length < 8) return 'Use at least 8 characters.';
    return null;
  }

  String? _validateConfirmation(String? value) {
    if (value == null || value.isEmpty) return 'Re-enter your password.';
    if (value != _passwordController.text) return 'Passwords do not match.';
    return null;
  }

  void _continue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the terms to continue.')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    final registration = RegistrationFormData(
      fullName: _nameController.text.trim(),
      cmsId: _cmsController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    Navigator.of(context).pushNamed(
      AppRoutes.verifyEmail,
      arguments: OtpScreenArguments(email: registration.email),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AuthHeader(title: 'Register'),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthProgress(step: 3, label: 'STEP 3 OF 5'),
                    const SizedBox(height: 17),
                    const Text(
                      'Create Your Account',
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Join CampConnect and connect with your university community.',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildInstitutionNotice(),
                    const SizedBox(height: 20),
                    AuthTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'e.g. Ali Raza',
                      icon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      validator: (value) => _required(value, 'full name'),
                    ),
                    const SizedBox(height: 15),
                    AuthTextField(
                      controller: _cmsController,
                      label: 'University CMS ID',
                      hint: 'e.g. F24-BSSE-0044',
                      icon: Icons.badge_outlined,
                      textInputAction: TextInputAction.next,
                      validator: (value) => _required(value, 'CMS ID'),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 4, top: 4),
                      child: Text(
                        'Check your campus RFID badge or student portal',
                        style: TextStyle(
                          color: AppColors.mutedText,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    AuthTextField(
                      controller: _emailController,
                      label: 'University Email',
                      hint: 'student@university.edu',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 15),
                    AuthTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Create a strong password (min. 8 characters)',
                      icon: Icons.lock_outline_rounded,
                      obscureText: !_isPasswordVisible,
                      onVisibilityPressed: () {
                        setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        );
                      },
                      onChanged: (_) => setState(() {}),
                      textInputAction: TextInputAction.next,
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 15),
                    AuthTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hint: 'Re-enter password',
                      icon: Icons.lock_reset_outlined,
                      obscureText: !_isConfirmPasswordVisible,
                      onVisibilityPressed: () {
                        setState(
                          () => _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible,
                        );
                      },
                      textInputAction: TextInputAction.done,
                      validator: _validateConfirmation,
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordStrength(),
                    const SizedBox(height: 14),
                    _buildTerms(),
                    const SizedBox(height: 20),
                    AuthPrimaryButton(
                      label: 'Continue to Verification',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: _continue,
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context)
                                .pushNamedAndRemoveUntil(
                                  AppRoutes.login,
                                  (route) => route.isFirst,
                                ),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.deepPrimary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstitutionNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.paleBlue,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: AppColors.deepPrimary,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Institutional Credentials',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Registration requires your active University CMS ID and student email.',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStrength() {
    final length = _passwordController.text.length;
    final strength = length == 0
        ? 0
        : length < 8
        ? 1
        : length < 12
        ? 2
        : 3;
    final label = switch (strength) {
      0 => 'Acceptable',
      1 => 'Weak',
      2 => 'Acceptable',
      _ => 'Strong',
    };
    final color = strength == 1 ? AppColors.error : AppColors.deepPrimary;

    return Container(
      padding: const EdgeInsets.fromLTRB(9, 8, 9, 9),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryText.withValues(alpha: 0.035),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Password Security',
                  style: TextStyle(color: AppColors.mutedText, fontSize: 12),
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: strength == 0 ? AppColors.mutedText : color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: List.generate(
              4,
              (index) => Expanded(
                child: Container(
                  height: 5,
                  margin: EdgeInsets.only(right: index == 3 ? 0 : 5),
                  decoration: BoxDecoration(
                    color: index < strength ? color : AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTerms() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: _acceptedTerms,
            onChanged: (value) =>
                setState(() => _acceptedTerms = value ?? false),
            activeColor: AppColors.deepPrimary,
            side: const BorderSide(color: AppColors.lightBlue, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            visualDensity: VisualDensity.compact,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'I agree to the Terms of Service and Campus Privacy Policy.',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
