import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_theme.dart';
import 'calendario.dart';
import 'navegacion_glass.dart';
import 'notificaciones.dart';
import 'perfil.dart';

class LicenciaturaPage extends StatefulWidget {
  const LicenciaturaPage({super.key});

  @override
  State<LicenciaturaPage> createState() => _LicenciaturaPageState();
}

class _LicenciaturaPageState extends State<LicenciaturaPage>
    with SingleTickerProviderStateMixin {
  static const Color primaryNavy = Color(0xFF061424);
  static const Color deepBlue = Color(0xFF0D233A);
  static const Color accentBlue = Color(0xFF0EA5E9);
  static const double _anchoDisenoAmplio = 980;

  static const String imagenPrograma =
      'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?auto=format&fit=crop&w=1600&q=85';

  static const String telefonoSecretaria = '2550-9202';
  static const String whatsappSecretaria = '50625509202';
  static const String correoSecretaria = 'asanabria@tec.ac.cr';

  int selectedIndex = 0;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

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

  Future<void> _abrirWhatsAppSecretaria() async {
    final uri = Uri.https('wa.me', '/$whatsappSecretaria', {
      'text':
          'Hola, quisiera información sobre la Licenciatura en Ingeniería '
          'en Producción Industrial.',
    });

    try {
      final abierto = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!abierto && mounted) {
        _mostrarMensaje('No se pudo abrir WhatsApp en este dispositivo.');
      }
    } catch (_) {
      if (mounted) {
        _mostrarMensaje('No se pudo abrir WhatsApp en este dispositivo.');
      }
    }
  }

  void _agendarCita() {
    _mostrarMensaje(
      'Consultá con Secretaría cómo solicitar una cita: '
      '$telefonoSecretaria o $correoSecretaria.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    final compactLandscape =
        screenSize.width > screenSize.height && screenSize.height < 560;

    final horizontalInset = screenSize.width < 360 ? 14.0 : 18.0;

    final maxContentWidth = screenSize.width >= 1360 ? 1400.0 : 1100.0;

    return DisplayFeatureSubScreen(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        extendBody: true,
        body: Stack(
          children: [
            const _FondoLiquidGlass(),

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
                                final ancho = constraints.maxWidth;

                                final pantallaAmplia =
                                    ancho >= _anchoDisenoAmplio;

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
                                            _construirTarjetaPrincipal(
                                              pantallaAmplia,
                                            ),

                                            SizedBox(
                                              height: compactLandscape
                                                  ? 22
                                                  : 30,
                                            ),

                                            if (pantallaAmplia) ...[
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

  Widget _circuloDecorativo({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  // ============================================================
  // TARJETA PRINCIPAL CON IMAGEN DE INGENIERÍA INDUSTRIAL
  // ============================================================

  Widget _construirTarjetaPrincipal(bool pantallaAmplia) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: pantallaAmplia ? 320 : 268),
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
            // Foto vertical a la derecha, con el tratamiento de las otras
            // tarjetas que combinan fotografía y degradado azul.
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: pantallaAmplia ? 0.58 : 0.60,
                  heightFactor: 1,
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (bounds) {
                      return const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          Color(0xCCFFFFFF),
                          Colors.white,
                        ],
                        stops: [0, 0.24, 0.62],
                      ).createShader(bounds);
                    },
                    child: Opacity(
                      opacity: 0.94,
                      child: Image.network(
                        imagenPrograma,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        filterQuality: FilterQuality.high,
                        semanticLabel:
                            'Fotografía de un entorno profesional relacionado '
                            'con la Ingeniería en Producción Industrial',
                        errorBuilder: (context, error, stackTrace) {
                          return const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF102A43), Color(0xFF176B87)],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Degradado que separa el texto de la imagen sin ocultarla.
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
                    stops: const [0.0, 0.46, 1.0],
                  ),
                ),
              ),
            ),

            // Detalles decorativos discretos sobre el borde de la fotografía.
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

            if (pantallaAmplia)
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
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.precision_manufacturing_rounded,
                            color: Color(0xFFBAE6FD),
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Producción industrial',
                            style: TextStyle(
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

            // Contenido alineado con el panel fotográfico.
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: pantallaAmplia ? 30 : 20,
                vertical: pantallaAmplia ? 28 : 20,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AppBackButton(
                              onDarkBackground: true,
                              onPressed: () {
                                Navigator.of(context).maybePop();
                              },
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
                                'LICENCIATURA',
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

                        SizedBox(height: pantallaAmplia ? 16 : 14),

                        Text(
                          'Licenciatura en Ingeniería en Producción Industrial',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: pantallaAmplia ? 30 : 22,
                            fontWeight: FontWeight.w900,
                            height: 1.12,
                            letterSpacing: -0.7,
                          ),
                        ),

                        SizedBox(height: pantallaAmplia ? 12 : 9),

                        Text(
                          'Procesos · Calidad · Productividad',
                          style: TextStyle(
                            color: const Color(0xFFD7F0FF),
                            fontSize: pantallaAmplia ? 13 : 11,
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                          ),
                        ),

                        SizedBox(height: pantallaAmplia ? 18 : 14),

                        // ETIQUETA CON EFECTO LIQUID GLASS
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
                                    Icons.auto_awesome_rounded,
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
                  Expanded(
                    flex: 3,
                    child: const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DESCRIPCIÓN DEL PROGRAMA
  // ============================================================

  Widget _construirDescripcion() {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tituloSeccion(
          'Descripción del programa',
          'Conocé el enfoque de la carrera',
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
                  Icons.insights_rounded,
                  color: colors.onPrimaryContainer,
                  size: 23,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Optimización e innovación en las organizaciones',
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'La Licenciatura en Producción Industrial prepara '
                'profesionales para planificar, diseñar, implementar '
                'y mejorar sistemas de producción de bienes y servicios. '
                'Integra personas, materiales, equipos, tecnología e '
                'información para optimizar recursos, impulsar la '
                'productividad y promover la mejora continua.',
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
                children: const [
                  _EtiquetaTema(
                    icono: Icons.check_circle_outline_rounded,
                    texto: 'Calidad',
                  ),
                  _EtiquetaTema(
                    icono: Icons.account_tree_outlined,
                    texto: 'Procesos',
                  ),
                  _EtiquetaTema(
                    icono: Icons.trending_up_rounded,
                    texto: 'Productividad',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DATOS GENERALES
  // ============================================================

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
                      Icons.location_on_outlined,
                      'Sedes',
                      'Cartago',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _datoBasico(
                      Icons.schedule_rounded,
                      'Grado académico',
                      'Licenciatura',
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
                  'El plan de estudios y sus requisitos pueden actualizarse.',
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
            'Título universitario',
            'Ingeniero (a) en Producción Industrial',
          ),
          const SizedBox(height: 12),
          _filaInformacion(
            Icons.calendar_view_week_rounded,
            'Modalidad académica',
            'Semestral',
          ),
          const SizedBox(height: 12),
          _filaInformacion(Icons.wb_sunny_outlined, 'Jornada', 'Diurna'),
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

  // ============================================================
  // CAMPO LABORAL
  // ============================================================

  Widget _construirCampoLaboral() {
    final colors = Theme.of(context).colorScheme;

    const areas = [
      _CampoLaboralData(
        'Gestión de operaciones',
        Icons.precision_manufacturing_outlined,
      ),
      _CampoLaboralData(
        'Mejoramiento de la calidad',
        Icons.fact_check_outlined,
      ),
      _CampoLaboralData('Logística integral', Icons.local_shipping_outlined),
      _CampoLaboralData('Optimización y simulación', Icons.trending_up_rounded),
      _CampoLaboralData(
        'Seguridad industrial y gestión ambiental',
        Icons.health_and_safety_outlined,
      ),
      _CampoLaboralData(
        'Administración de proyectos y finanzas',
        Icons.assignment_outlined,
      ),
      _CampoLaboralData('Gestión del talento humano', Icons.groups_outlined),
      _CampoLaboralData(
        'Emprendimiento y consultoría',
        Icons.lightbulb_outline_rounded,
      ),
      _CampoLaboralData('Inteligencia de negocios', Icons.analytics_outlined),
    ];

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
                'Posibles áreas de desarrollo profesional',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 11.5,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              ...areas.asMap().entries.map((entry) {
                final index = entry.key;
                final area = entry.value;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == areas.length - 1 ? 0 : 10,
                  ),
                  child: _filaCampoLaboral(area),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filaCampoLaboral(_CampoLaboralData area) {
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

  // ============================================================
  // CONTACTO Y CONSULTAS
  // ============================================================

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
            Positioned(
              top: 28,
              right: 25,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white.withValues(alpha: 0.20),
                size: 27,
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
                    'Contactá a la secretaría para resolver tus dudas '
                    'sobre la carrera, los requisitos y la oferta académica.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.76),
                      fontSize: 12,
                      height: 1.75,
                    ),
                  ),
                  const SizedBox(height: 21),
                  _botonAccionGlass(
                    texto: 'Contactar por WhatsApp',
                    icono: Icons.chat_rounded,
                    principal: true,
                    onTap: _abrirWhatsAppSecretaria,
                  ),
                  const SizedBox(height: 11),
                  _botonAccionGlass(
                    texto: 'Consultar cómo solicitar una cita',
                    icono: Icons.calendar_month_rounded,
                    principal: false,
                    onTap: _agendarCita,
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

  // ============================================================
  // TÍTULOS Y TARJETAS
  // ============================================================

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

  // ============================================================
  // NAVEGACIÓN INFERIOR LIQUID GLASS
  // ============================================================

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

// ============================================================
// FONDO LIQUID GLASS
// ============================================================

class _FondoLiquidGlass extends StatelessWidget {
  const _FondoLiquidGlass();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: dark
                      ? const [
                          Color(0xFF091522),
                          Color(0xFF10243A),
                          Color(0xFF142B3C),
                        ]
                      : const [
                          Color(0xFFF5F9FF),
                          Color(0xFFE5F1FC),
                          Color(0xFFF4F8FD),
                        ],
                ),
              ),
            ),
            Positioned(
              top: -85,
              right: -115,
              child: _burbuja(
                size: 350,
                color:
                    (dark ? const Color(0xFF1687F6) : const Color(0xFF55A9F1))
                        .withValues(alpha: dark ? 0.30 : 0.35),
              ),
            ),
            Positioned(
              top: 330,
              left: -155,
              child: _burbuja(
                size: 330,
                color:
                    (dark ? const Color(0xFF00B8A9) : const Color(0xFF39C8C0))
                        .withValues(alpha: dark ? 0.24 : 0.28),
              ),
            ),
            Positioned(
              bottom: -95,
              right: -70,
              child: _burbuja(
                size: 290,
                color: const Color(0xFF7C6BF2)
                    .withValues(alpha: dark ? 0.18 : 0.15),
              ),
            ),
            Positioned(
              bottom: 140,
              left: 45,
              child: _burbuja(
                size: 125,
                color: const Color(0xFF8FD8F3)
                    .withValues(alpha: dark ? 0.14 : 0.26),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _burbuja({required double size, required Color color}) {
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: 42, sigmaY: 42),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

// ============================================================
// ETIQUETAS DE TEMAS
// ============================================================

class _EtiquetaTema extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _EtiquetaTema({required this.icono, required this.texto});

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

// ============================================================
// MODELOS AUXILIARES
// ============================================================

class _CampoLaboralData {
  final String titulo;
  final IconData icono;

  const _CampoLaboralData(this.titulo, this.icono);
}
