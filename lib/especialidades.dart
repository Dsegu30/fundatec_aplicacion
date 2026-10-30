import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';
import 'calendario.dart';
import 'especialidad_detalle.dart';
import 'navegacion_glass.dart';
import 'notificaciones.dart';
import 'perfil.dart';
import 'responsive_layout.dart';

class EspecialidadesIndustrialesPage extends StatefulWidget {
  const EspecialidadesIndustrialesPage({super.key});

  @override
  State<EspecialidadesIndustrialesPage> createState() =>
      _EspecialidadesIndustrialesPageState();
}

class _EspecialidadesIndustrialesPageState
    extends State<EspecialidadesIndustrialesPage> {
  static const Color primaryNavy = Color(0xFF061424);
  static const Color deepBlue = Color(0xFF0D233A);
  int selectedIndex = 0;

  final List<_EspecialidadData> especialidades = const [
    _EspecialidadData(
      titulo: 'Auditoría de calidad',
      categoria: 'Especialización',
      descripcion:
          'Busca decretar si lo pactado se está cumpliendo, evaluar '
          'procedimientos para ver si reúnen las condiciones escritas y '
          'las condiciones de calidad.',
      icono: Icons.fact_check_outlined,
      colores: [Color(0xFF162D3D), Color(0xFF247B87)],
      imagen: 'https://images.unsplash.com/photo-1581092921461-eab62e97a780?auto=format&fit=crop&w=1500&q=92',
    ),
    _EspecialidadData(
      titulo: 'Estadística Experimental',
      categoria: 'Especialización',
      descripcion:
          'Examina datos en bruto con el propósito de sacar conclusiones '
          'sobre la información y es usado en varias industrias para permitir '
          'la toma de mejores decisiones empresariales.',
      icono: Icons.query_stats_rounded,
      colores: [Color(0xFF28345E), Color(0xFF6656A6)],
      imagen: 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?auto=format&fit=crop&w=1500&q=92',
    ),
    _EspecialidadData(
      titulo: 'Seis Sigma Yellow Belt',
      categoria: 'Especialización',
      descripcion:
          'Utiliza un conjunto de herramientas estadísticas que buscan '
          'reducir la variabilidad de los procesos dando prioridad a los '
          'requisitos de los clientes.',
      icono: Icons.auto_graph_rounded,
      colores: [Color(0xFF123B59), Color(0xFF167D9A)],
      imagen: 'https://images.unsplash.com/photo-1521737711867-e3b97375f902?auto=format&fit=crop&w=1500&q=92',
    ),
    _EspecialidadData(
      titulo: 'Servicio al cliente',
      categoria: 'Especialización',
      descripcion:
          'Desarrolla la capacidad de transformar las quejas y sugerencias '
          'de los usuarios en conocimiento útil para la entidad.',
      icono: Icons.support_agent_rounded,
      colores: [Color(0xFF17365D), Color(0xFF3979B9)],
      imagen: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=1500&q=92',
    ),
    _EspecialidadData(
      titulo: 'Metrología',
      categoria: 'Especialización',
      descripcion:
          'Aplica los conceptos de la teoría de la medición que son '
          'esenciales en el desarrollo de un eficiente y efectivo sistema '
          'metrológico.',
      icono: Icons.precision_manufacturing_outlined,
      colores: [Color(0xFF183344), Color(0xFF347F8C)],
      imagen: 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&w=1500&q=92',
    ),
  ];

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
    HapticFeedback.selectionClick();
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
        final compactLandscape = size.width > size.height && size.height < 600;
        final horizontalInset = size.width < 360 ? 14.0 : 20.0;
        final hinge = ResponsiveLayout.verticalHinge(context);
        final availableGridWidth = size.width - horizontalInset * 2;
        final columns = hinge != null || availableGridWidth >= 720 ? 2 : 1;
        final rowCount = (especialidades.length / columns).ceil();
        final rowSpacing = compactLandscape ? 12.0 : 20.0;
        final gridTopInset = compactLandscape ? 12.0 : 18.0;
        final gridBottomInset = compactLandscape ? 12.0 : 18.0;
        final minimumCardHeight = columns == 1 ? 120.0 : 150.0;

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
                          final cardHeight = math
                              .max(
                                minimumCardHeight,
                                availableCardSpace / rowCount,
                              )
                              .toDouble();
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
                                itemCount: especialidades.length,
                                maxWidth: double.infinity,
                                cardHeight: cardHeight,
                                maxCardHeight: cardHeight,
                                maxColumns: 2,
                                twoColumnMinWidth: 720,
                                spacing: rowSpacing,
                                itemBuilder: (context, index) =>
                                    _construirTarjeta(especialidades[index]),
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
          colors: [primaryNavy, deepBlue, Color(0xFF1B3C73)],
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
            'Especialidades industriales',
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
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _construirTarjeta(_EspecialidadData especialidad) {
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
                builder: (_) => EspecialidadDetallePage(
                  titulo: especialidad.titulo,
                  descripcion: especialidad.descripcion,
                  colores: especialidad.colores,
                  imagen: especialidad.imagen,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(radio),
          child: Container(
            height: 178,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radio),
              gradient: LinearGradient(
                colors: especialidad.colores,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: especialidad.colores.first.withValues(alpha: 0.22),
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
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.68,
                      child: Image.network(
                        especialidad.imagen,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        alignment: Alignment.centerRight,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            especialidad.colores.first.withValues(alpha: 0.82),
                            especialidad.colores.first.withValues(alpha: 0.58),
                            especialidad.colores.last.withValues(alpha: 0.16),
                          ],
                          stops: const [0.0, 0.38, 1.0],
                        ),
                      ),
                    ),
                  ),
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 47, 10),
                    child: Row(
                      children: [
                        Container(
                          width: 53,
                          height: 53,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(17),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Icon(
                            especialidad.icono,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                especialidad.titulo,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  height: 1.18,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                especialidad.descripcion,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11.5,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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

class _EspecialidadData {
  final String titulo;
  final String categoria;
  final String descripcion;
  final IconData icono;
  final List<Color> colores;
  final String imagen;

  const _EspecialidadData({
    required this.titulo,
    required this.categoria,
    required this.descripcion,
    required this.icono,
    required this.colores,
    required this.imagen,
  });
}
