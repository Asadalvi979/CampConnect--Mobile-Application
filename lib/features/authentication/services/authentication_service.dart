import '../models/registration_form_data.dart';

/// Backend contract for authentication. No API implementation is configured.
abstract interface class AuthenticationService {
  Future<void> requestLoginOtp(String email);

  Future<void> register(RegistrationFormData registration);

  Future<void> verifyEmailOtp({required String email, required String code});

  Future<void> resendEmailOtp(String email);

  Future<void> requestPasswordReset(String email);
}
