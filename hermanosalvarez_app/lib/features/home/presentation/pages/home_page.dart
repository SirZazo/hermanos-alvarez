import 'package:flutter/material.dart';

import '../../../../app/router.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../widgets/hero_section.dart';
import '../widgets/about_section.dart';
import '../widgets/footer.dart';
import '../widgets/value_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _offersKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  bool _initialScrollDone = false;

@override
void didChangeDependencies() {
  super.didChangeDependencies();

  if (_initialScrollDone) {
    return;
  }

  _initialScrollDone = true;

  final route = ModalRoute.of(context);
  final routeName = route?.settings.name;
  final arguments = route?.settings.arguments;

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    // Si venimos de otra sección de la Home y pulsamos Inicio,
    // colocamos primero el scroll en esa sección y después subimos animando.
    if (routeName == AppRouter.home && arguments is String) {
      GlobalKey? sourceKey;

      if (arguments == AppRouter.queOfrecemos) {
        sourceKey = _offersKey;
      } else if (arguments == AppRouter.contacto) {
        sourceKey = _contactKey;
      }

      final sourceContext = sourceKey?.currentContext;

      if (sourceContext != null) {
        await Scrollable.ensureVisible(
          sourceContext,
          duration: Duration.zero,
        );

        await Future.delayed(const Duration(milliseconds: 50));
      }

      final homeContext = _homeKey.currentContext;

      if (homeContext != null) {
        await Scrollable.ensureVisible(
          homeContext,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          alignment: 0,
        );
      }

      return;
    }

    GlobalKey? targetKey;

    if (routeName == AppRouter.queOfrecemos) {
      targetKey = _offersKey;
    } else if (routeName == AppRouter.contacto) {
      targetKey = _contactKey;
    }

    final targetContext = targetKey?.currentContext;

    if (targetContext != null) {
      await Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        alignment: 0.05,
      );
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KeyedSubtree(
                    key: _homeKey,
                    child: HeroSection(),
                  ),

                  KeyedSubtree(
                    key: _offersKey,
                    child: ValueSection(),
                  ),

                  AboutSection(),

                  KeyedSubtree(
                    key: _contactKey,
                    child: FooterSection(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}