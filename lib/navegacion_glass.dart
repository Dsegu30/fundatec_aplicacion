import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';

class NavegacionGlass extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool wide;
  final bool compact;
  final bool showAvisosBadge;

  const NavegacionGlass({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    this.wide = false,
    this.compact = false,
    this.showAvisosBadge = false,
  });

  static const _items = [
    (Icons.home_rounded, Icons.home_outlined, 'Inicio'),
    (Icons.calendar_month_rounded, Icons.calendar_month_outlined, 'Calendario'),
    (Icons.notifications_rounded, Icons.notifications_none_rounded, 'Avisos'),
    (Icons.person_rounded, Icons.person_outline_rounded, 'Perfil'),
  ];

  static const _indicatorHeroTag = ValueKey<String>(
    'navegacion-glass-jelly-indicator',
  );

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.sizeOf(context);
    final isWide = wide || screenSize.width >= 720;
    final isCompact =
        compact ||
        (screenSize.width > screenSize.height && screenSize.width < 720);
    final activeIndex = selectedIndex >= 0 && selectedIndex < _items.length
        ? selectedIndex
        : -1;

    return SafeArea(
      top: false,
      minimum: EdgeInsets.fromLTRB(
        isWide ? 24 : 14,
        0,
        isWide ? 24 : 14,
        isCompact ? 8 : 12,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWide ? 720 : 432),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 26, sigmaY: 26),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 5 : 7,
                  vertical: isCompact ? 5 : 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      (dark ? const Color(0xFF526B7F) : Colors.white)
                          .withValues(alpha: dark ? 0.58 : 0.62),
                      (dark ? const Color(0xFF172534) : Colors.white)
                          .withValues(alpha: dark ? 0.48 : 0.34),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: (dark ? const Color(0xFFC5E4F5) : Colors.white)
                        .withValues(alpha: dark ? 0.56 : 0.82),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10243B)
                          .withValues(alpha: dark ? 0.3 : 0.13),
                      blurRadius: 30,
                      spreadRadius: 1,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: dark ? 0.2 : 0.9),
                      blurRadius: 4,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = constraints.maxWidth / _items.length;

                    return Stack(
                      fit: StackFit.passthrough,
                      children: [
                        if (activeIndex >= 0)
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: activeIndex.toDouble(),
                              end: activeIndex.toDouble(),
                            ),
                            duration: const Duration(milliseconds: 560),
                            curve: Curves.easeInOutCubic,
                            builder: (context, animatedIndex, _) {
                              final travel = activeIndex - animatedIndex;
                              final stretch = (travel.abs() / 0.9).clamp(
                                0.0,
                                1.0,
                              );
                              final indicatorWidth = itemWidth - 6;
                              final stretchedWidth =
                                  indicatorWidth * (1 + stretch * 0.38);
                              final travelDirection = travel < 0 ? -1.0 : 1.0;

                              return Positioned(
                                left:
                                    animatedIndex * itemWidth +
                                    3 -
                                    (stretchedWidth - indicatorWidth) / 2,
                                top: 0,
                                bottom: 0,
                                width: stretchedWidth,
                                child: Hero(
                                  tag: _indicatorHeroTag,
                                  key: ValueKey<int>(activeIndex),
                                  createRectTween: (begin, end) =>
                                      RectTween(begin: begin, end: end),
                                  flightShuttleBuilder:
                                      (
                                        flightContext,
                                        animation,
                                        direction,
                                        fromHeroContext,
                                        toHeroContext,
                                      ) {
                                        final fromKey =
                                            (fromHeroContext.widget as Hero)
                                                .key;
                                        final toKey =
                                            (toHeroContext.widget as Hero).key;
                                        final fromIndex =
                                            fromKey is ValueKey<int>
                                            ? fromKey.value
                                            : activeIndex;
                                        final toIndex = toKey is ValueKey<int>
                                            ? toKey.value
                                            : activeIndex;
                                        final fromObject = fromHeroContext
                                            .findRenderObject();
                                        final itemWidth =
                                            fromObject is RenderBox &&
                                                fromObject.hasSize
                                            ? fromObject.size.width + 6
                                            : 0.0;
                                        final horizontalTravel =
                                            ((toIndex - fromIndex) * itemWidth)
                                                .toDouble();
                                        final flightDark =
                                            Theme.of(flightContext)
                                                .brightness ==
                                            Brightness.dark;

                                        return AnimatedBuilder(
                                          animation: animation,
                                          child: _JellyNavigationIndicator(
                                            dark: flightDark,
                                          ),
                                          builder: (context, child) {
                                            final progress =
                                                direction ==
                                                    HeroFlightDirection.pop
                                                ? 1 - animation.value
                                                : animation.value;
                                            final pulse = math.sin(
                                              math.pi * progress,
                                            );
                                            final joinProgress = Curves
                                                .easeInOutCubic
                                                .transform(
                                                  ((progress - 0.36) / 0.64)
                                                      .clamp(0.0, 1.0)
                                                      .toDouble(),
                                                );
                                            final dropletTravelProgress =
                                                joinProgress;
                                            final directionSign =
                                                horizontalTravel < 0
                                                ? -1.0
                                                : 1.0;

                                            return LayoutBuilder(
                                              builder: (context, constraints) {
                                                final width =
                                                    constraints.maxWidth;
                                                final height =
                                                    constraints.maxHeight;
                                                final dropletScale =
                                                    1 - joinProgress * 0.58;
                                                final dropletWidth =
                                                    width * 0.34 * dropletScale;
                                                final dropletHeight =
                                                    height *
                                                    0.72 *
                                                    dropletScale;
                                                final dropletCenter =
                                                    width / 2 +
                                                    horizontalTravel *
                                                        (dropletTravelProgress -
                                                            progress);
                                                final dropletLeft =
                                                    dropletCenter -
                                                    dropletWidth / 2;

                                                return Stack(
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    if (horizontalTravel.abs() >
                                                        8)
                                                      Positioned(
                                                        left: dropletLeft,
                                                        top:
                                                            (height -
                                                                dropletHeight) /
                                                            2,
                                                        width: dropletWidth,
                                                        height: dropletHeight,
                                                        child: Opacity(
                                                          opacity:
                                                              1 - joinProgress,
                                                          child: Transform.rotate(
                                                            angle:
                                                                directionSign *
                                                                    math.pi /
                                                                    2 +
                                                                math.sin(
                                                                      math.pi *
                                                                          joinProgress *
                                                                          2,
                                                                    ) *
                                                                    0.2,
                                                            child: Transform.scale(
                                                              scaleX:
                                                                  1 +
                                                                  pulse * 0.08,
                                                              scaleY:
                                                                  1 -
                                                                  joinProgress *
                                                                      0.12,
                                                              child: _WaterDrop(
                                                                dark:
                                                                    flightDark,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    Positioned.fill(
                                                      child: Transform.scale(
                                                        scaleX:
                                                            1 + pulse * 0.10,
                                                        scaleY:
                                                            1 - pulse * 0.04,
                                                        child: Transform.rotate(
                                                          angle:
                                                              directionSign *
                                                              pulse *
                                                              0.045,
                                                          child: child,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                  child: IgnorePointer(
                                    child: Transform.scale(
                                      scaleY: 1 - stretch * 0.08,
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          if (stretch > 0.01)
                                            Positioned(
                                              left: travelDirection > 0
                                                  ? -stretchedWidth * 0.1
                                                  : stretchedWidth * 0.76,
                                              top: constraints.maxHeight * 0.17,
                                              width:
                                                  stretchedWidth *
                                                  0.34 *
                                                  stretch,
                                              height:
                                                  constraints.maxHeight *
                                                  0.66 *
                                                  stretch,
                                              child: Opacity(
                                                opacity: math.min(
                                                  0.58,
                                                  stretch * 0.62,
                                                ),
                                                child: Transform.rotate(
                                                  angle:
                                                      travelDirection *
                                                      math.pi /
                                                      2,
                                                  child: _WaterDrop(dark: dark),
                                                ),
                                              ),
                                            ),
                                          Positioned.fill(
                                            child: _JellyNavigationIndicator(
                                              dark: dark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        Row(
                          children: List.generate(_items.length, (index) {
                            final item = _items[index];
                            final selected = activeIndex == index;

                            return Expanded(
                              child: Semantics(
                                button: true,
                                selected: selected,
                                label: item.$3,
                                child: Tooltip(
                                  message: item.$3,
                                  child: GelPress(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        onSelected(index);
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 420,
                                        ),
                                        curve: AppMotion.transitionCurve,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 3,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: isCompact ? 6 : 7,
                                          horizontal: 3,
                                        ),
                                        decoration: const BoxDecoration(),
                                        child: AnimatedScale(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: AppMotion.transitionCurve,
                                          scale: selected ? 1.025 : 1,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 350,
                                                ),
                                                curve:
                                                    AppMotion.transitionCurve,
                                                width: selected ? 39 : 36,
                                                height: selected ? 30 : 28,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                ),
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    Icon(
                                                      selected
                                                          ? item.$1
                                                          : item.$2,
                                                      size: selected ? 20 : 21,
                                                      color: selected
                                                          ? (dark
                                                                ? Colors.white
                                                                : const Color(
                                                                    0xFF123D60,
                                                                  ))
                                                          : (dark
                                                                ? const Color(
                                                                    0xFFB0C0D0,
                                                                  )
                                                                : const Color(
                                                                    0xFF657487,
                                                                  )),
                                                    ),
                                                    if (index == 2 &&
                                                        showAvisosBadge)
                                                      Positioned(
                                                        top: -2,
                                                        right: -3,
                                                        child: Container(
                                                          width: 8,
                                                          height: 8,
                                                          decoration: BoxDecoration(
                                                            color: const Color(
                                                              0xFF3478F6,
                                                            ),
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                              color: dark
                                                                  ? const Color(
                                                                      0xFF26384A,
                                                                    )
                                                                  : Colors
                                                                        .white,
                                                              width: 1.3,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              AnimatedSize(
                                                duration: const Duration(
                                                  milliseconds: 260,
                                                ),
                                                curve:
                                                    AppMotion.transitionCurve,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    top: selected ? 4 : 2,
                                                  ),
                                                  child: Text(
                                                    item.$3,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: isCompact
                                                          ? 9.5
                                                          : 10.5,
                                                      height: 1.1,
                                                      fontWeight: selected
                                                          ? FontWeight.w700
                                                          : FontWeight.w500,
                                                      letterSpacing: -0.1,
                                                      color: selected
                                                          ? (dark
                                                                ? const Color(
                                                                    0xFFD7E9FF,
                                                                  )
                                                                : const Color(
                                                                    0xFF123D60,
                                                                  ))
                                                          : (dark
                                                                ? const Color(
                                                                    0xFFB0C0D0,
                                                                  )
                                                                : const Color(
                                                                    0xFF64748B,
                                                                  )),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JellyNavigationIndicator extends StatelessWidget {
  final bool dark;

  const _JellyNavigationIndicator({required this.dark});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dark
                  ? [
                      const Color(0xFFB9E5F8).withValues(alpha: 0.42),
                      const Color(0xFF75BFE4).withValues(alpha: 0.34),
                      const Color(0xFF386C91).withValues(alpha: 0.3),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.84),
                      const Color(0xFFE7F8FF).withValues(alpha: 0.74),
                      const Color(0xFF9DDCFA).withValues(alpha: 0.56),
                    ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: dark ? 0.5 : 0.9),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2D80B9)
                    .withValues(alpha: dark ? 0.3 : 0.24),
                blurRadius: 22,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: dark ? 0.08 : 0.68),
                blurRadius: 8,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _WaterDrop extends StatelessWidget {
  final bool dark;

  const _WaterDrop({required this.dark});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WaterDropPainter(dark: dark),
      child: const SizedBox.expand(),
    );
  }
}

class _WaterDropPainter extends CustomPainter {
  final bool dark;

  const _WaterDropPainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final centerX = width / 2;
    final drop = Path()
      ..moveTo(centerX, 0)
      ..cubicTo(
        centerX + width * 0.17,
        height * 0.18,
        width * 0.98,
        height * 0.5,
        width * 0.86,
        height * 0.73,
      )
      ..cubicTo(
        width * 0.75,
        height * 0.94,
        width * 0.62,
        height,
        centerX,
        height,
      )
      ..cubicTo(
        width * 0.38,
        height,
        width * 0.25,
        height * 0.94,
        width * 0.14,
        height * 0.73,
      )
      ..cubicTo(
        width * 0.02,
        height * 0.5,
        centerX - width * 0.17,
        height * 0.18,
        centerX,
        0,
      )
      ..close();

    final glow = Paint()
      ..color = const Color(0xFF67C7F2).withValues(alpha: dark ? 0.34 : 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    canvas.drawPath(drop, glow);
    canvas.drawShadow(
      drop,
      const Color(0xFF2D80B9).withValues(alpha: 0.32),
      5,
      true,
    );

    final fill = Paint()
      ..shader = ui.Gradient.linear(
        Offset(width * 0.2, 0),
        Offset(width * 0.78, height),
        dark
            ? [
                const Color(0xFFE3F8FF).withValues(alpha: 0.82),
                const Color(0xFF79C9ED).withValues(alpha: 0.56),
                const Color(0xFF347EA8).withValues(alpha: 0.44),
              ]
            : [
                Colors.white.withValues(alpha: 0.94),
                const Color(0xFFB9E9FC).withValues(alpha: 0.82),
                const Color(0xFF62B8E1).withValues(alpha: 0.64),
              ],
        const [0.0, 0.55, 1.0],
      );
    canvas.drawPath(drop, fill);

    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: dark ? 0.86 : 0.94);
    canvas.drawPath(drop, rim);

    final highlight = Paint()
      ..color = Colors.white.withValues(alpha: dark ? 0.88 : 0.96);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(width * 0.4, height * 0.3),
        width: width * 0.17,
        height: height * 0.09,
      ),
      highlight,
    );
  }

  @override
  bool shouldRepaint(covariant _WaterDropPainter oldDelegate) {
    return oldDelegate.dark != dark;
  }
}
