import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_theme.dart';
import 'calendario.dart';
import 'navegacion_glass.dart';
import 'notificaciones.dart';
import 'perfil.dart';
import 'responsive_layout.dart';

enum ProgramaTecnico {
  calidad,
  supervisionProduccion,
  logisticaInventarios,
}

class TecnicoDetallePage extends StatefulWidget {
  const TecnicoDetallePage({super.key, required this.programa});

  final ProgramaTecnico programa;

  @override
  State<TecnicoDetallePage> createState() => _TecnicoDetallePageState();
}

class _TecnicoDetallePageState extends State<TecnicoDetallePage>
    with SingleTickerProviderStateMixin {
  static const Color primaryNavy = Color(0xFF061424);
  static const Color deepBlue = Color(0xFF0D233A);
  static const Color accentBlue = Color(0xFF0EA5E9);
  static const List<Color> heroColors = [
    Color(0xFF0D7478),
    Color(0xFF075B68),
  ];

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  int selectedIndex = 0;

  _ProgramaTecnicoInfo get info => switch (widget.programa) {
        ProgramaTecnico.calidad => _ProgramaTecnicoInfo.calidad,
        ProgramaTecnico.supervisionProduccion =>
          _ProgramaTecnicoInfo.supervision,
        ProgramaTecnico.logisticaInventarios =>
          _ProgramaTecnicoInfo.logistica,
      };

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0.035),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          behavior: SnackBarBehavior.floating,
          backgroundColor: deepBlue,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  Future<void> _abrirEnlace(Uri uri) async {
    try {
      final abierto = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!abierto && mounted) {
        _mostrarMensaje(
          'No se pudo abrir el enlace en este dispositivo.',
        );
      }
    } catch (_) {
      if (mounted) {
        _mostrarMensaje(
          'No se pudo abrir el enlace en este dispositivo.',
        );
      }
    }
  }

  Future<void> _abrirWhatsApp({required bool agendarCita}) {
    const tipo = 'programa';
    final nombre = info.titulo;

    final mensaje = agendarCita
        ? 'Hola, quisiera agendar una cita con ${info.coordinacion} '
            'para recibir más información sobre el $tipo "$nombre".'
        : 'Hola, quisiera hacer una consulta sobre el $tipo '
            '"$nombre". ¿Podrían brindarme más información?';

    return _abrirEnlace(
      Uri.https('api.whatsapp.com', '/send', {
        'phone': info.telefonoWhatsApp,
        'text': mensaje,
      }),
    );
  }

  Future<void> _abrirInformacion() =>
      _abrirEnlace(Uri.parse(info.urlInformacion));

  Future<void> _abrirMatricula() {
    final url = info.urlMatricula;

    if (url == null) {
      _mostrarMensaje(
        'El enlace de matrícula está pendiente de agregar.',
      );
      return Future<void>.value();
    }

    return _abrirEnlace(Uri.parse(url));
  }

  void _abrirPerfil() {
    HapticFeedback.selectionClick();

    Navigator.of(context).push(
      appPageRoute<void>(
        builder: (_) => const PerfilPage(),
      ),
    );
  }

  void _abrirCalendario() {
    HapticFeedback.selectionClick();

    Navigator.of(context).push(
      appPageRoute<void>(
        builder: (_) => const CalendarioPage(),
      ),
    );
  }

  void _abrirAvisos() {
    HapticFeedback.selectionClick();

    Navigator.of(context).push(
      appPageRoute<void>(
        builder: (_) => NotificacionesScreen(
          onSectionSelected: (index) {
            if (!mounted) return;

            if (index == 0) {
              Navigator.of(context).popUntil(
                (route) => route.isFirst,
              );
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
        Navigator.of(context).popUntil(
          (route) => route.isFirst,
        );
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
    final screenSize = MediaQuery.sizeOf(context);

    final compactLandscape =
        screenSize.width > screenSize.height &&
        screenSize.height < 560;

    final horizontalInset = screenSize.width < 360 ? 14.0 : 18.0;

    final maxContentWidth =
        ResponsiveLayout.contentMaxWidth(screenSize.width);

    return DisplayFeatureSubScreen(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        extendBody: true,
        body: Stack(
          children: [
            const FondoAppDifuminado(),

            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalInset,
                            compactLandscape ? 10 : 16,
                            horizontalInset,
                            145,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final wide =
                                    constraints.maxWidth >= 960;

                                return Center(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: maxContentWidth,
                                    ),
                                    child: FadeTransition(
                                      opacity: _fadeAnimation,
                                      child: SlideTransition(
                                        position: _slideAnimation,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _construirHero(wide),

                                            SizedBox(
                                              height: compactLandscape
                                                  ? 22
                                                  : 30,
                                            ),

                                            if (wide) ...[
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      children: [
                                                        _construirDescripcion(),
                                                        if (info.experiencia != null) ...[
                                                          const SizedBox(height: 28),
                                                          _construirExperiencia(),
                                                        ],
                                                        const SizedBox(
                                                          height: 28,
                                                        ),
                                                        _construirCaracteristicas(),
                                                      ],
                                                    ),
                                                  ),

                                                  const SizedBox(width: 22),

                                                  Expanded(
                                                    child: Column(
                                                      children: [
                                                        _construirAreasFormacion(),
                                                        const SizedBox(
                                                          height: 28,
                                                        ),
                                                        _construirPerfil(),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ] else ...[
                                              _construirDescripcion(),

                                              if (info.experiencia != null) ...[
                                                const SizedBox(height: 29),
                                                _construirExperiencia(),
                                              ],

                                              const SizedBox(height: 29),

                                              _construirCaracteristicas(),

                                              const SizedBox(height: 29),

                                              _construirAreasFormacion(),

                                              const SizedBox(height: 29),

                                              _construirPerfil(),
                                            ],

                                            SizedBox(
                                              height: wide ? 22 : 29,
                                            ),

                                            _construirEnlaces(),

                                            const SizedBox(height: 16),

                                            _construirConsultas(),

                                            const SizedBox(height: 22),

                                            _construirPie(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: _construirNavegacionInferior(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirHero(bool wide) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: wide ? 350 : 300,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: heroColors.first.withValues(alpha: 0.24),
            blurRadius: 36,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: heroColors,
                  ),
                ),
              ),
            ),

            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: 0.9,
                  heightFactor: 1,
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (bounds) =>
                        const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        Color(0x66FFFFFF),
                        Color(0xE6FFFFFF),
                      ],
                      stops: [0, 0.22, 1],
                    ).createShader(bounds),
                    child: Opacity(
                      opacity: 0.94,
                      child: Image.network(
                        info.imagen,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        filterQuality: FilterQuality.high,
                        color: Colors.white.withValues(alpha: 0.58),
                        colorBlendMode: BlendMode.softLight,
                        semanticLabel:
                            'Fotografía relacionada con ${info.titulo}',
                        errorBuilder: (context, error, stackTrace) =>
                            const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF102A43),
                                Color(0xFF176B87),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
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
                      heroColors.first.withValues(alpha: 0.98),
                      heroColors.first.withValues(alpha: 0.86),
                      heroColors.last.withValues(alpha: 0.38),
                    ],
                    stops: const [0, 0.48, 1],
                  ),
                ),
              ),
            ),

            Positioned(
              top: -75,
              right: -30,
              child: Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10),
                    width: 1.3,
                  ),
                ),
              ),
            ),

            Positioned(
              top: -30,
              right: 55,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentBlue.withValues(alpha: 0.05),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: wide ? 30 : 22,
                vertical: wide ? 30 : 22,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: wide ? 7 : 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AppBackButton(
                              onDarkBackground: true,
                              onPressed: () =>
                                  Navigator.of(context).maybePop(),
                            ),

                            const SizedBox(width: 10),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(
                                  alpha: 0.14,
                                ),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withValues(
                                    alpha: 0.25,
                                  ),
                                ),
                              ),
                              child: Text(
                                'TÉCNICO ${info.numero} DE 3 · TÉCNICOS',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: wide ? 23 : 19),

                        Text(
                          info.titulo,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: wide ? 34 : 27,
                            fontWeight: FontWeight.w900,
                            height: 1.12,
                            letterSpacing: -0.7,
                          ),
                        ),

                        SizedBox(height: wide ? 16 : 13),

                        Text(
                          info.temasHero,
                          style: TextStyle(
                            color: const Color(0xFFD7F0FF),
                            fontSize: wide ? 14 : 12,
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                          ),
                        ),

                        SizedBox(height: wide ? 17 : 14),

                        Text(
                          'Escuela de Ingeniería en Producción Industrial con '
                          'más de 50 años de experiencia en investigación, '
                          'extensión y docencia',
                          style: TextStyle(
                            color: const Color(0xFFD7F0FF),
                            fontSize: wide ? 13 : 11,
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (wide)
                    const Expanded(
                      flex: 3,
                      child: SizedBox.shrink(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirDescripcion() {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tituloSeccion(
          'Descripción del programa',
          Icons.school_outlined,
        ),

        const SizedBox(height: 14),

        _tarjetaGlass(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  info.iconoObjetivo,
                  color: colors.onPrimaryContainer,
                  size: 23,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                info.resumen,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.65,
                ),
              ),

              if (info.descripcion != null) ...[
                const SizedBox(height: 12),

                Text(
                  info.descripcion!,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12.5,
                    height: 1.75,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _construirExperiencia() {
    if (info.experiencia == null) {
      return const SizedBox.shrink();
    }

    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tituloSeccion(
          'Experiencia del programa',
          Icons.history_edu_outlined,
        ),
        const SizedBox(height: 14),
        _tarjetaGlass(
          child: Text(
            info.experiencia!,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 13,
              height: 1.65,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirCaracteristicas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tituloSeccion(
          'Características',
          Icons.info_outline_rounded,
        ),

        const SizedBox(height: 14),

        _tarjetaGlass(
          child: Column(
            children: [
              if (info.duracion != null)
                _filaCaracteristica(
                  Icons.schedule_rounded,
                  'Duración',
                  info.duracion!,
                ),

              if (info.modalidad != null)
                _filaCaracteristica(
                  Icons.laptop_mac_outlined,
                  'Modalidad',
                  info.modalidad!,
                ),

              if (info.reconocimiento != null)
                _filaCaracteristica(
                  Icons.workspace_premium_outlined,
                  'Título / reconocimiento',
                  info.reconocimiento!,
                ),

              if (info.requisito != null)
                _filaCaracteristica(
                  Icons.fact_check_outlined,
                  'Requisito de ingreso',
                  info.requisito!,
                ),

              if (info.requisitoTecnologico != null)
                _filaCaracteristica(
                  Icons.devices_outlined,
                  'Requerimientos tecnológicos',
                  info.requisitoTecnologico!,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filaCaracteristica(
    IconData icono,
    String titulo,
    String valor,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icono,
            size: 19,
            color: colors.primary,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  valor,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirAreasFormacion() {
    return _tarjetaListado(
      titulo: info.tituloAreas,
      elementos: info.areas,
      icono: Icons.school_rounded,
    );
  }

  Widget _construirPerfil() {
    return _tarjetaListado(
      titulo: info.tituloPerfil,
      elementos: info.resultados,
      icono: Icons.work_outline_rounded,
    );
  }

  Widget _tarjetaListado({
    required String titulo,
    required List<String> elementos,
    required IconData icono,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tituloSeccion(
          titulo,
          icono,
        ),

        const SizedBox(height: 14),

        _tarjetaGlass(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < elementos.length; i++) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 27,
                      height: 27,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF0D929B),
                            Color(0xFF075B68),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        elementos[i],
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),

                if (i != elementos.length - 1)
                  const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _construirEnlaces() {
    return _tarjetaGlass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF087A86).withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.link_rounded,
                  color: Color(0xFF087A86),
                  size: 22,
                ),
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Text(
                  '¿Querés saber más?',
                  style: TextStyle(
                    color: Color(0xFF087A86),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          LayoutBuilder(
            builder: (context, constraints) {
              final informacion = _botonEnlace(
                'Ver información del técnico',
                const Color(0xFF142B55),
                _abrirInformacion,
              );

              final matricula = _botonEnlace(
                '¿Querés matricularte?',
                const Color(0xFF159447),
                _abrirMatricula,
              );

              if (constraints.maxWidth < 420) {
                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: informacion,
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: matricula,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: informacion),

                  const SizedBox(width: 10),

                  Expanded(child: matricula),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _botonEnlace(
    String texto,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color,
              Color.lerp(color, Colors.black, 0.16)!,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.20),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                texto,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            const SizedBox(width: 5),

            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirConsultas() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: primaryNavy.withValues(alpha: 0.15),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27),
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF164C70),
                      Color(0xFF0B263F),
                      Color(0xFF061424),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: -65,
              right: -45,
              child: _circuloDecorativo(
                size: 190,
                color: Colors.white.withValues(alpha: 0.045),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(21),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),

                  const SizedBox(height: 17),

                  const Text(
                    '¿Necesitás más información?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 9),

                  Text(
                    'Contactá por WhatsApp para hacer consultas o agendar '
                    'una cita con ${info.coordinacion} y recibir más información '
                    'sobre el programa ${info.titulo}.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.76),
                      fontSize: 12,
                      height: 1.75,
                    ),
                  ),

                  const SizedBox(height: 21),

                  _botonAccionGlass(
                    texto: 'Hacer una consulta por WhatsApp',
                    icono: Icons.chat_rounded,
                    principal: true,
                    onTap: () =>
                        _abrirWhatsApp(agendarCita: false),
                  ),

                  const SizedBox(height: 11),

                  _botonAccionGlass(
                    texto: 'Agendar una cita con coordinación',
                    icono: Icons.calendar_month_rounded,
                    principal: false,
                    onTap: () =>
                        _abrirWhatsApp(agendarCita: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botonAccionGlass({
    required String texto,
    required IconData icono,
    required bool principal,
    required VoidCallback onTap,
  }) {
    final foreground = principal ? deepBlue : Colors.white;

    return GelPress(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: 12,
            sigmaY: 12,
          ),
          child: Material(
            color: principal
                ? Colors.white
                : Colors.white.withValues(alpha: 0.08),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(
                  minHeight: 53,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: principal
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      icono,
                      color: foreground,
                      size: 20,
                    ),

                    const SizedBox(width: 11),

                    Expanded(
                      child: Text(
                        texto,
                        style: TextStyle(
                          color: foreground,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    Icon(
                      Icons.arrow_forward_rounded,
                      color: principal
                          ? deepBlue
                          : Colors.white.withValues(alpha: 0.75),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _circuloDecorativo({
    required double size,
    required Color color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _construirPie() {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        children: [
          Container(
            width: 42,
            height: 3,
            decoration: BoxDecoration(
              color: colors.outlineVariant,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(height: 13),

          Text(
            'TEC MÓVIL',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Tecnológico de Costa Rica',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tituloSeccion(
    String titulo,
    IconData icono,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: accentBlue.withValues(alpha: 0.08),
                blurRadius: 13,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icono,
            color: colors.onPrimaryContainer,
            size: 23,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.35,
                ),
              ),

            ],
          ),
        ),
      ],
    );
  }

  Widget _tarjetaGlass({required Widget child}) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: 15,
          sigmaY: 15,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh.withValues(
              alpha: dark ? 0.78 : 0.70,
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: colors.outlineVariant.withValues(
                alpha: dark ? 0.72 : 0.68,
              ),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: (dark ? Colors.black : primaryNavy).withValues(
                  alpha: dark ? 0.20 : 0.08,
                ),
                blurRadius: 26,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _construirNavegacionInferior() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ancho = constraints.maxWidth;
        final alto = constraints.maxHeight;

        return NavegacionGlass(
          selectedIndex: selectedIndex,
          onSelected: _seleccionarSeccion,
          wide: ancho >= 720,
          compact: ancho > alto && ancho < 720,
        );
      },
    );
  }
}

class _ProgramaTecnicoInfo {
  final int numero;
  final String titulo;
  final String coordinacion;
  final String telefonoWhatsApp;
  final String temasHero;
  final String urlInformacion;
  final String? urlMatricula;
  final String resumen;
  final String? descripcion;
  final String? experiencia;
  final String tituloAreas;
  final String tituloPerfil;
  final String? duracion;
  final String? modalidad;
  final String? requisito;
  final String? reconocimiento;
  final String? requisitoTecnologico;
  final String imagen;
  final IconData iconoObjetivo;
  final List<String> areas;
  final List<String> resultados;

  const _ProgramaTecnicoInfo({
    required this.numero,
    required this.titulo,
    required this.coordinacion,
    required this.telefonoWhatsApp,
    required this.temasHero,
    required this.urlInformacion,
    this.urlMatricula,
    required this.resumen,
    this.descripcion,
    this.experiencia,
    required this.tituloAreas,
    required this.tituloPerfil,
    this.duracion,
    this.modalidad,
    this.requisito,
    this.reconocimiento,
    this.requisitoTecnologico,
    required this.imagen,
    required this.iconoObjetivo,
    required this.areas,
    required this.resultados,
  });

  // Nombres e información de cada técnico.

  static const calidad = _ProgramaTecnicoInfo(
    numero: 1,
    titulo: 'Técnico en Calidad',
    coordinacion: 'la Coordinación de Técnicos',
    telefonoWhatsApp: '+506 8607 0110',
    temasHero:
        'Programas de alto valor y demanda a nivel nacional e internacional',
    resumen:
        'Un programa alineado al Marco Nacional de Cualificaciones.',
    experiencia:
        'Ha formado profesionales de alta demanda en el país, tanto en el sector servicios como de manufactura.',
    descripcion:
        'Formar profesionales líderes a nivel técnico que cumplan con el sistema de gestión de calidad establecido por la organización que trabajen en equipo en la detección y análisis de problemas de calidad, así como en la creación de soluciones fundamentadas en datos aplicando, para ello, diversos conceptos, métodos y herramientas que les permita el logro del mejoramiento continuo de la calidad en sus organizaciones.',
    tituloAreas: 'Áreas y Ejes del programa',
    tituloPerfil: 'Propósitos Específicos',
    duracion: '1 año + 3 meses',
    modalidad: 'Virtual',
    requisito: 'Noveno año aprobado o bachillerato',
    reconocimiento: 'Título universitario de Técnico en Calidad',
    requisitoTecnologico:
        'Computadora, conexión a Internet estable y paquete de Office',
    urlInformacion: 'https://www.tec.ac.cr/tecnico-calidad',
    urlMatricula:
        'https://tienda.fundatec.ac.cr/detail/calidad/B1B48AA6-D73C-4833-B0BD-7AC4C2A3C575/2D9CA29B-0BC5-4038-829E-2D3DF76AA1C4',
    imagen:
        'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?auto=format&fit=crop&w=1600&q=85',
    iconoObjetivo: Icons.verified_outlined,
    areas: [
      'Control Estadístico de la Calidad',
      'Documentación y Normalización',
      'Metrología',
      'Mejoramiento Continuo de la Calidad',
      'Trabajo Colaborativo, Liderazgo, Comunicación Asertiva, Ética y '
          'Aprendizaje Basado en la Solución de Problemas',
    ],
    resultados: [
      'Dirigir o liderar equipos de resolución de problemas de calidad que '
          'utilizan metodologías Lean y Seis Sigma.',
      'Aplicar herramientas básicas y modernas de la calidad para la '
          'identificación y priorización de las causas de problemas relativos '
          'a la calidad.',
      'Proponer proyectos que permitan la mejora continua y la satisfacción del cliente.',
      'Contribuir al desarrollo de auditorías internas de calidad cumpliendo '
          'los principios de auditoría.',
      'Aplicar conceptos del control estadístico de la calidad para la '
          'evaluación y mejora de los procesos de producción y de desarrollo '
          'de servicios.',
    ],
  );

  static const supervision = _ProgramaTecnicoInfo(
    numero: 3,
    titulo: 'Técnico en Supervisión de Producción',
    coordinacion: 'la Coordinación de Técnicos',
    telefonoWhatsApp: '+506 8607 0110',
    temasHero:
        'Programas de alto valor y demanda a nivel nacional e internacional',
    resumen:
        'Un programa de alto nivel y demanda en servicios y producción con enfoque en procesos.',
    experiencia:
        'El programa tiene más de 25 años de experiencia en la formación de supervisores de producción, en más de 150 empresas de Costa Rica.',
    descripcion:
        'La formación que se brinda abarca áreas técnicas y administrativas, tales como la planeación y control de la producción, estudio del trabajo, calidad, liderazgo y recursos humanos.',
    tituloAreas: 'Áreas de formación',
    tituloPerfil: 'Perfil profesional',
    duracion: '1 año + 2 meses',
    modalidad: 'Virtual',
    requisito: 'Noveno año aprobado o bachillerato',
    reconocimiento:
        'Título universitario de Técnico en Supervisión de Producción al finalizar los 12 cursos y el proyecto de graduación',
    requisitoTecnologico:
        'Computadora y conexión a Internet estable',
    urlInformacion:
        'https://www.tec.ac.cr/tecnico-supervision-produccion',
    urlMatricula: 'https://www.tec.ac.cr/tecnico-supervision-produccion/matricula',
    imagen:
        'https://images.unsplash.com/photo-1567789884554-0b844b597180?auto=format&fit=crop&w=1600&q=85',
    iconoObjetivo: Icons.precision_manufacturing_outlined,
    areas: [
      'Planeación y control de la producción',
      'Estudio del trabajo',
      'Calidad',
      'Liderazgo y recursos humanos',
      'Metrología, costos y programación de producción',
    ],
    resultados: [
      'Estudios de métodos de trabajo y de determinación de tiempos estándar, '
          'de acuerdo con normas internacionales.',
      'Organizar y dirigir la inspección y el control de calidad de materiales '
          'y producto.',
      'Análisis metrológico.',
      'Apoyar el planeamiento y la programación de la producción.',
      'Coordinar los recursos materiales, humanos y de maquinaria requeridos '
          'para ejecutar la producción.',
      'Dirigir el proceso de producción.',
      'Dirigir al personal de producción hacia el cumplimiento de los objetivos '
          'de producción y de calidad.',
      'Organizar grupos para la solución de problemas y trabajo en equipo.',
      'Calcular costos de producción de los artículos manufacturados.',
      'Planear y ejecutar proyectos de reducción de costos, mejora de métodos '
          'y solución de problemas de calidad.',
    ],
  );

  static const logistica = _ProgramaTecnicoInfo(
    numero: 2,
    titulo: 'Técnico en Logística e Inventarios',
    coordinacion: 'la Coordinación de Logística e Inventarios',
    telefonoWhatsApp: '+506 8405 2075',
    temasHero:
        'Programas de alto valor y demanda a nivel nacional e internacional',
    resumen:
        'El programa está dirigido a personas que tengan a su cargo labores relacionadas con la logística y los inventarios de la empresa y que deseen desempeñar cargos de mandos medios en empresas de bienes o servicios.',
    tituloAreas: 'Cursos del programa',
    tituloPerfil: 'Perfil profesional',
    duracion:
        '24 horas por curso (6 lecciones distribuidas en 4 semanas). Se habilitan diferentes cursos cada mes.',
    reconocimiento:
        'Certificado de aprovechamiento por curso. No tiene créditos universitarios ni es reconocido para matricularse posteriormente en una carrera del TEC.',
    requisito: 'Copia del último título obtenido (mínimo noveno año)',
    urlInformacion:
        'https://www.tec.ac.cr/tecnico-logistica-inventarios',
    urlMatricula:'https://www.tec.ac.cr/tecnico-logistica-inventarios/matricula',
    imagen:
        'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&w=1600&q=85',
    iconoObjetivo: Icons.inventory_2_outlined,
    areas: [
      'Introducción a la Logística',
      'Administración de Bodegas e Inventarios I',
      'Administración del Transporte',
      'Administración de Bodegas e Inventarios II',
      'Infraestructura de Almacenes',
      'Matemática',
      'Costos Logísticos',
      'Estadística',
      'Planificación de la Producción y de Servicios',
      'Liderazgo y Gestión de Equipos en el Área Logística',
      'Administración de Abastecimiento y Compras',
      'Inventarios y Modelos de Pronósticos',
    ],
    resultados: [
      'Técnicas para la clasificación de los inventarios.',
      'Análisis de la rotación de los inventarios.',
      'Evaluación de indicadores de la exactitud y precisión de los inventarios.',
      'El estudiante tendrá una visión integradora de las actividades '
          'relacionadas con las formas de planificar, organizar, controlar y '
          'mejorar las diferentes operaciones de manufactura dentro de una '
          'planta.',
      'Aplicar los factores estratégicos de abastecimiento en las diferentes '
          'etapas del proceso comercial, permitiendo cumplir eficazmente con '
          'los compromisos adquiridos con los clientes y analizar la logística '
          'de los procesos operativos de la empresa ofreciendo técnicas '
          'prácticas para la adecuada optimización de la logística en la '
          'operación de los almacenes.',
    ],
  );
}
