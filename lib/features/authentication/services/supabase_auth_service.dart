import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_config.dart';
import '../models/registration_form_data.dart';
import 'authentication_service.dart';

/// Supabase implementation of [AuthenticationService].
///
/// Every method throws [SupabaseNotConfiguredException] when the app has no
/// real Supabase keys yet, so callers can fall back to preview behaviour.
///
/// Login flow (matches the app's screens): the login screen first checks the
/// password with [signInWithPassword], then sends a 6-digit email OTP with
/// [requestLoginOtp]; the OTP screen verifies it with [verifyEmailOtp].
/// Registration uses [register] (signUp, full name + CMS ID stored as user
/// metadata) and the same OTP screen with `isLoginOtp: false`.
class SupabaseAuthenticationService implements AuthenticationService {
  SupabaseClient get _client => Supabase.instance.client;

  void _requireConfigured() {
    if (!SupabaseConfig.isConfigured || !SupabaseConfig.isInitialized) {
      throw const SupabaseNotConfiguredException();
    }
  }

  @override
  String? get currentUserId {
    if (!SupabaseConfig.isConfigured || !SupabaseConfig.isInitialized) {
      return null;
    }
    return _client.auth.currentUser?.id;
  }

  @override
  String? get currentUserEmail {
    if (!SupabaseConfig.isConfigured || !SupabaseConfig.isInitialized) {
      return null;
    }
    return _client.auth.currentUser?.email;
  }

  @override
  Future<void> requestLoginOtp(String email) async {
    _requireConfigured();
    await _client.auth.signInWithOtp(email: email);
  }

  @override
  Future<void> register(RegistrationFormData registration) async {
    _requireConfigured();
    await _client.auth.signUp(
      email: registration.email,
      password: registration.password,
      data: {
        'full_name': registration.fullName,
        'cms_id': registration.cmsId,
      },
    );
  }

  @override
  Future<void> verifyEmailOtp({
    required String email,
    required String code,
    bool isLoginOtp = true,
  }) async {
    _requireConfigured();
    await _client.auth.verifyOTP(
      type: isLoginOtp ? OtpType.email : OtpType.signup,
      email: email,
      token: code,
    );
  }

  @override
  Future<void> resendEmailOtp(String email) async {
    _requireConfigured();
    await _client.auth.signInWithOtp(email: email);
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    _requireConfigured();
    await _client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    _requireConfigured();
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    if (!SupabaseConfig.isConfigured || !SupabaseConfig.isInitialized) {
      return;
    }
    await _client.auth.signOut();
  }
}
