import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'app_theme.dart';
import 'navegacion_glass.dart';
import 'notificaciones.dart';
import 'perfil.dart';

const azulTec = Color(0xFF083D91);
const azulBrillante = Color(0xFF2868ED);
const azulClaro = Color(0xFF79B5FF);
const fondoCalendario = Color(0xFFF2F6FD);
const textoSecundario = Color(0xFF718096);
const rojoTec = Color(0xFFE11D35);
const verdeTec = Color(0xFF16805D);

const categoriasCalendario = [
  'Técnico',
  'Licenciatura',
  'Posgrado',
  'Otro',
];

Color colorCategoria(String categoria) {
  switch (categoria) {
    case 'Técnico':
      return azulTec;
    case 'Licenciatura':
      return const Color(0xFF8051E8);
    case 'Posgrado':
      return azulBrillante;
    case 'Otro':
      return verdeTec;
    default:
      return textoSecundario;
  }
}

/// Oculta las barras de desplazamiento sin desactivar el scroll.
class ScrollBehaviorInvisible extends MaterialScrollBehavior {
  const ScrollBehaviorInvisible();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class Evento {
  final String id;
  final String titulo;
  final String descripcion;
  final DateTime fecha;
  final String hora;
  final String categoria;

  const Evento({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.hora,
    required this.categoria,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'descripcion': descripcion,
        'fecha': fecha.toIso8601String(),
        'hora': hora,
        'categoria': categoria,
      };

  factory Evento.fromJson(Map<String, dynamic> json) => Evento(
        id: json['id']?.toString() ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        titulo: json['titulo']?.toString() ?? 'Actividad',
        descripcion: json['descripcion']?.toString() ?? '',
        fecha: DateTime.tryParse(json['fecha']?.toString() ?? '') ??
            DateTime.now(),
        hora: json['hora']?.toString() ?? '08:00',
        categoria: categoriasCalendario.contains(json['categoria'])
            ? json['categoria'].toString()
            : 'Otro',
      );
}

class CalendarioPage extends StatefulWidget {
  final bool embedded;
  final VoidCallback? onBack;
  final ValueChanged<int>? onSectionSelected;

  const CalendarioPage({
    super.key,
    this.embedded = false,
    this.onBack,
    this.onSectionSelected,
  });

  @override
  State<CalendarioPage> createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage>
    with SingleTickerProviderStateMixin {
  static const String _clave = 'calendario_eventos_v2';

  final FlutterLocalNotificationsPlugin _notificaciones =
      FlutterLocalNotificationsPlugin();

  final TextEditingController _busqueda = TextEditingController();

  List<Evento> _eventos = [];

  DateTime _mesVisible = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  DateTime _seleccionada = DateUtils.dateOnly(DateTime.now());

  String _filtro = 'Todos';
  String _consulta = '';

  bool _cargando = true;
  bool _notificacionesActivas = false;

  void _seleccionarSeccion(int index) {
    if (widget.onSectionSelected != null) {
      widget.onSectionSelected!(index);
      return;
    }

    if (index == 1) return;

    if (index == 0) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
      return;
    }

    Navigator.of(context).push(
      appPageRoute<void>(
        builder: (context) => index == 2
            ? const NotificacionesScreen()
            : const PerfilPage(),
      ),
    );
  }

  late final AnimationController _entrada = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  @override
  void dispose() {
    _entrada.dispose();
    _busqueda.dispose();
    super.dispose();
  }

  Future<void> _inicializar() async {
    await _iniciarNotificaciones();
    await _cargarEventos();

    if (mounted) {
      _entrada.forward();
    }
  }

  Future<void> _iniciarNotificaciones() async {
    if (kIsWeb) {
      _notificacionesActivas = false;
      return;
    }

    try {
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('America/Costa_Rica'));

      const ajustes = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );

      await _notificaciones.initialize(ajustes);

      final android = _notificaciones
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await android?.requestNotificationsPermission();

      final ios = _notificaciones
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      _notificacionesActivas = true;
    } catch (e) {
      _notificacionesActivas = false;
      debugPrint('Error iniciando notificaciones: $e');
    }
  }

