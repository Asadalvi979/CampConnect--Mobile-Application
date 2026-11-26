import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../navigation/app_routes.dart';
import '../../profile/models/user_profile.dart';
import '../services/auth_services.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _loginError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter the admin email.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String? value) =>
      value == null || value.isEmpty ? 'Enter your password.' : null;

  /// Real admin login: password sign-in via Supabase Auth, then the
  /// `profiles` row is loaded and only role == admin may continue. There is
  /// no demo account and no hardcoded credential anywhere in this screen.
  Future<void> _login() async {
    if (_isLoading || !(_formKey.currentState?.validate() ?? false)) return;
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;
    setState(() {
      _isLoading = true;
      _loginError = null;
    });
    try {
      await AuthServices.current.signInWithPassword(
        email: email,
        password: password,
      );
      final loaded = await UserProfileStore.instance.loadFromSupabase();
      if (!loaded ||
          UserProfileStore.instance.profile.value.role !=
              UserProfileRole.admin) {
        await AuthServices.current.signOut();
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _loginError = 'This account does not have admin access.';
        });
        return;
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loginError = e is AuthException
            ? e.message
            : e is SupabaseNotConfiguredException
            ? e.toString()
            : 'Admin sign in failed. Please try again.';
      });
      return;
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.adminDashboard, (route) => false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const AuthHeader(title: 'Admin Login'),
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
                      'Sign in with your admin account to open admin tools.',
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
                              hint: 'Email address',
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
                              hint: 'Password',
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
                              label: 'Sign In',
                              icon: Icons.arrow_forward_rounded,
                              isLoading: _isLoading,
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
                            'Admin access only.',
                            style: TextStyle(
                              color: AppColors.deepPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Only accounts whose profile role is admin can sign in here. The first admin is promoted with SQL after signing up (see tools/supabase_schema.sql).',
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
