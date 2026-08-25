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
  static const String serviciosDiscrecionales = '/servicios-discrecionales';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );

      case queOfrecemos:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );

      case horarios:
        return MaterialPageRoute(
          builder: (_) => const HorariosPage(),
          settings: settings,
        );

      case contacto:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );

      case avisoLegal:
        return MaterialPageRoute(
          builder: (_) => const LegalPage(
            title: 'Aviso Legal',
            markdown: LegalTexts.avisoLegal,
          ),
          settings: settings,
        );

      case privacidad:
        return MaterialPageRoute(
          builder: (_) => const LegalPage(
            title: 'Política de Privacidad',
            markdown: LegalTexts.privacidad,
          ),
          settings: settings,
        );

      case cookies:
        return MaterialPageRoute(
          builder: (_) => const LegalPage(
            title: 'Política de Cookies',
            markdown: LegalTexts.cookies,
          ),
          settings: settings,
        );

        case serviciosDiscrecionales:
          return MaterialPageRoute(
            builder: (_) => const ServiciosDiscrecionalesPage(),
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