import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_theme.dart';
import 'calendario.dart';
import 'navegacion_glass.dart';
import 'notificaciones.dart';
import 'perfil.dart';

class MaestriaCalidadAcademicaPage extends StatelessWidget {
  const MaestriaCalidadAcademicaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PosgradoDetallePage(
      titulo: 'Maestría en Calidad (modalidad académica)',
      resumenHero:
          'Formación para liderar la calidad y la evaluación en organizaciones '
          'públicas y privadas.',
      enfoque:
          'Aprende a diseñar modelos, instrumentos y estrategias innovadoras '
          'en Seis Sigma, servicio al cliente y evaluación de procesos. '
          'Desarrolla competencias para tomar decisiones de alto impacto y '
          'liderar mejoras de calidad en organizaciones públicas y privadas.',
      areas: [
        'Título: Máster en Calidad, modalidad académica. Duración: 6 cuatrimestres.',
        'Dirigida a profesionales del sector público y privado que buscan '
            'mejorar la calidad de las organizaciones y la sociedad.',
        'Prepara para liderar áreas de calidad, innovación, seguridad y '
            'ambiente, y para diseñar sistemas integrados de gestión.',
        'Abre oportunidades en consultoría, auditoría, asesoría estratégica, '
            'academia e investigación.',
      ],
      idealPara:
          'Profesionales del sector público y privado que buscan mejorar la '
          'calidad de las organizaciones y la sociedad.',
      colores: [Color(0xFF102A43), Color(0xFF176B87)],
    );
  }
}

class MaestriaCalidadProfesionalPage extends StatelessWidget {
  const MaestriaCalidadProfesionalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PosgradoDetallePage(
      titulo: 'Maestría en Calidad (modalidad profesional)',
      resumenHero:
          'Desarrollo profesional para liderar la gestión de la calidad y la '
          'mejora continua dentro de las organizaciones.',
      enfoque:
          'Gestión de la calidad, mejora de procesos y solución de problemas '
          'en las organizaciones.',
      areas: [
        'Gestión de sistemas de calidad',
        'Mejora continua',
        'Analítica de datos',
        'Auditoría y gestión de procesos',
        'Liderazgo de iniciativas de mejora',
      ],
      idealPara:
          'Profesionales vinculados con gestión de la calidad, mejora continua, '
          'procesos, auditoría y liderazgo de iniciativas de mejora.',
      idealSi:
          'liderar la mejora continua y los sistemas de gestión de calidad.',
      colores: [Color(0xFF162D3D), Color(0xFF247B87)],
    );
  }
}

class MaestriaCadenaAbastecimientoPage extends StatelessWidget {
  const MaestriaCadenaAbastecimientoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PosgradoDetallePage(
      titulo: 'Maestría en Cadena de Abastecimiento',
      resumenHero:
          'Fortalece la eficiencia operativa y la competitividad de las '
          'organizaciones.',
      enfoque:
          'Fortalece la eficiencia operativa y la competitividad de las '
          'organizaciones. Brinda herramientas para enfrentar los desafíos '
          'del entorno internacional de la cadena de abastecimiento.',
      areas: [
        'Dirigida a personas con grado universitario en ingeniería o '
            'administración que trabajen o deseen incorporarse al área.',
        'Desarrolla competencias para dirigir la gestión logística y la '
            'cadena de abastecimiento.',
        'Abarca distribución, almacenaje, planificación, compras y '
            'aprovisionamiento, junto con tendencias estratégicas y '
            'metodológicas.',
        'Prepara para puestos gerenciales y ejecutivos y para desarrollar '
            'proyectos de investigación en el área.',
      ],
      idealPara:
          'Personas con grado universitario en ingeniería o administración '
          'que trabajen o deseen incorporarse al área.',
      colores: [Color(0xFF182848), Color(0xFF315C91)],
    );
  }
}

