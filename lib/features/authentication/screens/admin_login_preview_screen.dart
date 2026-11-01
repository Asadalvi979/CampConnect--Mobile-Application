import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../navigation/app_routes.dart';
import '../../profile/models/user_profile.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';

class AdminLoginPreviewScreen extends StatefulWidget {
  const AdminLoginPreviewScreen({super.key});

  @override
  State<AdminLoginPreviewScreen> createState() =>
      _AdminLoginPreviewScreenState();
}

class _AdminLoginPreviewScreenState extends State<AdminLoginPreviewScreen> {
  static const _previewEmail = 'admin@campconnect.com';
  static const _previewPassword = 'Admin123';

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String? _loginError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter the Admin preview email.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String? value) =>
      value == null || value.isEmpty ? 'Enter the preview password.' : null;

  void _login() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final email = _emailController.text.trim().toLowerCase();
    if (email != _previewEmail ||
        _passwordController.text != _previewPassword) {
      setState(
        () => _loginError = 'Incorrect Admin preview email or password.',
      );
      return;
    }

    UserProfileStore.instance.setRole(UserProfileRole.admin);
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.adminDashboard, (route) => false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const AuthHeader(title: 'Admin Preview Login'),
    body: SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(19),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_outlined,
                        size: 34,
                        color: AppColors.deepPrimary,
                      ),
                    ),
                    const SizedBox(height: 17),
                    const Text(
                      'Admin Login',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Sign in to preview the CampConnect Admin Panel.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryText.withValues(alpha: .04),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
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
                              label: 'Admin Email',
                              hint: 'Enter Admin preview email',
                              icon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: _validateEmail,
                              onChanged: (_) {
                                if (_loginError != null) {
                                  setState(() => _loginError = null);
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            AuthTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Enter preview password',
                              icon: Icons.lock_outline_rounded,
                              textInputAction: TextInputAction.done,
                              obscureText: !_isPasswordVisible,
                              onVisibilityPressed: () => setState(
                                () => _isPasswordVisible = !_isPasswordVisible,
                              ),
                              validator: _validatePassword,
                              onChanged: (_) {
                                if (_loginError != null) {
                                  setState(() => _loginError = null);
                                }
                              },
                            ),
                            if (_loginError != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                _loginError!,
                                key: const Key('admin-login-error'),
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            const SizedBox(height: 18),
                            AuthPrimaryButton(
                              label: 'Login to Admin Preview',
                              icon: Icons.arrow_forward_rounded,
                              onPressed: _login,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.paleBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Frontend preview only — not real authentication.',
                            style: TextStyle(
                              color: AppColors.deepPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 5),
                          SelectableText(
                            'Preview email: admin@campconnect.com\nPreview password: Admin123',
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 11,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false),
                      child: const Text('Back to Student Login'),
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
