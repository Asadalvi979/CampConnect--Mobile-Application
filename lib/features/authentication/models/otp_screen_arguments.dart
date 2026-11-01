class OtpScreenArguments {
  const OtpScreenArguments({required this.email, this.isLoginOtp = false});

  final String email;
  final bool isLoginOtp;
}