class MaestriaSistemasModernosManufacturaPage extends StatelessWidget {
  const MaestriaSistemasModernosManufacturaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PosgradoDetallePage(
      titulo: 'Maestría en Sistemas Modernos de Manufactura',
      resumenHero:
          'Fortalece competencias para optimizar procesos productivos e '
          'impulsar la competitividad industrial.',
      enfoque:
          'Fortalece competencias para optimizar procesos productivos e '
          'impulsar la competitividad industrial. Está dirigida a profesionales '
          'del sector empresarial que buscan aplicar técnicas y estrategias '
          'modernas de manufactura.',
      areas: [
        'Grado académico: Maestría. Se imparte en el Campus Tecnológico '
            'Central, Cartago.',
        'Cuenta con el Centro de Investigación en Sistemas Modernos de '
            'Manufactura y laboratorios de Manufactura Integrada por '
            'Computadora (CIM), robótica y automatización.',
        'Incluye equipos y áreas de neumática, hidráulica, CNC, PLC y '
            'simulación de sistemas modernos de manufactura.',
      ],
      idealPara:
          'Profesionales del sector empresarial que buscan aplicar técnicas '
          'y estrategias modernas de manufactura.',
      colores: [Color(0xFF162D3D), Color(0xFF247B87)],
    );
  }
}

class PosgradoDetallePage extends StatefulWidget {
  final String titulo;
  final String resumenHero;
  final String enfoque;
  final List<String> areas;
  final String idealPara;
  final String? idealSi;
  final List<Color> colores;

  const PosgradoDetallePage({
    super.key,
    required this.titulo,
    required this.resumenHero,
    required this.enfoque,
    required this.areas,
    required this.idealPara,
    this.idealSi,
    required this.colores,
  });

  @override
  State<PosgradoDetallePage> createState() => _PosgradoDetallePageState();
}

