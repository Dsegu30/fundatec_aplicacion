import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'dart:async';

import 'package:app_links/app_links.dart';

import 'app_theme.dart';
import 'calendario.dart';
import 'perfil.dart';
import 'notificaciones.dart';
import 'noticias.dart';
import 'tecnicos.dart';
import 'licenciatura.dart';
import 'posgrados.dart';
import 'navegacion_glass.dart';
import 'responsive_layout.dart';
import 'cursos_libres.dart';
import 'cursos_especialidades.dart';
import 'curso_detalle.dart';
import 'especialidades.dart';
import 'especialidad_detalle.dart';
import 'registro.dart' as registro;
import 'posgrados_detalle.dart';
import 'tecnico_detalle.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFFF6F8FA),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const TecApp());
}

class TecApp extends StatefulWidget {
  const TecApp({super.key, this.onLogout});

  final Future<void> Function()? onLogout;

  @override
  State<TecApp> createState() => _TecAppState();
}

class _TecAppState extends State<TecApp> {
  static const String _themeModeKey = 'app_theme_mode';
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _enlacesSubscription;

  @override
  void dispose() {
    _enlacesSubscription?.cancel();
    super.dispose();
  }

  ThemeMode _themeMode = ThemeMode.light;
  bool _mostrarRegistro = true;

  @override
  void initState() {
    super.initState();
    try {
      _mostrarRegistro = FirebaseAuth.instance.currentUser == null;
    } catch (error) {
      debugPrint('No se pudo recuperar la sesión de Firebase: $error');
      _mostrarRegistro = true;
    }
    _loadThemeMode();
    _iniciarEscuchaEnlaces();
  }

  Future<void> _loadThemeMode() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedMode = preferences.getString(_themeModeKey);

      final mode = switch (savedMode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.light,
      };

      if (mounted) {
        setState(() => _themeMode = mode);
      }
    } catch (error) {
      debugPrint('No se pudo cargar el tema guardado: $error');
    }
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    final previousMode = _themeMode;

    if (!mounted || mode == previousMode) return;

    setState(() {
      _themeMode = mode;
    });

    try {
      final preferences = await SharedPreferences.getInstance();

      final saved = await preferences.setString(
        _themeModeKey,
        mode == ThemeMode.dark ? 'dark' : 'light',
      );

      if (!saved) {
        throw StateError('La preferencia de tema no se pudo guardar.');
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _themeMode = previousMode;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('No se pudo guardar el tema: $error'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
    }
  }

  Future<void> _iniciarEscuchaEnlaces() async {
    _enlacesSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _procesarEnlaceVerificacion(uri);
      },
      onError: (Object error) {
        debugPrint('Error al recibir el enlace: $error');
      },
    );

    try {
      final enlaceInicial = await _appLinks.getInitialLink();

      if (enlaceInicial != null) {
        await _procesarEnlaceVerificacion(enlaceInicial);
      }
    } catch (error) {
      debugPrint('Error al recuperar el enlace inicial: $error');
    }
  }

  Future<void> _procesarEnlaceVerificacion(Uri uri) async {
    try {
      var enlace = uri;

      // Algunos enlaces pueden contener el enlace de acción
      // dentro de los parámetros continueUrl o link.
      for (var i = 0; i < 2; i++) {
        final anidado =
            enlace.queryParameters['continueUrl'] ??
            enlace.queryParameters['link'];

        if (anidado == null || anidado.isEmpty) break;

        final siguiente = Uri.tryParse(anidado);
        if (siguiente == null) break;

        enlace = siguiente;
      }

      final modo = enlace.queryParameters['mode'];
      final codigo = enlace.queryParameters['oobCode'];

      if (modo != 'verifyEmail' || codigo == null || codigo.isEmpty) {
        return;
      }

      await FirebaseAuth.instance.applyActionCode(codigo);

      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      setState(() {
        _mostrarRegistro = true;
      });

      debugPrint('Correo verificado correctamente.');
    } on FirebaseAuthException catch (error) {
      debugPrint('No se pudo verificar el correo: ${error.code}');
    } catch (error) {
      debugPrint('Error procesando la verificación: $error');
    }
  }

  Future<void> _cerrarSesion() async {
    final onLogout = widget.onLogout;
    if (onLogout != null) {
      await onLogout();
      return;
    }

    await FirebaseAuth.instance.signOut();
    if (mounted) setState(() => _mostrarRegistro = true);
  }

  void _registroCompletado() {
    if (mounted) setState(() => _mostrarRegistro = false);
  }

  @override
  Widget build(BuildContext context) {
    final dark = _themeMode == ThemeMode.dark;

    return AppThemePreference(
      themeMode: _themeMode,
      onThemeModeChanged: _setThemeMode,
      child: MaterialApp(
        key: ValueKey<bool>(_mostrarRegistro),
        title: 'TEC Móvil',
        debugShowCheckedModeBanner: false,
        scrollBehavior: const ScrollBehaviorInvisible(),
        theme: buildAppTheme(Brightness.light),
        darkTheme: buildAppTheme(Brightness.dark),
        themeMode: _themeMode,
        themeAnimationDuration: const Duration(milliseconds: 350),
        themeAnimationCurve: Curves.easeInOutCubic,
        builder: (context, child) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: dark
                  ? Brightness.light
                  : Brightness.dark,
              systemNavigationBarColor: dark
                  ? const Color(0xFF111923)
                  : const Color(0xFFF6F8FA),
              systemNavigationBarIconBrightness: dark
                  ? Brightness.light
                  : Brightness.dark,
            ),
            child: OrientationChangeTransition(
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
        home: _mostrarRegistro
            ? registro.RegistroPage(onRegistrationComplete: _registroCompletado)
            : TecHomeScreen(onLogout: _cerrarSesion),
      ),
    );
  }
}

