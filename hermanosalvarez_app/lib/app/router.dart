import 'package:flutter/material.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/horarios/pages/horarios_page.dart';

class AppRouter {
  static const String home = '/';
  static const String horarios = '/horarios';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );

      case horarios:
        return MaterialPageRoute(
          builder: (_) => const HorariosPage(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );
    }
  }
}