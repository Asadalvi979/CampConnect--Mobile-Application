import 'package:flutter/material.dart';

import 'core/supabase/supabase_config.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/navigation/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Init Supabase before runApp. When no real keys are configured yet this
  // is a no-op and the app runs in preview mode with mock data.
  await SupabaseConfig.initialize();
  runApp(const CampConnectApp());
}

class CampConnectApp extends StatelessWidget {
  const CampConnectApp({this.initialRoute = AppRoutes.splash, super.key});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: initialRoute,
      onGenerateInitialRoutes: (routeName) => [
        AppRoutes.onGenerateRoute(RouteSettings(name: routeName)),
      ],
      onGenerateRoute: AppRoutes.onGenerateRoute,
      color: AppColors.deepPrimary,
    );
  }
}
