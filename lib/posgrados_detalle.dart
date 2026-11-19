import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_theme.dart';
import 'calendario.dart';
import 'navegacion_glass.dart';
import 'notificaciones.dart';
import 'perfil.dart';

class MaestriaCalidadProfesionalPage extends StatelessWidget {
  const MaestriaCalidadProfesionalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PosgradoDetallePage(
      titulo: 'Maestría en Calidad',
      numeroPrograma: 1,
      modalidad: 'Modalidad Profesional',
      urlSolicitud: 'https://www.tec.ac.cr/form/calidad-profesional',
      urlInformacion: 'https://www.tec.ac.cr/maestria-calidad-profesional',
      descripcion:
          'Desarrollo profesional para liderar la gestión de la calidad y '
          'la mejora continua dentro de las organizaciones.',
      areasFormacion: [
        'Gestión de sistemas de calidad',
        'Mejora continua',
        'Analítica de datos',
        'Auditoría y gestión de procesos',
        'Liderazgo de iniciativas de mejora',
      ],
      enfoque:
          'Gestión de la calidad, mejora de procesos y solución de problemas '
          'en las organizaciones.',
      idealPara:
          'Profesionales vinculados con gestión de la calidad, mejora continua, '
          'procesos, auditoría y liderazgo de iniciativas de mejora.',
      idealSiQueres:
          'Liderar la mejora continua y los sistemas de gestión de calidad.',
      imagen: 'assets/images/Maestria_Calidad_Modalidad_Profesional.png',
      colores: [Color(0xFF0D7478), Color(0xFF075B68)],
    );
  }
}

class MaestriaCalidadAcademicaPage extends StatelessWidget {
  const MaestriaCalidadAcademicaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PosgradoDetallePage(
      titulo: 'Maestría en Calidad',
      numeroPrograma: 2,
      modalidad: 'Modalidad Académica',
      urlSolicitud: 'https://www.tec.ac.cr/solicitud-ingreso-maestria-calidad',
      urlInformacion: 'https://www.tec.ac.cr/maestria-calidad-academica',
      descripcion:
          'Desarrollo de capacidades para analizar, investigar y generar '
          'conocimiento en gestión de la calidad.',
      areasFormacion: [
        'Gestión estratégica de la calidad',
        'Analítica de datos',
        'Pensamiento crítico',
        'Investigación aplicada',
        'Innovación y mejora',
      ],
      enfoque: 'Investigación y desarrollo de conocimiento en el campo de la calidad.',
      idealPara:
          'Profesionales vinculados con calidad, docencia, investigación y '
          'análisis, interesados en profundizar sus conocimientos y desarrollar '
          'una visión estratégica.',
      idealSiQueres: 'Investigar y generar conocimiento nuevo en calidad.',
      imagen: 'assets/images/Maestria_Calidad_Modalidad_Academica.png',
      colores: [Color(0xFF0D7478), Color(0xFF075B68)],
    );
  }
}

class MaestriaCadenaAbastecimientoPage extends StatelessWidget {
  const MaestriaCadenaAbastecimientoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PosgradoDetallePage(
      titulo: 'Maestría en Cadena de Abastecimiento',
      numeroPrograma: 3,
      urlSolicitud: 'https://www.tec.ac.cr/solicitud-ingreso-maestria-cadena-abastecimiento',
      urlInformacion: 'https://www.tec.ac.cr/maestria-cadena-abastecimiento',
      descripcion:
          'Formación para impulsar cadenas de suministro eficientes, '
          'innovadoras y competitivas.',
      areasFormacion: [
        'Planificación y gestión de la cadena',
        'Logística',
        'Gestión de inventarios',
        'Optimización de procesos',
        'Innovación y tecnología',
      ],
      enfoque:
          'Gestión de las cadenas de suministro y mejora de las operaciones '
          'logísticas, del proveedor al cliente final.',
      idealPara:
          'Profesionales vinculados con logística, abastecimiento, operaciones, '
          'inventarios y gestión de la cadena de suministro.',
      idealSiQueres: 'Optimizar flujos, inventarios, transporte y operaciones.',
      imagen: 'assets/images/Maestria_Cadena_de_Abastecimiento.png',
      colores: [Color(0xFF0D7478), Color(0xFF075B68)],
    );
  }
}