  int _idAviso(Evento evento) {
    var hash = 0x811C9DC5;

    for (final unidad in evento.id.codeUnits) {
      hash = ((hash ^ unidad) * 0x01000193) & 0x7FFFFFFF;
    }

    return hash;
  }

  Future<void> _programarAviso(Evento evento) async {
    if (!_notificacionesActivas) return;

    try {
      final partes = evento.hora.split(':');
      final hora = int.tryParse(partes[0]) ?? 8;
      final minuto =
          partes.length > 1 ? int.tryParse(partes[1]) ?? 0 : 0;

      final inicio = DateTime(
        evento.fecha.year,
        evento.fecha.month,
        evento.fecha.day,
        hora,
        minuto,
      );

      final aviso = inicio.subtract(const Duration(days: 2));
      final id = _idAviso(evento);

      await _notificaciones.cancel(id);

      if (!aviso.isAfter(DateTime.now())) return;

      const detalles = NotificationDetails(
        android: AndroidNotificationDetails(
          'calendario_tec',
          'Recordatorios académicos',
          channelDescription: 'Avisos del calendario académico',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      );

      await _notificaciones.zonedSchedule(
        id,
        evento.titulo,
        evento.descripcion.isNotEmpty
            ? evento.descripcion
            : 'Tenés una actividad académica próximamente.',
        tz.TZDateTime.from(aviso, tz.local),
        detalles,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Error programando aviso: $e');
    }
  }

  Future<void> _cancelarAviso(Evento evento) async {
    if (!_notificacionesActivas) return;

    try {
      await _notificaciones.cancel(_idAviso(evento));
    } catch (e) {
      debugPrint('Error cancelando aviso: $e');
    }
  }

  Future<void> _cargarEventos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final datos = prefs.getString(_clave);

      if (datos != null) {
        final lista = jsonDecode(datos) as List<dynamic>;

        _eventos = lista
            .map(
              (e) => Evento.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Error cargando actividades: $e');
    }

    if (!mounted) return;

    setState(() => _cargando = false);

    for (final evento in _eventos) {
      await _programarAviso(evento);
    }
  }

  Future<void> _guardarEventos() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        _clave,
        jsonEncode(_eventos.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudieron guardar las actividades.'),
        ),
      );
    }
  }

  bool _mismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _nombreMes(int mes) => const [
        'Enero',
        'Febrero',
        'Marzo',
        'Abril',
        'Mayo',
        'Junio',
        'Julio',
        'Agosto',
        'Septiembre',
        'Octubre',
        'Noviembre',
        'Diciembre',
      ][mes - 1];

  String _fechaLarga(DateTime fecha) =>
      '${fecha.day} de ${_nombreMes(fecha.month)} de ${fecha.year}';

  List<Evento> get _eventosDelDia {
    final resultado = _eventos.where((e) {
      final coincideDia = _mismoDia(e.fecha, _seleccionada);
      final coincideCategoria =
          _filtro == 'Todos' || e.categoria == _filtro;

      final texto =
          '${e.titulo} ${e.descripcion} ${e.categoria}'.toLowerCase();

      final coincideTexto = texto.contains(_consulta.toLowerCase());

      return coincideDia && coincideCategoria && coincideTexto;
    }).toList();

    resultado.sort((a, b) => a.hora.compareTo(b.hora));
    return resultado;
  }

  List<Evento> _eventosDeFecha(DateTime fecha) =>
      _eventos.where((e) => _mismoDia(e.fecha, fecha)).toList();

  void _cambiarMes(int cambio) {
    setState(() {
      _mesVisible = DateTime(
        _mesVisible.year,
        _mesVisible.month + cambio,
      );

      final maximo =
          DateTime(_mesVisible.year, _mesVisible.month + 1, 0).day;

      _seleccionada = DateTime(
        _mesVisible.year,
        _mesVisible.month,
        _seleccionada.day.clamp(1, maximo),
      );
    });
  }

  void _irHoy() {
    final hoy = DateUtils.dateOnly(DateTime.now());

    setState(() {
      _seleccionada = hoy;
      _mesVisible = DateTime(hoy.year, hoy.month);
      _filtro = 'Todos';
      _consulta = '';
      _busqueda.clear();
    });
  }

  Future<void> _abrirFormulario({Evento? evento}) async {
    final resultado = await showModalBottomSheet<Evento>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FormularioEvento(
        evento: evento,
        fechaInicial: _seleccionada,
      ),
    );

    if (resultado == null || !mounted) return;

    if (evento != null) {
      await _cancelarAviso(evento);
    }

    setState(() {
      final indice = _eventos.indexWhere((e) => e.id == resultado.id);

      if (indice == -1) {
        _eventos.add(resultado);
      } else {
        _eventos[indice] = resultado;
      }

      _seleccionada = DateUtils.dateOnly(resultado.fecha);
      _mesVisible = DateTime(
        resultado.fecha.year,
        resultado.fecha.month,
      );
    });

    await _guardarEventos();
    await _programarAviso(resultado);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: azulTec,
        content: Text(
          evento == null
              ? 'Actividad guardada correctamente'
              : 'Actividad actualizada correctamente',
        ),
      ),
    );
  }

  Future<void> _eliminar(Evento evento) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar actividad'),
        content: Text('¿Deseás eliminar "${evento.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: rojoTec,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    await _cancelarAviso(evento);

    setState(() {
      _eventos.removeWhere((e) => e.id == evento.id);
    });

    await _guardarEventos();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const ScrollBehaviorInvisible(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        extendBody: true,
        body: Stack(
          children: [
            const Positioned.fill(
              child: _FondoLiquidGlass(),
            ),
            SafeArea(
              bottom: false,
              child: _cargando
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: azulBrillante,
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final ancho = constraints.maxWidth;

                        // Solo se usan dos columnas cuando realmente hay
                        // suficiente espacio horizontal para ambas.
                        // Los teléfonos, incluso en horizontal, conservan
                        // una única columna con desplazamiento vertical.
                        final ladoALado = ancho >= 900;

                        return Column(
                          children: [
                            _construirAppBar(),
                            Expanded(
                              child: ladoALado
                                  ? Center(
                                      child: ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(
                                          maxWidth: 1400,
                                        ),
                                        child: LayoutBuilder(
                                          builder: (context, interno) {
                                            final disponible =
                                                interno.maxWidth;

                                            final anchoCalendario =
                                                (disponible * .44)
                                                    .clamp(320.0, 520.0)
                                                    .toDouble();

                                            return Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: anchoCalendario,
                                                  child:
                                                      SingleChildScrollView(
                                                    physics:
                                                        const BouncingScrollPhysics(),
                                                    padding:
                                                        const EdgeInsets.only(
                                                      bottom: 24,
                                                    ),
                                                    child:
                                                        _construirCalendario(),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: _construirAgenda(),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  : SingleChildScrollView(
                                      primary: false,
                                      physics:
                                          const BouncingScrollPhysics(
                                        parent:
                                            AlwaysScrollableScrollPhysics(),
                                      ),
                                      keyboardDismissBehavior:
                                          ScrollViewKeyboardDismissBehavior
                                              .onDrag,
                                      padding: EdgeInsets.only(
                                        bottom: MediaQuery.viewPaddingOf(
                                                  context,
                                                ).bottom +
                                            110,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _construirCalendario(),
                                          _construirAgenda(
                                            dentroDesplazamiento: true,
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: widget.embedded ? 100 : 18),
          child: FloatingActionButton.extended(
            backgroundColor: azulTec,
            foregroundColor: Colors.white,
            elevation: 8,
            onPressed: () => _abrirFormulario(),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Nuevo evento',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        bottomNavigationBar: widget.embedded
            ? null
            : NavegacionGlass(
                selectedIndex: 1,
                onSelected: _seleccionarSeccion,
              ),
      ),
    );
  }

  Widget _construirAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
      child: Row(
        children: [
          _botonCristal(
            Icons.arrow_back_rounded,
            () {
              if (widget.onBack != null) {
                widget.onBack!();
              } else if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mi calendario',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.6,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'ORGANIZÁ TU VIDA ACADÉMICA',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 9,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          _botonCristal(Icons.today_rounded, _irHoy),
        ],
      ),
    );
  }

  Widget _construirCalendario() {
    final hoy = DateUtils.dateOnly(DateTime.now());
    final primero = DateTime(_mesVisible.year, _mesVisible.month, 1);
    final desplazamiento = primero.weekday - 1;
    final diasMes =
        DateTime(_mesVisible.year, _mesVisible.month + 1, 0).day;
    final totalCeldas = desplazamiento + diasMes <= 35 ? 35 : 42;

    return LayoutBuilder(
      builder: (context, constraints) {
        final ancho = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        final estrecho = ancho < 360;

        return _vidrio(
          margen: const EdgeInsets.fromLTRB(14, 5, 14, 12),
          radio: 28,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              estrecho ? 12 : 18,
              18,
              estrecho ? 12 : 18,
              16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              '${_nombreMes(_mesVisible.month)} '
                              '${_mesVisible.year}',
                              key: ValueKey(_mesVisible),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: estrecho ? 20 : 23,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_eventos.length} actividades registradas',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _botonCristal(
                      Icons.chevron_left_rounded,
                      () => _cambiarMes(-1),
                    ),
                    const SizedBox(width: 7),
                    _botonCristal(
                      Icons.chevron_right_rounded,
                      () => _cambiarMes(1),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: ['L', 'M', 'X', 'J', 'V', 'S', 'D']
                      .map(
                        (d) => Expanded(
                          child: Center(
                            child: Text(
                              d,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  key: ValueKey(
                    '${_mesVisible.year}-${_mesVisible.month}',
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: totalCeldas,
                  gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: estrecho ? 2 : 4,
                    mainAxisSpacing: 5,
                    childAspectRatio: estrecho ? 1.05 : .96,
                  ),
                  itemBuilder: (context, index) {
                    final dia = index - desplazamiento + 1;

                    if (dia < 1 || dia > diasMes) {
                      return const SizedBox.shrink();
                    }

                    final fecha = DateTime(
                      _mesVisible.year,
                      _mesVisible.month,
                      dia,
                    );

                    return _CeldaDia(
                      dia: dia,
                      seleccionado: _mismoDia(fecha, _seleccionada),
                      esHoy: _mismoDia(fecha, hoy),
                      eventos: _eventosDeFecha(fecha),
                      onTap: () {
                        setState(() => _seleccionada = fecha);
                      },
                    );
                  },
                ),
                const SizedBox(height: 13),
                const Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _Leyenda(color: rojoTec, texto: 'Hoy'),
                    _Leyenda(
                      color: azulBrillante,
                      texto: 'Seleccionado',
                    ),
                    _Leyenda(
                      color: Color(0xFF8051E8),
                      texto: 'Licenciatura',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _construirAgenda({bool dentroDesplazamiento = false}) {
    final eventos = _eventosDelDia;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        5,
        16,
        dentroDesplazamiento ? 18 : 100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: dentroDesplazamiento
            ? MainAxisSize.min
            : MainAxisSize.max,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TU AGENDA',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 10,
                        letterSpacing: 1.8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _fechaLarga(_seleccionada),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              _botonCristal(
                Icons.filter_alt_rounded,
                _mostrarFiltros,
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _busqueda,
            onChanged: (valor) => setState(() => _consulta = valor),
            decoration: InputDecoration(
              hintText: 'Buscar actividades...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _consulta.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _busqueda.clear();
                        setState(() => _consulta = '');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface.withValues(
                    alpha: .8,
                  ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 39,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: ['Todos', ...categoriasCalendario].map((categoria) {
                final activo = _filtro == categoria;
                final color = categoria == 'Todos'
                    ? azulTec
                    : colorCategoria(categoria);

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(categoria),
                    selected: activo,
                    onSelected: (_) =>
                        setState(() => _filtro = categoria),
                    selectedColor: color,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: .8),
                    labelStyle: TextStyle(
                      color: activo
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          if (dentroDesplazamiento)
            if (eventos.isEmpty)
              _estadoVacio()
            else
              ...eventos.map(
                (evento) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _tarjetaEvento(evento),
                ),
              )
          else
            Expanded(
              child: eventos.isEmpty
                  ? SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: _estadoVacio(),
                    )
                  : ListView.separated(
                      primary: false,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: eventos.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (_, index) =>
                          _tarjetaEvento(eventos[index]),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _estadoVacio() {
    return _vidrio(
      radio: 26,
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFDCEAFF), azulClaro],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_available_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Un día para organizarte',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agregá clases, exámenes, entregas y recordatorios '
              'para tener todo bajo control.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 15),
            FilledButton.icon(
              onPressed: () => _abrirFormulario(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Crear actividad'),
              style: FilledButton.styleFrom(
                backgroundColor: azulTec,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaEvento(Evento evento) {
    final color = colorCategoria(evento.categoria);

    return Dismissible(
      key: ValueKey(evento.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          color: rojoTec,
          borderRadius: BorderRadius.circular(23),
        ),
        child: const Icon(
          Icons.delete_rounded,
          color: Colors.white,
          size: 27,
        ),
      ),
      confirmDismiss: (_) async {
        await _eliminar(evento);
        return false;
      },
      child: _vidrio(
        radio: 23,
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(23),
                  ),
                ),
              ),
              Container(
                width: 56,
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      evento.fecha.day.toString().padLeft(2, '0'),
                      style: TextStyle(
                        color: color,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      _nombreMes(evento.fecha.month)
                          .substring(0, 3)
                          .toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        evento.titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (evento.descripcion.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(
                          evento.descripcion,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 7,
                        runSpacing: 5,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            color: color,
                            size: 14,
                          ),
                          Text(
                            evento.hora,
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: .1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              evento.categoria,
                              style: TextStyle(
                                color: color,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (accion) {
                  if (accion == 'editar') {
                    _abrirFormulario(evento: evento);
                  } else {
                    _eliminar(evento);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'editar',
                    child: Text('Editar'),
                  ),
                  PopupMenuItem(
                    value: 'eliminar',
                    child: Text('Eliminar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarFiltros() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _vidrio(
        radio: 28,
        margen: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtrar actividades',
                style: TextStyle(
                  color: Theme.of(ctx).colorScheme.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              ...['Todos', ...categoriasCalendario].map((categoria) {
                final color = categoria == 'Todos'
                    ? azulTec
                    : colorCategoria(categoria);

                return ListTile(
                  leading: Icon(
                    categoria == 'Todos'
                        ? Icons.grid_view_rounded
                        : Icons.circle,
                    color: color,
                  ),
                  title: Text(categoria),
                  trailing: _filtro == categoria
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: azulBrillante,
                        )
                      : null,
                  onTap: () {
                    setState(() => _filtro = categoria);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _botonCristal(IconData icono, VoidCallback accion) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: (dark ? const Color(0xFF26384A) : Colors.white)
              .withValues(alpha: .75),
          child: InkWell(
            onTap: accion,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                border: Border.all(
                  color: (dark ? const Color(0xFF52677D) : Colors.white)
                      .withValues(alpha: .9),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icono,
                color: Theme.of(context).colorScheme.onSurface,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _vidrio({
    required Widget child,
    EdgeInsetsGeometry? margen,
    double radio = 24,
  }) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: margen,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radio),
        boxShadow: [
          BoxShadow(
            color: azulTec.withValues(alpha: .06),
            blurRadius: 24,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radio),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 13, sigmaY: 13),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (dark ? const Color(0xFF26384A) : Colors.white)
                      .withValues(alpha: .88),
                  (dark ? const Color(0xFF1D2C3B) : Colors.white)
                      .withValues(alpha: .66),
                  (dark ? const Color(0xFF192838) : const Color(0xFFEAF2FF))
                      .withValues(alpha: .65),
                ],
              ),
              border: Border.all(
                color: (dark ? const Color(0xFF536B82) : Colors.white)
                    .withValues(alpha: .95),
              ),
              borderRadius: BorderRadius.circular(radio),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _Leyenda extends StatelessWidget {
  final Color color;
  final String texto;

  const _Leyenda({
    required this.color,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          texto,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FondoLiquidGlass extends StatelessWidget {
  const _FondoLiquidGlass();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dark
                  ? const [
                      Color(0xFF101923),
                      Color(0xFF152231),
                      Color(0xFF1B2B3B),
                    ]
                  : const [
                      Color(0xFFF8FAFF),
                      Color(0xFFEDF4FF),
                      Color(0xFFF7F8FD),
                    ],
            ),
          ),
        ),
        Positioned(
          top: -100,
          right: -90,
          child: _halo(270, azulClaro.withValues(alpha: .19)),
        ),
        Positioned(
          top: 310,
          left: -130,
          child: _halo(
            260,
            const Color(0xFF8DABFF).withValues(alpha: .13),
          ),
        ),
        Positioned(
          bottom: -100,
          right: -80,
          child: _halo(
            300,
            const Color(0xFF9DCFFF).withValues(alpha: .17),
          ),
        ),
      ],
    );
  }

  Widget _halo(double size, Color color) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _CeldaDia extends StatefulWidget {
  final int dia;
  final bool seleccionado;
  final bool esHoy;
  final List<Evento> eventos;
  final VoidCallback onTap;

  const _CeldaDia({
    required this.dia,
    required this.seleccionado,
    required this.esHoy,
    required this.eventos,
    required this.onTap,
  });

  @override
  State<_CeldaDia> createState() => _CeldaDiaState();
}

class _CeldaDiaState extends State<_CeldaDia> {
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    final seleccionado = widget.seleccionado;
    final esHoy = widget.esHoy;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedScale(
      scale: _presionado ? .9 : 1,
      duration: const Duration(milliseconds: 120),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 230),
        decoration: BoxDecoration(
          gradient: seleccionado
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4389FF),
                    azulBrillante,
                    azulTec,
                  ],
                )
              : esHoy
                  ? LinearGradient(
                      colors: [
                        const Color(0xFFFFF0F2),
                        rojoTec.withValues(alpha: .07),
                      ],
                    )
                  : null,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: seleccionado
                ? Colors.white.withValues(alpha: .7)
                : esHoy
                    ? rojoTec.withValues(alpha: .65)
                    : Colors.transparent,
          ),
          boxShadow: seleccionado
              ? [
                  BoxShadow(
                    color: azulBrillante.withValues(alpha: .25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: widget.onTap,
            onHighlightChanged: (valor) {
              setState(() => _presionado = valor);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${widget.dia}',
                  style: TextStyle(
                    color: seleccionado
                        ? Colors.white
                        : esHoy
                            ? rojoTec
                            : dark
                                ? const Color(0xFFE4EDF7)
                                : azulTec,
                    fontWeight: seleccionado || esHoy
                        ? FontWeight.w900
                        : FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.eventos.take(3).map((evento) {
                      return Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: seleccionado
                              ? Colors.white
                              : colorCategoria(evento.categoria),
                          shape: BoxShape.circle,
                        ),
                      );
                    }).toList(),
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

class FormularioEvento extends StatefulWidget {
  final Evento? evento;
  final DateTime fechaInicial;

  const FormularioEvento({
    super.key,
    required this.evento,
    required this.fechaInicial,
  });

  @override
  State<FormularioEvento> createState() => _FormularioEventoState();
}

class _FormularioEventoState extends State<FormularioEvento> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titulo;
  late final TextEditingController _descripcion;

  late DateTime _fecha;
  late TimeOfDay _hora;
  late String _categoria;

  @override
  void initState() {
    super.initState();

    final evento = widget.evento;

    _titulo = TextEditingController(text: evento?.titulo ?? '');
    _descripcion =
        TextEditingController(text: evento?.descripcion ?? '');

    _fecha = evento?.fecha ?? widget.fechaInicial;

    final partes = (evento?.hora ?? '08:00').split(':');

    _hora = TimeOfDay(
      hour: (int.tryParse(partes[0]) ?? 8).clamp(0, 23),
      minute: (partes.length > 1
              ? int.tryParse(partes[1]) ?? 0
              : 0)
          .clamp(0, 59),
    );

    _categoria = categoriasCalendario.contains(evento?.categoria)
        ? evento!.categoria
        : categoriasCalendario.first;
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  String _fechaTexto(DateTime fecha) =>
      '${fecha.day.toString().padLeft(2, '0')}/'
      '${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';

  String _horaTexto(TimeOfDay hora) =>
      '${hora.hour.toString().padLeft(2, '0')}:'
      '${hora.minute.toString().padLeft(2, '0')}';

  InputDecoration _decoracion(String texto, IconData icono) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return InputDecoration(
      labelText: texto,
      prefixIcon: Icon(icono, color: azulBrillante),
      filled: true,
      fillColor: (dark ? const Color(0xFF26384A) : const Color(0xFFEFF4FC))
          .withValues(alpha: .8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide(
          color: dark ? const Color(0xFF536B82) : const Color(0xFFDCE7F6),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(
          color: azulBrillante,
          width: 1.5,
        ),
      ),
    );
  }

  Future<void> _elegirFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: azulTec,
                secondary: azulBrillante,
              ),
        ),
        child: child!,
      ),
    );

    if (elegida != null) {
      setState(() => _fecha = elegida);
    }
  }

  Future<void> _elegirHora() async {
    final elegida = await showTimePicker(
      context: context,
      initialTime: _hora,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: azulTec,
            secondary: azulBrillante,
          ),
        ),
        child: child!,
      ),
    );

    if (elegida != null) {
      setState(() => _hora = elegida);
    }
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    final evento = Evento(
      id: widget.evento?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      titulo: _titulo.text.trim(),
      descripcion: _descripcion.text.trim(),
      fecha: DateUtils.dateOnly(_fecha),
      hora: _horaTexto(_hora),
      categoria: _categoria,
    );

    Navigator.pop(context, evento);
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.evento != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * .9,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF26384A)
                      : Colors.white.withValues(alpha: .98),
                  Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1B2938)
                      : const Color(0xFFF0F5FF).withValues(alpha: .98),
                ],
              ),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF536B82)
                    : Colors.white.withValues(alpha: .95),
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 26),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD5E1F2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        editando ? 'Editar actividad' : 'Nueva actividad',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Clases, exámenes, entregas y recordatorios.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 22),
                      TextFormField(
                        controller: _titulo,
                        textCapitalization: TextCapitalization.sentences,
                        maxLength: 100,
                        decoration: _decoracion(
                          'Nombre de la actividad',
                          Icons.event_note_rounded,
                        ),
                        validator: (valor) =>
                            valor == null || valor.trim().isEmpty
                                ? 'Escribí el nombre de la actividad'
                                : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _descripcion,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 3,
                        maxLength: 300,
                        decoration: _decoracion(
                          'Descripción (opcional)',
                          Icons.notes_rounded,
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: _categoria,
                        isExpanded: true,
                        decoration: _decoracion(
                          'Área académica',
                          Icons.school_rounded,
                        ),
                        items: categoriasCalendario
                            .map(
                              (categoria) => DropdownMenuItem(
                                value: categoria,
                                child: Text(categoria),
                              ),
                            )
                            .toList(),
                        onChanged: (valor) {
                          if (valor != null) {
                            setState(() => _categoria = valor);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final vertical = constraints.maxWidth < 330;

                          final botonFecha = OutlinedButton.icon(
                            onPressed: _elegirFecha,
                            icon: const Icon(
                              Icons.calendar_month_rounded,
                            ),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(_fechaTexto(_fecha)),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: azulTec,
                              padding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 8,
                              ),
                              side: const BorderSide(
                                color: Color(0xFFD6E3F5),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          );

                          final botonHora = OutlinedButton.icon(
                            onPressed: _elegirHora,
                            icon: const Icon(
                              Icons.access_time_rounded,
                            ),
                            label: Text(_horaTexto(_hora)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: azulTec,
                              padding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 8,
                              ),
                              side: const BorderSide(
                                color: Color(0xFFD6E3F5),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          );

                          if (vertical) {
                            return Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                botonFecha,
                                const SizedBox(height: 10),
                                botonHora,
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(child: botonFecha),
                              const SizedBox(width: 10),
                              Expanded(child: botonHora),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _guardar,
                          style: FilledButton.styleFrom(
                            backgroundColor: azulTec,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 17,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                          ),
                          icon: const Icon(Icons.check_rounded),
                          label: Text(
                            editando
                                ? 'Guardar cambios'
                                : 'Guardar actividad',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
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
    );
  }
}