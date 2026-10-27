import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppThemePreference extends InheritedWidget {
  final ThemeMode themeMode;
  final Future<void> Function(ThemeMode) onThemeModeChanged;

  const AppThemePreference({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    required super.child,
  });

  static AppThemePreference of(BuildContext context) => maybeOf(context)!;

  static AppThemePreference? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppThemePreference>();

  Future<void> changeTheme(BuildContext context, ThemeMode targetMode) async {
    if (targetMode == themeMode) return;

    await ThemeTransitionController.change(
      context: context,
      targetMode: targetMode,
      onThemeModeChanged: onThemeModeChanged,
    );
  }

  @override
  bool updateShouldNotify(AppThemePreference oldWidget) =>
      themeMode != oldWidget.themeMode ||
      onThemeModeChanged != oldWidget.onThemeModeChanged;
}

ThemeData buildAppTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;

  final scheme =
      ColorScheme.fromSeed(
        seedColor: const Color(0xFF2868ED),
        brightness: brightness,
        surface: dark ? const Color(0xFF121922) : const Color(0xFFF6F8FA),
      ).copyWith(
        primary: dark ? const Color(0xFFA8C7FF) : const Color(0xFF2868ED),
        onPrimary: dark ? const Color(0xFF071426) : Colors.white,
        secondary: dark ? const Color(0xFF75E2D2) : const Color(0xFF087F8C),
        onSurface: dark ? const Color(0xFFF7F9FC) : const Color(0xFF172B4D),
        onSurfaceVariant: dark
            ? const Color(0xFFD4DCE6)
            : const Color(0xFF687A94),
        outline: dark ? const Color(0xFF9AAABD) : const Color(0xFF687A94),
        outlineVariant: dark
            ? const Color(0xFF526478)
            : const Color(0xFFD4DDE8),
        surfaceContainerLowest: dark
            ? const Color(0xFF0D131A)
            : const Color(0xFFFFFFFF),
        surfaceContainerLow: dark
            ? const Color(0xFF171F29)
            : const Color(0xFFF9FAFC),
        surfaceContainer: dark
            ? const Color(0xFF1C2733)
            : const Color(0xFFF2F5F9),
        surfaceContainerHigh: dark
            ? const Color(0xFF263443)
            : const Color(0xFFEAF0F6),
        surfaceContainerHighest: dark
            ? const Color(0xFF304153)
            : const Color(0xFFE1E9F2),
      );

  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    visualDensity: VisualDensity.standard,
    colorScheme: scheme,
    textTheme: ThemeData(brightness: brightness, fontFamily: 'Roboto').textTheme
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface),
    scaffoldBackgroundColor: dark
        ? const Color(0xFF101923)
        : const Color(0xFFF7FAFF),
    canvasColor: scheme.surface,
    cardColor: dark ? const Color(0xFF202D3A) : Colors.white,
    dividerColor: dark ? const Color(0xFF526273) : const Color(0x1F061424),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
    ),
    iconTheme: IconThemeData(color: scheme.onSurfaceVariant),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHigh,
      labelStyle: TextStyle(color: scheme.onSurfaceVariant),
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      prefixIconColor: scheme.onSurfaceVariant,
      suffixIconColor: scheme.onSurfaceVariant,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.error, width: 1.6),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      disabledColor: scheme.surfaceContainer,
      selectedColor: scheme.primary.withValues(alpha: dark ? 0.28 : 0.16),
      secondarySelectedColor: scheme.secondary.withValues(
        alpha: dark ? 0.28 : 0.16,
      ),
      labelStyle: TextStyle(color: scheme.onSurface),
      secondaryLabelStyle: TextStyle(color: scheme.onSurface),
      side: BorderSide(color: scheme.outlineVariant),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return scheme.onPrimary;
        return scheme.onSurfaceVariant;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return scheme.primary;
        return scheme.surfaceContainerHighest;
      }),
      trackOutlineColor: WidgetStateProperty.all(scheme.outline),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: scheme.primary,
      selectionColor: scheme.primary.withValues(alpha: dark ? 0.36 : 0.24),
      selectionHandleColor: scheme.primary,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: dark ? const Color(0xFF202D3A) : Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: dark ? const Color(0xFF202D3A) : Colors.white,
      modalBackgroundColor: dark ? const Color(0xFF202D3A) : Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: dark ? const Color(0xFF263648) : const Color(0xFF0D233A),
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeThroughPageTransitionsBuilder(),
        TargetPlatform.iOS: FadeThroughPageTransitionsBuilder(),
        TargetPlatform.windows: FadeThroughPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeThroughPageTransitionsBuilder(),
        TargetPlatform.linux: FadeThroughPageTransitionsBuilder(),
      },
    ),
  );
}

