import '../models/registration_form_data.dart';

/// Backend contract for authentication. Implemented by
/// [SupabaseAuthenticationService]; swap via [AuthServices] in tests.
abstract interface class AuthenticationService {
  /// Id of the signed-in user, or null when signed out / not configured.
  String? get currentUserId;

  /// Email of the signed-in user, or null when signed out / not configured.
  String? get currentUserEmail;

  Future<void> requestLoginOtp(String email);

  Future<void> register(RegistrationFormData registration);

  Future<void> verifyEmailOtp({
    required String email,
    required String code,
    bool isLoginOtp = true,
  });

  Future<void> resendEmailOtp(String email);

  Future<void> requestPasswordReset(String email);

  /// Password sign-in. Used by the login screen (before the OTP step) and
  /// by the admin login screen (followed by a profiles.role == admin check).
  Future<void> signInWithPassword({
    required String email,
    required String password,
  });

  /// Signs out the current session. No-op when Supabase is not configured.
  Future<void> signOut();
}
