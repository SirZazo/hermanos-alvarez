import 'package:flutter/material.dart';

import '../features/home/presentation/pages/home_page.dart';
import '../features/horarios/pages/horarios_page.dart';
import '../features/legal/data/legal_texts.dart';
import '../features/legal/pages/legal_page.dart';
import '../features/servicios_discrecionales/presentation/pages/servicios_discrecionales_page.dart';

class AppRouter {
  static const String home = '/';
  static const String queOfrecemos = '/que-ofrecemos';
  static const String horarios = '/horarios';
  static const String contacto = '/contacto';

  static const String avisoLegal = '/aviso-legal';
  static const String privacidad = '/privacidad';
  static const String cookies = '/cookies';

  static const String serviciosDiscrecionales =
      '/servicios-discrecionales/solicitar-presupuesto';

  // ---------------------------------------------------------------------------
  // TRANSICIÓN COMÚN
  // ---------------------------------------------------------------------------

  static Route<dynamic> _animatedRoute({
    required Widget page,
    required RouteSettings settings,
  }) {
    return PageRouteBuilder<dynamic>(
      settings: settings,

      transitionDuration: const Duration(
        milliseconds: 220,
      ),

      reverseTransitionDuration: const Duration(
        milliseconds: 180,
      ),

      pageBuilder: (
        context,
        animation,
        secondaryAnimation,
      ) {
        return page;
      },

      transitionsBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: child,
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // RUTAS
  // ---------------------------------------------------------------------------

  static Route<dynamic> onGenerateRoute(
    RouteSettings settings,
  ) {
    switch (settings.name) {
      case home:
        return _animatedRoute(
          page: const HomePage(),
          settings: settings,
        );

      case queOfrecemos:
        return _animatedRoute(
          page: const HomePage(),
          settings: settings,
        );

      case horarios:
        return _animatedRoute(
          page: const HorariosPage(),
          settings: settings,
        );

      case contacto:
        return _animatedRoute(
          page: const HomePage(),
          settings: settings,
        );

      case avisoLegal:
        return _animatedRoute(
          page: const LegalPage(
            title: 'Aviso Legal',
            markdown: LegalTexts.avisoLegal,
          ),
          settings: settings,
        );

      case privacidad:
        return _animatedRoute(
          page: const LegalPage(
            title: 'Política de Privacidad',
            markdown: LegalTexts.privacidad,
          ),
          settings: settings,
        );

      case cookies:
        return _animatedRoute(
          page: const LegalPage(
            title: 'Política de Cookies',
            markdown: LegalTexts.cookies,
          ),
          settings: settings,
        );

      case serviciosDiscrecionales:
        return _animatedRoute(
          page: const ServiciosDiscrecionalesPage(),
          settings: settings,
        );

      default:
        return _animatedRoute(
          page: const HomePage(),
          settings: settings,
        );
    }
  }
}