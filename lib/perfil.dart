import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'calendario.dart';
import 'navegacion_glass.dart';
import 'notificaciones.dart';

class PerfilPage extends StatelessWidget {
  final bool embedded;
  final VoidCallback? onBack;
  final ValueChanged<int>? onSectionSelected;

  const PerfilPage({
    super.key,
    this.embedded = false,
    this.onBack,
    this.onSectionSelected,
  });

  static const Color rojoAcento = Color(0xFFE11D2E);
  static const Color azulTec = Color(0xFF083D91);
  static const Color azulBrillante = Color(0xFF2868ED);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contenido = SafeArea(
      bottom: false,
      child: Stack(
        children: [
          const Positioned.fill(child: _FondoPerfilClaro()),
          Positioned.fill(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 132),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: Column(
                          children: [
                            _barraSuperior(context),
                            const SizedBox(height: 34),
                            _encabezado(context),
                            const SizedBox(height: 42),
                            _tarjetaOpciones(
                              context,
                              opciones: const [
                                _OpcionPerfil(
                                  icono: Icons.badge_outlined,
                                  titulo: 'Información personal',
                                  descripcion: 'Mis datos',
                                  color: azulTec,
                                ),
                                _OpcionPerfil(
                                  icono: Icons.shield_outlined,
                                  titulo: 'Seguridad de la cuenta',
                                  descripcion: 'Acceso y seguridad',
                                  color: azulTec,
                                ),
                                _OpcionPerfil(
                                  icono: Icons.school_outlined,
                                  titulo: 'Mi carrera',
                                  descripcion: 'Información académica',
                                  color: azulTec,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _tarjetaOpciones(
                              context,
                              opciones: const [
                                _OpcionPerfil(
                                  icono: Icons.folder_open_rounded,
                                  titulo: 'Mis documentos',
                                  descripcion: 'Documentos académicos',
                                  color: azulTec,
                                ),
                                _OpcionPerfil(
                                  icono: Icons.tune_rounded,
                                  titulo: 'Configuración',
                                  descripcion: 'Preferencias de la aplicación',
                                  color: azulTec,
                                ),
                                _OpcionPerfil(
                                  icono: Icons.help_outline_rounded,
                                  titulo: 'Ayuda',
                                  descripcion: 'Centro de ayuda',
                                  color: azulTec,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _botonCerrarSesion(context),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!embedded)
            Align(
              alignment: Alignment.bottomCenter,
              child: NavegacionGlass(
                selectedIndex: 3,
                onSelected: (index) => _seleccionarSeccion(context, index),
                wide: MediaQuery.sizeOf(context).width >= 720,
              ),
            ),
        ],
      ),
    );

    if (embedded) {
      return contenido;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: contenido,
    );
  }

  void _seleccionarSeccion(BuildContext context, int index) {
    if (onSectionSelected != null) {
      onSectionSelected!(index);
      return;
    }

    switch (index) {
      case 0:
        Navigator.of(context).popUntil((route) => route.isFirst);
        break;
      case 1:
        Navigator.of(context)
            .push(appPageRoute<void>(builder: (_) => const CalendarioPage()));
        break;
      case 2:
        Navigator.of(context).push(
          appPageRoute<void>(builder: (_) => const NotificacionesScreen()),
        );
        break;
    }
  }

  Widget _barraSuperior(BuildContext context) {
    return Row(
      children: [
        AppBackButton(
          onPressed: () {
            if (onBack != null) {
              onBack!();
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        Expanded(
          child: Text(
            'Mi perfil',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _encabezado(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          width: 122,
          height: 122,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dark
                  ? const [Color(0xFF27384A), Color(0xFF192838)]
                  : const [Color(0xFFFFFFFF), Color(0xFFE6F0FF)],
            ),
            border: Border.all(
              color: dark ? const Color(0xFF31465A) : Colors.white,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: azulBrillante.withValues(alpha: 0.14),
                blurRadius: 28,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: azulTec.withValues(alpha: 0.07),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            Icons.person_rounded,
            color: dark ? const Color(0xFF9FB8D4) : const Color(0xFF7795BE),
            size: 72,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Mi cuenta',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Estudiante · Tecnológico de Costa Rica',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: azulBrillante.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: azulBrillante.withValues(alpha: 0.16)),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  size: 15,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: 7),
                Text(
                  'Perfil académico',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tarjetaOpciones(
    BuildContext context, {
    required List<_OpcionPerfil> opciones,
  }) {
    return _Cristal(
      radio: 25,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Column(
        children: [
          for (int i = 0; i < opciones.length; i++) ...[
            _filaOpcion(context, opciones[i]),
            if (i != opciones.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 58),
                child: Divider(
                  height: 1,
                  thickness: 0.7,
                  color: Theme.of(context).dividerColor,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _filaOpcion(BuildContext context, _OpcionPerfil opcion) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final themePreference = AppThemePreference.maybeOf(context);
    final themeMode = themePreference?.themeMode ?? ThemeMode.system;
    final descripcion = opcion.titulo == 'Configuración'
        ? 'Modo ${_themeModeLabel(themeMode)}'
        : opcion.descripcion;
    return GelPress(
      enabled: opcion.titulo != 'Configuración',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(17),
          splashColor: azulBrillante.withValues(alpha: 0.07),
          highlightColor: azulBrillante.withValues(alpha: 0.035),
          onTap: opcion.titulo == 'Configuración'
              ? null
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${opcion.titulo}: función pendiente de configurar.',
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: azulTec,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  );
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        dark
                            ? const Color(0xFF26394D)
                            : Colors.white.withValues(alpha: 0.98),
                        dark
                            ? const Color(0xFF1C2B3A)
                            : const Color(0xFFEAF2FF).withValues(alpha: 0.85),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: azulTec.withValues(alpha: 0.10)),
                    boxShadow: [
                      BoxShadow(
                        color: azulTec.withValues(alpha: 0.045),
                        blurRadius: 9,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    opcion.icono,
                    color: theme.colorScheme.primary,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opcion.titulo,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        descripcion,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (opcion.titulo == 'Configuración')
                  ThemeModeSwitch(
                    key: const ValueKey('theme-mode-switch'),
                    value: themeMode == ThemeMode.dark,
                    onChanged: themePreference == null
                        ? null
                        : (isDark) => themePreference.onThemeModeChanged(
                            isDark ? ThemeMode.dark : ThemeMode.light,
                          ),
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 23,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'Claro',
      ThemeMode.dark => 'Oscuro',
      ThemeMode.system => 'Claro',
    };
  }

  Widget _botonCerrarSesion(BuildContext context) {
    return GelPress(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (dialogContext) {
                return AlertDialog(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(color: rojoAcento.withValues(alpha: 0.15)),
                  ),
                  title: const Text('Cerrar sesión'),
                  content: const Text(
                    'La opción de cerrar sesión debe conectarse con el sistema de autenticación de la aplicación.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Conectá esta opción con Firebase Auth para cerrar sesión.',
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Continuar',
                        style: TextStyle(
                          color: rojoAcento,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 17),
            decoration: BoxDecoration(
              color: rojoAcento.withValues(alpha: 0.055),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: rojoAcento.withValues(alpha: 0.22)),
              boxShadow: [
                BoxShadow(
                  color: rojoAcento.withValues(alpha: 0.035),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: rojoAcento, size: 19),
                SizedBox(width: 10),
                Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: rojoAcento,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FondoPerfilClaro extends StatelessWidget {
  const _FondoPerfilClaro();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
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

class _Cristal extends StatelessWidget {
  final Widget child;
  final double radio;
  final EdgeInsetsGeometry padding;

  const _Cristal({
    required this.child,
    this.radio = 24,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radio),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: (dark ? const Color(0xFF26384A) : Colors.white).withValues(
              alpha: dark ? 0.96 : 0.56,
            ),
            borderRadius: BorderRadius.circular(radio),
            border: Border.all(
              color: (dark ? const Color(0xFF52677D) : Colors.white).withValues(
                alpha: 0.92,
              ),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF41658F).withValues(alpha: 0.075),
                blurRadius: 26,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: dark ? 0.08 : 0.8),
                blurRadius: 2,
                spreadRadius: -1,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class ThemeModeSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const ThemeModeSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return GelPress(
      enabled: enabled,
      child: Semantics(
        button: true,
        toggled: value,
        enabled: enabled,
        label: value ? 'Desactivar modo oscuro' : 'Activar modo oscuro',
        child: Tooltip(
          message: value ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: enabled ? () => onChanged!(!value) : null,
              child: SizedBox(
                width: 76,
                height: 50,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 520),
                    curve: Curves.easeInOutCubicEmphasized,
                    width: 70,
                    height: 40,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: value
                            ? const [
                                Color(0xFF253A68),
                                Color(0xFF111C35),
                                Color(0xFF382B62),
                              ]
                            : const [
                                Color(0xFF9DDCFF),
                                Color(0xFFE1F4FF),
                                Color(0xFFBBDCFB),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: value
                            ? const Color(0xFF7388C7).withValues(alpha: 0.65)
                            : Colors.white.withValues(alpha: 0.9),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (value
                                      ? const Color(0xFF7079FF)
                                      : const Color(0xFF56A7E8))
                                  .withValues(alpha: 0.32),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 260),
                          opacity: value ? 0.8 : 0.0,
                          child: const Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                color: Color(0xFFFFF2BC),
                                size: 12,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 260),
                            opacity: value ? 0.0 : 0.95,
                            child: const Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Icon(
                                Icons.wb_sunny_rounded,
                                color: Color(0xFFFFB547),
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                        AnimatedAlign(
                          duration: const Duration(milliseconds: 620),
                          curve: Curves.elasticOut,
                          alignment: value
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 420),
                            curve: Curves.easeOutBack,
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: value
                                    ? const [
                                        Color(0xFFF7F5FF),
                                        Color(0xFFD8D8FF),
                                      ]
                                    : const [Colors.white, Color(0xFFF0F8FF)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (value
                                              ? const Color(0xFF080E22)
                                              : const Color(0xFF5284B1))
                                          .withValues(alpha: 0.3),
                                  blurRadius: 7,
                                  offset: const Offset(0, 2),
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(
                                    alpha: value ? 0.45 : 0.95,
                                  ),
                                  blurRadius: 2,
                                  offset: const Offset(0, -1),
                                ),
                              ],
                            ),
                            child: Center(
                              child: AnimatedRotation(
                                turns: value ? 0.5 : 0,
                                duration: const Duration(milliseconds: 560),
                                curve: Curves.easeOutBack,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 220),
                                  transitionBuilder: (child, animation) =>
                                      ScaleTransition(
                                        scale: animation,
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                      ),
                                  child: Icon(
                                    value
                                        ? Icons.nightlight_round
                                        : Icons.wb_sunny_rounded,
                                    key: ValueKey<bool>(value),
                                    size: 17,
                                    color: value
                                        ? const Color(0xFF53629B)
                                        : const Color(0xFFE99A2E),
                                  ),
                                ),
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
      ),
    );
  }
}

class _OpcionPerfil {
  final IconData icono;
  final String titulo;
  final String descripcion;
  final Color color;

  const _OpcionPerfil({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.color,
  });
}
