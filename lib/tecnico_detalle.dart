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

enum ProgramaTecnico { calidad, supervisionProduccion, logisticaInventarios }

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

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  int selectedIndex = 0;

  _ProgramaTecnicoInfo get info => switch (widget.programa) {
    ProgramaTecnico.calidad => _ProgramaTecnicoInfo.calidad,
    ProgramaTecnico.supervisionProduccion => _ProgramaTecnicoInfo.supervision,
    ProgramaTecnico.logisticaInventarios => _ProgramaTecnicoInfo.logistica,
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
        Tween<Offset>(begin: const Offset(0, 0.035), end: Offset.zero).animate(
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
        _mostrarMensaje('No se pudo abrir el enlace en este dispositivo.');
      }
    } catch (_) {
      if (mounted) {
        _mostrarMensaje('No se pudo abrir el enlace en este dispositivo.');
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final compactLandscape =
        screenSize.width > screenSize.height && screenSize.height < 560;
    final horizontalInset = screenSize.width < 360 ? 14.0 : 18.0;
    final maxContentWidth = ResponsiveLayout.contentMaxWidth(screenSize.width);

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
                                final wide = constraints.maxWidth >= 980;
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
                                                        const SizedBox(
                                                          height: 28,
                                                        ),
                                                        _construirCampoLaboral(),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 22),
                                                  Expanded(
                                                    child: Column(
                                                      children: [
                                                        _construirDatosBasicos(),
                                                        const SizedBox(
                                                          height: 28,
                                                        ),
                                                        _construirConsultas(),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ] else ...[
                                              _construirDescripcion(),
                                              const SizedBox(height: 29),
                                              _construirDatosBasicos(),
                                              const SizedBox(height: 29),
                                              _construirCampoLaboral(),
                                              const SizedBox(height: 29),
                                              _construirConsultas(),
                                            ],
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
      constraints: BoxConstraints(minHeight: wide ? 320 : 268),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: primaryNavy.withValues(alpha: 0.24),
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
                    colors: [Color(0xFF061424), Color(0xFF123D60)],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: wide ? 0.58 : 0.60,
                  heightFactor: 1,
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (bounds) => const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        Color(0xCCFFFFFF),
                        Colors.white,
                      ],
                      stops: [0, 0.24, 0.62],
                    ).createShader(bounds),
                    child: Opacity(
                      opacity: 0.94,
                      child: Image.network(
                        info.imagen,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        filterQuality: FilterQuality.high,
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
                      primaryNavy.withValues(alpha: 0.82),
                      primaryNavy.withValues(alpha: 0.62),
                      deepBlue.withValues(alpha: 0.12),
                    ],
                    stops: const [0, 0.46, 1],
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
            if (wide)
              Positioned(
                right: 20,
                bottom: 20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: primaryNavy.withValues(alpha: 0.46),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.24),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            info.iconoObjetivo,
                            color: const Color(0xFFBAE6FD),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            info.distintivo,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: wide ? 30 : 20,
                vertical: wide ? 28 : 20,
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
                              onPressed: () => Navigator.of(context).maybePop(),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.20),
                                ),
                              ),
                              child: const Text(
                                'TÉCNICO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: wide ? 16 : 14),
                        Text(
                          info.titulo,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: wide ? 30 : 22,
                            fontWeight: FontWeight.w900,
                            height: 1.12,
                            letterSpacing: -0.7,
                          ),
                        ),
                        SizedBox(height: wide ? 12 : 9),
                        Text(
                          info.temasHero,
                          style: TextStyle(
                            color: const Color(0xFFD7F0FF),
                            fontSize: wide ? 13 : 11,
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: wide ? 18 : 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 13,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.22),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.trending_up_rounded,
                                    color: Color(0xFF7DD3FC),
                                    size: 17,
                                  ),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Conocé tu futuro profesional',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (wide) const Expanded(flex: 3, child: SizedBox.shrink()),
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
          info.subtituloDescripcion,
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
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                info.descripcion,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 12.5,
                  height: 1.85,
                ),
              ),
              const SizedBox(height: 17),
              Divider(color: colors.outlineVariant, height: 1),
              const SizedBox(height: 15),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: info.areas
                    .take(4)
                    .map(
                      (area) => _EtiquetaTemaTecnico(
                        icono: info.iconoObjetivo,
                        texto: area,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _construirDatosBasicos() {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tituloSeccion(
          'Características',
          'Datos principales de la institución y el programa',
          Icons.info_outline_rounded,
        ),
        const SizedBox(height: 14),
        _tarjetaGlass(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 47,
                    height: 47,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE2F3FD), Color(0xFFDCE7FF)],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.account_balance_outlined,
                      color: Color(0xFF1476A5),
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tecnológico de Costa Rica',
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Escuela de Ingeniería en Producción Industrial',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 10.5,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 19),
              Divider(height: 1, color: colors.outlineVariant),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _datoBasico(
                      Icons.schedule_rounded,
                      'Duración',
                      info.duracion,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _datoBasico(
                      Icons.laptop_mac_outlined,
                      'Modalidad',
                      info.modalidad,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _tarjetaInformacionAdicional(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tarjetaInformacionAdicional() {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh.withValues(
          alpha: dark ? 0.78 : 0.66,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: colors.primary, size: 19),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'La oferta, los requisitos y las fechas pueden actualizarse. Consulta el sitio oficial del TEC.',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                    height: 1.65,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Divider(color: colors.outlineVariant, height: 1),
          const SizedBox(height: 13),
          _filaInformacion(
            Icons.workspace_premium_outlined,
            'Título / reconocimiento',
            info.reconocimiento,
          ),
          const SizedBox(height: 12),
          _filaInformacion(
            Icons.fact_check_outlined,
            'Requisito de ingreso',
            info.requisito,
          ),
          if (info.requisitoTecnologico != null) ...[
            const SizedBox(height: 12),
            _filaInformacion(
              Icons.devices_outlined,
              'Requerimiento tecnológico',
              info.requisitoTecnologico!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _filaInformacion(IconData icono, String titulo, String valor) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 18, color: colors.primary),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11),
              ),
              const SizedBox(height: 3),
              Text(
                valor,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _datoBasico(IconData icono, String titulo, String valor) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(minHeight: 133),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh.withValues(
          alpha: dark ? 0.78 : 0.66,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icono, color: colors.onPrimaryContainer, size: 19),
          ),
          const SizedBox(height: 12),
          Text(
            titulo,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            valor,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirCampoLaboral() {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tituloSeccion(
          'Campo laboral',
          'Áreas en las que podés desarrollarte',
          Icons.work_outline_rounded,
        ),
        const SizedBox(height: 14),
        _tarjetaGlass(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info.resultadosIntro,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 11.5,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              ...info.resultados.asMap().entries.map((entry) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: entry.key == info.resultados.length - 1 ? 0 : 10,
                  ),
                  child: _filaCampoLaboral(
                    _CampoTecnicoData(entry.value, _iconoResultado(entry.key)),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  IconData _iconoResultado(int index) {
    const iconos = [
      Icons.fact_check_outlined,
      Icons.groups_outlined,
      Icons.analytics_outlined,
      Icons.trending_up_rounded,
    ];
    return iconos[index % iconos.length];
  }

  Widget _filaCampoLaboral(_CampoTecnicoData area) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh.withValues(
          alpha: dark ? 0.76 : 0.62,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(area.icono, color: colors.onPrimaryContainer, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              area.titulo,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: colors.onSurfaceVariant,
            size: 13,
          ),
        ],
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
                    'Contactá por WhatsApp para hacer '
                    'consultas o agenda una cita a ${info.coordinacion} y recibir más información '
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
                    onTap: () => _abrirWhatsApp(agendarCita: false),
                  ),
                  const SizedBox(height: 11),
                  _botonAccionGlass(
                    texto: 'Agendar una cita con coordinación',
                    icono: Icons.calendar_month_rounded,
                    principal: false,
                    onTap: () => _abrirWhatsApp(agendarCita: true),
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
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            color: principal
                ? Colors.white
                : Colors.white.withValues(alpha: 0.08),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 53),
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
                    Icon(icono, color: foreground, size: 20),
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

  Widget _circuloDecorativo({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
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
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _tituloSeccion(String titulo, String subtitulo, IconData icono) {
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
          child: Icon(icono, color: colors.onPrimaryContainer, size: 23),
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
              const SizedBox(height: 4),
              Text(
                subtitulo,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 10.5,
                  height: 1.45,
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
        filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
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
  final String titulo;
  final String coordinacion;
  final String telefonoWhatsApp;
  final String temasHero;
  final String distintivo;
  final String resumen;
  final String subtituloDescripcion;
  final String descripcion;
  final String duracion;
  final String modalidad;
  final String requisito;
  final String reconocimiento;
  final String? requisitoTecnologico;
  final String resultadosIntro;
  final String imagen;
  final IconData iconoObjetivo;
  final List<String> areas;
  final List<String> resultados;

  const _ProgramaTecnicoInfo({
    required this.titulo,
    required this.coordinacion,
    required this.telefonoWhatsApp,
    required this.temasHero,
    required this.distintivo,
    required this.resumen,
    required this.subtituloDescripcion,
    required this.descripcion,
    required this.duracion,
    required this.modalidad,
    required this.requisito,
    required this.reconocimiento,
    this.requisitoTecnologico,
    required this.resultadosIntro,
    required this.imagen,
    required this.iconoObjetivo,
    required this.areas,
    required this.resultados,
  });

  static const calidad = _ProgramaTecnicoInfo(
    titulo: 'Técnico en Calidad',
    coordinacion: 'la Coordinación de Técnicos',
    telefonoWhatsApp: '50686070110',
    temasHero: 'Calidad · Metrología · Mejora continua',
    distintivo: 'Gestión de calidad',
    resumen:
        'Mejorá continuamente la calidad de productos, servicios y procesos',
    subtituloDescripcion: 'Conocé el enfoque del programa',
    descripcion: 'El programa forma líderes técnicos para trabajar en sistemas de gestión de calidad, detectar y analizar problemas, y proponer soluciones basadas en datos en organizaciones públicas y privadas.',
    duracion: '1 año y 3 meses',
    modalidad: 'Virtual o presencial',
    requisito: 'III ciclo aprobado',
    reconocimiento: 'Título universitario de Técnico en Calidad',
    requisitoTecnologico: 'Computadora y conexión estable a internet',
    resultadosIntro: 'Podrás aportar en la gestión y mejora de la calidad mediante tareas como:',
    imagen: 'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?auto=format&fit=crop&w=1600&q=85',
    iconoObjetivo: Icons.verified_outlined,
    areas: [
      'Control estadístico de la calidad',
      'Documentación y normalización',
      'Metrología y sistemas de medición',
      'Mejoramiento continuo de la calidad',
      'Trabajo colaborativo, liderazgo y comunicación asertiva',
    ],
    resultados: [
      'Aplicar herramientas de calidad para identificar y priorizar causas de problemas.',
      'Apoyar auditorías internas y verificar estándares de calidad.',
      'Usar conceptos estadísticos y metrológicos para analizar procesos.',
      'Proponer proyectos de mejora continua y satisfacción del cliente.',
    ],
  );

  static const supervision = _ProgramaTecnicoInfo(
    titulo: 'Técnico en Supervisión de Producción',
    coordinacion: 'la Coordinación de Técnicos',
    telefonoWhatsApp: '50686070110',
    temasHero: 'Producción · Liderazgo · Calidad',
    distintivo: 'Producción industrial',
    resumen: 'Coordiná personas, recursos y procesos de producción',
    subtituloDescripcion: 'Conocé el enfoque del programa',
    descripcion: 'La formación técnica y administrativa prepara a jefes, supervisores y líderes de procesos para asumir puestos de mando medio en empresas de manufactura y servicios.',
    duracion: '1 año y 2 meses',
    modalidad: 'Virtual',
    requisito: 'Noveno año aprobado o bachillerato',
    reconocimiento:
        'Título universitario de Técnico en Supervisión de Producción',
    requisitoTecnologico: 'Computadora y conexión estable a internet',
    resultadosIntro: 'Podrás contribuir a la coordinación y dirección de las operaciones mediante tareas como:',
    imagen: 'https://images.unsplash.com/photo-1567789884554-0b844b597180?auto=format&fit=crop&w=1600&q=85',
    iconoObjetivo: Icons.precision_manufacturing_outlined,
    areas: [
      'Planeación y control de la producción',
      'Estudio del trabajo y tiempos estándar',
      'Control y administración de la calidad',
      'Liderazgo y administración de recursos humanos',
      'Metrología, costos y programación de producción',
    ],
    resultados: [
      'Coordinar recursos materiales, humanos y de maquinaria.',
      'Dirigir personal hacia los objetivos de producción y calidad.',
      'Organizar inspecciones y controles de calidad.',
      'Planear proyectos de reducción de costos y mejora de métodos.',
    ],
  );

  static const logistica = _ProgramaTecnicoInfo(
    titulo: 'Técnico en Logística e Inventarios',
    coordinacion: 'la Coordinación de Logística e Inventarios',
    telefonoWhatsApp: '50684052075',
    temasHero: 'Logística · Inventarios · Abastecimiento',
    distintivo: 'Logística empresarial',
    resumen: 'Optimizá el flujo de productos, almacenes e inventarios',
    subtituloDescripcion: 'Conocé el enfoque del programa',
    descripcion: 'Programa dirigido a personas que trabajan con logística e inventarios y desean desarrollar habilidades para coordinar operaciones en empresas de bienes y servicios.',
    duracion: '24 horas por curso',
    modalidad: 'Virtual',
    requisito: 'Noveno año aprobado',
    reconocimiento: 'Programa de capacitación sin créditos universitarios',
    resultadosIntro: 'Podrás apoyar las operaciones de logística e inventarios mediante tareas como:',
    imagen: 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&w=1600&q=85',
    iconoObjetivo: Icons.inventory_2_outlined,
    areas: [
      'Introducción a la logística',
      'Administración de bodegas e inventarios',
      'Transporte, abastecimiento y compras',
      'Inventarios y modelos de pronósticos',
    ],
    resultados: [
      'Clasificar inventarios y analizar su rotación.',
      'Evaluar indicadores de exactitud y precisión de inventarios.',
      'Planificar, organizar y mejorar operaciones de almacén.',
      'Apoyar el abastecimiento y la logística de operaciones.',
    ],
  );
}

class _CampoTecnicoData {
  final String titulo;
  final IconData icono;

  const _CampoTecnicoData(this.titulo, this.icono);
}

class _EtiquetaTemaTecnico extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _EtiquetaTemaTecnico({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.surfaceContainer.withValues(alpha: dark ? 0.78 : 0.65),
            colors.surfaceContainerHigh.withValues(alpha: dark ? 0.72 : 0.60),
          ],
        ),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, color: colors.primary, size: 15),
          const SizedBox(width: 6),
          Text(
            texto,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
