import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/navigation/app_routes.dart';

void main() {
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
