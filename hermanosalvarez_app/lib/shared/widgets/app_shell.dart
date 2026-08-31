import 'package:flutter/material.dart';

import '../../features/cookies/presentation/widgets/cookie_banner.dart';
import 'navbar.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final Widget? background;

  const AppShell({super.key, required this.child, this.background});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      endDrawer: const AppNavbarDrawer(),
      body: Stack(
        children: [
          // Fondo opcional que ocupa TODA la pantalla,
          // incluido el espacio situado detrás del navbar.
          if (background != null) Positioned.fill(child: background!),

          Column(
            children: [
              const AppNavbar(),
              Expanded(child: child),
            ],
          ),

          const Align(alignment: Alignment.bottomCenter, child: CookieBanner()),
        ],
      ),
    );
  }
}
