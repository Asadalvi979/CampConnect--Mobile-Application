import 'dart:io';

/// Parses the project-root `.env` file into a Map (no new deps).
/// Native platforms only — the web build uses `supabase_env_web.dart`.
Map<String, String> readSupabaseEnv() {
  final result = <String, String>{};
  final candidates = [File('.env'), File('lib/.env')];
  for (final file in candidates) {
    if (!file.existsSync()) continue;
    for (final line in file.readAsLinesSync()) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final eq = trimmed.indexOf('=');
      if (eq < 0) continue;
      result.putIfAbsent(
        trimmed.substring(0, eq).trim(),
        () => trimmed.substring(eq + 1).trim(),
      );
    }
  }
  return result;
}
