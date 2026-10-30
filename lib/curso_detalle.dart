import 'dart:ui' as ui;

// Se conservan las implementaciones y parámetros existentes del archivo.
// Algunos pertenecen a variantes de detalle que no se instancian actualmente.
// ignore_for_file: unused_element, unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_theme.dart';
import 'calendario.dart';
import 'navegacion_glass.dart';
import 'notificaciones.dart';
import 'perfil.dart';

class CursoLibreData {
  final String id;
  final String nombre;
  final String categoria;
  final String tipo;
  final String grupo;
  final String descripcion;
  final List<String> aspectos;
  final String imagen;
  final List<Color> colores;
  final IconData icono;
  final String descuento;
  final String fechas;
  final String modalidad;
  final String telefonoWhatsApp;
  final String correo;
  final String coordinacion;
  final String encargados;

  const CursoLibreData({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.tipo,
    required this.grupo,
    required this.descripcion,
    required this.aspectos,
    required this.imagen,
    required this.colores,
    required this.icono,
    this.descuento = '15% de descuento aplicable en cada materia al matricular',
    this.fechas = 'Inicio de lecciones: setiembre, octubre y noviembre',
    this.modalidad = 'Virtual y presencial con campus virtual FUNDATEC',
    this.telefonoWhatsApp = '50686070110',
    this.correo = 'tecproducalidad@fundatec.ac.cr',
    this.coordinacion = 'Coordinación de Cursos Libres y Especialidades',
    this.encargados = 'Liss Salas Cerdas y Zelmira Villalobos Méndez',
  });
}

class CursoDetallePage extends StatefulWidget {
  final CursoLibreData curso;

  const CursoDetallePage({super.key, required this.curso});

  @override
  State<CursoDetallePage> createState() => _CursoDetallePageState();
}

