import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_env_io.dart'
    if (dart.library.html) 'supabase_env_web.dart';

/// Supabase configuration and bootstrap for CampConnect.
///
/// Works in two modes:
/// * Configured — real project URL + anon key are present (in `.env` on
///   native, or in the fallbacks below on web). Supabase is initialized and
///   the auth screens talk to the real backend.
/// * Preview — placeholders are still in place (no real keys yet). Supabase
///   is NOT initialized, the auth service throws [SupabaseNotConfiguredException],
///   and the screens fall back to the existing preview behaviour so the app
///   and its widget tests keep working without keys.
abstract final class SupabaseConfig {
  // Hardcoded fallbacks (same values as `.env` — used when `.env` is missing
  // or the platform can't read it, e.g. web).
  // TODO: replace BOTH placeholders with the real first-mad project values.
  static const String urlFallback = 'https://krxyclswprgumpxqvhfk.supabase.co';
  static const String anonKeyFallback = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtyeHljbHN3cHJndW1weHF2aGZrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTU2NDk1MzIsImV4cCI6MjExMTIyNTUzMn0.Fg_P_spzVr_uWuwWEjuXQpgXjfOHk6MRSTV6NZ8Q5AY';

  static bool _initialized = false;

  /// True once [initialize] has successfully initialized Supabase.
  static bool get isInitialized => _initialized;

  static String get url =>
      readSupabaseEnv()['SUPABASE_URL'] ?? urlFallback;

  static String get anonKey =>
      readSupabaseEnv()['SUPABASE_ANON_KEY'] ?? anonKeyFallback;

  /// True when real (non-placeholder) credentials are present.
  static bool get isConfigured =>
      !url.contains('YOUR_PROJECT_REF') &&
      !anonKey.contains('YOUR_ANON_KEY') &&
      url.startsWith('https://') &&
      anonKey.isNotEmpty;

  /// True when Supabase is actually live: real keys present AND
  /// [initialize] has run successfully. Screens and route guards use this,
  /// not [isConfigured]: keys alone (e.g. a real `.env` during widget tests,
  /// where main() never runs) must keep the app in preview mode.
  static bool get isLive => isConfigured && isInitialized;

  /// Initialize Supabase once, before `runApp`. Never throws: when the app
  /// is not configured (or init fails) it stays in preview mode.
  static Future<void> initialize() async {
    if (!isConfigured) {
      debugPrint(
        'Supabase not configured (placeholders in .env/fallbacks) — '
        'running in preview mode with mock data.',
      );
      return;
    }
    try {
      await Supabase.initialize(url: url, publishableKey: anonKey);
      _initialized = true;
    } catch (e) {
      debugPrint('Supabase init failed — running in preview mode: $e');
      _initialized = false;
    }
  }

  /// True when a real Supabase session exists.
  static bool get hasSession {
    if (!_initialized) return false;
    return Supabase.instance.client.auth.currentSession != null;
  }

  /// The signed-in user, or null in preview mode / when signed out.
  static User? get currentUser {
    if (!_initialized) return null;
    return Supabase.instance.client.auth.currentUser;
  }
}

/// Thrown by the auth service when Supabase has no real keys yet.
class SupabaseNotConfiguredException implements Exception {
  const SupabaseNotConfiguredException();

  @override
  String toString() =>
      'Supabase is not configured yet. Add your project URL and anon key '
      'to .env (and the fallbacks in supabase_config.dart for web).';
}
