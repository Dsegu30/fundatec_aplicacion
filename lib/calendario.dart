
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CalendarioApp());
}

class CalendarioApp extends StatelessWidget {
  const CalendarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendario TEC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: fondoCalendario,
        colorScheme: ColorScheme.fromSeed(
          seedColor: azulTec,
          primary: azulTec,
          secondary: azulBrillante,
          surface: Colors.white,
        ),
        splashFactory: InkSparkle.splashFactory,
      ),
      home: const CalendarioPage(),
    );
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
        titulo: json['titulo']?.toString() ?? 'Evento',
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
  const CalendarioPage({super.key});

  @override
  State<CalendarioPage> createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage>
    with TickerProviderStateMixin {
  static const String _clave = 'calendario_eventos_v2';

  final FlutterLocalNotificationsPlugin _notificaciones =
      FlutterLocalNotificationsPlugin();

  List<Evento> _eventos = [];

  DateTime _mesVisible = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _seleccionada = DateUtils.dateOnly(DateTime.now());

  String _filtro = 'Todos';
  bool _cargando = true;
  bool _notificacionesActivas = false;

  late final AnimationController _entrada = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  );

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  @override
  void dispose() {
    _entrada.dispose();
    super.dispose();
  }

  Future<void> _inicializar() async {
    await _iniciarNotificaciones();
    await _cargarEventos();
    if (mounted) _entrada.forward();
  }

  Future<void> _iniciarNotificaciones() async {
    try {
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('America/Costa_Rica'));

      const ajustes = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );

      await _notificaciones.initialize(settings: ajustes);

      final android = _notificaciones
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();

      final ios = _notificaciones
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      await ios?.requestPermissions(alert: true, badge: true, sound: true);

      _notificacionesActivas = true;
    } catch (e) {
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

      // Aviso automático dos días antes.
      final aviso = inicio.subtract(const Duration(days: 2));
      final id = _idAviso(evento);

      await _notificaciones.cancel(id: id);

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
        id: id,
        title: 'Recordatorio: ${evento.titulo}',
        body: 'Tu actividad es el ${_fechaCorta(evento.fecha)} '
            'a las ${evento.hora}.',
        scheduledDate: tz.TZDateTime.from(aviso, tz.local),
        notificationDetails: detalles,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Error programando aviso: $e');
    }
  }

  Future<void> _cancelarAviso(Evento evento) async {
    if (!_notificacionesActivas) return;
    try {
      await _notificaciones.cancel(id: _idAviso(evento));
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
            .map((e) => Evento.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (e) {
      debugPrint('Error cargando eventos: $e');
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
        const SnackBar(content: Text('No se pudieron guardar los eventos.')),
      );
    }
  }

  bool _mismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _nombreMes(int mes) => const [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
      ][mes - 1];

  String _fechaCorta(DateTime fecha) =>
      '${fecha.day.toString().padLeft(2, '0')}/'
      '${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';

  String _fechaLarga(DateTime fecha) =>
      '${fecha.day} de ${_nombreMes(fecha.month)} de ${fecha.year}';

  List<Evento> get _eventosDelDia {
    final resultado = _eventos.where((e) =>
        _mismoDia(e.fecha, _seleccionada) &&
        (_filtro == 'Todos' || e.categoria == _filtro)).toList();
    resultado.sort((a, b) => a.hora.compareTo(b.hora));
    return resultado;
  }

  List<Evento> _eventosDeFecha(DateTime fecha) =>
      _eventos.where((e) => _mismoDia(e.fecha, fecha)).toList();

  void _cambiarMes(int cambio) {
    setState(() {
      _mesVisible = DateTime(_mesVisible.year, _mesVisible.month + cambio);
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
    });
  }

  Future<void> _abrirFormulario({Evento? evento}) async {
    final resultado = await showModalBottomSheet<Evento>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: azulTec.withValues(alpha: 0.24),
      builder: (_) => FormularioEvento(
        evento: evento,
        fechaInicial: _seleccionada,
      ),
    );

    if (resultado == null || !mounted) return;

    if (evento != null) await _cancelarAviso(evento);

    setState(() {
      final indice = _eventos.indexWhere((e) => e.id == resultado.id);
      if (indice == -1) {
        _eventos.add(resultado);
      } else {
        _eventos[indice] = resultado;
      }

      _seleccionada = DateUtils.dateOnly(resultado.fecha);
      _mesVisible = DateTime(resultado.fecha.year, resultado.fecha.month);
    });

    await _guardarEventos();
    await _programarAviso(resultado);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: azulTec,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        content: Text(evento == null
            ? 'Actividad guardada correctamente'
            : 'Actividad actualizada correctamente'),
      ),
    );
  }

  Future<void> _eliminar(Evento evento) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Eliminar actividad'),
        content: Text('¿Deseás eliminar "${evento.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: rojoTec),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;
    await _cancelarAviso(evento);
    setState(() => _eventos.removeWhere((e) => e.id == evento.id));
    await _guardarEventos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: fondoCalendario,
      body: Stack(
        children: [
          const Positioned.fill(child: _FondoLiquidGlass()),
          SafeArea(
            bottom: false,
            child: _cargando
                ? const Center(
                    child: CircularProgressIndicator(color: azulBrillante),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final ancho = constraints.maxWidth;
                      final escritorio = ancho >= 850;

                      return Column(
                        children: [
                          _construirAppBar(),
                          Expanded(
                            child: escritorio
                                ? Center(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                          maxWidth: 1200),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: ancho.clamp(850, 1200) * .43,
                                            child: _construirCalendario(),
                                          ),
                                          Expanded(child: _construirAgenda()),
                                        ],
                                      ),
                                    ),
                                  )
                                : Column(
                                    children: [
                                      _construirCalendario(),
                                      Expanded(child: _construirAgenda()),
                                    ],
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: _botonFlotante(
          icono: Icons.add_rounded,
          texto: 'Nuevo evento',
          onTap: () => _abrirFormulario(),
        ),
      ),
    );
  }

  Widget _construirAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
      child: Row(
        children: [
          _glassButton(
            icon: Icons.arrow_back_rounded,
            onTap: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mi calendario',
                  style: TextStyle(
                    color: azulTec,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.6,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'ORGANIZÁ TU VIDA ACADÉMICA',
                  style: TextStyle(
                    color: textoSecundario,
                    fontSize: 9,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          _glassButton(icon: Icons.today_rounded, onTap: _irHoy),
        ],
      ),
    );
  }

  Widget _construirCalendario() {
    final hoy = DateUtils.dateOnly(DateTime.now());
    final primero = DateTime(_mesVisible.year, _mesVisible.month, 1);
    final desplazamiento = primero.weekday - 1;
    final diasMes = DateTime(_mesVisible.year, _mesVisible.month + 1, 0).day;
    final totalCeldas = desplazamiento + diasMes <= 35 ? 35 : 42;

    return _vidrio(
      margen: const EdgeInsets.fromLTRB(14, 5, 14, 12),
      radio: 30,
      intensidad: 14,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(.06, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: Text(
                          '${_nombreMes(_mesVisible.month)} ${_mesVisible.year}',
                          key: ValueKey(_mesVisible),
                          style: const TextStyle(
                            color: azulTec,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -.7,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_eventos.length} actividades registradas',
                        style: const TextStyle(
                          color: textoSecundario,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _glassButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => _cambiarMes(-1),
                ),
                const SizedBox(width: 8),
                _glassButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: () => _cambiarMes(1),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: ['L', 'M', 'X', 'J', 'V', 'S', 'D']
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(
                            d,
                            style: const TextStyle(
                              color: textoSecundario,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: GridView.builder(
                key: ValueKey('${_mesVisible.year}-${_mesVisible.month}'),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: totalCeldas,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 6,
                  childAspectRatio: .87,
                ),
                itemBuilder: (context, index) {
                  final dia = index - desplazamiento + 1;
                  if (dia < 1 || dia > diasMes) {
                    return const SizedBox.shrink();
                  }

                  final fecha =
                      DateTime(_mesVisible.year, _mesVisible.month, dia);
                  final seleccionado = _mismoDia(fecha, _seleccionada);
                  final esHoy = _mismoDia(fecha, hoy);
                  final eventos = _eventosDeFecha(fecha);

                  return _CeldaDia(
                    dia: dia,
                    seleccionado: seleccionado,
                    esHoy: esHoy,
                    eventos: eventos,
                    onTap: () => setState(() => _seleccionada = fecha),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 14,
              runSpacing: 9,
              alignment: WrapAlignment.center,
              children: [
                _leyenda(rojoTec, 'Hoy'),
                _leyenda(azulBrillante, 'Seleccionado'),
                _leyenda(const Color(0xFF8051E8), 'Licenciatura'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _leyenda(Color color, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: .3), blurRadius: 5),
            ],
          ),
        ),
        const SizedBox(width: 5),
        Text(
          texto,
          style: const TextStyle(
            color: textoSecundario,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _construirAgenda() {
    final eventos = _eventosDelDia;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TU AGENDA',
                      style: TextStyle(
                        color: textoSecundario,
                        fontSize: 10,
                        letterSpacing: 1.8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        _fechaLarga(_seleccionada),
                        key: ValueKey(_seleccionada),
                        style: const TextStyle(
                          color: azulTec,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _glassButton(
                icon: Icons.tune_rounded,
                onTap: _mostrarFiltros,
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['Todos', ...categoriasCalendario].map((categoria) {
                final activo = _filtro == categoria;
                final color =
                    categoria == 'Todos' ? azulTec : colorCategoria(categoria);

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _chipCategoria(
                    categoria: categoria,
                    activo: activo,
                    color: color,
                    onTap: () => setState(() => _filtro = categoria),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, .04),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: eventos.isEmpty
                  ? _estadoVacio(key: ValueKey('vacio-$_seleccionada-$_filtro'))
                  : ListView.separated(
                      key: ValueKey('lista-$_seleccionada-$_filtro'),
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: eventos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 11),
                      itemBuilder: (_, index) =>
                          _tarjetaEvento(eventos[index], index),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipCategoria({
    required String categoria,
    required bool activo,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 230),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: activo
            ? [
                BoxShadow(
                  color: color.withValues(alpha: .22),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: activo ? color : Colors.white.withValues(alpha: .67),
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: activo
                    ? Colors.white.withValues(alpha: .55)
                    : Colors.white.withValues(alpha: .9),
              ),
            ),
            child: Text(
              categoria,
              style: TextStyle(
                color: activo ? Colors.white : textoSecundario,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarFiltros() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _panelVidrio(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtrar actividades',
              style: TextStyle(
                color: azulTec,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Seleccioná el área académica que querés ver.',
              style: TextStyle(color: textoSecundario, fontSize: 12),
            ),
            const SizedBox(height: 12),
            ...['Todos', ...categoriasCalendario].map((categoria) {
              final color =
                  categoria == 'Todos' ? azulTec : colorCategoria(categoria);
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: Icon(
                  categoria == 'Todos'
                      ? Icons.grid_view_rounded
                      : Icons.circle,
                  color: color,
                  size: 19,
                ),
                title: Text(
                  categoria,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                trailing: _filtro == categoria
                    ? const Icon(Icons.check_circle, color: azulBrillante)
                    : null,
                onTap: () {
                  setState(() => _filtro = categoria);
                  Navigator.pop(ctx);
                },
              );
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _estadoVacio({Key? key}) {
    return Center(
      key: key,
      child: SingleChildScrollView(
        child: _vidrio(
          radio: 28,
          intensidad: 10,
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white, Color(0xFFDCEAFF), azulClaro],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: azulBrillante.withValues(alpha: .2),
                        blurRadius: 25,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.event_available_rounded,
                    color: azulTec,
                    size: 35,
                  ),
                ),
                const SizedBox(height: 17),
                const Text(
                  'Un día para organizarte',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: azulTec,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Agregá clases, exámenes, entregas y recordatorios para tener todo bajo control.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textoSecundario,
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 19),
                FilledButton.icon(
                  onPressed: () => _abrirFormulario(),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Crear actividad'),
                  style: FilledButton.styleFrom(
                    backgroundColor: azulTec,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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

  Widget _tarjetaEvento(Evento evento, int indice) {
    final color = colorCategoria(evento.categoria);

    return TweenAnimationBuilder<double>(
      key: ValueKey(evento.id),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + indice * 70),
      curve: Curves.easeOutCubic,
      builder: (context, valor, child) => Opacity(
        opacity: valor,
        child: Transform.translate(
          offset: Offset(0, 15 * (1 - valor)),
          child: child,
        ),
      ),
      child: Dismissible(
        key: ValueKey('deslizar-${evento.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: rojoTec,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.delete_rounded, color: Colors.white),
        ),
        confirmDismiss: (_) async {
          await _eliminar(evento);
          return false;
        },
        child: _vidrio(
          radio: 24,
          intensidad: 9,
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [color, color.withValues(alpha: .45)],
                    ),
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(24),
                    ),
                  ),
                ),
                Container(
                  width: 59,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withValues(alpha: .16),
                        color.withValues(alpha: .045),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: color.withValues(alpha: .10),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        evento.fecha.day.toString().padLeft(2, '0'),
                        style: TextStyle(
                          color: color,
                          fontSize: 23,
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
                          style: const TextStyle(
                            color: azulTec,
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
                            style: const TextStyle(
                              color: textoSecundario,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],
                        const SizedBox(height: 9),
                        Wrap(
                          spacing: 7,
                          runSpacing: 5,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Icon(Icons.access_time_rounded,
                                color: color, size: 14),
                            Text(
                              evento.hora,
                              style: const TextStyle(
                                color: textoSecundario,
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
                                color: color.withValues(alpha: .10),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: color.withValues(alpha: .12),
                                ),
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
                  icon: const Icon(Icons.more_vert_rounded,
                      color: textoSecundario),
                  onSelected: (accion) {
                    if (accion == 'editar') {
                      _abrirFormulario(evento: evento);
                    } else if (accion == 'eliminar') {
                      _eliminar(evento);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'editar', child: Text('Editar')),
                    PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return _BotonCristal(icon: icon, onTap: onTap);
  }

  Widget _botonFlotante({
    required IconData icono,
    required String texto,
    required VoidCallback onTap,
  }) {
    return _BotonNuevo(icono: icono, texto: texto, onTap: onTap);
  }

  Widget _vidrio({
    required Widget child,
    EdgeInsetsGeometry? margen,
    double radio = 25,
    double intensidad = 15,
  }) {
    return _TarjetaCristal(
      margen: margen,
      radio: radio,
      intensidad: intensidad,
      child: child,
    );
  }

  Widget _panelVidrio({required Widget child}) {
    return _TarjetaCristal(
      radio: 30,
      intensidad: 22,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 25, 22, 28),
        child: SafeArea(top: false, child: child),
      ),
    );
  }
}

// Fondo ambiental con halos luminosos.
class _FondoLiquidGlass extends StatelessWidget {
  const _FondoLiquidGlass();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
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
          child: _halo(260, const Color(0xFF8DABFF).withValues(alpha: .13)),
        ),
        Positioned(
          bottom: -100,
          right: -80,
          child: _halo(300, const Color(0xFF9DCFFF).withValues(alpha: .17)),
        ),
      ],
    );
  }

  Widget _halo(double size, Color color) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
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

// Panel con desenfoque, reflejo superior y borde translúcido.
class _TarjetaCristal extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margen;
  final double radio;
  final double intensidad;

  const _TarjetaCristal({
    required this.child,
    this.margen,
    required this.radio,
    required this.intensidad,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margen,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radio),
        boxShadow: [
          BoxShadow(
            color: azulTec.withValues(alpha: .055),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: .75),
            blurRadius: 2,
            spreadRadius: -1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radio),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: intensidad,
            sigmaY: intensidad,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: .83),
                  Colors.white.withValues(alpha: .58),
                  const Color(0xFFEAF2FF).withValues(alpha: .57),
                ],
              ),
              borderRadius: BorderRadius.circular(radio),
              border: Border.all(
                color: Colors.white.withValues(alpha: .95),
                width: 1.35,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 15,
                  right: 15,
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0),
                          Colors.white,
                          Colors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Botón de cristal con animación al presionar.
class _BotonCristal extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _BotonCristal({required this.icon, required this.onTap});

  @override
  State<_BotonCristal> createState() => _BotonCristalState();
}

class _BotonCristalState extends State<_BotonCristal> {
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _presionado ? .90 : 1,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Material(
            color: Colors.white.withValues(alpha: .62),
            child: InkWell(
              onTap: widget.onTap,
              onHighlightChanged: (valor) =>
                  setState(() => _presionado = valor),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .95),
                    width: 1.3,
                  ),
                ),
                child: Icon(widget.icon, color: azulTec, size: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Celda animada para cada día.
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

    return AnimatedScale(
      scale: _presionado ? .88 : 1,
      duration: const Duration(milliseconds: 120),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: seleccionado
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4389FF), azulBrillante, azulTec],
                )
              : esHoy
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFFF0F2),
                        rojoTec.withValues(alpha: .07),
                      ],
                    )
                  : null,
          color: seleccionado || esHoy ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: seleccionado
                ? Colors.white.withValues(alpha: .65)
                : esHoy
                    ? rojoTec.withValues(alpha: .65)
                    : Colors.transparent,
            width: seleccionado ? 1.2 : 1,
          ),
          boxShadow: seleccionado
              ? [
                  BoxShadow(
                    color: azulBrillante.withValues(alpha: .32),
                    blurRadius: 13,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: .30),
                    blurRadius: 1,
                    spreadRadius: -1,
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onTap,
            onHighlightChanged: (valor) =>
                setState(() => _presionado = valor),
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
                            : azulTec,
                    fontWeight: seleccionado || esHoy
                        ? FontWeight.w900
                        : FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
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

class _BotonNuevo extends StatefulWidget {
  final IconData icono;
  final String texto;
  final VoidCallback onTap;

  const _BotonNuevo({
    required this.icono,
    required this.texto,
    required this.onTap,
  });

  @override
  State<_BotonNuevo> createState() => _BotonNuevoState();
}

class _BotonNuevoState extends State<_BotonNuevo> {
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _presionado ? .94 : 1,
      duration: const Duration(milliseconds: 140),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              onHighlightChanged: (valor) =>
                  setState(() => _presionado = valor),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF3279F6),
                      azulBrillante,
                      azulTec,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .72),
                    width: 1.3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: azulBrillante.withValues(alpha: .29),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icono, color: Colors.white, size: 22),
                    const SizedBox(width: 9),
                    Text(
                      widget.texto,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
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
    _descripcion = TextEditingController(
      text: evento?.descripcion ?? '',
    );

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

  InputDecoration _decoracion(String titulo, IconData icono) {
    return InputDecoration(
      labelText: titulo,
      prefixIcon: Icon(icono, color: azulBrillante),
      filled: true,
      fillColor: const Color(0xFFEFF4FC).withValues(alpha: .80),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: Color(0xFFDCE7F6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: azulBrillante, width: 1.5),
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
          colorScheme: const ColorScheme.light(
            primary: azulTec,
            secondary: azulBrillante,
          ),
        ),
        child: child!,
      ),
    );

    if (elegida != null) setState(() => _fecha = elegida);
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

    if (elegida != null) setState(() => _hora = elegida);
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
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * .9,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: .97),
                  const Color(0xFFF0F5FF).withValues(alpha: .98),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: .95),
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
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
                      const SizedBox(height: 23),
                      Text(
                        editando ? 'Editar actividad' : 'Nueva actividad',
                        style: const TextStyle(
                          color: azulTec,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Clases, exámenes, entregas y recordatorios.',
                        style: TextStyle(
                          color: textoSecundario,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 23),
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
                      const SizedBox(height: 12),
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
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _categoria,
                        isExpanded: true,
                        decoration: _decoracion(
                          'Área académica',
                          Icons.school_rounded,
                        ),
                        items: categoriasCalendario
                            .map((categoria) => DropdownMenuItem(
                                  value: categoria,
                                  child: Text(categoria),
                                ))
                            .toList(),
                        onChanged: (valor) {
                          if (valor != null) {
                            setState(() => _categoria = valor);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _elegirFecha,
                              icon: const Icon(Icons.calendar_month_rounded),
                              label: FittedBox(
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
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _elegirHora,
                              icon: const Icon(Icons.access_time_rounded),
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
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 23),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _guardar,
                          style: FilledButton.styleFrom(
                            backgroundColor: azulTec,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 17),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                            elevation: 5,
                            shadowColor: azulTec.withValues(alpha: .25),
                          ),
                          icon: const Icon(Icons.check_rounded),
                          label: Text(
                            editando ? 'Guardar cambios' : 'Guardar actividad',
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
