import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'notificaciones.dart';
import 'perfil.dart';

class LicenciaturaPage extends StatefulWidget {
  const LicenciaturaPage({super.key});

  @override
  State<LicenciaturaPage> createState() => _LicenciaturaPageState();
}

class _LicenciaturaPageState extends State<LicenciaturaPage> {
  static const Color primaryNavy = Color(0xFF061424);
  static const Color deepBlue = Color(0xFF0D233A);
  static const Color backgroundGrey = Color(0xFFF6F8FA);
  static const Color accentBlue = Color(0xFF176B87);

  static const String paginaOficial =
      'https://tec.ac.cr/licenciatura-ingenieria-produccion-industrial';

  static const String paginaGeneral =
      'https://www.tec.ac.cr/ingenieria-produccion-industrial';

  static const String paginaPreguntas =
      'https://www.tec.ac.cr/ingenieria-produccion-industrial-preguntas-frecuentes';

  int selectedIndex = 0;

  // TARJETA SUPERIOR ORIGINAL CONSERVADA.
  final List<_TecnicoData> tecnicos = const [
    _TecnicoData(
      titulo: 'Licenciatura en Producción Industrial',
      descripcion:
          'Desarrollá tus habilidades para mejorar procesos, administrar recursos y resolver retos de la industria.',
      icono: Icons.precision_manufacturing_outlined,
      colores: [Color(0xFF102A43), Color(0xFF176B87)],
      imagen:
          'https://images.unsplash.com/photo-1567789884554-0b844b597180?auto=format&fit=crop&w=900&q=85',
    ),
  ];

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          behavior: SnackBarBehavior.floating,
          backgroundColor: deepBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  void _abrirPerfil() {
    HapticFeedback.selectionClick();

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const PerfilPage(),
      ),
    );
  }

  void _abrirAvisos() {
    HapticFeedback.selectionClick();

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => NotificacionesScreen(
          onSectionSelected: (index) {
            if (!mounted) return;

            if (index == 0) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            } else if (index == 1) {
              Navigator.of(context).pop();
              _mostrarMensaje(
                'El calendario estará disponible próximamente.',
              );
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
    HapticFeedback.selectionClick();

    switch (index) {
      case 0:
        Navigator.of(context).popUntil((route) => route.isFirst);
        break;

      case 1:
        // No se conecta con el calendario anterior.
        _mostrarMensaje(
          'El calendario estará disponible próximamente.',
        );
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
      backgroundColor: backgroundGrey,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _construirEncabezado(),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 22, 16, 25),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _construirTarjeta(tecnicos[index]);
                        },
                        childCount: tecnicos.length,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _construirInformacion(),
                  ),
                ],
              ),
            ),
            _construirNavegacionInferior(),
          ],
        ),
      ),
    );
  }

  // ENCABEZADO.
  Widget _construirEncabezado() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryNavy,
            deepBlue,
            Color(0xFF1B3C73),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                tooltip: 'Avisos',
                onPressed: _abrirAvisos,
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ],
          ),
          const Text(
            'Licenciatura',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Conocé la carrera y encontrá la información que necesitás.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 17),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
              ),
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

  // TARJETA SUPERIOR ORIGINAL CONSERVADA.
  Widget _construirTarjeta(_TecnicoData tecnico) {
    const radio = 25.0;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radio),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          _mostrarMensaje(
            'Seleccionaste: ${tecnico.titulo}',
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
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.68,
                    child: Image.network(
                      tecnico.imagen,
                      fit: BoxFit.cover,
                      alignment: Alignment.centerRight,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox.shrink();
                      },
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
                          tecnico.colores.first.withValues(alpha: 0.88),
                          tecnico.colores.first.withValues(alpha: 0.60),
                          tecnico.colores.last.withValues(alpha: 0.18),
                        ],
                        stops: const [0.0, 0.45, 1.0],
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
                  padding: const EdgeInsets.fromLTRB(16, 17, 18, 17),
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
                            const SizedBox(height: 8),
                            Text(
                              tecnico.descripcion,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11.5,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // INFORMACIÓN BÁSICA DE LA CARRERA.
  Widget _construirInformacion() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tituloSeccion(
            'Información básica',
            'Lo principal que necesitás conocer',
            Icons.school_outlined,
          ),
          const SizedBox(height: 14),
          _construirDatosBasicos(),

          const SizedBox(height: 25),

          _tituloSeccion(
            '¿De qué trata?',
            'Una visión general de la carrera',
            Icons.precision_manufacturing_outlined,
          ),
          const SizedBox(height: 14),
          _construirDescripcion(),

          const SizedBox(height: 25),

          _tituloSeccion(
            'Campo laboral',
            '¿Dónde podés trabajar?',
            Icons.work_outline_rounded,
          ),
          const SizedBox(height: 14),
          _construirCampoLaboral(),

          const SizedBox(height: 25),

          _construirConsultas(),

          const SizedBox(height: 18),

          const Center(
            child: Text(
              'Información de referencia. Consultá los canales oficiales del TEC.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF7A8795),
                fontSize: 10.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tituloSeccion(
    String titulo,
    String subtitulo,
    IconData icono,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: const Color(0xFFE5EFF7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icono,
            color: accentBlue,
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
                style: const TextStyle(
                  color: primaryNavy,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitulo,
                style: const TextStyle(
                  color: Color(0xFF7A8795),
                  fontSize: 11.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _construirDatosBasicos() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE3EAF0),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryNavy.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.account_balance_outlined,
                color: accentBlue,
                size: 23,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tecnológico de Costa Rica',
                  style: TextStyle(
                    color: primaryNavy,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(
            color: Color(0xFFEDF1F5),
            height: 1,
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _datoBasico(
                  Icons.workspace_premium_outlined,
                  'Grado',
                  'Licenciatura',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _datoBasico(
                  Icons.location_on_outlined,
                  'Sedes indicadas',
                  'Cartago ',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5F8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: accentBlue,
                  size: 20,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Los requisitos, horarios y la oferta vigente '
                    'se deben confirmar directamente con el TEC.',
                    style: TextStyle(
                      color: Color(0xFF486075),
                      fontSize: 11.5,
                      height: 1.5,
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

  Widget _datoBasico(
    IconData icono,
    String titulo,
    String valor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icono,
            color: accentBlue,
            size: 21,
          ),
          const SizedBox(height: 9),
          Text(
            titulo,
            style: const TextStyle(
              color: Color(0xFF7A8795),
              fontSize: 10.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(
              color: primaryNavy,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirDescripcion() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE3EAF0),
        ),
      ),
      child: const Text(
        'La Ingeniería en Producción Industrial busca mejorar '
        'la forma en que las organizaciones producen bienes y '
        'ofrecen servicios. Combina conocimientos de procesos, '
        'calidad, logística, administración y tecnología para '
        'aprovechar mejor los recursos y resolver problemas.',
        style: TextStyle(
          color: Color(0xFF617285),
          fontSize: 12.5,
          height: 1.7,
        ),
      ),
    );
  }

  Widget _construirCampoLaboral() {
    const areas = [
      _CampoLaboralData(
        titulo: 'Producción',
        icono: Icons.precision_manufacturing_outlined,
      ),
      _CampoLaboralData(
        titulo: 'Control de calidad',
        icono: Icons.fact_check_outlined,
      ),
      _CampoLaboralData(
        titulo: 'Logística',
        icono: Icons.local_shipping_outlined,
      ),
      _CampoLaboralData(
        titulo: 'Gestión de proyectos',
        icono: Icons.assignment_outlined,
      ),
      _CampoLaboralData(
        titulo: 'Mejora de procesos',
        icono: Icons.trending_up_rounded,
      ),
      _CampoLaboralData(
        titulo: 'Análisis de operaciones',
        icono: Icons.analytics_outlined,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE3EAF0),
        ),
      ),
      child: Wrap(
        spacing: 9,
        runSpacing: 10,
        children: areas.map((area) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5F8),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  area.icono,
                  color: accentBlue,
                  size: 17,
                ),
                const SizedBox(width: 7),
                Text(
                  area.titulo,
                  style: const TextStyle(
                    color: Color(0xFF31546E),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ACCESO A CONSULTAS E INFORMACIÓN OFICIAL.
  Widget _construirConsultas() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF123D60),
            Color(0xFF0B263F),
          ],
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: primaryNavy.withValues(alpha: 0.13),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.question_answer_outlined,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(height: 12),
          const Text(
            '¿Tenés dudas sobre la carrera?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Consultá la información oficial, los requisitos '
            'de ingreso y las preguntas frecuentes del TEC.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _mostrarInformacionOficial,
              icon: const Icon(
                Icons.open_in_new_rounded,
                size: 18,
              ),
              label: const Text('Consultar información'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF123D60),
                minimumSize: const Size(double.infinity, 48),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarInformacionOficial() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Información oficial',
            style: TextStyle(
              color: primaryNavy,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Seleccioná el enlace que necesitás consultar. '
                  'Podés copiarlo y abrirlo desde el navegador.',
                  style: TextStyle(
                    height: 1.5,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 18),
                _enlaceOficial(
                  dialogContext,
                  'Información de la licenciatura',
                  paginaOficial,
                ),
                const SizedBox(height: 16),
                _enlaceOficial(
                  dialogContext,
                  'Información general de la carrera',
                  paginaGeneral,
                ),
                const SizedBox(height: 16),
                _enlaceOficial(
                  dialogContext,
                  'Preguntas frecuentes',
                  paginaPreguntas,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _enlaceOficial(
    BuildContext dialogContext,
    String titulo,
    String enlace,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: primaryNavy,
            fontWeight: FontWeight.w800,
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 5),
        SelectableText(
          enlace,
          style: const TextStyle(
            color: accentBlue,
            fontSize: 11.5,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 5),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () async {
              await Clipboard.setData(
                ClipboardData(text: enlace),
              );

              if (!dialogContext.mounted) return;

              Navigator.pop(dialogContext);
              _mostrarMensaje('Enlace copiado al portapapeles.');
            },
            icon: const Icon(
              Icons.copy_rounded,
              size: 16,
            ),
            label: const Text('Copiar enlace'),
          ),
        ),
      ],
    );
  }

  // NAVEGACIÓN INFERIOR.
  Widget _construirNavegacionInferior() {
    const elementos = [
      _NavegacionItem(Icons.home_rounded, 'Inicio'),
      _NavegacionItem(Icons.calendar_month_rounded, 'Calendario'),
      _NavegacionItem(Icons.notifications_none_rounded, 'Avisos'),
      _NavegacionItem(Icons.person_outline_rounded, 'Perfil'),
    ];

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(14, 4, 14, 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: 20,
            sigmaY: 20,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 7,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.90),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryNavy.withValues(alpha: 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              children: List.generate(elementos.length, (index) {
                final seleccionado = selectedIndex == index;
                final elemento = elementos[index];

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _seleccionarSeccion(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 2,
                      ),
                      decoration: BoxDecoration(
                        color: seleccionado
                            ? const Color(0xFFE3F0FB)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(23),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            width: seleccionado ? 42 : 38,
                            height: 31,
                            decoration: BoxDecoration(
                              gradient: seleccionado
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF17466D),
                                        Color(0xFF0B263F),
                                      ],
                                    )
                                  : null,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              elemento.icono,
                              color: seleccionado
                                  ? Colors.white
                                  : const Color(0xFF657487),
                              size: 21,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            elemento.titulo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: seleccionado
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: seleccionado
                                  ? const Color(0xFF123D60)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _TecnicoData {
  final String titulo;
  final String descripcion;
  final IconData icono;
  final List<Color> colores;
  final String imagen;

  const _TecnicoData({
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.colores,
    required this.imagen,
  });
}

class _NavegacionItem {
  final IconData icono;
  final String titulo;

  const _NavegacionItem(this.icono, this.titulo);
}

class _CampoLaboralData {
  final String titulo;
  final IconData icono;

  const _CampoLaboralData({
    required this.titulo,
    required this.icono,
  });
}