class _CursoDetallePageState extends State<CursoDetallePage>
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
    final tipo = widget.curso.tipo.toLowerCase();
    final nombre = widget.curso.nombre;
    final mensaje = agendarCita
        ? 'Hola, quisiera agendar una cita con la ${widget.curso.coordinacion} '
              'para recibir más información sobre el $tipo "$nombre".'
        : 'Hola, quisiera hacer una consulta sobre el $tipo '
              '"$nombre". ¿Podrían brindarme más información?';
    final uri = Uri.https('api.whatsapp.com', '/send', {
      'phone': widget.curso.telefonoWhatsApp,
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
    return Builder(
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
              const FondoAppDifuminado(),
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
  }

  Widget _tarjetaSobrePrograma() {
    return _tarjetaGlass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tituloSeccion('Sobre el programa', Icons.school_outlined),
          const SizedBox(height: 15),
          Text(
            widget.curso.descripcion,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
              height: 1.75,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                Icons.local_offer_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.curso.descuento,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tarjetaEnfoque() {
    return _tarjetaGlass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tituloSeccion('Enfoque y características', Icons.tune_rounded),
          const SizedBox(height: 17),
          for (
            var index = 0;
            index < widget.curso.aspectos.length;
            index++
          ) ...[
            if (index > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 13),
                child: Divider(
                  height: 1,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            _punto(widget.curso.aspectos[index]),
          ],
        ],
      ),
    );
  }

  Widget _tarjetaPrincipal({required bool wide}) {
    final colors = widget.curso.colores;

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
                        widget.curso.imagen,
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
                              child: Text(
                                widget.curso.tipo.toUpperCase(),
                                style: const TextStyle(
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
                          widget.curso.nombre,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: wide ? 28 : 22,
                            fontWeight: FontWeight.w900,
                            height: 1.14,
                            letterSpacing: -0.7,
                          ),
                        ),
                        SizedBox(height: wide ? 13 : 10),
                        const Text(
                          'Escuela de Ingeniería en Producción Industrial',
                          style: TextStyle(
                            color: Color(0xFFD7F0FF),
                            fontSize: 12,
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
                    'una cita con la Coordinación de Cursos Libres y Especialidades '
                    'sobre ${widget.curso.nombre}.',
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
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'ESCUELA DE INGENIERÍA EN PRODUCCIÓN INDUSTRIAL',
            style: TextStyle(
              color: colors.onSurfaceVariant.withValues(alpha: 0.72),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tecnológico de Costa Rica · FUNDATEC',
            style: TextStyle(
              color: colors.onSurfaceVariant.withValues(alpha: 0.55),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
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
/*
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

  Widget _tarjetaGlass({required Widget child, EdgeInsets? padding}) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh.withValues(
              alpha: dark ? .78 : .70,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colors.outlineVariant.withValues(
                alpha: dark ? .72 : .68,
              ),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: (dark ? Colors.black : primaryNavy).withValues(
                  alpha: dark ? .16 : .06,
                ),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _botonIconoGlass({
    required IconData icono,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 13, sigmaY: 13),
        child: Material(
          color: Colors.white.withValues(alpha: .10),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: .15),
                ),
              ),
              child: Tooltip(
                message: tooltip,
                child: Icon(icono, color: Colors.white, size: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _burbujaDecorativa(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
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
*/

class _FondoCursosGlass extends StatelessWidget {
  const _FondoCursosGlass();

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
                350,
                (dark ? const Color(0xFF1687F6) : const Color(0xFF55A9F1))
                    .withValues(alpha: dark ? .30 : .35),
              ),
            ),
            Positioned(
              top: 330,
              left: -155,
              child: _burbuja(
                330,
                (dark ? const Color(0xFF00B8A9) : const Color(0xFF39C8C0))
                    .withValues(alpha: dark ? .24 : .28),
              ),
            ),
            Positioned(
              bottom: -95,
              right: -70,
              child: _burbuja(
                290,
                const Color(0xFF7C6BF2).withValues(alpha: dark ? .18 : .15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _burbuja(double size, Color color) {
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

class _CursoData {
  final String titulo;
  final String categoria;
  final String tipo;
  final int? niveles;
  final IconData icono;
  final Color color;
  final String detalle;
  final String objetivo;
  final List<String> contenidos;
  final List<String> habilidades;

  const _CursoData({
    required this.titulo,
    required this.categoria,
    required this.tipo,
    required this.icono,
    required this.color,
    required this.niveles,
    required this.detalle,
    required this.objetivo,
    required this.contenidos,
    required this.habilidades,
  });
}

/// Pantalla independiente para cada curso libre.
/// Cada tarjeta envía su propio objeto _CursoData a esta página.
class CursoLibreDetallePage extends StatefulWidget {
  final _CursoData curso;

  const CursoLibreDetallePage({super.key, required this.curso});

  @override
  State<CursoLibreDetallePage> createState() => _CursoLibreDetallePageState();
}

class _CursoLibreDetallePageState extends State<CursoLibreDetallePage>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  _CursoData get curso => widget.curso;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, .035),
      end: Offset.zero,
    ).animate(_fade);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  Future<void> _consultarCorreo() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'tecproducalidad@fundatec.ac.cr',
      queryParameters: {
        'subject': 'Consulta sobre ${curso.titulo}',
        'body':
            'Buenas, quisiera recibir más información sobre ${curso.titulo}.',
      },
    );
    try {
      final abierto = await launchUrl(uri);
      if (!abierto && mounted) {
        _mostrarMensaje('No se pudo abrir la aplicación de correo.');
      }
    } catch (_) {
      if (mounted) _mostrarMensaje('No se pudo abrir la aplicación de correo.');
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          const _FondoCursosGlass(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _construirBarraSuperior(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 125),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: FadeTransition(
                          opacity: _fade,
                          child: SlideTransition(
                            position: _slide,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _construirHero(dark),
                                const SizedBox(height: 18),
                                _tarjetaSeccion(
                                  titulo: 'Sobre este curso',
                                  icono: Icons.menu_book_rounded,
                                  child: Text(
                                    curso.detalle,
                                    style: TextStyle(
                                      color: colors.onSurfaceVariant,
                                      fontSize: 13,
                                      height: 1.8,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                _tarjetaSeccion(
                                  titulo: 'Objetivo del curso',
                                  icono: Icons.flag_outlined,
                                  child: Text(
                                    curso.objetivo,
                                    style: TextStyle(
                                      color: colors.onSurfaceVariant,
                                      fontSize: 13,
                                      height: 1.8,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                _tarjetaSeccion(
                                  titulo: 'Temas que se pueden abordar',
                                  icono: Icons.checklist_rounded,
                                  child: Column(
                                    children: curso.contenidos.map((tema) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 11,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.check_circle_rounded,
                                              color: curso.color,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                tema,
                                                style: TextStyle(
                                                  color:
                                                      colors.onSurfaceVariant,
                                                  fontSize: 12,
                                                  height: 1.6,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                _tarjetaSeccion(
                                  titulo: 'Habilidades relacionadas',
                                  icono: Icons.auto_awesome_rounded,
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: curso.habilidades.map((
                                      habilidad,
                                    ) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 11,
                                          vertical: 9,
                                        ),
                                        decoration: BoxDecoration(
                                          color: curso.color.withValues(
                                            alpha: .10,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            13,
                                          ),
                                          border: Border.all(
                                            color: curso.color.withValues(
                                              alpha: .22,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          habilidad,
                                          style: TextStyle(
                                            color: colors.onSurface,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                if (curso.niveles != null) ...[
                                  const SizedBox(height: 15),
                                  _tarjetaSeccion(
                                    titulo: 'Estructura del curso',
                                    icono: Icons.stairs_rounded,
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: List.generate(
                                        curso.niveles!,
                                        (index) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 13,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: curso.color.withValues(
                                              alpha: .10,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            'Nivel ${index + 1}',
                                            style: TextStyle(
                                              color: curso.color,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 15),
                                _construirInformacionOficial(),
                                const SizedBox(height: 25),
                                Center(
                                  child: Text(
                                    'TEC MÓVIL  ·  Formación · Innovación · Futuro',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: colors.onSurfaceVariant.withValues(
                                        alpha: .75,
                                      ),
                                      fontSize: 10,
                                      height: 1.6,
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
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _construirNavegacionInferior(),
          ),
        ],
      ),
    );
  }

  Widget _construirBarraSuperior() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(17, 9, 17, 13),
      child: Row(
        children: [
          _botonGlass(
            icono: Icons.arrow_back_rounded,
            tooltip: 'Volver a cursos',
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURSOS LIBRES',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Información del curso',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          _botonGlass(
            icono: Icons.notifications_none_rounded,
            tooltip: 'Avisos',
            onTap: _abrirAvisos,
          ),
          const SizedBox(width: 8),
          _botonGlass(
            icono: Icons.person_outline_rounded,
            tooltip: 'Mi perfil',
            onTap: _abrirPerfil,
          ),
        ],
      ),
    );
  }

  Widget _construirHero(bool dark) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [curso.color.withValues(alpha: .98), const Color(0xFF061424)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: curso.color.withValues(alpha: dark ? .12 : .20),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            bottom: -32,
            child: Icon(
              curso.icono,
              size: 150,
              color: Colors.white.withValues(alpha: .09),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .20),
                  ),
                ),
                child: Text(
                  curso.categoria.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: 61,
                height: 61,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .23),
                  ),
                ),
                child: Icon(curso.icono, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 19),
              Text(
                curso.titulo,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                  letterSpacing: -.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Conocé el objetivo, los temas y las habilidades relacionadas con esta opción de formación.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .82),
                  fontSize: 12,
                  height: 1.7,
                ),
              ),
              if (curso.niveles != null) ...[
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Icon(
                      Icons.layers_outlined,
                      color: Colors.white,
                      size: 17,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${curso.niveles} niveles',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _tarjetaSeccion({
    required String titulo,
    required IconData icono,
    required Widget child,
  }) {
    final colors = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(23),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(19),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh.withValues(alpha: .78),
            borderRadius: BorderRadius.circular(23),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: .8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 39,
                    height: 39,
                    decoration: BoxDecoration(
                      color: curso.color.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(icono, color: curso.color, size: 21),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      titulo,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirInformacionOficial() {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D233A), Color(0xFF164C70)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.white, size: 22),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Información oficial y matrícula',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            'La información descriptiva de esta pantalla es orientativa. Confirmá con el TEC los requisitos, fechas, costos, duración y modalidad vigentes para ${curso.titulo}.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .82),
              fontSize: 12,
              height: 1.75,
            ),
          ),
          const SizedBox(height: 17),
          _botonAccion(
            texto: 'Consultar oferta oficial del TEC',
            icono: Icons.open_in_new_rounded,
            principal: true,
            onTap: _abrirSitioOficial,
          ),
          const SizedBox(height: 10),
          _botonAccion(
            texto: 'Consultar por correo',
            icono: Icons.email_outlined,
            principal: false,
            onTap: _consultarCorreo,
          ),
          const SizedBox(height: 12),
          Text(
            'Contacto: tecproducalidad@fundatec.ac.cr',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .76),
              fontSize: 10.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Página oficial: www.tec.ac.cr/cursos-libres-especialidades',
            style: TextStyle(
              color: colors.onSurface.withValues(alpha: 0),
              fontSize: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _botonAccion({
    required String texto,
    required IconData icono,
    required bool principal,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: principal ? Colors.white : Colors.white.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: principal
                    ? Colors.white
                    : Colors.white.withValues(alpha: .24),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icono,
                  color: principal ? const Color(0xFF0D233A) : Colors.white,
                  size: 19,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    texto,
                    style: TextStyle(
                      color: principal ? const Color(0xFF0D233A) : Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: principal ? const Color(0xFF0D233A) : Colors.white,
                  size: 17,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _botonGlass({
    required IconData icono,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHigh
            .withValues(alpha: .8),
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant
                    .withValues(alpha: .8),
              ),
            ),
            child: Icon(
              icono,
              color: Theme.of(context).colorScheme.onSurface,
              size: 21,
            ),
          ),
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
