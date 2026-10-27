import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';
import 'calendario.dart';
import 'navegacion_glass.dart';
import 'notificaciones.dart';
import 'perfil.dart';
import 'responsive_layout.dart';
import 'tecnico_detalle.dart';

class TecnicosPage extends StatefulWidget {
  const TecnicosPage({super.key});

  @override
  State<TecnicosPage> createState() => _TecnicosPageState();
}

class _TecnicosPageState extends State<TecnicosPage> {
  static const Color primaryNavy = Color(0xFF061424);
  static const Color deepBlue = Color(0xFF0D233A);
  int selectedIndex = 0;

  final List<_TecnicoData> tecnicos = const [
    _TecnicoData(
      titulo: 'Técnico en Calidad',
      descripcion: 'Desarrolla tus habilidades en control, mejora y aseguramiento de la calidad industrial.',
      icono: Icons.verified_outlined,
      colores: [Color(0xFF0D233A), Color(0xFF1B3C73)],
      imagen: 'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?auto=format&fit=crop&w=1500&q=92',
      detalle: ProgramaTecnico.calidad,
    ),
    _TecnicoData(
      titulo: 'Técnico en Logística e Inventarios',
      descripcion: 'Aprende sobre inventarios, almacenamiento, organización y distribución de productos.',
      icono: Icons.inventory_2_outlined,
      colores: [Color(0xFF087F8C), Color(0xFF14B8A6)],
      imagen: 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&w=1500&q=92',
      detalle: ProgramaTecnico.logisticaInventarios,
    ),
    _TecnicoData(
      titulo: 'Técnico en Supervisión de Producción',
      descripcion: 'Conoce los procesos industriales y la supervisión de las operaciones de producción.',
      icono: Icons.precision_manufacturing_outlined,
      colores: [Color(0xFF4F46A5), Color(0xFF7C3AED)],
      imagen: 'https://images.unsplash.com/photo-1567789884554-0b844b597180?auto=format&fit=crop&w=1500&q=92',
      detalle: ProgramaTecnico.supervisionProduccion,
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
    setState(() => selectedIndex = index);

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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            const FondoAppDifuminado(),
            Positioned.fill(
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) => SizedBox(
                      width: double.infinity,
                      child: _construirEncabezado(
                        ResponsiveLayout.isCompactLandscape(
                          constraints.maxWidth,
                          MediaQuery.sizeOf(context).height,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final screenSize = MediaQuery.sizeOf(context);
                        final compactLandscape =
                            ResponsiveLayout.isCompactLandscape(
                              screenSize.width,
                              screenSize.height,
                            );
                        final horizontalPadding =
                            constraints.maxWidth < 360 ? 12.0 : 18.0;
                        final rowSpacing = compactLandscape ? 12.0 : 18.0;
                        final verticalPadding = compactLandscape ? 10.0 : 18.0;
                        final hinge = ResponsiveLayout.verticalHinge(context);
                        final availableWidth =
                            constraints.maxWidth - horizontalPadding * 2;
                        final minimumThreeColumnWidth = compactLandscape
                            ? 750.0
                            : 1050.0;
                        final columns = hinge != null
                            ? 2
                            : availableWidth >= minimumThreeColumnWidth
                            ? 3
                            : availableWidth >= 720
                            ? 2
                            : 1;
                        final rows = (tecnicos.length / columns).ceil();
                        final minimumCardHeight = columns == 1 ? 120.0 : 140.0;
                        final availableCardHeight =
                            (constraints.maxHeight -
                                    verticalPadding * 2 -
                                    rowSpacing * (rows - 1)) /
                                rows;
                        final cardHeight = availableCardHeight
                            .clamp(minimumCardHeight, double.infinity)
                            .toDouble();

                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            verticalPadding,
                            horizontalPadding,
                            verticalPadding,
                          ),
                          child: ResponsiveCardGrid(
                            itemCount: tecnicos.length,
                            maxWidth: double.infinity,
                            cardHeight: cardHeight,
                            maxCardHeight: cardHeight,
                            spacing: rowSpacing,
                            threeColumnMinWidth: minimumThreeColumnWidth,
                            twoColumnMinWidth: 720,
                            maxColumns: 3,
                            itemBuilder: (context, index) =>
                                _construirTarjeta(tecnicos[index]),
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
      ),
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
            'Técnicos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Conoce nuestros técnicos y encuentra tu camino.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          SizedBox(height: compacto ? 0 : 16),
          if (!compacto)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.engineering_outlined, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Escuela de Ingeniería en Producción Industrial',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _construirTarjeta(_TecnicoData tecnico) {
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
                builder: (_) => TecnicoDetallePage(programa: tecnico.detalle),
              ),
            );
          },
          borderRadius: BorderRadius.circular(radio),
          child: Container(
            height: 178,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radio),
              gradient: LinearGradient(
                colors: tecnico.colores,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: tecnico.colores.first.withValues(alpha: 0.22),
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
                  // Imagen de fondo con transparencia.
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.68,
                      child: Image.network(
                        tecnico.imagen,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        alignment: Alignment.centerRight,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),

                  // Degradado para que la imagen se mezcle con los colores.
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            tecnico.colores.first.withValues(alpha: 0.82),
                            tecnico.colores.first.withValues(alpha: 0.58),
                            tecnico.colores.last.withValues(alpha: 0.16),
                          ],
                          stops: const [0.0, 0.38, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Capa de color suave sobre toda la fotografía.
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: tecnico.colores.first.withValues(alpha: 0.04),
                      ),
                    ),
                  ),

                  // Círculo decorativo.
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

                  // Icono, título y descripción.
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
                            tecnico.icono,
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
                                tecnico.titulo,
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
                                tecnico.descripcion,
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

                  // Botón circular con flecha.
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
    final size = MediaQuery.sizeOf(context);
    final wide = size.width >= 720;
    final compact = size.width > size.height && size.width < 720;

    return NavegacionGlass(
      selectedIndex: selectedIndex,
      onSelected: _seleccionarSeccion,
      wide: wide,
      compact: compact,
    );
  }
}

class _TecnicoData {
  final String titulo;
  final String descripcion;
  final IconData icono;
  final List<Color> colores;
  final String imagen;
  final ProgramaTecnico detalle;

  const _TecnicoData({
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.colores,
    required this.imagen,
    required this.detalle,
  });
}