// ============================================================
// COMPORTAMIENTO DE DESPLAZAMIENTO
// ============================================================

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

// ============================================================
// MODELO DE BÚSQUEDA
// ============================================================

class AppSearchItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String category;
  final VoidCallback onTap;

  const AppSearchItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.category,
    required this.onTap,
  });
}

// ============================================================
// PANTALLA PRINCIPAL
// ============================================================

class TecHomeScreen extends StatefulWidget {
  const TecHomeScreen({super.key, this.onLogout});

  final Future<void> Function()? onLogout;

  @override
  State<TecHomeScreen> createState() => _TecHomeScreenState();
}

class _TecHomeScreenState extends State<TecHomeScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryNavy = Color(0xFF061424);
  static const Color deepBlue = Color(0xFF0D233A);
  static const Color accentTeal = Color(0xFF0EA5E9);
  static const Color accentPurple = Color(0xFF6366F1);

  final ScrollController _homeScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  int selectedIndex = 0;
  int _sectionTransitionDirection = 1;
  String _searchQuery = '';
  bool _searchHasFocus = false;

  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  late final List<AppSearchItem> _searchItems = [
    AppSearchItem(
      title: 'Técnico Industrial',
      subtitle: 'Control, mejora y aseguramiento de la calidad industrial.',
      icon: Icons.verified_outlined,
      category: 'Académico',
      onTap: () => _navigateToPage(
        (_) => const TecnicoDetallePage(programa: ProgramaTecnico.calidad),
      ),
    ),
    AppSearchItem(
      title: 'Técnico en Logística e Inventarios',
      subtitle: 'Organización, almacenamiento y control de inventarios.',
      icon: Icons.inventory_2_outlined,
      category: 'Académico',
      onTap: () => _navigateToPage(
        (_) => const TecnicoDetallePage(
          programa: ProgramaTecnico.logisticaInventarios,
        ),
      ),
    ),
    AppSearchItem(
      title: 'Técnico en Supervisión de Producción',
      subtitle: 'Supervisión y optimización de procesos productivos.',
      icon: Icons.precision_manufacturing_outlined,
      category: 'Académico',
      onTap: () => _navigateToPage(
        (_) => const TecnicoDetallePage(
          programa: ProgramaTecnico.supervisionProduccion,
        ),
      ),
    ),
    AppSearchItem(
      title: 'Licenciatura Industrial',
      subtitle: 'Grado académico superior orientado a la alta gerencia.',
      icon: Icons.workspace_premium_rounded,
      category: 'Académico',
      onTap: _openLicenciatura,
    ),
    AppSearchItem(
      title: 'Doctorado Académico en Ingeniería',
      subtitle: 'Investigación avanzada y desarrollo de conocimiento técnico.',
      icon: Icons.engineering_outlined,
      category: 'Posgrado',
      onTap: () => _navigateToPage(
        (_) => const PosgradoDetallePage(
          titulo: 'Doctorado Académico en Ingeniería',
          numeroPrograma: null,
          etiquetaPrograma: 'DOCTORADO ACADÉMICO · POSGRADOS INDUSTRIAL',
          descripcion:
              'Investigación avanzada para generar conocimiento y aportar '
              'soluciones innovadoras en ingeniería.',
          enfoque:
              'Desarrolla investigación avanzada, genera conocimiento y '
              'aporta soluciones innovadoras en el campo de la ingeniería.',
          areasFormacion: [
            'Consulta con la coordinación las líneas de investigación y el '
                'proceso de admisión.',
            'Solicita información actualizada sobre requisitos, duración y '
                'modalidad.',
          ],
          idealPara:
              'Personas interesadas en desarrollar investigación avanzada en '
              'el campo de la ingeniería.',
          idealSiQueres:
              'Desarrollar investigación avanzada y generar conocimiento '
              'aplicado en ingeniería.',
          imagen:
              'https://images.unsplash.com/photo-1581092918056-0c4c3acd3789?auto=format&fit=crop&w=1600&q=85',
          colores: [Color(0xFF102A43), Color(0xFF176B87)],
        ),
      ),
    ),
    AppSearchItem(
      title: 'Maestría en Calidad Académica',
      subtitle: 'Estudio de modelos, instrumentos y estrategias de calidad.',
      icon: Icons.school_outlined,
      category: 'Posgrado',
      onTap: () => _navigateToPage((_) => const MaestriaCalidadAcademicaPage()),
    ),
    AppSearchItem(
      title: 'Maestría en Calidad Profesional',
      subtitle:
          'Gestión de la calidad orientada a resultados y mejora continua.',
      icon: Icons.fact_check_outlined,
      category: 'Posgrado',
      onTap: () =>
          _navigateToPage((_) => const MaestriaCalidadProfesionalPage()),
    ),
    AppSearchItem(
      title: 'Maestría en Cadena de Abastecimiento',
      subtitle: 'Logística, planificación y gestión eficiente de la cadena.',
      icon: Icons.local_shipping_outlined,
      category: 'Posgrado',
      onTap: () =>
          _navigateToPage((_) => const MaestriaCadenaAbastecimientoPage()),
    ),
    AppSearchItem(
      title: 'Maestría en Sistemas Modernos de Manufactura',
      subtitle: 'Automatización y optimización de procesos de manufactura.',
      icon: Icons.precision_manufacturing_outlined,
      category: 'Posgrado',
      onTap: () => _navigateToPage(
        (_) => const MaestriaSistemasModernosManufacturaPage(),
      ),
    ),
    AppSearchItem(
      title: 'Posgrados Industrial',
      subtitle: 'Programas de posgrado especializados para ingenieros.',
      icon: Icons.school_outlined,
      category: 'Académico',
      onTap: _openPosgrados,
    ),
    AppSearchItem(
      title: 'Cursos Libres',
      subtitle: 'Cursos para ampliar tus conocimientos y habilidades.',
      icon: Icons.menu_book_rounded,
      category: 'Académico',
      onTap: _openCursosLibres,
    ),
    AppSearchItem(
      title: 'Especialidades y Cursos Industriales',
      subtitle: 'Elige entre cursos libres y especialidades industriales.',
      icon: Icons.engineering_rounded,
      category: 'Académico',
      onTap: _openCursosEspecialidades,
    ),
    AppSearchItem(
      title: 'Excel',
      subtitle:
          'Herramientas digitales para organización, fórmulas y análisis.',
      icon: Icons.table_chart_rounded,
      category: 'Curso',
      onTap: () => _openCursoLibre('excel-avanzado-ii'),
    ),
    AppSearchItem(
      title: 'Power BI',
      subtitle: 'Dashboards y análisis de datos para la toma de decisiones.',
      icon: Icons.bar_chart_rounded,
      category: 'Curso',
      onTap: () => _openCursoLibre('power-bi-produccion-calidad'),
    ),
    AppSearchItem(
      title: 'Minitab',
      subtitle: 'Estadística aplicada para análisis y mejora de procesos.',
      icon: Icons.analytics_rounded,
      category: 'Curso',
      onTap: () => _openCursoLibre('minitab'),
    ),
    AppSearchItem(
      title: 'Gerencia de Proyectos',
      subtitle: 'Planificación, ejecución y seguimiento de proyectos.',
      icon: Icons.account_tree_rounded,
      category: 'Curso',
      onTap: () => _openCursoLibre('fundamentos-gerencia-proyectos'),
    ),
    AppSearchItem(
      title: 'Caracterización y Análisis de Fallas',
      subtitle: 'Identificación de fallas y acciones correctivas en procesos.',
      icon: Icons.troubleshoot_rounded,
      category: 'Curso',
      onTap: () => _openCursoLibre('caracterizacion-analisis-fallas'),
    ),
    AppSearchItem(
      title: 'Normas ISO 14001, 45001 y 50001',
      subtitle: 'Gestión ambiental, seguridad y energía en la organización.',
      icon: Icons.verified_user_outlined,
      category: 'Curso',
      onTap: () => _openCursoLibre('normas-iso-14001-45001-50001'),
    ),
    AppSearchItem(
      title: 'Servicio al Cliente',
      subtitle: 'Mejora de la comunicación y atención al usuario.',
      icon: Icons.support_agent_rounded,
      category: 'Curso',
      onTap: () => _openCursoLibre('introduccion-servicio-cliente'),
    ),
    AppSearchItem(
      title: 'Habilidades Blandas',
      subtitle: 'Comunicación, liderazgo y adaptación interpersonal.',
      icon: Icons.groups_rounded,
      category: 'Curso',
      onTap: () => _openCursoLibre('habilidades-blandas'),
    ),
    AppSearchItem(
      title: 'Innovación y Cambio',
      subtitle: 'Impulsa ideas nuevas y adapta procesos a nuevos contextos.',
      icon: Icons.lightbulb_outline_rounded,
      category: 'Curso',
      onTap: () => _openCursoLibre('innovacion-cambio'),
    ),
    AppSearchItem(
      title: 'Liderazgo',
      subtitle: 'Desarrollo de equipos y toma de decisiones estratégicas.',
      icon: Icons.workspace_premium_outlined,
      category: 'Curso',
      onTap: () => _openCursoLibre('liderazgo'),
    ),
    AppSearchItem(
      title: 'Producción Esbelta',
      subtitle:
          'Optimización de procesos con enfoque en valor y productividad.',
      icon: Icons.precision_manufacturing_outlined,
      category: 'Curso',
      onTap: () => _openCursoLibre('produccion-esbelta'),
    ),
    AppSearchItem(
      title: 'Taller Norma 17025',
      subtitle: 'Competencia de laboratorios de ensayo y calibración.',
      icon: Icons.fact_check_outlined,
      category: 'Curso',
      onTap: () => _openCursoLibre('norma-17025'),
    ),
    AppSearchItem(
      title: 'Norma ISO 37002',
      subtitle: 'Sistemas de gestión de denuncias y respuesta institucional.',
      icon: Icons.gpp_good_outlined,
      category: 'Curso',
      onTap: () => _openCursoLibre('norma-iso-37002'),
    ),
    AppSearchItem(
      title: 'Eliminación de Desperdicios',
      subtitle: 'Reducción de actividades innecesarias en los procesos.',
      icon: Icons.delete_sweep_outlined,
      category: 'Curso',
      onTap: () => _openCursoLibre('eliminacion-desperdicios'),
    ),
    AppSearchItem(
      title: 'Buenas Prácticas para un Ambiente Productivo y Seguro',
      subtitle: 'Espacios de trabajo ordenados, productivos y seguros.',
      icon: Icons.health_and_safety_outlined,
      category: 'Curso',
      onTap: () => _openCursoLibre('ambiente-productivo-seguro'),
    ),
    AppSearchItem(
      title: 'Especialidades Industriales',
      subtitle: 'Conoce las opciones de formación industrial.',
      icon: Icons.engineering_rounded,
      category: 'Académico',
      onTap: _openEspecialidades,
    ),
    AppSearchItem(
      title: 'Auditoría de calidad',
      subtitle: 'Evaluación de procesos y cumplimiento de estándares.',
      icon: Icons.fact_check_outlined,
      category: 'Especialidad',
      onTap: () => _openEspecialidad(
        titulo: 'Auditoría de calidad',
        descripcion:
            'Busca decretar si lo pactado se está cumpliendo, evaluar '
            'procedimientos para ver si reúnen las condiciones escritas y '
            'las condiciones de calidad.',
        imagen: 'https://images.unsplash.com/photo-1581092921461-eab62e97a780?auto=format&fit=crop&w=1500&q=92',
        colores: const [Color(0xFF162D3D), Color(0xFF247B87)],
      ),
    ),
    AppSearchItem(
      title: 'Estadística Experimental',
      subtitle: 'Análisis de datos para toma de decisiones y mejora continua.',
      icon: Icons.query_stats_rounded,
      category: 'Especialidad',
      onTap: () => _openEspecialidad(
        titulo: 'Estadística Experimental',
        descripcion:
            'Examina datos en bruto con el propósito de sacar conclusiones '
            'sobre la información y es usado en varias industrias para '
            'permitir la toma de mejores decisiones empresariales.',
        imagen: 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?auto=format&fit=crop&w=1500&q=92',
        colores: const [Color(0xFF28345E), Color(0xFF6656A6)],
      ),
    ),
    AppSearchItem(
      title: 'Seis Sigma Yellow Belt',
      subtitle:
          'Herramientas estadísticas para reducir variabilidad del proceso.',
      icon: Icons.auto_graph_rounded,
      category: 'Especialidad',
      onTap: () => _openEspecialidad(
        titulo: 'Seis Sigma Yellow Belt',
        descripcion:
            'Utiliza un conjunto de herramientas estadísticas que buscan '
            'reducir la variabilidad de los procesos dando prioridad a los '
            'requisitos de los clientes.',
        imagen: 'https://images.unsplash.com/photo-1521737711867-e3b97375f902?auto=format&fit=crop&w=1500&q=92',
        colores: const [Color(0xFF123B59), Color(0xFF167D9A)],
      ),
    ),
    AppSearchItem(
      title: 'Metrología',
      subtitle: 'Aplicación de conceptos de medición y control dimensional.',
      icon: Icons.precision_manufacturing_outlined,
      category: 'Especialidad',
      onTap: () => _openEspecialidad(
        titulo: 'Metrología',
        descripcion:
            'Aplica los conceptos de la teoría de la medición que son '
            'esenciales en el desarrollo de un eficiente y efectivo sistema '
            'metrológico.',
        imagen: 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&w=1500&q=92',
        colores: const [Color(0xFF183344), Color(0xFF347F8C)],
      ),
    ),
    AppSearchItem(
      title: 'Calendario Académico',
      subtitle: 'Consulta fechas importantes, exámenes y entregas.',
      icon: Icons.calendar_month_rounded,
      category: 'Sección',
      onTap: _openCalendar,
    ),
    AppSearchItem(
      title: 'Noticias del TEC',
      subtitle: 'Entérate de los últimos acontecimientos institucionales.',
      icon: Icons.newspaper_rounded,
      category: 'Sección',
      onTap: _openNews,
    ),
    AppSearchItem(
      title: 'Recursos Estudiantiles',
      subtitle: 'Material didáctico, guías y descargas útiles.',
      icon: Icons.menu_book_rounded,
      category: 'Herramientas',
      onTap: () => _showSnackbar('Recursos estudiantiles: próximamente'),
    ),
    AppSearchItem(
      title: 'Mi Perfil',
      subtitle: 'Gestiona tu cuenta, estado activo y datos de estudiante.',
      icon: Icons.person_outline_rounded,
      category: 'Usuario',
      onTap: () => _navigateToSection(3),
    ),
    AppSearchItem(
      title: 'Escuela de Ingeniería en Producción Industrial',
      subtitle: 'Conoce más sobre la escuela, historia y contactos.',
      icon: Icons.engineering_outlined,
      category: 'Institucional',
      onTap: () => _showSnackbar('Información de la Escuela: próximamente'),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.035),
      end: Offset.zero,
    ).animate(_fadeAnimation);

    _entranceController.forward();
    _searchController.addListener(_handleSearchChange);
    _searchFocusNode.addListener(_handleSearchFocusChange);
  }

  void _handleSearchChange() {
    if (!mounted) return;

    setState(() {
      _searchQuery = _searchController.text.trim();
    });
  }

  void _handleSearchFocusChange() {
    if (!mounted) return;

    setState(() {
      _searchHasFocus = _searchFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChange);
    _searchFocusNode.removeListener(_handleSearchFocusChange);
    _searchFocusNode.dispose();
    _searchController.dispose();
    _homeScrollController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    FocusScope.of(context).unfocus();
  }

  void _setActiveSection(int index) {
    _sectionTransitionDirection = index >= selectedIndex ? 1 : -1;
    selectedIndex = index;
  }

  void _openCalendar() {
    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();
    _searchController.clear();

    setState(() {
      _setActiveSection(1);
      _searchQuery = '';
    });
  }

  void _openProfile() {
    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();
    _searchController.clear();

    setState(() {
      _setActiveSection(3);
      _searchQuery = '';
    });
  }

  /// Helper que centraliza la navegación hacia páginas externas.
  /// Aplica feedback háptico, quita el foco del teclado y push de ruta.
  Future<void> _navigateToPage(WidgetBuilder builder) async {
    if (!mounted) return;

    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();
    _searchController.clear();

    await Navigator.of(context).push(appPageRoute<void>(builder: builder));
  }

  void _openTecnicos() => _navigateToPage((context) => const TecnicosPage());

  void _openLicenciatura() =>
      _navigateToPage((context) => const LicenciaturaPage());

  void _openPosgrados() => _navigateToPage((context) => const PosgradosPage());

  void _openCursosLibres() =>
      _navigateToPage((context) => const CursosLibresCatalogoPage());

  void _openCursosEspecialidades() =>
      _navigateToPage((_) => const CursosEspecialidadesPage());

  void _openNews() => _navigateToPage((_) => const NoticiasPage());

  void _openCursoLibre(String id) => _navigateToPage(
    (_) => CursoDetallePage(curso: CursosLibresCatalogoPage.detallePorId(id)),
  );

  void _openEspecialidades() =>
      _navigateToPage((context) => const EspecialidadesIndustrialesPage());

  void _openEspecialidad({
    required String titulo,
    required String descripcion,
    required String imagen,
    required List<Color> colores,
  }) => _navigateToPage(
    (_) => EspecialidadDetallePage(
      titulo: titulo,
      descripcion: descripcion,
      imagen: imagen,
      colores: colores,
    ),
  );

  bool _matchesSearchItem(AppSearchItem item, String query) {
    final normalizedQuery = query.toLowerCase();
    return item.title.toLowerCase().contains(normalizedQuery) ||
        item.subtitle.toLowerCase().contains(normalizedQuery) ||
        item.category.toLowerCase().contains(normalizedQuery);
  }

  void _submitSearch(String query) {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return;

    for (final item in _searchItems) {
      if (_matchesSearchItem(item, normalizedQuery)) {
        item.onTap();
        return;
      }
    }
  }

  void _goHome() {
    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();
    _searchController.clear();

    setState(() {
      _setActiveSection(0);
      _searchQuery = '';
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _homeScrollController.hasClients) {
        _homeScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _navigateToSection(int index) {
    if (index == 3) {
      _openProfile();
      return;
    }

    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();
    _searchController.clear();

    setState(() {
      _setActiveSection(index);
      _searchQuery = '';
    });

    if (index != 0 && index != 2) {
      _showSnackbar(_sectionMessage(index));
    }
  }

  String _sectionMessage(int index) {
    switch (index) {
      case 1:
        return 'Calendario académico';
      case 2:
        return 'Avisos y notificaciones';
      case 3:
        return 'Perfil de estudiante';
      default:
        return 'Sección seleccionada';
    }
  }

  void _showSnackbar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: deepBlue,
        duration: const Duration(milliseconds: 1800),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ==========================================================
  // CONSTRUCCIÓN RESPONSIVA DE LA PANTALLA
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            final isFoldableOrTablet = width >= 720;
            final isCompactLandscape = ResponsiveLayout.isCompactLandscape(
              width,
              height,
            );
            final contentMaxWidth = ResponsiveLayout.contentMaxWidth(width);

            final sideBySideCards = width >= 900;

            final filteredItems = _searchItems
                .where((item) => _matchesSearchItem(item, _searchQuery))
                .toList();

            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const FondoAppDifuminado(),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: math.min(width, contentMaxWidth),
                          height: constraints.maxHeight,
                          child: AnimatedSwitcher(
                            duration: AppMotion.sectionTransitionDuration,
                            reverseDuration:
                                AppMotion.sectionTransitionDuration,
                            switchInCurve: AppMotion.transitionCurve,
                            switchOutCurve: AppMotion.transitionCurve,
                            layoutBuilder: (currentChild, previousChildren) {
                              return Stack(
                                alignment: Alignment.topCenter,
                                children: [...previousChildren, ?currentChild],
                              );
                            },
                            transitionBuilder: (child, animation) {
                              final curvedAnimation = CurvedAnimation(
                                parent: animation,
                                curve: AppMotion.transitionCurve,
                                reverseCurve: AppMotion.transitionCurve,
                              );
                              final springAnimation = CurvedAnimation(
                                parent: animation,
                                curve: AppMotion.pageOpenCurve,
                                reverseCurve: Curves.easeInCubic,
                              );
                              final isIncoming =
                                  child.key == ValueKey<int>(selectedIndex);
                              final travelDirection = isIncoming
                                  ? _sectionTransitionDirection
                                  : -_sectionTransitionDirection;

                              return FadeTransition(
                                opacity: curvedAnimation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: Offset(
                                      AppMotion.pageSlideDistance *
                                          travelDirection,
                                      0,
                                    ),
                                    end: Offset.zero,
                                  ).animate(curvedAnimation),
                                  child: ScaleTransition(
                                    scale: Tween<double>(
                                      begin: AppMotion.sectionOpenScale,
                                      end: 1,
                                    ).animate(springAnimation),
                                    child: AnimatedBuilder(
                                      animation: springAnimation,
                                      child: child,
                                      builder: (context, section) {
                                        final gel = (1 - springAnimation.value)
                                            .clamp(-0.12, 1.0);
                                        return Transform(
                                          alignment: Alignment.center,
                                          transform: Matrix4.diagonal3Values(
                                            1 + AppMotion.gelStretchX * gel,
                                            1 - AppMotion.gelSquashY * gel,
                                            1,
                                          ),
                                          child: section,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: KeyedSubtree(
                              key: ValueKey<int>(selectedIndex),
                              child: selectedIndex == 1
                                  ? CalendarioPage(
                                      embedded: true,
                                      onBack: _goHome,
                                    )
                                  : selectedIndex == 3
                                  ? PerfilPage(
                                      embedded: true,
                                      onBack: _goHome,
                                      onLogout: widget.onLogout,
                                      onSectionSelected: (index) {
                                        if (index == 0) {
                                          _goHome();
                                        } else if (index == 1) {
                                          _openCalendar();
                                        } else {
                                          _navigateToSection(index);
                                        }
                                      },
                                    )
                                  : selectedIndex == 2
                                  ? NotificacionesScreen(
                                      embedded: true,
                                      onSectionSelected: (index) {
                                        if (index == 0) {
                                          _goHome();
                                        } else if (index == 1) {
                                          _openCalendar();
                                        } else {
                                          _navigateToSection(index);
                                        }
                                      },
                                    )
                                  : Align(
                                      alignment: Alignment.topCenter,
                                      child: CustomScrollView(
                                        controller: _homeScrollController,
                                        keyboardDismissBehavior:
                                            ScrollViewKeyboardDismissBehavior
                                                .onDrag,
                                        physics: const BouncingScrollPhysics(
                                          parent:
                                              AlwaysScrollableScrollPhysics(),
                                        ),
                                        slivers: [
                                          SliverToBoxAdapter(
                                            child: _buildHeader(
                                              compact: isCompactLandscape,
                                              wide: isFoldableOrTablet,
                                            ),
                                          ),
                                          SliverPadding(
                                            padding: EdgeInsets.fromLTRB(
                                              isFoldableOrTablet ? 24 : 16,
                                              isCompactLandscape ? 12 : 24,
                                              isFoldableOrTablet ? 24 : 16,
                                              isCompactLandscape ? 112 : 130,
                                            ),
                                            sliver: _searchQuery.isEmpty
                                                ? SliverList(
                                                    delegate: SliverChildListDelegate([
                                                      _buildMainCards(
                                                        wide: sideBySideCards,
                                                        compact:
                                                            isCompactLandscape,
                                                      ),
                                                      const SizedBox(
                                                        height: 26,
                                                      ),
                                                      _buildQuickAccess(
                                                        wide:
                                                            isFoldableOrTablet,
                                                      ),
                                                      const SizedBox(
                                                        height: 30,
                                                      ),
                                                      _buildQuickLinks(),
                                                      const SizedBox(
                                                        height: 24,
                                                      ),
                                                    ]),
                                                  )
                                                : _buildSearchResultsSliver(
                                                    filteredItems,
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
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _buildBottomNavigation(
                        wide: isFoldableOrTablet,
                        compact: isCompactLandscape,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================================
  // ENCABEZADO
  // ==========================================================

  Widget _buildHeader({required bool compact, required bool wide}) {
    if (compact) return _buildCompactLandscapeHeader();

    final horizontalPadding = wide ? 32.0 : 20.0;
    final searchActive = _searchHasFocus || _searchQuery.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryNavy,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryNavy.withValues(alpha: 0.30),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.14,
                child: Image.network(
                  'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?auto=format&fit=crop&w=2200&q=92',
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                compact ? 16 : 22,
                horizontalPadding,
                compact ? 24 : 32,
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: compact ? -20 : -14,
                    left: horizontalPadding + 44,
                    right: horizontalPadding + 44,
                    height: compact ? 88 : 104,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: 1,
                        child: Image.asset(
                          'assets/images/tec_logo.png',
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          semanticLabel: 'Tecnológico de Costa Rica',
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: compact ? 48 : 58),
                      SizedBox(height: compact ? 18 : 24),
                      Text(
                        'Hola, Bienvenido',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: wide ? 28 : 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tu formación, un mismo camino',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.engineering_outlined,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Escuela de Ingeniería en Producción Industrial',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: compact ? 16 : 20),
                      GelPress(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(23),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.20),
                                blurRadius: 22,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: accentTeal.withValues(
                                  alpha: searchActive ? 0.30 : 0.12,
                                ),
                                blurRadius: searchActive ? 24 : 15,
                                spreadRadius: searchActive ? 1 : 0,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(23),
                            child: BackdropFilter(
                              filter: ui.ImageFilter.blur(
                                sigmaX: 24,
                                sigmaY: 24,
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 280),
                                curve: Curves.easeOutCubic,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withValues(
                                        alpha: searchActive ? 0.28 : 0.20,
                                      ),
                                      const Color(0xFFB8F4FF).withValues(
                                        alpha: searchActive ? 0.17 : 0.11,
                                      ),
                                      const Color(0xFF70CFFF)
                                          .withValues(alpha: 0.09),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(23),
                                  border: Border.all(
                                    color: searchActive
                                        ? const Color(0xFF9DEBFF)
                                              .withValues(alpha: 0.88)
                                        : Colors.white.withValues(alpha: 0.42),
                                    width: searchActive ? 1.5 : 1,
                                  ),
                                ),
                                child: Stack(
                                  clipBehavior: Clip.hardEdge,
                                  children: [
                                    Positioned(
                                      top: 0,
                                      left: 28,
                                      right: 28,
                                      child: IgnorePointer(
                                        child: Container(
                                          height: 1.5,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.white.withValues(
                                                  alpha: 0,
                                                ),
                                                Colors.white.withValues(
                                                  alpha: searchActive
                                                      ? 0.95
                                                      : 0.70,
                                                ),
                                                Colors.white.withValues(
                                                  alpha: 0,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: -43,
                                      left: 34,
                                      child: IgnorePointer(
                                        child: Container(
                                          width: 145,
                                          height: 88,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [
                                                Colors.white.withValues(
                                                  alpha: 0.18,
                                                ),
                                                Colors.white.withValues(
                                                  alpha: 0.02,
                                                ),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: -58,
                                      right: -20,
                                      child: IgnorePointer(
                                        child: Container(
                                          width: 155,
                                          height: 115,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [
                                                accentTeal.withValues(
                                                  alpha: searchActive
                                                      ? 0.28
                                                      : 0.16,
                                                ),
                                                accentTeal.withValues(
                                                  alpha: 0.03,
                                                ),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 5,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Colors.white.withValues(
                                                    alpha: 0.28,
                                                  ),
                                                  Colors.white.withValues(
                                                    alpha: 0.06,
                                                  ),
                                                ],
                                              ),
                                              border: Border.all(
                                                color: Colors.white.withValues(
                                                  alpha: 0.25,
                                                ),
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.search_rounded,
                                              color: searchActive
                                                  ? const Color(0xFFB8F4FF)
                                                  : Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: TextField(
                                              controller: _searchController,
                                              focusNode: _searchFocusNode,
                                              textInputAction:
                                                  TextInputAction.search,
                                              onSubmitted: _submitSearch,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              cursorColor: const Color(
                                                0xFFB8F4FF,
                                              ),
                                              decoration: const InputDecoration(
                                                filled: false,
                                                fillColor: Colors.transparent,
                                                hintText: 'Buscar técnico, carreras, calendario...',
                                                hintStyle: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                border: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                                isDense: true,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      vertical: 10,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          if (_searchQuery.isNotEmpty)
                                            GestureDetector(
                                              onTap: () {
                                                HapticFeedback.lightImpact();
                                                _clearSearch();
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.24),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withValues(
                                                          alpha: 0.30,
                                                        ),
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.close_rounded,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
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
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactLandscapeHeader() {
    final searchActive = _searchHasFocus || _searchQuery.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryNavy,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryNavy.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.14,
                child: Image.network(
                  'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?auto=format&fit=crop&w=2200&q=92',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 42,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/tec_logo.png',
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            semanticLabel: 'Tecnológico de Costa Rica',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Hola, Bienvenido',
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Escuela de Ingeniería en Producción Industrial',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.17),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.40),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              color: searchActive
                                  ? const Color(0xFFB8F4FF)
                                  : Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                textInputAction: TextInputAction.search,
                                onSubmitted: _submitSearch,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                                cursorColor: const Color(0xFFB8F4FF),
                                decoration: const InputDecoration(
                                  hintText:
                                      'Buscar técnico, carreras, calendario...',
                                  hintStyle: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12.5,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                            if (_searchQuery.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  _clearSearch();
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: Colors.white,
                                    size: 18,
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
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // RESULTADOS DE BÚSQUEDA
  // ==========================================================

  Widget _buildSearchResultsSliver(List<AppSearchItem> results) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    if (results.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
          alignment: Alignment.center,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 44,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Sin resultados encontrados',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Prueba con otra palabra clave o término.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Text(
                  'Resultados de búsqueda (${results.length})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearSearch,
                  style: TextButton.styleFrom(
                    foregroundColor: accentTeal,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Limpiar búsqueda',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
        }

        final item = results[index - 1];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: GelPress(
              child: InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: dark ? 0.14 : 0.08,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          item.icon,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                                fontSize: 14.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: dark ? 0.14 : 0.08,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          item.category,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }, childCount: results.length + 1),
    );
  }

  // ==========================================================
  // TARJETAS ACADÉMICAS / NOMBRES
  // ==========================================================

  Widget _buildMainCards({required bool wide, required bool compact}) {
    final cards = [
      _MainCardData(
        gradientColors: [const Color(0xFF061424), const Color(0xFF2878B5)],
        icon: Icons.engineering_rounded,
        title: 'Especialidades y\nCursos Industrial',
        description: 'Explora cursos cortos y especialidades industrial en un solo lugar.',
        imageUrl: 'assets/images/Cursos y especialidades.jpeg',
        onTap: _openCursosEspecialidades,
      ),

      _MainCardData(
        gradientColors: [deepBlue, const Color(0xFF1B3C73)],
        icon: Icons.verified_outlined,
        title: 'Técnico Industrial',
        description: 'Desarrolla tus habilidades en control, mejora y aseguramiento de la calidad industrial.',
        imageUrl: 'assets/images/TECNICO.jpeg',
        onTap: _openTecnicos,
      ),

      _MainCardData(
        gradientColors: [const Color(0xFF0D9488), const Color(0xFF14B8A6)],
        icon: Icons.workspace_premium_rounded,
        title: 'Licenciatura\nIndustrial',
        description: 'Obtén tu grado académico superior con planes de estudio orientados a la alta gerencia.',
        imageUrl: 'https://images.unsplash.com/photo-1531482615713-2afd69097998?auto=format&fit=crop&w=1600&q=95',
        onTap: _openLicenciatura,
      ),

      _MainCardData(
        gradientColors: [accentPurple, const Color(0xFF4E46B4)],
        icon: Icons.school_outlined,
        title: 'Posgrados\nIndustrial',
        description: 'Lleva tu conocimiento al siguiente nivel con programas de posgrado especializados.',
        imageUrl: 'assets/images/LogoPosgrados.jpeg',
        onTap: _openPosgrados,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final displaySize = MediaQuery.sizeOf(context);
        final shortLandscape =
            displaySize.width > displaySize.height && displaySize.height < 600;

        // Cuatro columnas en escritorio ancho; tres en escritorio mediano,
        // dos en tablet y una en móvil.
        final hinge = ResponsiveLayout.verticalHinge(context);
        final int columns;
        if (hinge != null) {
          columns = 2;
        } else if (availableWidth >= 1450) {
          columns = 4;
        } else if (availableWidth >= 1050) {
          columns = 3;
        } else if (availableWidth >= 570) {
          columns = 2;
        } else {
          columns = 1;
        }

        final spacing = ResponsiveLayout.spacingFor(context, minimum: 15);
        final cardHeight = shortLandscape ? 148.0 : 190.0;
        final singleColumnHeight = compact ? 136.0 : 154.0;

        if (columns == 1) {
          return Column(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(height: 14),
                _buildProCard(data: cards[i], height: singleColumnHeight),
              ],
            ],
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: 15,
            mainAxisExtent: cardHeight,
          ),
          itemBuilder: (context, index) {
            return _buildProCard(
              data: cards[index],
              height: cardHeight,
              wide: true,
            );
          },
        );
      },
    );
  }

  Widget _buildProCard({
    required _MainCardData data,
    required double height,
    bool wide = false,
  }) {
    final cardRadius = BorderRadius.circular(26);
    final isPosgradosLogo = data.imageUrl == 'assets/images/LogoPosgrados.jpeg';

    return GelPress(
      child: Semantics(
        button: true,
        label: '${data.title.replaceAll('\n', ' ')}. ${data.description}',
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Material(
            color: Colors.transparent,
            borderRadius: cardRadius,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();

                data.onTap?.call();
              },
              borderRadius: cardRadius,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  borderRadius: cardRadius,
                  gradient: LinearGradient(
                    colors: data.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: data.gradientColors.first.withValues(alpha: 0.23),
                      blurRadius: 22,
                      offset: const Offset(0, 9),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: cardRadius,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FractionallySizedBox(
                            widthFactor: 0.9,
                            child: ShaderMask(
                              blendMode: BlendMode.dstIn,
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.transparent,
                                    Color(0x66FFFFFF),
                                    Color(0xE6FFFFFF),
                                  ],
                                  stops: const [0, 0.22, 1],
                                ).createShader(bounds);
                              },
                              child: data.imageUrl.startsWith('assets/')
                                  ? Image.asset(
                                      data.imageUrl,
                                      fit: isPosgradosLogo
                                          ? BoxFit.contain
                                          : BoxFit.cover,
                                      filterQuality: FilterQuality.high,
                                      alignment: isPosgradosLogo
                                          ? Alignment.centerRight
                                          : Alignment.center,
                                      color: Colors.white.withValues(
                                        alpha: 0.58,
                                      ),
                                      colorBlendMode: BlendMode.softLight,
                                    )
                                  : Image.network(
                                      data.imageUrl,
                                      fit: BoxFit.cover,
                                      filterQuality: FilterQuality.high,
                                      alignment: Alignment.center,
                                      color: Colors.white.withValues(
                                        alpha: 0.58,
                                      ),
                                      colorBlendMode: BlendMode.softLight,
                                      errorBuilder: (_, _, _) =>
                                          const SizedBox.shrink(),
                                      loadingBuilder:
                                          (context, child, progress) {
                                            if (progress == null) return child;
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
                                data.gradientColors.first.withValues(
                                  alpha: 0.98,
                                ),
                                data.gradientColors.first.withValues(
                                  alpha: 0.86,
                                ),
                                data.gradientColors.last.withValues(
                                  alpha: 0.38,
                                ),
                              ],
                              stops: const [0, 0.48, 1],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -36,
                        right: wide ? 110 : 95,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.045),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          wide ? 20 : 17,
                          wide ? 18 : 15,
                          wide ? 54 : 50,
                          wide ? 18 : 15,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: wide ? 56 : 48,
                              height: wide ? 56 : 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(17),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.30),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                data.icon,
                                color: Colors.white,
                                size: wide ? 29 : 25,
                              ),
                            ),
                            SizedBox(width: wide ? 15 : 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    data.title.replaceAll('\n', ' '),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: wide ? 17 : 16,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.35,
                                      height: 1.12,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.15,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                    data.description,
                                    maxLines: wide ? 3 : 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.88,
                                      ),
                                      fontSize: wide ? 11.5 : 11.2,
                                      height: 1.35,
                                      letterSpacing: 0.05,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 13,
                        bottom: 13,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.19),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.34),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18,
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

  // ==========================================================
  // ACCESO RÁPIDO
  // ==========================================================

  Widget _buildQuickAccess({required bool wide}) {
    final theme = Theme.of(context);

    const items = [
      _QuickItem(
        Icons.calendar_month_rounded,
        'Agendar cita',
        Color(0xFF3B82F6),
      ),
      _QuickItem(Icons.newspaper_rounded, 'Noticias', Color(0xFF10B981)),
    ];

    if (MediaQuery.sizeOf(context).width < 520) {
      return _buildCompactQuickAccess(items, wide: wide);
    }

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(
            child: GelPress(
              child: Material(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();

                    switch (items[i].label) {
                      case 'Agendar cita':
                        _openCalendar();
                        break;
                      case 'Noticias':
                        _openNews();
                        break;
                      default:
                        _showSnackbar('${items[i].label}: próximamente');
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: wide ? 100 : 90,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.dividerColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: items[i].color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            items[i].icon,
                            color: items[i].color,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            items[i].label,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
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
        ],
      ],
    );
  }

  // ==========================================================
  // ENLACES RÁPIDOS
  // ==========================================================

  Widget _buildCompactQuickAccess(
    List<_QuickItem> items, {
    required bool wide,
  }) {
    final theme = Theme.of(context);

    Widget card(_QuickItem item) {
      return GelPress(
        child: Material(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();

              switch (item.label) {
                case 'Agendar cita':
                  _openCalendar();
                  break;
                case 'Noticias':
                  _openNews();
                  break;
                default:
                  _showSnackbar(item.label);
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: wide ? 100 : 90,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(item.icon, color: item.color, size: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(child: card(items[0])),
        const SizedBox(width: 12),
        Expanded(child: card(items[1])),
      ],
    );
  }

  Widget _buildQuickLinks() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Enlaces rápidos',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            TextButton(
              onPressed: () => _showSnackbar('Más enlaces: próximamente'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Row(
                children: [
                  Text(
                    'Ver todo',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 14),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GelPress(
          child: Material(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () =>
                  _showSnackbar('Información de la Escuela: próximamente'),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F2C59), Color(0xFF1B3C73)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(11),
                        child: Icon(
                          Icons.school_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Conoce más sobre la Escuela\nde Ingeniería en Producción Industrial',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8),
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // BARRA DE NAVEGACIÓN INFERIOR CON EFECTO GLASS
  // ==========================================================

  Widget _buildBottomNavigation({required bool wide, required bool compact}) {
    return NavegacionGlass(
      selectedIndex: selectedIndex,
      wide: wide,
      compact: compact,
      onSelected: (index) {
        if (index == 0) {
          _goHome();
        } else if (index == 1) {
          _openCalendar();
        } else {
          _navigateToSection(index);
        }
      },
    );
  }
}

// ============================================================
// MODELOS DE LA INTERFAZ
// ============================================================

class _MainCardData {
  final List<Color> gradientColors;
  final IconData icon;
  final String title;
  final String description;
  final String imageUrl;
  final VoidCallback? onTap;

  const _MainCardData({
    required this.gradientColors,
    required this.icon,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.onTap,
  });
}

class _QuickItem {
  final IconData icon;
  final String label;
  final Color color;

  const _QuickItem(this.icon, this.label, this.color);
}
