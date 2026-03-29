import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../widgets/hero_section.dart';
import '../widgets/commitment_section.dart';
import '../widgets/about_section.dart';
//import '../widgets/location_section.dart';
import '../widgets/footer.dart';
import '../widgets/value_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeroSection(),
                  ValueSection(),
                  AboutSection(),
                  //LocationSection(),
                  FooterSection(),
                  
                  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}