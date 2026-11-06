import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../navigation/app_routes.dart';
import '../models/otp_screen_arguments.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Please enter your university email.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password.';
    return null;
  }

  Future<void> _signIn() async {
    if (_isLoading || !(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pushNamed(
      AppRoutes.verifyEmail,
      arguments: OtpScreenArguments(
        email: _emailController.text.trim(),
        isLoginOtp: true,
      ),
    );
  }

  void _showPreviewMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AuthHeader(title: 'Sign In'),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 36,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildWelcome(),
                      const SizedBox(height: 22),
                      _buildLoginCard(),
                      const SizedBox(height: 22),
                      _buildRegistrationLink(),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: () =>
                            Navigator.of(context)
                                .pushNamed(AppRoutes.adminLogin),
                        icon: const Icon(
                          Icons.admin_panel_settings_outlined,
                          size: 17,
                        ),
                        label: const Text('Admin Login'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.deepPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcome() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 66,
              height: 66,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.paleBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Image.asset(universityLogoAsset, fit: BoxFit.contain),
            ),
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.lightBlue,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 14,
                color: AppColors.deepPrimary,
              ),
              SizedBox(width: 5),
              Flexible(
                child: Text(
                  'Step 2 of 5 • Authentication',
                  maxLines: 1,
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Welcome Back!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 27,
            height: 1.25,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Sign in to continue your university journey.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryText.withValues(alpha: 0.035),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthTextField(
              controller: _emailController,
              label: 'University Email',
              trailingLabel: '.edu verified',
              hint: 'e.g. CMS@student.riphahsahiwal.edu.pk',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: _validateEmail,
            ),
            const SizedBox(height: 17),
            AuthTextField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Enter your password',
              icon: Icons.lock_outline_rounded,
              textInputAction: TextInputAction.done,
              obscureText: !_isPasswordVisible,
              onVisibilityPressed: () {
                setState(() => _isPasswordVisible = !_isPasswordVisible);
              },
              validator: _validatePassword,
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _rememberMe = !_rememberMe),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        children: [
                          _RememberCheckbox(value: _rememberMe),
                          const SizedBox(width: 7),
                          const Flexible(
                            child: Text(
                              'Remember me',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.secondaryText,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.forgotPassword),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.deepPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AuthPrimaryButton(
              label: 'Sign In',
              icon: Icons.arrow_forward_rounded,
              isLoading: _isLoading,
              onPressed: _signIn,
            ),
            const SizedBox(height: 18),
            _buildSsoDivider(),
            const SizedBox(height: 14),
            _buildSsoButton(),
            const SizedBox(height: 15),
            _buildSecurityNote(),
          ],
        ),
      ),
    );
  }

  Widget _buildSsoDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.lightBlue, height: 1)),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Or sign in with University Portal',
                maxLines: 1,
                style: TextStyle(
                  color: AppColors.mutedText.withValues(alpha: 0.9),
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.lightBlue, height: 1)),
      ],
    );
  }

  Widget _buildSsoButton() {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: () => _showPreviewMessage('Campus SSO is not connected.'),
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.paleBlue,
          foregroundColor: AppColors.primaryText,
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.account_balance_outlined,
                size: 18,
                color: AppColors.deepPrimary,
              ),
            ),
            const SizedBox(width: 9),
            const Expanded(
              child: Text(
                'Campus SSO Gateway',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.mutedText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityNote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.paleBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline_rounded, size: 15, color: AppColors.success),
          SizedBox(width: 5),
          Flexible(
            child: Text(
              'Campus SSO is not connected.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mutedText, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationLink() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.register),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.deepPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Create Account',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _RememberCheckbox extends StatelessWidget {
  const _RememberCheckbox({required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: value ? AppColors.deepPrimary : AppColors.white,
        border: Border.all(
          color: value ? AppColors.deepPrimary : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: value
          ? const Icon(Icons.check_rounded, size: 15, color: AppColors.white)
          : null,
    );
  }
}
