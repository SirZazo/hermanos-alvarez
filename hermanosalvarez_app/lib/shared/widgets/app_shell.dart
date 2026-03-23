import 'package:flutter/material.dart';
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
      body: Column(
        children: [
          const AppNavbar(),
          Expanded(child: child),
        ],
      ),
    );
  }
}