class MaestriaSistemasModernosManufacturaPage extends StatelessWidget {
  const MaestriaSistemasModernosManufacturaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PosgradoDetallePage(
      titulo: 'Maestría en Sistemas Modernos de Manufactura',
      numeroPrograma: 4,
      urlSolicitud: 'https://www.tec.ac.cr/maestria-sistemas-modernos-manufactura/admision',
      urlInformacion:
          'https://www.tec.ac.cr/maestria-sistemas-modernos-manufactura',
      descripcion:
          'Preparación para impulsar la evolución tecnológica y productiva '
          'de la industria.',
      areasFormacion: [
        'Manufactura avanzada',
        'Industria 4.0',
        'Automatización',
        'Tecnologías emergentes',
        'Optimización de procesos',
      ],
      enfoque:
          'Sistemas de producción, tecnologías de manufactura y mejora de los '
          'procesos productivos.',
      idealPara:
          'Profesionales vinculados con manufactura, producción, procesos, '
          'automatización y tecnología, interesados en impulsar la transformación '
          'de los sistemas productivos.',
      idealSiQueres: 'Modernizar la producción e incorporar automatización.',
      imagen: 'assets/images/Maestria_Sistemas_Modernos_de_Manufactura.png',
      colores: [Color(0xFF0D7478), Color(0xFF075B68)],
    );
  }
}

class PosgradoDetallePage extends StatefulWidget {
  final String titulo;
  final int? numeroPrograma;
  final String? etiquetaPrograma;
  final String? modalidad;
  final String? urlSolicitud;
  final String? urlInformacion;
  final String descripcion;
  final List<String> areasFormacion;
  final String enfoque;
  final String idealPara;
  final String idealSiQueres;
  final String imagen;
  final List<Color> colores;

  const PosgradoDetallePage({
    super.key,
    required this.titulo,
    required this.numeroPrograma,
    this.etiquetaPrograma,
    this.modalidad,
    this.urlSolicitud,
    this.urlInformacion,
    required this.descripcion,
    required this.areasFormacion,
    required this.enfoque,
    required this.idealPara,
    required this.idealSiQueres,
    required this.imagen,
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

    final nombre = widget.modalidad == null
        ? widget.titulo
        : '${widget.titulo} (${widget.modalidad})';

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

  Future<void> _abrirSolicitud() async {
    final url = widget.urlSolicitud;

    if (url == null) return;

    final uri = Uri.parse(url);

    try {
      final abierto = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!abierto && mounted) {
        _mostrarMensaje('No se pudo abrir el formulario de solicitud.');
      }
    } catch (error) {
      if (mounted) {
        _mostrarMensaje('No se pudo abrir el formulario: $error');
      }
    }
  }

  Future<void> _abrirInformacion() async {
    final url = widget.urlInformacion;

    if (url == null) return;

    final uri = Uri.parse(url);

    try {
      final abierto = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!abierto && mounted) {
        _mostrarMensaje('No se pudo abrir la información de la maestría.');
      }
    } catch (error) {
      if (mounted) {
        _mostrarMensaje('No se pudo abrir la información: $error');
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
              const _FondoPosgrado(),
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

                                        // DISTRIBUCIÓN EN PANTALLAS GRANDES
                                        if (wideLayout)
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    _tarjetaEnfoque(),
                                                    const SizedBox(height: 16),
                                                    _tarjetaIdealPara(),
                                                    const SizedBox(height: 16),
                                                    _tarjetaIdealSiQueres(),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 22),
                                              Expanded(child: _tarjetaAreas()),
                                            ],
                                          )
                                        // DISTRIBUCIÓN EN PANTALLAS PEQUEÑAS
                                        else ...[
                                          _tarjetaEnfoque(),
                                          const SizedBox(height: 16),
                                          _tarjetaIdealPara(),
                                          const SizedBox(height: 16),
                                          _tarjetaIdealSiQueres(),
                                          const SizedBox(height: 16),
                                          _tarjetaAreas(),
                                        ],

                                        const SizedBox(height: 22),
                                        _tarjetaSolicitud(),
                                        const SizedBox(height: 16),
                                        _tarjetaBeneficios(),
                                        const SizedBox(height: 22),
                                        _construirConsultas(),
                                        const SizedBox(height: 25),
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

  // ÁREAS DE FORMACIÓN