class _PosgradoDetallePageState extends State<PosgradoDetallePage>
    with SingleTickerProviderStateMixin {
  static const String _whatsappPosgrados = '50686906006';

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
    const tipo = 'programa';
    final nombre = widget.titulo;
    final mensaje = agendarCita
        ? 'Hola, quisiera agendar una cita con la Coordinación de Posgrados '
              'para recibir más información sobre el $tipo "$nombre".'
        : 'Hola, quisiera hacer una consulta sobre el $tipo '
              '"$nombre". ¿Podrían brindarme más información?';
    final uri = Uri.https('api.whatsapp.com', '/send', {
      'phone': _whatsappPosgrados,
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
        const maxWidth = 1180.0;

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
                                        constraints.maxWidth >= 720;

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _tarjetaPrincipal(wide: wideLayout),
                                        SizedBox(
                                          height: compactLandscape ? 22 : 30,
                                        ),
                                        if (wideLayout)
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 11,
                                                child: Column(
                                                  children: [_tarjetaAreas()],
                                                ),
                                              ),
                                              const SizedBox(width: 22),
                                              Expanded(
                                                flex: 9,
                                                child: Column(
                                                  children: [
                                                    _tarjetaEnfoque(),
                                                    const SizedBox(height: 18),
                                                    _tarjetaIdealPara(),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        else ...[
                                          _tarjetaAreas(),
                                          const SizedBox(height: 18),
                                          _tarjetaEnfoque(),
                                          const SizedBox(height: 18),
                                          _tarjetaIdealPara(),
                                        ],
                                        const SizedBox(height: 22),
                                        _construirConsultas(wide: wideLayout),
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

  Widget _tarjetaAreas() {
    return _tarjetaGlass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _etiquetaSeccion('ÁREAS DE FORMACIÓN'),
          const SizedBox(height: 7),
          Text(
            'Lo que vas a desarrollar',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 22,
              height: 1.2,
              letterSpacing: -0.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          for (var index = 0; index < widget.areas.length; index++) ...[
            if (index > 0) const SizedBox(height: 9),
            _filaArea(index + 1, widget.areas[index]),
          ],
        ],
      ),
    );
  }

  Widget _tarjetaEnfoque() {
    return _tarjetaGlass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _etiquetaSeccion('ENFOQUE DEL PROGRAMA'),
          const SizedBox(height: 8),
          Text(
            widget.enfoque,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaIdealPara() {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        _tarjetaGlass(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _etiquetaSeccion('IDEAL PARA'),
              const SizedBox(height: 8),
              Text(
                widget.idealPara,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
        if (widget.idealSi case final idealSi?) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF173B42) : const Color(0xFFE2F1F1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 13,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(
                    text: 'Ideal si querés: ',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(text: idealSi),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _tarjetaPrincipal({required bool wide}) {
    final colors = widget.colores;
    final theme = Theme.of(context);
    final titlePanel = Container(
      width: double.infinity,
      padding: EdgeInsets.all(wide ? 24 : 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'PROGRAMA DE POSGRADO',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 9,
              letterSpacing: 2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.titulo.toUpperCase(),
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: wide ? 22 : 20,
              height: 1.13,
              letterSpacing: -0.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppBackButton(
              onDarkBackground: true,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(width: 11),
            const Flexible(
              child: Text(
                'POSGRADOS · TEC',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: wide ? 24 : 16),
        Text(
          widget.resumenHero,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: wide ? 16 : 14,
            height: 1.65,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: wide ? 225 : 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.24),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(
              top: -70,
              right: -40,
              child: _circulo(
                size: 180,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(wide ? 24 : 18),
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 6, child: intro),
                        const SizedBox(width: 24),
                        Expanded(flex: 4, child: titlePanel),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [intro, const SizedBox(height: 18), titlePanel],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaGlass({required Widget child}) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh.withValues(
              alpha: dark ? 0.82 : 0.76,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colors.outlineVariant.withValues(
                alpha: dark ? 0.72 : 0.68,
              ),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: (dark ? Colors.black : const Color(0xFF061424))
                    .withValues(alpha: dark ? 0.18 : 0.07),
                blurRadius: 23,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _etiquetaSeccion(String texto) {
    return Text(
      texto,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontSize: 10,
        letterSpacing: 0.7,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _filaArea(int numero, String texto) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.72),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 27,
            height: 27,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.secondary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$numero',
              style: TextStyle(
                color: colors.secondary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirConsultas({required bool wide}) {
    final theme = Theme.of(context);
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONTACTO CON COORDINACIÓN · POSGRADOS',
          style: const TextStyle(
            color: Color(0xFF38A85B),
            fontSize: 10,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          '¿Listo para dar el siguiente paso?',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 22,
            height: 1.2,
            letterSpacing: -0.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Consultá sobre ${widget.titulo} o agendá una cita con la '
          'Coordinación de Posgrados.',
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 13,
            height: 1.55,
          ),
        ),
      ],
    );

    final actions = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _botonAccionGlass(
          texto: 'Hacer una consulta',
          icono: Icons.chat_rounded,
          principal: true,
          onTap: _contactarPorWhatsApp,
        ),
        const SizedBox(height: 10),
        _botonAccionGlass(
          texto: 'Agendar una cita',
          icono: Icons.calendar_month_rounded,
          principal: false,
          onTap: _consultarCita,
        ),
      ],
    );

    return _tarjetaGlass(
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 7, child: info),
                const SizedBox(width: 24),
                Expanded(flex: 5, child: actions),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [info, const SizedBox(height: 18), actions],
            ),
    );
  }

  Widget _botonAccionGlass({
    required String texto,
    required IconData icono,
    required bool principal,
    required VoidCallback onTap,
  }) {
    const background = Color(0xFF0B2757);
    final foreground = Colors.white;

    return GelPress(
      child: Material(
        color: principal ? const Color(0xFF45B96A) : background,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icono, color: foreground, size: 18),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    texto,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 17,
                ),
              ],
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
