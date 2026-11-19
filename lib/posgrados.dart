import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';
import 'calendario.dart';
import 'navegacion_glass.dart';
import 'notificaciones.dart';
import 'perfil.dart';
import 'posgrados_detalle.dart';
import 'responsive_layout.dart';

class PosgradosPage extends StatefulWidget {
  const PosgradosPage({super.key});

  @override
  State<PosgradosPage> createState() => _PosgradosPageState();
}

class _PosgradosPageState extends State<PosgradosPage> {
  static const Color primaryNavy = Color(0xFF061424);
  static const Color deepBlue = Color(0xFF0D233A);

  int selectedIndex = 0;

  final List<_PosgradoData> posgrados = const [
    _PosgradoData(
      titulo: 'Maestría en Calidad Académica',
      descripcion:
          'Diseña modelos, instrumentos y estrategias para fortalecer la calidad y evaluación de las organizaciones.',
      icono: Icons.school_outlined,
      colores: [Color(0xFF17375E), Color(0xFF3977B8)],
      imagen: 'assets/images/Maestria_Calidad_Modalidad_Academica.png',
      programa: _TipoPosgrado.calidadAcademica,
    ),
    _PosgradoData(
      titulo: 'Maestría en Calidad Profesional',
      descripcion:
          'Transforma la gestión de la calidad en resultados concretos y mejora continua para las organizaciones.',
      icono: Icons.fact_check_outlined,
      colores: [Color(0xFF162D3D), Color(0xFF247B87)],
      imagen: 'assets/images/Maestria_Calidad_Modalidad_Profesional.png',
      programa: _TipoPosgrado.calidadProfesional,
    ),
    _PosgradoData(
      titulo: 'Maestría en Cadena de Abastecimiento',
      descripcion:
          'Especialízate en logística, planificación y gestión eficiente de las cadenas de suministro.',
      icono: Icons.local_shipping_outlined,
      colores: [Color(0xFF182848), Color(0xFF315C91)],
      imagen: 'assets/images/Maestria_Cadena_de_Abastecimiento.png',
      programa: _TipoPosgrado.cadenaAbastecimiento,
    ),
    _PosgradoData(
      titulo: 'Maestría en Sistemas Modernos de Manufactura',
      descripcion:
          'Aprende sobre tecnologías modernas, automatización y optimización de procesos de manufactura.',
      icono: Icons.precision_manufacturing_outlined,
      colores: [Color(0xFF162D3D), Color(0xFF247B87)],
      imagen: 'assets/images/Maestria_Sistemas_Modernos_de_Manufactura.png',
      programa: _TipoPosgrado.sistemasModernosManufactura,
    ),
  ];

  Widget _detalleDe(_PosgradoData posgrado) {
    return switch (posgrado.programa) {
      _TipoPosgrado.calidadAcademica =>
        const MaestriaCalidadAcademicaPage(),
      _TipoPosgrado.calidadProfesional =>
        const MaestriaCalidadProfesionalPage(),
      _TipoPosgrado.cadenaAbastecimiento =>
        const MaestriaCadenaAbastecimientoPage(),
      _TipoPosgrado.sistemasModernosManufactura =>
        const MaestriaSistemasModernosManufacturaPage(),
    };
  }

  void _abrirCalendario() {
    HapticFeedback.selectionClick();

    Navigator.push(
      context,
      appPageRoute<void>(builder: (_) => const CalendarioPage()),
    );
  }

  void _abrirPerfil() {
    HapticFeedback.selectionClick();

    Navigator.push(
      context,
      appPageRoute<void>(builder: (_) => const PerfilPage()),
    );
  }

  void _abrirAvisos() {
    HapticFeedback.selectionClick();

    Navigator.push(
      context,
      appPageRoute<void>(
        builder: (_) => NotificacionesScreen(
          onSectionSelected: (index) {
            if (!mounted) return;

            if (index == 0) {
              Navigator.pop(context);
              setState(() => selectedIndex = 0);
            } else if (index == 1) {
              Navigator.pop(context);
              _abrirCalendario();
            } else if (index == 3) {
              Navigator.pop(context);
              _abrirPerfil();
            }
          },
        ),
      ),
    );
  }

