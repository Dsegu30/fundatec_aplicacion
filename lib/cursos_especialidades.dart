import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';
import 'calendario.dart';
import 'cursos_libres.dart';
import 'especialidades.dart';
import 'navegacion_glass.dart';
import 'notificaciones.dart';
import 'perfil.dart';
import 'responsive_layout.dart';

class CursosEspecialidadesPage extends StatefulWidget {
  const CursosEspecialidadesPage({super.key});

  @override
  State<CursosEspecialidadesPage> createState() =>
      _CursosEspecialidadesPageState();
}

class _CursosEspecialidadesPageState extends State<CursosEspecialidadesPage> {
  int _selectedIndex = 0;

  void _abrirCursos() {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      appPageRoute<void>(builder: (_) => const CursosLibresCatalogoPage()),
    );
  }

  void _abrirEspecialidades() {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      appPageRoute<void>(
        builder: (_) => const EspecialidadesIndustrialesPage(),
      ),
    );
  }

  void _abrirCalendario() {
    Navigator.of(context)
        .push(appPageRoute<void>(builder: (_) => const CalendarioPage()));
  }

  void _abrirPerfil() {
    Navigator.of(context)
        .push(appPageRoute<void>(builder: (_) => const PerfilPage()));
  }

  void _abrirAvisos() {
    Navigator.of(context).push(
      appPageRoute<void>(
        builder: (_) => NotificacionesScreen(
          onSectionSelected: (index) {
            if (!mounted) return;
            if (index == 0) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            } else if (index == 1) {
              Navigator.of(context).pop();
              _abrirCalendario();
            } else if (index == 3) {
              Navigator.of(context).pop();
              _abrirPerfil();
            }
          },
        ),
      ),
    );
  }

  void _seleccionarSeccion(int index) {
    HapticFeedback.selectionClick();
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.of(context).popUntil((route) => route.isFirst);
        break;
      case 1:
        _abrirCalendario();
        break;
      case 2:
        _abrirAvisos();
        break;
      case 3:
        _abrirPerfil();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final wide = size.width >= 720;
    final compactLandscape =
        ResponsiveLayout.isCompactLandscape(size.width, size.height) &&
        MediaQuery.textScalerOf(context).scale(1) <= 1.2;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          const FondoAppDifuminado(),
          SafeArea(
            child: Column(
              children: [
                _construirEncabezado(wide: wide, compact: compactLandscape),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final horizontalPadding = wide ? 32.0 : 20.0;
                      final maxWidth =
                          constraints.maxWidth - horizontalPadding * 2;
                      final contentWidth = maxWidth
                          .clamp(0.0, 1320.0)
                          .toDouble();
                      final hinge = ResponsiveLayout.verticalHinge(context);
                      final singleColumn = contentWidth < 620 && hinge == null;
                      final spacing = ResponsiveLayout.spacingFor(
                        context,
                        minimum: 18,
                      );
                      final verticalInset = compactLandscape ? 12.0 : 26.0;
                      final contentHeight =
                          (constraints.maxHeight - verticalInset * 2)
                              .clamp(0.0, double.infinity)
                              .toDouble();
                      final cardWidth = singleColumn
                          ? contentWidth
                          : (contentWidth - spacing) / 2;
                      final textScale = MediaQuery.textScalerOf(context)
                          .scale(1);
                      final cardHeight = compactLandscape
                          ? 168.0
                          : (260 * textScale).clamp(260.0, 420.0).toDouble();

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          verticalInset,
                          horizontalPadding,
                          verticalInset,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: contentHeight),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1320),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: spacing,
                                runSpacing: spacing,
                                children: [
                                  _OpcionFormacionCard(
                                    key: const ValueKey(
                                      'selector-cursos-libres',
                                    ),
                                    width: cardWidth,
                                    height: cardHeight,
                                    compact: compactLandscape,
                                    titulo: 'Cursos libres',
                                    descripcion:
                                        'Amplía tus conocimientos y desarrolla '
                                        'nuevas habilidades con opciones prácticas.',
                                    icono: Icons.menu_book_rounded,
                                    colores: const [
                                      Color(0xFF061424),
                                      Color(0xFF2878B5),
                                    ],
                                    onTap: _abrirCursos,
                                  ),
                                  _OpcionFormacionCard(
                                    key: const ValueKey(
                                      'selector-especialidades',
                                    ),
                                    width: cardWidth,
                                    height: cardHeight,
                                    compact: compactLandscape,
                                    titulo: 'Especialidades industriales',
                                    descripcion:
                                        'Conoce las opciones de formación para '
                                        'especializarte y avanzar profesionalmente.',
                                    icono: Icons.engineering_rounded,
                                    colores: const [
                                      Color(0xFF343A40),
                                      Color(0xFFB63D4A),
                                    ],
                                    onTap: _abrirEspecialidades,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavegacionGlass(
        selectedIndex: _selectedIndex,
        onSelected: _seleccionarSeccion,
        wide: wide,
      ),
    );
  }

  Widget _construirEncabezado({required bool wide, required bool compact}) {
    final horizontalPadding = wide ? 32.0 : 22.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        compact ? 4 : 12,
        horizontalPadding,
        compact ? 12 : 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF061424), Color(0xFF0D233A), Color(0xFF1B3C73)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBackButton(
            onDarkBackground: true,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          SizedBox(height: compact ? 2 : 10),
          Text(
            'Especialidades y Cursos Industriales',
            style: TextStyle(
              color: Colors.white,
              fontSize: compact
                  ? 22
                  : wide
                  ? 30
                  : 25,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: compact ? 3 : 6),
          Text(
            'Elige qué tipo de formación quieres explorar.',
            maxLines: compact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white70,
              fontSize: compact ? 11 : 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpcionFormacionCard extends StatelessWidget {
  const _OpcionFormacionCard({
    super.key,
    required this.width,
    required this.height,
    required this.compact,
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.colores,
    required this.onTap,
  });

  final double width;
  final double height;
  final bool compact;
  final String titulo;
  final String descripcion;
  final IconData icono;
  final List<Color> colores;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(26);

    return GelPress(
      child: Semantics(
        button: true,
        label: '$titulo. $descripcion',
        child: SizedBox(
          width: width,
          height: height,
          child: Material(
            color: Colors.transparent,
            borderRadius: radius,
            child: InkWell(
              onTap: onTap,
              borderRadius: radius,
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colores,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: radius,
                  child: Stack(
                    children: [
                      Positioned(
                        right: -28,
                        top: -34,
                        child: Container(
                          width: 148,
                          height: 148,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? 16 : 20,
                          vertical: compact ? 16 : 18,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: compact ? 42 : 54,
                              height: compact ? 42 : 54,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(
                                  compact ? 14 : 17,
                                ),
                              ),
                              child: Icon(
                                icono,
                                color: Colors.white,
                                size: compact ? 22 : 28,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              titulo,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: compact ? 17 : 21,
                                height: 1.15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: compact ? 4 : 7),
                            Text(
                              descripcion,
                              maxLines: compact ? 1 : 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: compact ? 11 : 12.5,
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: compact ? 6 : 12),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Ver opciones',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: compact ? 10 : 12,
                                  ),
                                ),
                                SizedBox(width: compact ? 4 : 6),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: compact ? 14 : 16,
                                ),
                              ],
                            ),
                          ],
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
  }
}
