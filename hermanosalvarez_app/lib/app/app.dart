import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';

class HermanosAlvarezApp extends StatelessWidget {
  const HermanosAlvarezApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Autocares Hermanos Álvarez',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.home,
    );
  }
}