  void _seleccionarSeccion(int index) {
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    setState(() => selectedIndex = index);

    switch (index) {
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
    return Builder(
      builder: (context) {
        final size = MediaQuery.sizeOf(context);

        final compactLandscape =
            size.width > size.height && size.height < 600;

        final horizontalInset = size.width < 360 ? 14.0 : 20.0;

        final hinge = ResponsiveLayout.verticalHinge(context);

        final availableGridWidth =
            size.width - horizontalInset * 2;

        final columns =
            hinge != null || availableGridWidth >= 720 ? 2 : 1;

        final rowCount = (posgrados.length / columns).ceil();

        final rowSpacing = compactLandscape ? 12.0 : 16.0;

        final gridTopInset = compactLandscape ? 12.0 : 16.0;

        final gridBottomInset = compactLandscape ? 12.0 : 16.0;

        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final minimumCardHeight =
            (columns == 1 ? 135.0 : 150.0) * textScale;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              const FondoAppDifuminado(),

              SafeArea(
                child: Column(
                  children: [
                    _construirEncabezado(compactLandscape),

                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final availableCardSpace =
                              constraints.maxHeight -
                              gridTopInset -
                              gridBottomInset -
                              rowSpacing * (rowCount - 1);

                          final cardHeight = math.max(
                            minimumCardHeight,
                            availableCardSpace / rowCount,
                          ).toDouble();

                          return SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                horizontalInset,
                                gridTopInset,
                                horizontalInset,
                                gridBottomInset,
                              ),
                              child: ResponsiveCardGrid(
                                itemCount: posgrados.length,
                                maxWidth: double.infinity,
                                cardHeight: cardHeight,
                                maxCardHeight: cardHeight,
                                maxColumns: 2,
                                twoColumnMinWidth: 720,
                                spacing: rowSpacing,
                                itemBuilder: (context, index) =>
                                    _construirTarjeta(posgrados[index]),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    _construirNavegacionInferior(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _construirEncabezado([bool compacto = false]) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        compacto ? 18 : 22,
        compacto ? 8 : 18,
        compacto ? 18 : 22,
        compacto ? 12 : 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryNavy,
            deepBlue,
            Color(0xFF1B3C73),
          ],
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

          const Text(
            'Posgrados',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Descubre nuevas oportunidades para especializarte y avanzar profesionalmente.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirTarjeta(_PosgradoData posgrado) {
    const radio = 25.0;

    return GelPress(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radio),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();

            Navigator.of(context).push(
              appPageRoute<void>(
                builder: (_) => _detalleDe(posgrado),
              ),
            );
          },
          borderRadius: BorderRadius.circular(radio),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radio),
              gradient: LinearGradient(
                colors: posgrado.colores,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: posgrado.colores.first.withValues(alpha: 0.22),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radio),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen ubicada en el lado derecho.
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FractionallySizedBox(
                        widthFactor: 0.9,
                        heightFactor: 1,
                        child: ShaderMask(
                          blendMode: BlendMode.dstIn,
                          shaderCallback: (bounds) {
                            return const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.transparent,
                                Color(0x66FFFFFF),
                                Color(0xE6FFFFFF),
                              ],
                              stops: [0.0, 0.22, 1.0],
                            ).createShader(bounds);
                          },
                          child: Image.asset(
                            posgrado.imagen,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            filterQuality: FilterQuality.high,
                            color: Colors.white.withValues(alpha: 0.58),
                            colorBlendMode: BlendMode.softLight,
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Degradado para integrar la imagen con el fondo.
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            posgrado.colores.first.withValues(alpha: 0.98),
                            posgrado.colores.first.withValues(alpha: 0.86),
                            posgrado.colores.last.withValues(alpha: 0.38),
                          ],
                          stops: const [0.0, 0.48, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Decoración de fondo.
                  Positioned(
                    top: -35,
                    right: 45,
                    child: Container(
                      width: 115,
                      height: 115,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),

                  // Texto e icono.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      14,
                      10,
                      45,
                      10,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Icon(
                            posgrado.icono,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),

                        const SizedBox(width: 11),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                posgrado.titulo,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  height: 1.18,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                posgrado.descripcion,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11.5,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Botón de avanzar.
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 19,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirNavegacionInferior() {
    return NavegacionGlass(
      selectedIndex: selectedIndex,
      onSelected: _seleccionarSeccion,
      wide: MediaQuery.sizeOf(context).width >= 720,
    );
  }
}

class _PosgradoData {
  final String titulo;
  final String descripcion;
  final IconData icono;
  final List<Color> colores;
  final String imagen;
  final _TipoPosgrado programa;

  const _PosgradoData({
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.colores,
    required this.imagen,
    required this.programa,
  });
}

enum _TipoPosgrado {
  calidadAcademica,
  calidadProfesional,
  cadenaAbastecimiento,
  sistemasModernosManufactura,
}