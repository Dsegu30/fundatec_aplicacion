import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

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
    scaffoldBackgroundColor: scheme.surface,
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
          builder: (_, __) => CustomPaint(
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

/// Usá esta ruta para las pantallas abiertas con Navigator.push.
Route<T> appPageRoute<T>({required WidgetBuilder builder}) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (context, animation, secondaryAnimation) {
      return builder(context);
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final enter = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      final exit = CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeInOutCubic,
      );

      return FadeTransition(
        opacity: enter,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.035, 0.012),
            end: Offset.zero,
          ).animate(enter),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.985, end: 1).animate(enter),
            child: FadeTransition(
              opacity: ReverseAnimation(exit),
              child: child,
            ),
          ),
        ),
      );
    },
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
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.025, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