/// Fondo común inspirado en el degradado y las luces difuminadas de Perfil.
class FondoAppDifuminado extends StatelessWidget {
  const FondoAppDifuminado({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: dark
                      ? const [
                          Color(0xFF101923),
                          Color(0xFF152231),
                          Color(0xFF1B2B3B),
                        ]
                      : const [
                          Color(0xFFFFFFFF),
                          Color(0xFFF7FAFF),
                          Color(0xFFEEF4FC),
                        ],
                ),
              ),
            ),
            Positioned(
              top: -100,
              right: -80,
              child: _brillo(
                size: 270,
                color: const Color(0xFF7CB4FF).withValues(alpha: 0.18),
              ),
            ),
            Positioned(
              top: 290,
              left: -125,
              child: _brillo(
                size: 250,
                color: const Color(0xFFB9D8FF).withValues(alpha: 0.18),
              ),
            ),
            Positioned(
              bottom: 70,
              right: -100,
              child: _brillo(
                size: 250,
                color: const Color(0xFFE5A8B0).withValues(alpha: 0.09),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _brillo({required double size, required Color color}) {
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: 38, sigmaY: 38),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

/// Administra la animación de cambio de tema.
class ThemeTransitionController {
  ThemeTransitionController._();

  static bool _isRunning = false;

  static Future<void> change({
    required BuildContext context,
    required ThemeMode targetMode,
    required Future<void> Function(ThemeMode) onThemeModeChanged,
  }) async {
    if (_isRunning) return;

    final overlayState = Overlay.maybeOf(context, rootOverlay: true);

    if (overlayState == null || !context.mounted) {
      await onThemeModeChanged(targetMode);
      return;
    }

    _isRunning = true;

    final controller = AnimationController(
      vsync: overlayState,
      duration: const Duration(milliseconds: 1050),
    );

    final entry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: ThemeTransitionOverlay(
          animation: controller,
          dark: targetMode == ThemeMode.dark,
        ),
      ),
    );

    bool changed = false;
    Future<void>? changeFuture;

    void changeAtCenter() {
      if (changed) return;
      changed = true;
      changeFuture = onThemeModeChanged(targetMode);
    }

    void listen() {
      if (controller.value >= 0.50) {
        changeAtCenter();
      }
    }

    try {
      overlayState.insert(entry);
      controller.addListener(listen);

      await controller.forward();

      changeAtCenter();

      if (changeFuture != null) {
        await changeFuture;
      }
    } finally {
      controller.removeListener(listen);
      entry.remove();
      entry.dispose();
      controller.dispose();
      _isRunning = false;
    }
  }
}

/// Efecto de dos ondas que se encuentran en el centro.
class ThemeTransitionOverlay extends StatelessWidget {
  final Animation<double> animation;
  final bool dark;

