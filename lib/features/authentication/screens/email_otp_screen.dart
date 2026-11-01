import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../navigation/app_routes.dart';
import '../models/otp_screen_arguments.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_primary_button.dart';

class EmailOtpScreen extends StatefulWidget {
  const EmailOtpScreen({required this.arguments, super.key});

  final OtpScreenArguments arguments;

  @override
  State<EmailOtpScreen> createState() => _EmailOtpScreenState();
}

class _EmailOtpScreenState extends State<EmailOtpScreen> {
  final _codeController = TextEditingController();
  final _codeFocusNode = FocusNode();

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  String get _maskedEmail {
    final parts = widget.arguments.email.split('@');
    if (parts.length != 2 || parts.first.isEmpty) {
      return widget.arguments.email;
    }
    final local = parts.first;
    final visibleStart = local.length > 1 ? local[0] : '';
    final visibleEnd = local.length > 2 ? local[local.length - 1] : '';
    return '$visibleStart***$visibleEnd@${parts[1]}';
  }

  void _verifyEmail() {
    FocusScope.of(context).unfocus();
    if (_codeController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 6-digit verification code.')),
      );
      return;
    }
    if (widget.arguments.isLoginOtp) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preview only: this OTP was not checked. Opening the student dashboard.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.studentDashboard, (route) => false);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Preview only: this code has not been verified. Backend integration is required.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  void _resendCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Preview only: no email was sent. OTP delivery needs backend integration.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AuthHeader(title: 'Verify Otp'),
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
                      _buildProgress(),
                      const SizedBox(height: 24),
                      _buildOtpCard(),
                      const SizedBox(height: 20),
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back, size: 17),
                        label: const Text('Back to Registration'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.secondaryText,
                        ),
                      ),
                      TextButton(
                        onPressed: () => ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Contact your campus IT support for assistance.',
                              ),
                            ),
                          ),
                        child: const Text.rich(
                          TextSpan(
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(text: 'Having trouble? '),
                              TextSpan(
                                text: 'Contact Campus IT',
                                style: TextStyle(color: AppColors.deepPrimary),
                              ),
                            ],
                          ),
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

  Widget _buildProgress() {
    return Wrap(
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 8,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.lightBlue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Verification Step',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Step 4 of 5',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 9),
            Container(
              width: 46,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOtpCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryText.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: AppColors.lightBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.paleBlue, width: 8),
                ),
                child: const Icon(
                  Icons.mark_email_read_outlined,
                  size: 34,
                  color: AppColors.primary,
                ),
              ),
              Positioned(
                bottom: -3,
                right: -3,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    color: AppColors.white,
                    size: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          const Text(
            'Verify Your Email',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 21,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "We've sent a 6-digit verification code to",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
          ),
          const SizedBox(height: 9),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.paleBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.school_outlined,
                  size: 15,
                  color: AppColors.deepPrimary,
                ),
                const SizedBox(width: 5),
                Text(
                  _maskedEmail,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.deepPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.edit_outlined,
                  size: 14,
                  color: AppColors.mutedText,
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          _buildCodeInput(),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Icon(
                Icons.content_paste_rounded,
                size: 14,
                color: AppColors.success,
              ),
              const SizedBox(width: 5),
              const Text(
                'Preview code:',
                style: TextStyle(color: AppColors.mutedText, fontSize: 11),
              ),
              const SizedBox(width: 5),
              InkWell(
                onTap: () {
                  _codeController.text = '492718';
                  setState(() {});
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.paleBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '492718',
                    style: TextStyle(
                      color: AppColors.deepPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                "Didn't receive code? ",
                style: TextStyle(color: AppColors.mutedText, fontSize: 12),
              ),
              TextButton(
                onPressed: _resendCode,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.deepPrimary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Resend Code',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          _buildInstitutionNote(),
          const SizedBox(height: 20),
          AuthPrimaryButton(
            label: 'Verify Email',
            icon: Icons.arrow_forward_rounded,
            onPressed: _verifyEmail,
          ),
        ],
      ),
    );
  }

  Widget _buildCodeInput() {
    return Semantics(
      label: 'Six digit verification code',
      child: GestureDetector(
        onTap: _codeFocusNode.requestFocus,
        child: SizedBox(
          height: 56,
          child: Stack(
            children: [
              Row(
                children: List.generate(6, (index) {
                  final code = _codeController.text;
                  final hasDigit = index < code.length;
                  final active =
                      _codeFocusNode.hasFocus && index == code.length;
                  return Expanded(
                    child: Container(
                      height: 54,
                      margin: EdgeInsets.only(right: index == 5 ? 0 : 7),
                      decoration: BoxDecoration(
                        color: hasDigit ? AppColors.white : AppColors.paleBlue,
                        border: Border.all(
                          color: active
                              ? AppColors.primary
                              : AppColors.paleBlue,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        hasDigit ? code[index] : '•',
                        style: TextStyle(
                          color: hasDigit
                              ? AppColors.primaryText
                              : AppColors.border,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              Positioned.fill(
                child: Opacity(
                  opacity: 0.01,
                  child: TextField(
                    controller: _codeController,
                    focusNode: _codeFocusNode,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    maxLength: 6,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    style: const TextStyle(color: Colors.transparent),
                    cursorColor: Colors.transparent,
                    decoration: const InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      filled: false,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstitutionNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.paleBlue,
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: AppColors.success, size: 20),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Institutional Single Sign-On\nAfter verification, your university directory and academic courses can be linked.',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
