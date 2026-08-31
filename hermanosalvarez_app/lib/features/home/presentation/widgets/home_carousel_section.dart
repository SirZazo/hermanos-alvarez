import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'about_section.dart';
import 'hero_section.dart';
import 'value_section.dart';

class HomeCarouselSection extends StatefulWidget {
  final int initialPage;

  const HomeCarouselSection({super.key, this.initialPage = 0});

  @override
  State<HomeCarouselSection> createState() => _HomeCarouselSectionState();
}

class _HomeCarouselSectionState extends State<HomeCarouselSection> {
  static const int _pageCount = 3;
  static const Duration _autoPlayDelay = Duration(seconds: 7);
  static const Duration _animationDuration = Duration(milliseconds: 650);

  static const double _outerRadius = 22;

  late final PageController _pageController;

  Timer? _autoPlayTimer;
  late int _currentPage;

  @override
  void initState() {
    super.initState();

    _currentPage = widget.initialPage.clamp(0, _pageCount - 1).toInt();
    _pageController = PageController(initialPage: _currentPage);

    _scheduleNextPage();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _scheduleNextPage() {
    _autoPlayTimer?.cancel();

    _autoPlayTimer = Timer(_autoPlayDelay, () {
      if (!mounted || !_pageController.hasClients) {
        return;
      }

      final nextPage = (_currentPage + 1) % _pageCount;

      _pageController.animateToPage(
        nextPage,
        duration: _animationDuration,
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _goToPage(int page) {
    if (!_pageController.hasClients) {
      return;
    }

    final normalizedPage = (page + _pageCount) % _pageCount;

    _autoPlayTimer?.cancel();

    _pageController.animateToPage(
      normalizedPage,
      duration: _animationDuration,
      curve: Curves.easeInOutCubic,
    );
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });

    _scheduleNextPage();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    final carouselHeight = switch (screenWidth) {
      < 600 => 780.0,
      < 900 => 650.0,
      _ => 500.0,
    };

    return SizedBox(
      width: double.infinity,
      height: carouselHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_outerRadius),
                border: Border.all(
                  color: AppColors.heritageGreenSoft.withValues(alpha: 0.70),
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(16, 58, 34, 0.10),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_outerRadius),
                child: ScrollConfiguration(
                  behavior: const _CarouselScrollBehavior(),
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    physics: const PageScrollPhysics(),
                    children: const [
                      HeroSection(),
                      ValueSection(),
                      AboutSection(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 14,
            top: 0,
            bottom: 0,
            child: Center(
              child: _CarouselArrow(
                icon: Icons.chevron_left_rounded,
                tooltip: 'Anterior',
                onPressed: () => _goToPage(_currentPage - 1),
              ),
            ),
          ),

          Positioned(
            right: 14,
            top: 0,
            bottom: 0,
            child: Center(
              child: _CarouselArrow(
                icon: Icons.chevron_right_rounded,
                tooltip: 'Siguiente',
                onPressed: () => _goToPage(_currentPage + 1),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 18,
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Tooltip(
          message: tooltip,
          child: Material(
            color: const Color(0xFF082F62).withValues(alpha: 0.48),
            shape: CircleBorder(
              side: BorderSide(color: Colors.white.withValues(alpha: 0.28)),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: SizedBox(
                width: 52,
                height: 52,
                child: Center(child: Icon(icon, color: Colors.white, size: 32)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFF082F62).withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(pageCount, (index) {
              final isActive = index == currentPage;

              return GestureDetector(
                onTap: () => onSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.accent
                        : Colors.white.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

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