  const ThemeTransitionOverlay({
    super.key,
    required this.animation,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: animation,
          builder: (_, _) => CustomPaint(
            painter: _ThemeTransitionPainter(
              progress: animation.value,
              dark: dark,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _ThemeTransitionPainter extends CustomPainter {
  final double progress;
  final bool dark;

  const _ThemeTransitionPainter({required this.progress, required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || size.isEmpty) return;

    const meetingPoint = 0.50;

    final targetColor = dark
        ? const Color(0xFF111923)
        : const Color(0xFFF6F9FF);

    final lightColor = dark ? const Color(0xFF719BFF) : const Color(0xFF65B8FF);

    final expansion = Curves.easeInOutCubic.transform(
      (progress / meetingPoint).clamp(0.0, 1.0),
    );

    final fade = progress <= meetingPoint
        ? 1.0
        : (1 - (progress - meetingPoint) / (1 - meetingPoint)).clamp(0.0, 1.0);

    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        math.sqrt(size.width * size.width + size.height * size.height) *
        expansion;

    final corners = <Offset>[Offset.zero, Offset(size.width, size.height)];

    for (final corner in corners) {
      if (radius <= 0) continue;

      final bounds = Rect.fromCircle(center: corner, radius: radius);

      // La onda cubre la pantalla con el color del nuevo tema.
      canvas.drawCircle(
        corner,
        radius,
        Paint()
          ..color = targetColor.withValues(alpha: fade)
          ..isAntiAlias = true,
      );

      // Halo luminoso en el borde de cada onda.
      final halo = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.transparent,
            Colors.transparent,
            lightColor.withValues(alpha: 0.20 * fade),
            Colors.white.withValues(alpha: 0.82 * fade),
            lightColor.withValues(alpha: 0),
          ],
          stops: const [0, 0.89, 0.94, 0.975, 1],
        ).createShader(bounds);

      canvas.drawCircle(corner, radius * 0.98, halo);

      final outline = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = Colors.white.withValues(alpha: 0.75 * fade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawCircle(corner, radius * 0.985, outline);
    }

    // Destello justo cuando ambas ondas se encuentran.
    final impactProgress = ((progress - meetingPoint + 0.09) / 0.18).clamp(
      0.0,
      1.0,
    );

    final impact = math.sin(impactProgress * math.pi);
    final flashRadius = 28.0 + 125.0 * impact;

    if (impact > 0) {
      final flash = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.95 * impact),
            lightColor.withValues(alpha: 0.48 * impact),
            lightColor.withValues(alpha: 0.10 * impact),
            Colors.transparent,
          ],
          stops: const [0, 0.23, 0.58, 1],
        ).createShader(Rect.fromCircle(center: center, radius: flashRadius));

      canvas.drawCircle(center, flashRadius, flash);

      final particles = Paint()
        ..color = Colors.white.withValues(alpha: impact)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

      const directions = <Offset>[
        Offset(-1, -0.8),
        Offset(1, -0.8),
        Offset(-0.8, 1),
        Offset(0.8, 1),
        Offset(0, -1),
        Offset(1, 0),
        Offset(-1, 0),
      ];

      for (int i = 0; i < directions.length; i++) {
        final distance = 15 + 35 * impact;
        final point = center + directions[i] * distance;

        canvas.drawCircle(point, (i % 3 == 0 ? 3.0 : 2.0) * impact, particles);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ThemeTransitionPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.dark != dark;
  }
}

/// Botón de regreso compartido para las secciones de la aplicación.
class AppBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool onDarkBackground;

  const AppBackButton({
    super.key,
    required this.onPressed,
    this.onDarkBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = onDarkBackground ? Colors.white : colors.onSurface;
    final topFill = onDarkBackground
        ? Colors.white.withValues(alpha: 0.20)
        : colors.surfaceContainerHigh.withValues(alpha: 0.88);
    final bottomFill = onDarkBackground
        ? Colors.white.withValues(alpha: 0.10)
        : colors.surfaceContainerHigh.withValues(alpha: 0.70);
    final outline = onDarkBackground
        ? Colors.white.withValues(alpha: 0.32)
        : colors.outlineVariant.withValues(alpha: 0.78);

    return Tooltip(
      message: 'Atrás',
      child: Semantics(
        button: true,
        label: 'Atrás',
        child: GelPress(
          child: SizedBox.square(
            dimension: 48,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(17),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [topFill, bottomFill],
                  ),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: outline),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: onDarkBackground ? 0.12 : 0.06,
                      ),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(
                        alpha: onDarkBackground ? 0.13 : 0.68,
                      ),
                      blurRadius: 4,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(17),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onPressed();
                  },
                  child: Center(
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: foreground,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

abstract final class AppMotion {
  static const Duration pageTransitionDuration = Duration(milliseconds: 560);
  static const Duration sectionTransitionDuration = Duration(milliseconds: 520);
  static const Duration gelPressDuration = Duration(milliseconds: 110);
  static const Duration gelReleaseDuration = Duration(milliseconds: 460);
  static const Curve transitionCurve = Curves.easeInOutCubicEmphasized;
  static const Curve pageOpenCurve = Curves.easeOutBack;
  static const Curve gelPressCurve = Curves.easeOutCubic;
  static const Curve gelReleaseCurve = Curves.elasticOut;
  static const double pageSlideDistance = 0.046;
  static const double pageOpenScale = 0.90;
  static const double sectionOpenScale = 0.95;
  static const double pageRevealRadius = 36;
  static const double gelStretchX = 0.032;
  static const double gelSquashY = 0.085;
}

class OrientationChangeTransition extends StatefulWidget {
  final Widget child;

  const OrientationChangeTransition({
    super.key,
    required this.child,
  });

  @override
  State<OrientationChangeTransition> createState() =>
      _OrientationChangeTransitionState();
}

class _OrientationChangeTransitionState
    extends State<OrientationChangeTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;
  bool? _wasLandscape;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
      value: 1,
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _scale = Tween<double>(begin: 0.985, end: 1).animate(_fade);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.018),
      end: Offset.zero,
    ).animate(_fade);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.sizeOf(context);
    final isLandscape = size.width > size.height;
    if (_wasLandscape != null && isLandscape != _wasLandscape) {
      _controller.forward(from: 0);
    }
    _wasLandscape = isLandscape;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(scale: _scale, child: widget.child),
      ),
    );
  }
}

