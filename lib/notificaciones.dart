import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'calendario.dart';
import 'navegacion_glass.dart';
import 'perfil.dart';

const Color _azulTec = Color(0xFF083D91);
const Color _azulBrillante = Color(0xFF3478F6);
const Color _azulClaro = Color(0xFF80B8FF);

class NotificacionesScreen extends StatefulWidget {
  final bool embedded;
  final ValueChanged<int>? onSectionSelected;

  const NotificacionesScreen({
    super.key,
    this.embedded = false,
    this.onSectionSelected,
  });

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrada;
  late final AnimationController _ambiente;

  int _filtroSeleccionado = 0;
  final int _pestanaSeleccionada = 2;

  final List<_Aviso> _avisos = [
    _Aviso(
      id: 1,
      categoria: 'Académico',
      titulo: 'Actividad académica',
      descripcion: 'Hay una nueva actualización disponible para tu programa.',
      fecha: 'Hace 10 min',
      icono: Icons.calendar_month_rounded,
      color: const Color(0xFF3478F6),
      leido: false,
    ),
    _Aviso(
      id: 2,
      categoria: 'Importante',
      titulo: 'Aviso importante',
      descripcion: 'Consulta las novedades y la información de tu programa.',
      fecha: 'Hace 2 horas',
      icono: Icons.campaign_rounded,
      color: const Color(0xFF8B67E8),
      leido: false,
    ),
    _Aviso(
      id: 3,
      categoria: 'Recordatorio',
      titulo: 'Mantente al día',
      descripcion: 'Revisa los próximos eventos y actividades académicas.',
      fecha: 'Ayer',
      icono: Icons.event_available_rounded,
      color: const Color(0xFF16A58B),
      leido: true,
    ),
    _Aviso(
      id: 4,
      categoria: 'Información',
      titulo: 'Información disponible',
      descripcion: 'Puedes consultar nuevos recursos desde tu plataforma.',
      fecha: 'Hace 2 días',
      icono: Icons.auto_stories_rounded,
      color: const Color(0xFFDC9345),
      leido: true,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _entrada = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _ambiente = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entrada.dispose();
    _ambiente.dispose();
    super.dispose();
  }

  List<_Aviso> get _avisosVisibles {
    if (_filtroSeleccionado == 1) {
      return _avisos.where((aviso) => !aviso.leido).toList();
    }
    return _avisos;
  }

  int get _noLeidos => _avisos.where((aviso) => !aviso.leido).length;

  void _seleccionarSeccion(int index) {
    if (widget.embedded && widget.onSectionSelected != null) {
      widget.onSectionSelected!(index);
      return;
    }

    if (index == 2) return;

    if (index == 0) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
      return;
    }

    Navigator.of(context).push(
      appPageRoute<void>(
        builder: (context) =>
            index == 1 ? const CalendarioPage() : const PerfilPage(),
      ),
    );
  }

  void _marcarComoLeido(_Aviso aviso) {
    setState(() {
      aviso.leido = true;
    });
  }

