import 'package:flutter/material.dart';

import '../../../../app/router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../widgets/footer.dart';
import '../widgets/home_carousel_section.dart';

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
    final routeName = ModalRoute.of(context)?.settings.name;

    final initialCarouselPage = routeName == AppRouter.queOfrecemos ? 1 : 0;

    return AppShell(
      // Fondo global de toda la Home:
      // navbar + carrusel + footer.
      background: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: AppColors.heritageBackgroundSoft),

          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.80,
                child: Image.asset(
                  'assets/images/home_background.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),
        ],
      ),

      child: SingleChildScrollView(
        child: Column(
          children: [
            // ---------------------------------------------------------------
            // CARRUSEL
            // ---------------------------------------------------------------
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  child: KeyedSubtree(
                    key: _homeKey,
                    child: KeyedSubtree(
                      key: _offersKey,
                      child: HomeCarouselSection(
                        initialPage: initialCarouselPage,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ---------------------------------------------------------------
            // FOOTER
            //
            // Está FUERA del maxWidth del carrusel.
            // Su caja principal controla su ancho internamente,
            // mientras que la barra inferior puede ocupar toda la pantalla.
            // ---------------------------------------------------------------
            KeyedSubtree(key: _contactKey, child: const FooterSection()),
          ],
        ),
      ),
    );
  }
}
