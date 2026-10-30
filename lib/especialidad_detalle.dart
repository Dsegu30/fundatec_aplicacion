import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_theme.dart';
import 'calendario.dart';
import 'navegacion_glass.dart';
import 'notificaciones.dart';
import 'perfil.dart';

class EspecialidadDetallePage extends StatefulWidget {
  final String titulo;
  final String descripcion;
  final List<String> aspectos;
  final String imagen;
  final List<Color> colores;

  const EspecialidadDetallePage({
    super.key,
    required this.titulo,
    required this.descripcion,
    this.aspectos = const [],
    required this.imagen,
    required this.colores,
  });

  @override
  State<EspecialidadDetallePage> createState() =>
      _EspecialidadDetallePageState();
}

class _EspecialidadDetallePageState extends State<EspecialidadDetallePage>
    with SingleTickerProviderStateMixin {
  static const String _whatsappEspecialidades = '50686070110';

  int _selectedIndex = 0;
  late final AnimationController _entradaController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _entradaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
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

  void _seleccionarSeccion(int index) {
    HapticFeedback.selectionClick();
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    setState(() => _selectedIndex = index);
    switch (index) {
      case 1:
        Navigator.of(context)
            .push(appPageRoute<void>(builder: (_) => const CalendarioPage()));
        break;
      case 2:
        _abrirAvisos();
        break;
      case 3:
        Navigator.of(context)
            .push(appPageRoute<void>(builder: (_) => const PerfilPage()));
        break;
    }
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
              Navigator.of(context).push(
                appPageRoute<void>(builder: (_) => const CalendarioPage()),
              );
            } else if (index == 3) {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .push(appPageRoute<void>(builder: (_) => const PerfilPage()));
            }
          },
        ),
      ),
    );
  }

  Future<void> _abrirWhatsApp({required bool agendarCita}) async {
    const tipo = 'especialidad';
    const articulo = 'la';
    final nombre = widget.titulo;
    final mensaje = agendarCita
        ? 'Hola, quisiera agendar una cita con la Coordinación de Cursos Libres y Especialidades '
              'para recibir más información sobre $articulo $tipo "$nombre".'
        : 'Hola, quisiera hacer una consulta sobre $articulo $tipo '
              '"$nombre". ¿Podrían brindarme más información?';
    final uri = Uri.https('api.whatsapp.com', '/send', {
      'phone': _whatsappEspecialidades,
      'text': mensaje,
    });

    try {
      final abierto = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!abierto && mounted) {
        _mostrarMensaje('No se pudo abrir WhatsApp en este dispositivo.');
      }
    } catch (error) {
      if (mounted) {
        _mostrarMensaje('No se pudo abrir WhatsApp: $error');
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
          backgroundColor: const Color(0xFF0D233A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  void _contactarPorWhatsApp() {
    _abrirWhatsApp(agendarCita: false);
  }

  void _consultarCita() {
    _abrirWhatsApp(agendarCita: true);
  }

  @override
  Widget build(BuildContext context) {
    final page = Builder(
      builder: (context) {
        final size = MediaQuery.sizeOf(context);
        final compactLandscape = size.width > size.height && size.height < 560;
        final horizontalInset = size.width < 360 ? 14.0 : 18.0;
        final maxWidth = size.width;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          extendBody: true,
          body: Stack(
            children: [
              const _FondoEspecialidades(),
              SafeArea(
                bottom: false,
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
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
                            child: Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: maxWidth),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final wideLayout =
                                        constraints.maxWidth >= 960;

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _tarjetaPrincipal(
                                          wide: constraints.maxWidth >= 760,
                                        ),
                                        SizedBox(
                                          height: compactLandscape ? 22 : 30,
                                        ),
                                        if (wideLayout)
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    _tarjetaSobrePrograma(),
                                                    const SizedBox(height: 24),
                                                    _tarjetaEnfoque(),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 22),
                                              Expanded(
                                                child: _construirConsultas(),
                                              ),
                                            ],
                                          )
                                        else ...[
                                          _tarjetaSobrePrograma(),
                                          const SizedBox(height: 24),
                                          _tarjetaEnfoque(),
                                          const SizedBox(height: 24),
                                          _construirConsultas(),
                                        ],
                                        const SizedBox(height: 23),
                                        _pie(),
                                      ],
                                    );
                                  },
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
              Align(
                alignment: Alignment.bottomCenter,
                child: NavegacionGlass(
                  selectedIndex: _selectedIndex,
                  onSelected: _seleccionarSeccion,
                  wide: size.width >= 720,
                  compact: size.width > size.height && size.width < 720,
                ),
              ),
            ],
          ),
        );
      },
    );

    return page;
  }

  Widget _tarjetaSobrePrograma() {
    return _tarjetaGlass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tituloSeccion('Sobre la especialidad', Icons.school_outlined),
          const SizedBox(height: 15),
          Text(
            widget.descripcion,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
              height: 1.75,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaEnfoque() {
    final aspectos = widget.aspectos.isNotEmpty
        ? widget.aspectos
        : [
            'Conoce los objetivos y contenidos principales de ${widget.titulo}.',
            widget.descripcion,
            'Consulta con la Coordinación de Cursos Libres y Especialidades los requisitos, la modalidad, los horarios y la disponibilidad.',
          ];

    return _tarjetaGlass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tituloSeccion('Enfoque y caracteristicas', Icons.tune_rounded),
          const SizedBox(height: 17),
          for (var index = 0; index < aspectos.length; index++) ...[
            if (index > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 13),
                child: Divider(
                  height: 1,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            _punto(aspectos[index]),
          ],
        ],
      ),
    );
  }

  Widget _tarjetaPrincipal({required bool wide}) {
    final colors = widget.colores;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: wide ? 320 : 270),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.24),
            blurRadius: 36,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
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
                        widget.imagen,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox.shrink();
                        },
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
                      colors.first.withValues(alpha: 0.94),
                      colors.first.withValues(alpha: 0.74),
                      colors.last.withValues(alpha: 0.08),
                    ],
                    stops: const [0, 0.55, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -65,
              right: -45,
              child: _circulo(
                size: 190,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(wide ? 28 : 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            AppBackButton(
                              onDarkBackground: true,
                              onPressed: () => Navigator.of(context).maybePop(),
                            ),
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
                                'ESPECIALIDAD INDUSTRIAL',
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
                        SizedBox(height: wide ? 20 : 15),
                        Text(
                          widget.titulo,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: wide ? 30 : 23,
                            fontWeight: FontWeight.w900,
                            height: 1.12,
                            letterSpacing: -0.7,
                          ),
                        ),
                        SizedBox(height: wide ? 13 : 10),
                        Text(
                          'Escuela de Ingeniería en Producción Industrial',
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
                  const Expanded(flex: 3, child: SizedBox.shrink()),
                ],
              ),
            ),
          ],
        ),
      ),
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
                color: (dark ? Colors.black : const Color(0xFF061424))
                    .withValues(alpha: dark ? 0.20 : 0.08),
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

  Widget _tituloSeccion(String titulo, IconData icono) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icono, color: colors.onPrimaryContainer, size: 23),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            titulo,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _punto(String texto) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_outline_rounded, color: colors.primary),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            texto,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 12,
              height: 1.7,
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirConsultas() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF061424).withValues(alpha: 0.15),
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
              child: _circulo(
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
                    'una cita con la Coordinación de Cursos Libres y Especialidades y recibir '
                    'más información sobre ${widget.titulo}.',
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
                    onTap: _contactarPorWhatsApp,
                  ),
                  const SizedBox(height: 11),
                  _botonAccionGlass(
                    texto: 'Agendar una cita con coordinación',
                    icono: Icons.calendar_month_rounded,
                    principal: false,
                    onTap: _consultarCita,
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
    final foreground = principal ? const Color(0xFF0D233A) : Colors.white;

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
                          ? const Color(0xFF0D233A)
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

  Widget _pie() {
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

  Widget _circulo({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _FondoEspecialidades extends StatelessWidget {
  const _FondoEspecialidades();

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
              bottom: -95,
              right: -70,
              child: _burbuja(
                size: 290,
                color: const Color(0xFF7C6BF2)
                    .withValues(alpha: dark ? 0.18 : 0.15),
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
