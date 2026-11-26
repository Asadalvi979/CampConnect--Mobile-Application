import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../navigation/app_routes.dart';
import '../models/otp_screen_arguments.dart';
import '../services/auth_services.dart';
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
    final email = _emailController.text.trim();
    if (SupabaseConfig.isConfigured) {
      // Real login: password is checked first, then a 6-digit email OTP is
      // sent and verified on the OTP screen.
      try {
        await AuthServices.current.signInWithPassword(
          email: email,
          password: _passwordController.text,
        );
        await AuthServices.current.requestLoginOtp(email);
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _showPreviewMessage(_errorMessage(e));
        return;
      }
    } else {
      // Preview mode: no backend yet, keep the old 300 ms fake delay.
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pushNamed(
      AppRoutes.verifyEmail,
      arguments: OtpScreenArguments(email: email, isLoginOtp: true),
    );
  }

  String _errorMessage(Object e) {
    if (e is AuthException) return e.message;
    if (e is SupabaseNotConfiguredException) return e.toString();
    return 'Sign in failed. Please try again.';
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
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.xxl,
            ),
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
                      const SizedBox(height: AppSpacing.xxl),
                      _buildLoginCard(),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildRegistrationLink(),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton.icon(
                        onPressed: () =>
                            Navigator.of(context)
                                .pushNamed(AppRoutes.adminLogin),
                        icon: const Icon(
                          Icons.admin_panel_settings_outlined,
                          size: 17,
                        ),
                        label: const Text('Admin Login'),
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
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Container(
          width: 66,
          height: 66,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(color: AppColors.border),
          ),
          child: Image.asset(universityLogoAsset, fit: BoxFit.contain),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.verified_user_outlined,
              size: 14,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                'Step 2 of 5 • Authentication',
                maxLines: 1,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Welcome Back!',
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Sign in to continue your university journey.',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: AppColors.border),
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
            const SizedBox(height: AppSpacing.xl),
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
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _rememberMe = !_rememberMe),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          _RememberCheckbox(value: _rememberMe),
                          const SizedBox(width: AppSpacing.sm),
                          Flexible(
                            child: Text(
                              'Remember me',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w400,
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
                    minimumSize: const Size(0, AppTargets.min),
                  ),
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AuthPrimaryButton(
              label: 'Sign In',
              icon: Icons.arrow_forward_rounded,
              isLoading: _isLoading,
              onPressed: _signIn,
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildSsoDivider(),
            const SizedBox(height: AppSpacing.md),
            _buildSsoButton(),
            const SizedBox(height: AppSpacing.xl),
            _buildSecurityNote(),
          ],
        ),
      ),
    );
  }

  Widget _buildSsoDivider() {
    return Center(
      child: Text(
        'Or sign in with University Portal',
        maxLines: 1,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildSsoButton() {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: () => _showPreviewMessage('Campus SSO is not connected.'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.account_balance_outlined,
              size: 20,
              color: AppColors.primaryDark,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Campus SSO Gateway',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontSize: 13),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityNote() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.lock_outline_rounded,
          size: 15,
          color: AppColors.textMuted,
        ),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            'Campus SSO is not connected.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationLink() {
    final textTheme = Theme.of(context).textTheme;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.register),
          style: TextButton.styleFrom(
            minimumSize: const Size(0, AppTargets.min),
          ),
          child: Text(
            'Create Account',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
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
      duration: AppMotion.press,
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: value ? AppColors.primaryDark : AppColors.white,
        border: Border.all(
          color: value ? AppColors.primaryDark : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: value
          ? const Icon(Icons.check_rounded, size: 15, color: AppColors.white)
          : null,
    );
  }
}
