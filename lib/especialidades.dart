import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_theme.dart';
import 'calendario.dart';
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

  final List<_EspecialidadData> _especialidades = [
    _EspecialidadData(
      titulo: 'Auditoría de calidad',
      categoria: 'Especialización',
      descripcion:
          'Evalúa si lo pactado se cumple y revisa que los procedimientos '
          'reúnan las condiciones documentadas y los criterios de calidad.',
      icono: Icons.fact_check_outlined,
      colores: const [Color(0xFF162D3D), Color(0xFF247B87)],
      imagen: 'https://images.unsplash.com/photo-1581092921461-eab62e97a780?auto=format&fit=crop&w=1200&q=85',
    ),
    _EspecialidadData(
      titulo: 'Estadística Experimental',
      categoria: 'Especialización',
      descripcion:
          'Analiza datos en bruto para obtener conclusiones y apoyar mejores '
          'decisiones empresariales en distintas industrias.',
      icono: Icons.query_stats_rounded,
      colores: const [Color(0xFF28345E), Color(0xFF6656A6)],
      imagen: 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?auto=format&fit=crop&w=1200&q=85',
    ),
    _EspecialidadData(
      titulo: 'Seis Sigma Yellow Belt',
      categoria: 'Especialización',
      descripcion:
          'Utiliza herramientas estadísticas para reducir la variabilidad '
          'de los procesos y dar prioridad a los requisitos de los clientes.',
      icono: Icons.auto_graph_rounded,
      colores: const [Color(0xFF123B59), Color(0xFF167D9A)],
      imagen: 'https://images.unsplash.com/photo-1521737711867-e3b97375f902?auto=format&fit=crop&w=1200&q=85',
    ),
    _EspecialidadData(
      titulo: 'Servicio al cliente',
      categoria: 'Especialización',
      descripcion:
          'Desarrolla la capacidad de convertir las quejas y sugerencias de '
          'las personas usuarias en conocimiento útil para la organización.',
      icono: Icons.support_agent_rounded,
      colores: const [Color(0xFF17365D), Color(0xFF3979B9)],
      imagen: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=1200&q=85',
    ),
    _EspecialidadData(
      titulo: 'Metrología',
      categoria: 'Especialización',
      descripcion:
          'Aplica conceptos de la teoría de la medición esenciales para '
          'desarrollar un sistema metrológico eficiente y efectivo.',
      icono: Icons.precision_manufacturing_outlined,
      colores: const [Color(0xFF183344), Color(0xFF347F8C)],
      imagen: 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&w=1200&q=85',
    ),
  ];

  void _abrirPerfil() {
    HapticFeedback.selectionClick();

    Navigator.of(context)
        .push(appPageRoute<void>(builder: (_) => const PerfilPage()));
  }

  void _abrirCalendario() {
    HapticFeedback.selectionClick();

    Navigator.of(context)
        .push(appPageRoute<void>(builder: (_) => const CalendarioPage()));
  }

  void _abrirAvisos() {
    HapticFeedback.selectionClick();

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

  void _mostrarDetalles(_EspecialidadData especialidad) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      appPageRoute<void>(
        builder: (_) => _EspecialidadDetallePage(especialidad: especialidad),
      ),
    );
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
                        final size = MediaQuery.sizeOf(context);
                        final landscape = ResponsiveLayout.isCompactLandscape(
                          size.width,
                          size.height,
                        );
                        final horizontalPadding = constraints.maxWidth < 360
                            ? 12.0
                            : 18.0;
                        final spacing = landscape ? 12.0 : 18.0;
                        final verticalPadding = landscape ? 10.0 : 18.0;
                        final hinge = ResponsiveLayout.verticalHinge(context);
                        final gridWidth =
                            constraints.maxWidth - horizontalPadding * 2;
                        final threeColumnMinWidth = landscape ? 750.0 : 1050.0;
                        final columns = hinge != null
                            ? 2
                            : gridWidth >= threeColumnMinWidth
                            ? 3
                            : gridWidth >= 720
                            ? 2
                            : 1;
                        final rows = (_especialidades.length / columns).ceil();
                        final minimumCardHeight = columns == 1 ? 136.0 : 148.0;
                        final availableHeight =
                            (constraints.maxHeight -
                                verticalPadding * 2 -
                                spacing * (rows - 1)) /
                            rows;
                        final cardHeight = availableHeight
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
                            itemCount: _especialidades.length,
                            maxWidth: double.infinity,
                            cardHeight: cardHeight,
                            maxCardHeight: cardHeight,
                            spacing: spacing,
                            threeColumnMinWidth: threeColumnMinWidth,
                            twoColumnMinWidth: 720,
                            maxColumns: 3,
                            itemBuilder: (context, index) =>
                                _construirTarjeta(_especialidades[index]),
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
            'Especialidades',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Conoce la oferta de especialidades industriales del TEC.',
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
                  Icon(
                    Icons.engineering_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
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

  Widget _construirTarjeta(_EspecialidadData especialidad) {
    const radio = 25.0;

    return GelPress(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radio),
        child: InkWell(
          onTap: () => _mostrarDetalles(especialidad),
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
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: especialidad.colores.first.withValues(
                          alpha: 0.04,
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
                    padding: const EdgeInsets.fromLTRB(12, 12, 44, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Icon(
                            especialidad.icono,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 10),
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
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  height: 1.18,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                especialidad.descripcion,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10.5,
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

class _EspecialidadDetallePage extends StatefulWidget {
  final _EspecialidadData especialidad;

  const _EspecialidadDetallePage({required this.especialidad});

  @override
  State<_EspecialidadDetallePage> createState() =>
      _EspecialidadDetallePageState();
}

class _EspecialidadDetallePageState extends State<_EspecialidadDetallePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late final AnimationController _entradaController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _entradaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _fade = CurvedAnimation(
      parent: _entradaController,
      curve: Curves.easeOutCubic,
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.035),
      end: Offset.zero,
    ).animate(_fade);
    _entradaController.forward();
  }

  @override
  void dispose() {
    _entradaController.dispose();
    super.dispose();
  }

  void _abrirPerfil() {
    Navigator.of(context)
        .push(appPageRoute<void>(builder: (_) => const PerfilPage()));
  }

  void _abrirCalendario() {
    Navigator.of(context)
        .push(appPageRoute<void>(builder: (_) => const CalendarioPage()));
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
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    setState(() => _selectedIndex = index);
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
    final screenSize = MediaQuery.sizeOf(context);
    final compactLandscape = ResponsiveLayout.isCompactLandscape(
      screenSize.width,
      screenSize.height,
    );
    final wide = screenSize.width >= 900;
    final horizontalInset = screenSize.width < 360 ? 14.0 : 18.0;
    final maxWidth = ResponsiveLayout.contentMaxWidth(screenSize.width);
    final especialidad = widget.especialidad;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          const FondoAppDifuminado(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalInset,
                            compactLandscape ? 10 : 16,
                            horizontalInset,
                            24,
                          ),
                          child: FadeTransition(
                            opacity: _fade,
                            child: SlideTransition(
                              position: _slide,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _construirHero(
                                    especialidad,
                                    wide: wide,
                                    compactLandscape: compactLandscape,
                                  ),
                                  SizedBox(height: compactLandscape ? 18 : 26),
                                  if (wide)
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 6,
                                          child: _tarjetaInformacion(
                                            icono: Icons.school_outlined,
                                            titulo: 'Información de la especialidad',
                                            contenido: Text(
                                              especialidad.descripcion,
                                              style: _textoDetalle(context),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          flex: 4,
                                          child: Column(
                                            children: [
                                              _tarjetaInformacion(
                                                icono: Icons.category_outlined,
                                                titulo: 'Tipo de oferta',
                                                contenido: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: _etiqueta(
                                                    context,
                                                    especialidad.categoria,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              _tarjetaAviso(context),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  else ...[
                                    _tarjetaInformacion(
                                      icono: Icons.school_outlined,
                                      titulo: 'Información de la especialidad',
                                      contenido: Text(
                                        especialidad.descripcion,
                                        style: _textoDetalle(context),
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    _tarjetaInformacion(
                                      icono: Icons.category_outlined,
                                      titulo: 'Tipo de oferta',
                                      contenido: Align(
                                        alignment: Alignment.centerLeft,
                                        child: _etiqueta(
                                          context,
                                          especialidad.categoria,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    _tarjetaAviso(context),
                                  ],
                                  const SizedBox(height: 22),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: OutlinedButton.icon(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      icon: const Icon(
                                        Icons.arrow_back_rounded,
                                      ),
                                      label: const Text(
                                        'Volver a todas las especialidades',
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
                NavegacionGlass(
                  selectedIndex: _selectedIndex,
                  onSelected: _seleccionarSeccion,
                  wide: screenSize.width >= 720,
                  compact: compactLandscape,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirHero(
    _EspecialidadData especialidad, {
    required bool wide,
    required bool compactLandscape,
  }) {
    final heroHeight = compactLandscape
        ? 190.0
        : wide
        ? 300.0
        : 255.0;

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              especialidad.imagen,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: especialidad.colores),
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFF061424).withValues(alpha: 0.94),
                    const Color(0xFF061424).withValues(alpha: 0.64),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.62, 1],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(compactLandscape ? 14 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      AppBackButton(
                        onDarkBackground: true,
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const Spacer(),
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.28),
                          ),
                        ),
                        child: Icon(especialidad.icono, color: Colors.white),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ESPECIALIDAD INDUSTRIAL',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.3,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        especialidad.titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: wide
                              ? 34
                              : compactLandscape
                              ? 24
                              : 29,
                          height: 1.12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaInformacion({
    required IconData icono,
    required String titulo,
    required Widget contenido,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF061424).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: colors.primary, size: 21),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          contenido,
        ],
      ),
    );
  }

  Widget _tarjetaAviso(BuildContext context) {
    return _tarjetaInformacion(
      icono: Icons.info_outline_rounded,
      titulo: 'Información oficial',
      contenido: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'El TEC anuncia un 15% de descuento en cada materia al matricular '
            'y el inicio de lecciones de las especialidades a partir de '
            'noviembre de 2026. Confirma fechas, requisitos y modalidad en '
            'la página oficial antes de matricular.',
            style: _textoDetalle(context),
          ),
          const SizedBox(height: 10),
          Text(
            'Contacto: tecproducalidad@fundatec.ac.cr',
            style: _textoDetalle(context),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _abrirSitioOficial,
              icon: const Icon(Icons.open_in_new_rounded, size: 17),
              label: const Text('Consultar oferta oficial'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirSitioOficial() async {
    final uri = Uri.https('www.tec.ac.cr', '/cursos-libres-especialidades');
    try {
      final abierto = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!abierto && mounted) {
        _mostrarMensaje('No se pudo abrir el sitio oficial del TEC.');
      }
    } catch (_) {
      if (mounted) {
        _mostrarMensaje('No se pudo abrir el sitio oficial del TEC.');
      }
    }
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  Widget _etiqueta(BuildContext context, String categoria) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        categoria,
        style: TextStyle(
          color: colors.primary,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  TextStyle _textoDetalle(BuildContext context) => TextStyle(
    color: Theme.of(context).colorScheme.onSurfaceVariant,
    fontSize: 14,
    height: 1.75,
  );
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