  Widget _tarjetaAreas() {
    return _tarjetaGlass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.school_rounded, color: Color(0xFF087A86), size: 22),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'ÁREAS DE FORMACIÓN',
                  style: TextStyle(
                    color: Color(0xFF087A9A),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            'Lo que vas a desarrollar',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 17),
          for (var i = 0; i < widget.areasFormacion.length; i++) ...[
            _areaNumerada(i + 1, widget.areasFormacion[i]),
            if (i != widget.areasFormacion.length - 1)
              const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _areaNumerada(int numero, String texto) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF0D8A98).withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D929B), Color(0xFF075B68)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$numero',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TARJETAS DE INFORMACIÓN

  Widget _tarjetaEnfoque() {
    return _tarjetaInformacion(
      titulo: 'ENFOQUE DEL PROGRAMA',
      contenido: widget.enfoque,
      icono: Icons.track_changes_rounded,
    );
  }

  Widget _tarjetaIdealPara() {
    return _tarjetaInformacion(
      titulo: 'IDEAL PARA',
      contenido: widget.idealPara,
      icono: Icons.groups_outlined,
    );
  }

  Widget _tarjetaIdealSiQueres() {
    return _tarjetaGlass(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE3F5F4), Color(0xFFD5ECEE)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF0D929B).withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 37,
              height: 37,
              decoration: BoxDecoration(
                color: const Color(0xFF087A86).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.lightbulb_rounded,
                color: Color(0xFF087A86),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'IDEAL SI QUERÉS',
                    style: TextStyle(
                      color: Color(0xFF087A86),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    widget.idealSiQueres,
                    style: const TextStyle(
                      color: Color(0xFF12364B),
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
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
    required String titulo,
    required String contenido,
    required IconData icono,
  }) {
    return _tarjetaGlass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D929B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icono, color: const Color(0xFF087A86), size: 23),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    color: Color(0xFF087A9A),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            contenido,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              height: 1.65,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // SOLICITUD DE INGRESO

  Widget _tarjetaSolicitud() {
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
                  color: const Color(0xFF159447).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assignment_turned_in_rounded,
                  color: Color(0xFF159447),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'SOLICITUD DE INGRESO',
                  style: TextStyle(
                    color: Color(0xFF159447),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'I CUATRIMESTRE 2027',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '¿Listo para postularte?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            'Completá tu solicitud de ingreso. Si cancelás tu prematrícula '
            'antes del 15 de noviembre de 2026, accedés al paquete completo '
            'de beneficios. *Aplican restricciones.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 17),
          LayoutBuilder(
            builder: (context, constraints) {
              final solicitud = _etiquetaSolicitud(
                'Completar solicitud',
                Icons.arrow_forward_rounded,
                const Color(0xFF2DB65D),
                onTap: widget.urlSolicitud == null ? null : _abrirSolicitud,
              );
              final informacion = _etiquetaSolicitud(
                'Conocé la maestría',
                Icons.arrow_forward_rounded,
                const Color(0xFF142B55),
                onTap: widget.urlInformacion == null ? null : _abrirInformacion,
              );

              if (constraints.maxWidth < 420) {
                return Column(
                  children: [
                    SizedBox(width: double.infinity, child: solicitud),
                    const SizedBox(height: 10),
                    SizedBox(width: double.infinity, child: informacion),
                  ],
                );
              }
return Row(
  children: [
    Expanded(child: solicitud),
    const SizedBox(width: 10),
    Expanded(child: informacion),
  ],
);
},
),
],
),
);
}

  Widget _etiquetaSolicitud(
    String texto,
    IconData icono,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, Color.lerp(color, Colors.black, 0.16)!],
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
            Icon(icono, color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }

  // BENEFICIOS

  Widget _tarjetaBeneficios() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF183F72), Color(0xFF142B55), Color(0xFF0B203E)],
        ),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF142B55).withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                color: Color(0xFFFFD477),
                size: 27,
              ),
              SizedBox(width: 11),
              Expanded(
                child: Text(
                  'Beneficios complementarios 100% gratis',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          const Divider(color: Colors.white24),
          const SizedBox(height: 10),
          const Text(
            'IA generativa, Power BI, coaching ejecutivo, liderazgo, '
            'nivelatorios de estadística y 10% de descuento en tus cursos.',
            style: TextStyle(
              color: Color(0xFFE3EAF7),
              fontSize: 14,
              height: 1.7,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            '*Aplican restricciones. Consultá las condiciones de cada beneficio en tu cita de asesoría.',
            style: TextStyle(
              color: Color(0xFFCAD5E8),
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // TARJETA PRINCIPAL

  Widget _tarjetaPrincipal({required bool wide}) {
    final colors = widget.colores;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: wide ? 350 : 300),
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
                  widthFactor: 0.9,
                  heightFactor: 1,
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (bounds) => const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        Color(0x66FFFFFF),
                        Color(0xE6FFFFFF),
                      ],
                      stops: [0, 0.22, 1],
                    ).createShader(bounds),
                    child: widget.imagen.startsWith('assets/')
                        ? Image.asset(
                            widget.imagen,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            filterQuality: FilterQuality.high,
                            color: Colors.white.withValues(alpha: 0.58),
                            colorBlendMode: BlendMode.softLight,
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox.shrink();
                            },
                          )
                        : Image.network(
                            widget.imagen,
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
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      colors.first.withValues(alpha: 0.98),
                      colors.first.withValues(alpha: 0.86),
                      colors.last.withValues(alpha: 0.38),
                    ],
                    stops: const [0, 0.48, 1],
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
              padding: EdgeInsets.all(wide ? 30 : 22),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: wide ? 7 : 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 9,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            AppBackButton(
                              onDarkBackground: true,
                              onPressed: () => Navigator.of(context).maybePop(),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Text(
                                widget.etiquetaPrograma ??
                                    'MAESTRÍA ${widget.numeroPrograma} DE 4 · POSGRADOS INDUSTRIAL',
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
                          widget.titulo,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: wide ? 34 : 27,
                            fontWeight: FontWeight.w900,
                            height: 1.12,
                            letterSpacing: -0.7,
                          ),
                        ),
                        if (widget.modalidad != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            widget.modalidad!,
                            style: const TextStyle(
                              color: Color(0xFF69D6B0),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                        SizedBox(height: wide ? 16 : 13),
                        Text(
                          widget.descripcion,
                          style: TextStyle(
                            color: const Color(0xFFE8F7F7),
                            fontSize: wide ? 14 : 12,
                            height: 1.6,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: wide ? 17 : 14),
                        Text(
                          'Escuela de Ingeniería en Producción Industrial',
                          style: TextStyle(
                            color: const Color(0xFFD7F0FF),
                            fontSize: wide ? 14 : 12,
                            fontWeight: FontWeight.w700,
                            height: 1.5,
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

  // TARJETAS GLASS

  Widget _tarjetaGlass({required Widget child}) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dark
                  ? [
                      const Color(0xFF18334A).withValues(alpha: 0.94),
                      const Color(0xFF10263A).withValues(alpha: 0.90),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.96),
                      const Color(0xFFF1F8FC).withValues(alpha: 0.94),
                    ],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: dark
                  ? const Color(0xFF4B91A9).withValues(alpha: 0.35)
                  : const Color(0xFF80BFCB).withValues(alpha: 0.55),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF075B68).withValues(alpha: 0.09),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // CONTACTO Y CONSULTAS

  Widget _construirConsultas() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF061424).withValues(alpha: 0.18),
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
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: Colors.white,
                      size: 29,
                    ),
                  ),
                  const SizedBox(height: 19),
                  const Text(
                    '¿Necesitás más información?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 11),
                  Text(
                    'Contactá por WhatsApp para hacer consultas o agendar '
                    'una cita con la Coordinación de Posgrados y recibir '
                    'más información sobre ${widget.titulo}.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.84),
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 23),
                  _botonAccionGlass(
                    texto: 'Hacer una consulta por WhatsApp',
                    icono: Icons.chat_rounded,
                    principal: true,
                    onTap: _contactarPorWhatsApp,
                  ),
                  const SizedBox(height: 13),
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
                constraints: const BoxConstraints(minHeight: 58),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
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
                    Icon(icono, color: foreground, size: 22),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Text(
                        texto,
                        style: TextStyle(
                          color: foreground,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: principal
                          ? const Color(0xFF0D233A)
                          : Colors.white.withValues(alpha: 0.75),
                      size: 20,
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

  // PIE DE PÁGINA

  Widget _pie() {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        children: [
          Container(
            width: 46,
            height: 4,
            decoration: BoxDecoration(
              color: colors.outlineVariant,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'TEC MÓVIL',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tecnológico de Costa Rica · www.tec.ac.cr/posgrados-industrial',
            textAlign: TextAlign.center,
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

class _FondoPosgrado extends StatelessWidget {
  const _FondoPosgrado();

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
