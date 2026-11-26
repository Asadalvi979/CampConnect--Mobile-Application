import 'authentication_service.dart';
import 'supabase_auth_service.dart';

/// Injectable holder for the [AuthenticationService] implementation.
///
/// Production code reads [AuthServices.current] (Supabase by default).
/// Widget tests swap in a fake with `AuthServices.current = fake;` and
/// restore it with [reset] in tearDown, so no test ever touches Supabase.
abstract final class AuthServices {
  /// The active implementation (Supabase by default). Tests swap in a fake
  /// with `AuthServices.current = fake;` and restore it with [reset].
  static AuthenticationService current = SupabaseAuthenticationService();

  static void reset() {
    current = SupabaseAuthenticationService();
  }
}