/// Adds a soft horizontal stretch and vertical squash to a tappable child.
class GelPress extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const GelPress({super.key, required this.child, this.enabled = true});

  @override
  State<GelPress> createState() => _GelPressState();
}

class _GelPressState extends State<GelPress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      lowerBound: -0.12,
      upperBound: 1,
      value: 0,
    );
  }

  @override
  void didUpdateWidget(covariant GelPress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled && !widget.enabled) {
      _controller.animateBack(
        0,
        duration: AppMotion.gelReleaseDuration,
        curve: AppMotion.gelReleaseCurve,
      );
    }
  }

  void _press(PointerDownEvent event) {
    if (!widget.enabled) return;
    _controller.animateTo(
      1,
      duration: AppMotion.gelPressDuration,
      curve: AppMotion.gelPressCurve,
    );
  }

  void _release(PointerEvent event) {
    if (!widget.enabled) return;
    _controller.animateBack(
      0,
      duration: AppMotion.gelReleaseDuration,
      curve: AppMotion.gelReleaseCurve,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: widget.enabled ? _press : null,
      onPointerUp: widget.enabled ? _release : null,
      onPointerCancel: widget.enabled ? _release : null,
      child: AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) {
          final press = _controller.value;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(
              1 + AppMotion.gelStretchX * press,
              1 - AppMotion.gelSquashY * press,
              1,
            ),
            child: child,
          );
        },
      ),
    );
  }
}

/// Usá esta ruta para las pantallas abiertas con Navigator.push.
Widget _appPageTransition(
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final enter = CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  final exit = CurvedAnimation(
    parent: secondaryAnimation,
    curve: Curves.easeInCubic,
    reverseCurve: Curves.easeOutCubic,
  );

  return SlideTransition(
    position: Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.012),
    ).animate(exit),
    child: FadeTransition(
      opacity: ReverseAnimation(exit),
      child: FadeTransition(
        opacity: enter,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.035),
            end: Offset.zero,
          ).animate(enter),
          child: child,
        ),
      ),
    ),
  );
}

Route<T> appPageRoute<T>({required WidgetBuilder builder}) {
  return PageRouteBuilder<T>(
    transitionDuration: AppMotion.pageTransitionDuration,
    reverseTransitionDuration: AppMotion.pageTransitionDuration,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        _appPageTransition(animation, secondaryAnimation, child),
  );
}

/// Constructor de transición de página con fundido.
class FadeThroughPageTransitionsBuilder extends PageTransitionsBuilder {
  const FadeThroughPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _appPageTransition(animation, secondaryAnimation, child);
  }
}
