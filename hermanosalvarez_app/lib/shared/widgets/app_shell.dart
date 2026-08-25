import 'package:flutter/material.dart';

import '../../features/cookies/presentation/widgets/cookie_banner.dart';
import 'navbar.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const AppNavbarDrawer(),
      body: Stack(
        children: [
          Column(
            children: [
              const AppNavbar(),
              Expanded(
                child: child,
              ),
            ],
          ),

          const Align(
            alignment: Alignment.bottomCenter,
            child: CookieBanner(),
          ),
        ],
      ),
    );
  }
}