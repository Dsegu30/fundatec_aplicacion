import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';
import 'calendario.dart';
import 'perfil.dart';
import 'notificaciones.dart';
import 'tecnicos.dart';
import 'licenciatura.dart';
import 'posgrados.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
  const TecApp({super.key});

  @override
  State<TecApp> createState() => _TecAppState();
}

class _TecAppState extends State<TecApp> {
  static const String _themeModeKey = 'app_theme_mode';

  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
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

  @override
  Widget build(BuildContext context) {
    final dark = _themeMode == ThemeMode.dark;

    return AppThemePreference(
      themeMode: _themeMode,
      onThemeModeChanged: _setThemeMode,
      child: MaterialApp(
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
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const TecHomeScreen(),
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
  const TecHomeScreen({super.key});

  @override
  State<TecHomeScreen> createState() => _TecHomeScreenState();
}

class _TecHomeScreenState extends State<TecHomeScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryNavy = Color(0xFF061424);
  static const Color deepBlue = Color(0xFF0D233A);
  static const Color accentTeal = Color(0xFF0EA5E9);
  static const Color accentPurple = Color(0xFF6366F1);
  static const Color alertRed = Color(0xFFEF4444);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ScrollController _homeScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  int selectedIndex = 0;
  String _searchQuery = '';

  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  late final List<AppSearchItem> _searchItems = [
    AppSearchItem(
      title: 'Técnico en Calidad',
      subtitle: 'Control, mejora y aseguramiento de la calidad industrial.',
      icon: Icons.verified_outlined,
      category: 'Académico',
      onTap: _openTecnicos,
    ),
    AppSearchItem(
      title: 'Licenciatura Industrial',
      subtitle: 'Grado académico superior orientado a la alta gerencia.',
      icon: Icons.workspace_premium_rounded,
      category: 'Académico',
      onTap: _openLicenciatura,
    ),
    AppSearchItem(
      title: 'Posgrados Industrial',
      subtitle: 'Programas de posgrado especializados para ingenieros.',
      icon: Icons.school_outlined,
      category: 'Académico',
      onTap: _openPosgrados,
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
      onTap: () => _navigateToSection(2),
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
    AppSearchItem(
      title: 'Cursos Libres',
      subtitle: 'Cursos para ampliar tus conocimientos y habilidades.',
      icon: Icons.menu_book_rounded,
      category: 'Académico',
      onTap: () => _showSnackbar('Cursos Libres: próximamente'),
    ),
    AppSearchItem(
      title: 'Especialidades Industriales',
      subtitle: 'Conoce las opciones de formación industrial.',
      icon: Icons.engineering_rounded,
      category: 'Académico',
      onTap: () => _showSnackbar('Especialidades Industriales: próximamente'),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
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
  }

  void _handleSearchChange() {
    if (!mounted) return;

    setState(() {
      _searchQuery = _searchController.text.trim();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChange);
    _searchController.dispose();
    _homeScrollController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    FocusScope.of(context).unfocus();
  }

  void _openCalendar() {
    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();
    _searchController.clear();

    setState(() {
      selectedIndex = 1;
      _searchQuery = '';
    });
  }

  void _openProfile() {
    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();
    _searchController.clear();

    setState(() {
      selectedIndex = 3;
      _searchQuery = '';
    });
  }

  void _openTecnicos() {
    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();

    Navigator.of(context)
        .push(appPageRoute<void>(builder: (context) => const TecnicosPage()));
  }

  void _openLicenciatura() {
    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();

    Navigator.of(
      context,
    ).push(appPageRoute<void>(builder: (context) => const LicenciaturaPage()));
  }

  void _openPosgrados() {
    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();

    Navigator.of(context)
        .push(appPageRoute<void>(builder: (context) => const PosgradosPage()));
  }

  void _goHome() {
    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();
    _searchController.clear();

    setState(() {
      selectedIndex = 0;
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
      selectedIndex = index;
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
      key: _scaffoldKey,
      drawer: _buildFloatingDrawer(),
      drawerScrimColor: primaryNavy.withOpacity(0.48),
      drawerEdgeDragWidth: 24,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            final isFoldableOrTablet = width >= 720;
            final isLandscapePhone = width > height && width < 720;

            final contentMaxWidth = isFoldableOrTablet
                ? 960.0
                : isLandscapePhone
                ? 720.0
                : 460.0;

            final sideBySideCards = width >= 900;

            final filteredItems = _searchItems.where((item) {
              final query = _searchQuery.toLowerCase();

              return item.title.toLowerCase().contains(query) ||
                  item.subtitle.toLowerCase().contains(query) ||
                  item.category.toLowerCase().contains(query);
            }).toList();

            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: math.min(width, contentMaxWidth),
                          height: constraints.maxHeight,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 420),
                            reverseDuration: const Duration(milliseconds: 300),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            layoutBuilder: (currentChild, previousChildren) {
                              return Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  ...previousChildren,
                                  if (currentChild != null) currentChild,
                                ],
                              );
                            },
                            transitionBuilder: (child, animation) {
                              final curvedAnimation = CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                                reverseCurve: Curves.easeInCubic,
                              );

                              return FadeTransition(
                                opacity: curvedAnimation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.018, 0.012),
                                    end: Offset.zero,
                                  ).animate(curvedAnimation),
                                  child: ScaleTransition(
                                    scale: Tween<double>(
                                      begin: 0.985,
                                      end: 1,
                                    ).animate(curvedAnimation),
                                    child: child,
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
                                              compact: isLandscapePhone,
                                              wide: isFoldableOrTablet,
                                            ),
                                          ),
                                          SliverPadding(
                                            padding: EdgeInsets.fromLTRB(
                                              isFoldableOrTablet ? 24 : 16,
                                              24,
                                              isFoldableOrTablet ? 24 : 16,
                                              isLandscapePhone ? 112 : 130,
                                            ),
                                            sliver: _searchQuery.isEmpty
                                                ? SliverList(
                                                    delegate:
                                                        SliverChildListDelegate([
                                                          _buildMainCards(
                                                            wide:
                                                                sideBySideCards,
                                                            compact:
                                                                isLandscapePhone,
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
                        compact: isLandscapePhone,
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
    final horizontalPadding = wide ? 32.0 : 20.0;

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
            color: primaryNavy.withOpacity(0.30),
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
                  'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?auto=format&fit=crop&w=1400&q=85',
                  fit: BoxFit.cover,
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
                          semanticLabel: 'Tecnológico de Costa Rica',
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildLiquidGlassButton(
                            icon: Icons.menu_rounded,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _scaffoldKey.currentState?.openDrawer();
                            },
                          ),
                          Expanded(child: SizedBox(height: compact ? 48 : 58)),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              _buildLiquidGlassButton(
                                icon: Icons.notifications_none_rounded,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  _navigateToSection(2);
                                },
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: alertRed,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: primaryNavy,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
                              color: Colors.black.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.12),
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _searchQuery.isNotEmpty
                                    ? accentTeal
                                    : Colors.white.withOpacity(0.3),
                                width: _searchQuery.isNotEmpty ? 1.5 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search_rounded,
                                  color: _searchQuery.isNotEmpty
                                      ? accentTeal
                                      : Colors.white70,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    cursorColor: accentTeal,
                                    decoration: const InputDecoration(
                                      hintText: 'Buscar técnico, carreras, calendario...',
                                      hintStyle: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w400,
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
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.25),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                    ),
                                  )
                                else
                                  Icon(
                                    Icons.tune_rounded,
                                    color: Colors.white.withOpacity(0.6),
                                    size: 18,
                                  ),
                              ],
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

  Widget _buildLiquidGlassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          ),
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
                      color: Colors.black.withOpacity(0.04),
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
                color: Colors.black.withOpacity(0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
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
        );
      }, childCount: results.length + 1),
    );
  }

  // ==========================================================
  // TARJETAS ACADÉMICAS
  // ==========================================================

  Widget _buildMainCards({required bool wide, required bool compact}) {
    final cards = [
      _MainCardData(
        gradientColors: [const Color(0xFF061424), const Color(0xFF2878B5)],
        icon: Icons.menu_book_rounded,
        title: 'Cursos Libres',
        description: 'Explora cursos libres para ampliar tus conocimientos y desarrollar nuevas habilidades.',
        imageUrl: 'https://images.unsplash.com/photo-1581092160562-40aa08e78837?auto=format&fit=crop&w=800&q=85',
        onTap: () => _showSnackbar('Cursos Libres: próximamente'),
      ),
      _MainCardData(
        gradientColors: [const Color(0xFF343A40), alertRed],
        icon: Icons.engineering_rounded,
        title: 'Especialidades\nIndustriales',
        description: 'Conoce las especialidades industriales y las opciones de formación disponibles.',
        imageUrl: 'https://images.unsplash.com/photo-1557683316-973673baf926?auto=format&fit=crop&w=800&q=85',
        onTap: () => _showSnackbar('Especialidades Industriales: próximamente'),
      ),
      _MainCardData(
        gradientColors: [deepBlue, const Color(0xFF1B3C73)],
        icon: Icons.verified_outlined,
        title: 'Técnico en\nCalidad',
        description: 'Desarrolla tus habilidades en control, mejora y aseguramiento de la calidad industrial.',
        imageUrl: 'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?auto=format&fit=crop&w=800&q=85',
      ),
      _MainCardData(
        gradientColors: [const Color(0xFF0D9488), const Color(0xFF14B8A6)],
        icon: Icons.workspace_premium_rounded,
        title: 'Licenciatura\nIndustrial',
        description: 'Obtén tu grado académico superior con planes de estudio orientados a la alta gerencia.',
        imageUrl: 'https://images.unsplash.com/photo-1531482615713-2afd69097998?auto=format&fit=crop&w=800&q=85',
        onTap: _openLicenciatura,
      ),
      _MainCardData(
        gradientColors: [accentPurple, const Color(0xFF4E46B4)],
        icon: Icons.school_outlined,
        title: 'Posgrados\nIndustrial',
        description: 'Lleva tu conocimiento al siguiente nivel con programas de posgrado especializados.',
        imageUrl: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=800&q=85',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        final int columns;
        final double cardHeight;

        if (availableWidth >= 850) {
          columns = 3;
          cardHeight = 205;
        } else if (availableWidth >= 570) {
          columns = 2;
          cardHeight = 200;
        } else {
          columns = 1;
          cardHeight = compact ? 136 : 154;
        }

        if (columns == 1) {
          return Column(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(height: 14),
                _buildProCard(data: cards[i], height: cardHeight),
              ],
            ],
          );
        }

        if (columns == 3) {
          return Column(
            children: [
              Row(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(width: 15),
                    Expanded(
                      child: _buildProCard(
                        data: cards[i],
                        height: 190,
                        wide: true,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  for (var i = 3; i < cards.length; i++) ...[
                    if (i > 3) const SizedBox(width: 15),
                    Expanded(
                      child: _buildProCard(
                        data: cards[i],
                        height: 190,
                        wide: true,
                      ),
                    ),
                  ],
                  if (cards.length == 4) const Spacer(),
                ],
              ),
            ],
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 15,
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

    return Semantics(
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

              if (data.onTap != null) {
                data.onTap!();
              } else if (data.title.startsWith('Técnico')) {
                _openTecnicos();
              } else if (data.title.startsWith('Licenciatura')) {
                _openLicenciatura();
              } else if (data.title.startsWith('Posgrados')) {
                _openPosgrados();
              } else {
                _showSnackbar('Abriendo ${data.title.replaceAll('\n', ' ')}');
              }
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
                    color: data.gradientColors.first.withOpacity(0.23),
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
                        child: SizedBox(
                          width: wide ? 230 : 205,
                          child: ShaderMask(
                            blendMode: BlendMode.dstIn,
                            shaderCallback: (bounds) {
                              return const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.transparent,
                                  Color(0x33FFFFFF),
                                  Color(0xBFFFFFFF),
                                ],
                                stops: [0, 0.32, 1],
                              ).createShader(bounds);
                            },
                            child: Image.network(
                              data.imageUrl,
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              color: Colors.white.withOpacity(0.58),
                              colorBlendMode: BlendMode.softLight,
                              errorBuilder: (_, __, ___) =>
                                  const SizedBox.shrink(),
                              loadingBuilder: (context, child, progress) {
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
                              data.gradientColors.first.withOpacity(0.99),
                              data.gradientColors.first.withOpacity(0.91),
                              data.gradientColors.last.withOpacity(0.48),
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
                          color: Colors.white.withOpacity(0.045),
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
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(17),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.30),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
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
                                        color: Colors.black.withOpacity(0.15),
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
                                    color: Colors.white.withOpacity(0.88),
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
                          color: Colors.white.withOpacity(0.19),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.34),
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
    );
  }

  // ==========================================================
  // ACCESO RÁPIDO
  // ==========================================================

  Widget _buildQuickAccess({required bool wide}) {
    final theme = Theme.of(context);

    const items = [
      _QuickItem(Icons.calendar_month_rounded, 'Calendario', Color(0xFF3B82F6)),
      _QuickItem(Icons.newspaper_rounded, 'Noticias', Color(0xFF10B981)),
      _QuickItem(Icons.menu_book_rounded, 'Recursos', Color(0xFFF59E0B)),
      _QuickItem(Icons.person_outline_rounded, 'Mi Perfil', Color(0xFF8B5CF6)),
    ];

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(
            child: Material(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();

                  switch (items[i].label) {
                    case 'Calendario':
                      _openCalendar();
                      break;
                    case 'Mi Perfil':
                      _navigateToSection(3);
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
                        color: Colors.black.withOpacity(0.03),
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
                          color: items[i].color.withOpacity(0.1),
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
        ],
      ],
    );
  }

  // ==========================================================
  // ENLACES RÁPIDOS
  // ==========================================================

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
        Material(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () =>
                _showSnackbar('Información de la Escuela: próximamente'),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
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
      ],
    );
  }

  // ==========================================================
  // BARRA DE NAVEGACIÓN INFERIOR CON EFECTO GLASS
  // ==========================================================

  Widget _buildBottomNavigation({required bool wide, required bool compact}) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    final items = <_DockItem>[
      const _DockItem(Icons.home_rounded, Icons.home_outlined, 'Inicio'),
      const _DockItem(
        Icons.calendar_month_rounded,
        Icons.calendar_month_outlined,
        'Calendario',
      ),
      const _DockItem(
        Icons.notifications_rounded,
        Icons.notifications_none_rounded,
        'Avisos',
      ),
      const _DockItem(
        Icons.person_rounded,
        Icons.person_outline_rounded,
        'Perfil',
      ),
    ];

    return SafeArea(
      top: false,
      minimum: EdgeInsets.fromLTRB(
        wide ? 24 : 14,
        0,
        wide ? 24 : 14,
        compact ? 8 : 12,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: wide ? 760 : 460),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 6 : 8,
                  vertical: compact ? 6 : 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      (dark ? const Color(0xFF26384A) : Colors.white)
                          .withValues(alpha: dark ? 0.96 : 0.46),
                      (dark ? const Color(0xFF172534) : Colors.white)
                          .withValues(alpha: dark ? 0.9 : 0.24),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: (dark ? const Color(0xFF8FA5BA) : Colors.white)
                        .withValues(alpha: dark ? 0.9 : 0.78),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10243B).withOpacity(0.13),
                      blurRadius: 34,
                      spreadRadius: 1,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(dark ? 0.08 : 0.9),
                      blurRadius: 2,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: Row(
                  children: List.generate(items.length, (index) {
                    final selected = selectedIndex == index;
                    final item = items[index];

                    return Expanded(
                      child: Semantics(
                        button: true,
                        selected: selected,
                        label: item.label,
                        child: Tooltip(
                          message: item.label,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              if (index == 0) {
                                _goHome();
                              } else if (index == 1) {
                                _openCalendar();
                              } else {
                                _navigateToSection(index);
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 420),
                              curve: Curves.easeOutCubic,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: EdgeInsets.symmetric(
                                vertical: compact ? 7 : 9,
                                horizontal: 3,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                gradient: selected
                                    ? LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          dark
                                              ? const Color(0xFF33495F)
                                              : Colors.white.withOpacity(0.98),
                                          (dark
                                                  ? const Color(0xFF293D51)
                                                  : const Color(0xFFE5F4FF))
                                              .withOpacity(0.94),
                                          (dark
                                                  ? const Color(0xFF203447)
                                                  : const Color(0xFFD5EAFB))
                                              .withOpacity(0.88),
                                        ],
                                      )
                                    : null,
                                border: selected
                                    ? Border.all(
                                        color:
                                            (dark
                                                    ? const Color(0xFF526A81)
                                                    : Colors.white)
                                                .withOpacity(0.95),
                                      )
                                    : null,
                                boxShadow: selected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF2D80B9)
                                              .withOpacity(0.16),
                                          blurRadius: 15,
                                          offset: const Offset(0, 5),
                                        ),
                                        BoxShadow(
                                          color: Colors.white.withOpacity(
                                            dark ? 0.08 : 0.95,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, -1),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutBack,
                                scale: selected ? 1.04 : 1,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 350,
                                      ),
                                      curve: Curves.easeOutCubic,
                                      width: selected ? 42 : 38,
                                      height: selected ? 32 : 30,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        gradient: selected
                                            ? const LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Color(0xFF17466D),
                                                  Color(0xFF0B263F),
                                                ],
                                              )
                                            : null,
                                        boxShadow: selected
                                            ? [
                                                BoxShadow(
                                                  color: const Color(0xFF123D60)
                                                      .withOpacity(0.24),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Icon(
                                        selected ? item.activeIcon : item.icon,
                                        size: selected ? 20 : 21,
                                        color: selected
                                            ? Colors.white
                                            : dark
                                            ? const Color(0xFFB0C0D0)
                                            : const Color(0xFF657487),
                                      ),
                                    ),
                                    AnimatedSize(
                                      duration: const Duration(
                                        milliseconds: 260,
                                      ),
                                      curve: Curves.easeOutCubic,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          top: selected ? 4 : 2,
                                        ),
                                        child: Text(
                                          item.label,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: compact ? 9.5 : 10.5,
                                            height: 1.1,
                                            fontWeight: selected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            letterSpacing: -0.1,
                                            color: selected
                                                ? dark
                                                      ? const Color(0xFFD7E9FF)
                                                      : const Color(0xFF123D60)
                                                : dark
                                                ? const Color(0xFFB0C0D0)
                                                : const Color(0xFF64748B),
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
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // MENÚ LATERAL FLOTANTE
  // ==========================================================

  Widget _buildFloatingDrawer() {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final drawerWidth = math.min(screenWidth * 0.82, 340.0);

    return Drawer(
      width: drawerWidth,
      elevation: 0,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(28)),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.97),
            child: SafeArea(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(22, 22, 18, 26),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF061424), Color(0xFF1B3C73)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.school_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'TEC MÓVIL',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tu formación,\nun mismo camino.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Tecnológico de Costa Rica',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 25, 18, 12),
                    child: Text(
                      'MENÚ PRINCIPAL',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  _drawerTile(
                    Icons.home_rounded,
                    'Inicio',
                    'Pantalla principal',
                    0,
                  ),
                  _drawerTile(
                    Icons.calendar_month_rounded,
                    'Calendario',
                    'Fechas académicas',
                    1,
                  ),
                  _drawerTile(
                    Icons.notifications_none_rounded,
                    'Avisos',
                    'Novedades y notificaciones',
                    2,
                  ),
                  _drawerTile(
                    Icons.person_outline_rounded,
                    'Mi perfil',
                    'Tu espacio personal',
                    3,
                  ),
                  _drawerTile(
                    Icons.menu_book_rounded,
                    'Recursos',
                    'Material de estudio',
                    4,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).colorScheme.surfaceContainerHigh
                            : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 25,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Escuela de Ingeniería en Producción Industrial',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
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
  }

  Widget _drawerTile(IconData icon, String title, String subtitle, int index) {
    final selected = selectedIndex == index;
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: selected
            ? dark
                  ? theme.colorScheme.surfaceContainerHighest
                  : const Color(0xFFE1EFFB)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          borderRadius: BorderRadius.circular(17),
          onTap: () {
            Navigator.pop(context);

            if (index == 0) {
              _goHome();
              return;
            }

            if (index == 1) {
              _openCalendar();
              return;
            }

            if (index == 4) {
              _showSnackbar('Recursos estudiantiles: próximamente');
              return;
            }

            _navigateToSection(index);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: selected
                    ? dark
                          ? theme.colorScheme.outline
                          : const Color(0xFFC8DFF2)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: selected
                        ? dark
                              ? theme.colorScheme.primary
                              : const Color(0xFF164B73)
                        : dark
                        ? theme.colorScheme.surfaceContainerHigh
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: selected
                        ? dark
                              ? theme.colorScheme.onPrimary
                              : Colors.white
                        : dark
                        ? theme.colorScheme.onSurfaceVariant
                        : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: selected
                              ? dark
                                    ? theme.colorScheme.primary
                                    : const Color(0xFF164B73)
                              : dark
                              ? theme.colorScheme.onSurface
                              : const Color(0xFF061424),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: dark
                              ? theme.colorScheme.onSurfaceVariant
                              : const Color(0xFF8290A2),
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: dark
                        ? theme.colorScheme.primary
                        : const Color(0xFF164B73),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MODELOS DE LA INTERFAZ
// ============================================================

class _DockItem {
  final IconData activeIcon;
  final IconData icon;
  final String label;

  const _DockItem(this.activeIcon, this.icon, this.label);
}

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
