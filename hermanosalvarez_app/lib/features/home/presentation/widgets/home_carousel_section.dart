import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'about_section.dart';
import 'hero_section.dart';
import 'location_section.dart';

class HomeCarouselSection extends StatefulWidget {
  final int initialPage;

  const HomeCarouselSection({super.key, this.initialPage = 0});

  @override
  State<HomeCarouselSection> createState() => _HomeCarouselSectionState();
}

class _HomeCarouselSectionState extends State<HomeCarouselSection> {
  // ---------------------------------------------------------------------------
  // CONFIGURACIÓN
  // ---------------------------------------------------------------------------

  static const int _pageCount = 3;

  static const Duration _autoPlayDelay = Duration(seconds: 10);

  static const Duration _animationDuration = Duration(milliseconds: 650);

  static const double _outerRadius = 22;

  // Espacio exclusivo para los indicadores.
  // Así nunca se colocan encima del contenido.
  static const double _indicatorAreaHeight = 42;

  // ---------------------------------------------------------------------------
  // ESTADO
  // ---------------------------------------------------------------------------

  late final PageController _pageController;

  Timer? _autoPlayTimer;

  late int _currentPage;

  // ---------------------------------------------------------------------------
  // CICLO DE VIDA
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _currentPage = widget.initialPage.clamp(0, _pageCount - 1);

    _pageController = PageController(initialPage: _currentPage);

    _scheduleNextPage();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // AUTOPLAY
  // ---------------------------------------------------------------------------

  void _scheduleNextPage() {
    // Cancelamos cualquier temporizador anterior.
    _autoPlayTimer?.cancel();

    _autoPlayTimer = Timer(_autoPlayDelay, () {
      if (!mounted || !_pageController.hasClients) {
        return;
      }

      // Ciclo infinito:
      //
      // 0 -> 1
      // 1 -> 2
      // 2 -> 0
      //
      final nextPage = (_currentPage + 1) % _pageCount;

      _pageController.animateToPage(
        nextPage,
        duration: _animationDuration,
        curve: Curves.easeInOutCubic,
      );
    });
  }

  // ---------------------------------------------------------------------------
  // NAVEGACIÓN MANUAL
  // ---------------------------------------------------------------------------

  void _goToPage(int page) {
    if (!_pageController.hasClients) {
      return;
    }

    final normalizedPage = (page + _pageCount) % _pageCount;

    // Reiniciamos los 10 segundos después de cualquier
    // interacción manual.
    _autoPlayTimer?.cancel();

    // Si el usuario pulsa la página en la que ya está,
    // simplemente reiniciamos el temporizador.
    if (normalizedPage == _currentPage) {
      _scheduleNextPage();
      return;
    }

    _pageController.animateToPage(
      normalizedPage,
      duration: _animationDuration,
      curve: Curves.easeInOutCubic,
    );
  }

  // ---------------------------------------------------------------------------
  // CAMBIO DE PÁGINA
  // ---------------------------------------------------------------------------

  void _onPageChanged(int page) {
    if (!mounted) {
      return;
    }

    setState(() {
      _currentPage = page;
    });

    // Cada vez que llegamos a una nueva página,
    // empiezan de nuevo los 10 segundos.
    _scheduleNextPage();
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    // Altura de las slides + zona inferior de indicadores.
    final carouselHeight = switch (screenWidth) {
      < 600 => 822.0,
      < 900 => 692.0,
      _ => 542.0,
    };

    return SizedBox(
      width: double.infinity,
      height: carouselHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // -------------------------------------------------------------------
          // CONTENIDO DEL CARRUSEL
          // -------------------------------------------------------------------

          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: _indicatorAreaHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_outerRadius),
              child: ScrollConfiguration(
                behavior: const _CarouselScrollBehavior(),
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  physics: const PageScrollPhysics(),
                  children: const [
                    // 1 - Inicio
                    HeroSection(),

                    // 2 - Quiénes somos
                    AboutSection(),

                    // 3 - Ubicación
                    LocationSection(),
                  ],
                ),
              ),
            ),
          ),

          // -------------------------------------------------------------------
          // FLECHA IZQUIERDA
          // -------------------------------------------------------------------
          Positioned(
            left: 14,
            top: 0,
            bottom: _indicatorAreaHeight,
            child: Center(
              child: _CarouselArrow(
                icon: Icons.chevron_left_rounded,
                tooltip: 'Anterior',
                onPressed: () {
                  _goToPage(_currentPage - 1);
                },
              ),
            ),
          ),

          // -------------------------------------------------------------------
          // FLECHA DERECHA
          // -------------------------------------------------------------------
          Positioned(
            right: 14,
            top: 0,
            bottom: _indicatorAreaHeight,
            child: Center(
              child: _CarouselArrow(
                icon: Icons.chevron_right_rounded,
                tooltip: 'Siguiente',
                onPressed: () {
                  _goToPage(_currentPage + 1);
                },
              ),
            ),
          ),

          // -------------------------------------------------------------------
          // INDICADORES
          // -------------------------------------------------------------------
          Positioned(
            left: 0,
            right: 0,
            bottom: 2,
            height: 38,
            child: Center(
              child: _CarouselIndicators(
                currentPage: _currentPage,
                pageCount: _pageCount,
                onSelected: _goToPage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// FLECHAS
// =============================================================================

class _CarouselArrow extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _CarouselArrow({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 52,
            height: 52,
            child: Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: 36,
                shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// INDICADORES
// =============================================================================

class _CarouselIndicators extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final ValueChanged<int> onSelected;

  const _CarouselIndicators({
    required this.currentPage,
    required this.pageCount,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.heritageGreenDark.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(16, 58, 34, 0.12),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(pageCount, (index) {
          final isActive = index == currentPage;

          return GestureDetector(
            onTap: () {
              onSelected(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 22 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.heritageAccent
                    : Colors.white.withValues(alpha: 0.68),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// =============================================================================
// COMPORTAMIENTO DEL SCROLL
// =============================================================================

class _CarouselScrollBehavior extends MaterialScrollBehavior {
  const _CarouselScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}