  void _marcarTodosComoLeidos() {
    setState(() {
      for (final aviso in _avisos) {
        aviso.leido = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Todas las notificaciones están al día.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _azulTec,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  void _abrirAviso(_Aviso aviso) {
    if (!aviso.leido) {
      _marcarComoLeido(aviso);
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _DetalleAviso(aviso: aviso);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: theme.colorScheme.surface)),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ambiente,
              builder: (context, child) {
                return CustomPaint(
                  painter: _FondoGlassPainter(
                    progreso: _ambiente.value,
                    dark: theme.brightness == Brightness.dark,
                  ),
                );
              },
            ),
          ),
          SafeArea(
            bottom: !widget.embedded,
            child: FadeTransition(
              opacity: CurvedAnimation(parent: _entrada, curve: Curves.easeOut),
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.025),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _entrada,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: Column(
                  children: [
                    _construirBarraSuperior(),
                    Expanded(child: _construirContenido()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.embedded ? null : _construirNavegacion(),
    );
  }

  Widget _construirBarraSuperior() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 8),
      child: Row(
        children: [
          _BotonGlass(
            icono: Icons.arrow_back_rounded,
            onTap: () {
              if (widget.embedded && widget.onSectionSelected != null) {
                widget.onSectionSelected!(0);
              } else if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          const Spacer(),
          _BotonGlass(
            icono: Icons.tune_rounded,
            onTap: () {
              _mostrarOpciones();
            },
          ),
        ],
      ),
    );
  }

  Widget _construirContenido() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 5,
                      height: 17,
                      decoration: BoxDecoration(
                        color: _azulBrillante,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'PLATAFORMA ACADÉMICA',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 10,
                          letterSpacing: 2.1,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Centro de\navisos',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 39,
                          height: 1.02,
                          letterSpacing: -1.6,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _IconoPrincipalGlass(cantidad: _noLeidos),
                  ],
                ),
                const SizedBox(height: 13),
                Text(
                  'Todo lo importante de tu vida académica, '
                  'en un solo lugar.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                    height: 1.55,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 26),
                _construirFiltros(),
                const SizedBox(height: 20),
                _construirTuEspacio(),
              ],
            ),
          ),
        ),
        if (_avisosVisibles.isEmpty)
          const SliverFillRemaining(hasScrollBody: false, child: _EstadoVacio())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 145),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final aviso = _avisosVisibles[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TarjetaAviso(
                    aviso: aviso,
                    indice: index,
                    onTap: () => _abrirAviso(aviso),
                  ),
                );
              }, childCount: _avisosVisibles.length),
            ),
          ),
      ],
    );
  }

  Widget _construirFiltros() {
    return Row(
      children: [
        Expanded(
          child: _SegmentoGlass(
            seleccionado: _filtroSeleccionado == 0,
            texto: 'Todas',
            onTap: () {
              setState(() => _filtroSeleccionado = 0);
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SegmentoGlass(
            seleccionado: _filtroSeleccionado == 1,
            texto: 'Sin leer',
            contador: _noLeidos,
            onTap: () {
              setState(() => _filtroSeleccionado = 1);
            },
          ),
        ),
        const SizedBox(width: 10),
        _BotonGlass(
          icono: Icons.done_all_rounded,
          onTap: _marcarTodosComoLeidos,
        ),
      ],
    );
  }

  Widget _construirTuEspacio() {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(21),
          decoration: BoxDecoration(
            color: (dark ? const Color(0xFF26384A) : Colors.white).withValues(
              alpha: dark ? 0.96 : 0.69,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: (dark ? const Color(0xFF536B82) : Colors.white).withValues(
                alpha: 0.95,
              ),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: _azulTec.withValues(alpha: 0.055),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -15,
                top: -27,
                child: Container(
                  width: 125,
                  height: 125,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _azulClaro.withValues(alpha: 0.17),
                        _azulClaro.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 31,
                        height: 31,
                        decoration: BoxDecoration(
                          color: _azulBrillante.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 17,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'TU ESPACIO',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 10,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF36B98A),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'ACTIVO',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 9,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 19),
                  Text(
                    'Mantente al día.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 25,
                      height: 1.15,
                      letterSpacing: -0.7,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'Tus novedades y recordatorios académicos, '
                    'organizados para ti.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 19),
                  Row(
                    children: [
                      const Icon(
                        Icons.notifications_active_outlined,
                        size: 16,
                        color: _azulBrillante,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _noLeidos == 0
                              ? 'Estás al día con tus avisos'
                              : 'Tenés $_noLeidos avisos por revisar',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 17,
                        color: _azulBrillante,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirNavegacion() {
    return NavegacionGlass(
      selectedIndex: _pestanaSeleccionada,
      showAvisosBadge: _noLeidos > 0,
      onSelected: _seleccionarSeccion,
    );
  }

  void _mostrarOpciones() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 35),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface
                    .withValues(alpha: 0.96),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD3DCE9),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Gestionar avisos',
                    style: TextStyle(
                      fontSize: 23,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Organizá tus notificaciones como prefirás.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 22),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.done_all_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Marcar todo como leído'),
                    onTap: () {
                      Navigator.pop(context);
                      _marcarTodosComoLeidos();
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.filter_alt_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Mostrar solo sin leer'),
                    onTap: () {
                      setState(() => _filtroSeleccionado = 1);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Aviso {
  _Aviso({
    required this.id,
    required this.categoria,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.icono,
    required this.color,
    required this.leido,
  });

  final int id;
  final String categoria;
  final String titulo;
  final String descripcion;
  final String fecha;
  final IconData icono;
  final Color color;
  bool leido;
}

// TARJETA INDIVIDUAL

class _TarjetaAviso extends StatefulWidget {
  const _TarjetaAviso({
    required this.aviso,
    required this.indice,
    required this.onTap,
  });

  final _Aviso aviso;
  final int indice;
  final VoidCallback onTap;

  @override
  State<_TarjetaAviso> createState() => _TarjetaAvisoState();
}

class _TarjetaAvisoState extends State<_TarjetaAviso>
    with SingleTickerProviderStateMixin {
  late final AnimationController _reflejo;
  bool _presionado = false;

  @override
  void initState() {
    super.initState();

    _reflejo = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
  }

  @override
  void dispose() {
    _reflejo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aviso = widget.aviso;
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return AnimatedScale(
      scale: _presionado ? 0.985 : 1,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _presionado = true);
          _reflejo.forward(from: 0);
        },
        onTapCancel: () {
          setState(() => _presionado = false);
        },
        onTapUp: (_) {
          setState(() => _presionado = false);
        },
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (dark ? const Color(0xFF26384A) : Colors.white)
                    .withValues(
                      alpha: dark
                          ? aviso.leido
                                ? 0.94
                                : 0.98
                          : aviso.leido
                          ? 0.61
                          : 0.83,
                    ),
                borderRadius: BorderRadius.circular(23),
                border: Border.all(
                  color: (dark ? const Color(0xFF536B82) : Colors.white)
                      .withValues(alpha: 0.95),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _azulTec.withValues(
                      alpha: aviso.leido ? 0.025 : 0.055,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 47,
                    height: 47,
                    decoration: BoxDecoration(
                      color: aviso.color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(aviso.icono, color: aviso.color, size: 23),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                aviso.titulo,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontSize: 14,
                                  fontWeight: aviso.leido
                                      ? FontWeight.w600
                                      : FontWeight.w800,
                                ),
                              ),
                            ),
                            if (!aviso.leido) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: _azulBrillante,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          aviso.descripcion,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 11),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              aviso.fecha,
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                      ],
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
}

// ICONO DE CABECERA

class _IconoPrincipalGlass extends StatelessWidget {
  const _IconoPrincipalGlass({required this.cantidad});

  final int cantidad;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: 72,
          height: 80,
          decoration: BoxDecoration(
            color: (dark ? const Color(0xFF26384A) : Colors.white).withValues(
              alpha: dark ? 0.96 : 0.68,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: (dark ? const Color(0xFF536B82) : Colors.white).withValues(
                alpha: 0.95,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: _azulTec.withValues(alpha: 0.06),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 35,
              ),
              if (cantidad > 0)
                Positioned(
                  top: 15,
                  right: 14,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _azulBrillante,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// BOTÓN TRANSLÚCIDO

class _BotonGlass extends StatelessWidget {
  const _BotonGlass({required this.icono, required this.onTap});

  final IconData icono;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(17),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Material(
          color: (dark ? const Color(0xFF26384A) : Colors.white).withValues(
            alpha: dark ? 0.96 : 0.68,
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(17),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: (dark ? const Color(0xFF536B82) : Colors.white)
                      .withValues(alpha: 0.95),
                ),
              ),
              child: Icon(
                icono,
                color: Theme.of(context).colorScheme.primary,
                size: 21,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// FILTRO TIPO GLASS

class _SegmentoGlass extends StatelessWidget {
  const _SegmentoGlass({
    required this.seleccionado,
    required this.texto,
    required this.onTap,
    this.contador = 0,
  });

  final bool seleccionado;
  final String texto;
  final int contador;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      height: 46,
      decoration: BoxDecoration(
        color: seleccionado
            ? _azulTec
            : (dark ? const Color(0xFF26384A) : Colors.white).withValues(
                alpha: dark ? 0.96 : 0.67,
              ),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: seleccionado
              ? _azulTec
              : (dark ? const Color(0xFF536B82) : Colors.white).withValues(
                  alpha: 0.96,
                ),
        ),
        boxShadow: seleccionado
            ? [
                BoxShadow(
                  color: _azulTec.withValues(alpha: 0.17),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    texto,
                    style: TextStyle(
                      color: seleccionado ? Colors.white : muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (contador > 0 && texto == 'Sin leer') ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: seleccionado
                            ? Colors.white.withValues(alpha: 0.20)
                            : _azulBrillante.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$contador',
                        style: TextStyle(
                          color: seleccionado ? Colors.white : _azulTec,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ESTADO VACÍO

class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: (dark ? const Color(0xFF26384A) : Colors.white)
                    .withValues(alpha: dark ? 0.96 : 0.8),
                shape: BoxShape.circle,
                border: Border.all(
                  color: dark ? const Color(0xFF536B82) : Colors.white,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _azulTec.withValues(alpha: 0.07),
                    blurRadius: 25,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 37,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Todo está tranquilo',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No tenés avisos pendientes por revisar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// DETALLE DEL AVISO

class _DetalleAviso extends StatelessWidget {
  const _DetalleAviso({required this.aviso});

  final _Aviso aviso;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 35),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.97),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6DFEC),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                const SizedBox(height: 27),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: aviso.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: Icon(aviso.icono, color: aviso.color, size: 27),
                ),
                const SizedBox(height: 20),
                Text(
                  aviso.categoria.toUpperCase(),
                  style: TextStyle(
                    color: _azulBrillante,
                    fontSize: 10,
                    letterSpacing: 1.8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  aviso.titulo,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 27,
                    letterSpacing: -0.6,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  aviso.descripcion,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 15,
                    height: 1.65,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 16,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      aviso.fecha,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: _azulTec,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Entendido',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// FONDO AMBIENTAL LIQUID GLASS

class _FondoGlassPainter extends CustomPainter {
  _FondoGlassPainter({required this.progreso, required this.dark});

  final double progreso;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 45);

    paint.color = const Color(0xFF8EB9FF).withValues(alpha: 0.15);

    canvas.drawCircle(
      Offset(size.width * (0.90 - progreso * 0.06), size.height * 0.15),
      size.width * 0.37,
      paint,
    );

    paint.color = const Color(0xFFB8D3FF).withValues(alpha: 0.15);

    canvas.drawCircle(
      Offset(size.width * 0.05, size.height * (0.55 + progreso * 0.04)),
      size.width * 0.32,
      paint,
    );

    paint.color = Colors.white.withValues(alpha: dark ? 0.04 : 0.35);

    canvas.drawCircle(
      Offset(size.width * 0.90, size.height * 0.79),
      size.width * 0.26,
      paint,
    );

    final banda = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.0),
              Colors.white.withValues(alpha: dark ? 0.025 : 0.13),
              Colors.white.withValues(alpha: 0.0),
            ],
            stops: const [0.25, 0.5, 0.75],
          ).createShader(
            Rect.fromLTWH(
              size.width * (progreso * 0.2),
              0,
              size.width,
              size.height,
            ),
          );

    canvas.drawRect(Offset.zero & size, banda);
  }

  @override
  bool shouldRepaint(covariant _FondoGlassPainter oldDelegate) {
    return oldDelegate.progreso != progreso || oldDelegate.dark != dark;
  }
}
