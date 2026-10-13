import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const TecApp());
}

class TecApp extends StatelessWidget {
  const TecApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TEC Móvil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF6F8FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF061424),
          brightness: Brightness.light,
        ),
      ),
      home: const TecHomeScreen(),
    );
  }
}

// Modelo para los elementos indexados
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
  static const Color backgroundGrey = Color(0xFFF6F8FA);

  int selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Índice global de contenido de toda la app
  late final List<AppSearchItem> _searchItems = [
    AppSearchItem(
      title: 'Técnico en Calidad',
      subtitle: 'Control, mejora y aseguramiento de la calidad industrial.',
      icon: Icons.verified_outlined,
      category: 'Académico',
      onTap: () => _showSnackbar('Abriendo detalle: Técnico en Calidad'),
    ),
    AppSearchItem(
      title: 'Licenciatura Industrial',
      subtitle: 'Grado académico superior orientado a la alta gerencia.',
      icon: Icons.workspace_premium_rounded,
      category: 'Académico',
      onTap: () => _showSnackbar('Abriendo detalle: Licenciatura Industrial'),
    ),
    AppSearchItem(
      title: 'Posgrados Industrial',
      subtitle: 'Programas de posgrado especializados para ingenieros.',
      icon: Icons.school_outlined,
      category: 'Académico',
      onTap: () => _showSnackbar('Abriendo detalle: Posgrados Industrial'),
    ),
    AppSearchItem(
      title: 'Calendario Académico',
      subtitle: 'Consulta fechas importantes, exámenes y entregas.',
      icon: Icons.calendar_month_rounded,
      category: 'Sección',
      onTap: () {
        setState(() => selectedIndex = 1);
        _clearSearch();
      },
    ),
    AppSearchItem(
      title: 'Noticias del TEC',
      subtitle: 'Entérate de los últimos acontecimientos institucionales.',
      icon: Icons.newspaper_rounded,
      category: 'Sección',
      onTap: () => _showSnackbar('Abriendo sección de Noticias'),
    ),
    AppSearchItem(
      title: 'Recursos Estudiantiles',
      subtitle: 'Material didáctico, guías y descargas útiles.',
      icon: Icons.menu_book_rounded,
      category: 'Herramientas',
      onTap: () => _showSnackbar('Abriendo Recursos'),
    ),
    AppSearchItem(
      title: 'Mi Perfil',
      subtitle: 'Gestiona tu cuenta, estado activo y datos de estudiante.',
      icon: Icons.person_outline_rounded,
      category: 'Usuario',
      onTap: () {
        setState(() => selectedIndex = 3);
        _clearSearch();
      },
    ),
    AppSearchItem(
      title: 'Escuela de Ingeniería en Producción Industrial',
      subtitle: 'Conoce más sobre la escuela, historia y contactos.',
      icon: Icons.engineering_outlined,
      category: 'Institucional',
      onTap: () => _showSnackbar('Abriendo info de la Escuela'),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(_fadeAnimation);
    _entranceController.forward();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    FocusScope.of(context).unfocus();
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
        backgroundColor: deepBlue,
        duration: const Duration(milliseconds: 1600),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            final isFoldableOrTablet = width >= 720;
            final isLandscapePhone = width > height && width < 720;
            final contentMaxWidth = isFoldableOrTablet
                ? 960.0
                : (isLandscapePhone ? 720.0 : 460.0);
            final sideBySideCards = width >= 580;

            final filteredItems = _searchItems
                .where((item) =>
                    item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    item.subtitle
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ||
                    item.category
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                .toList();

            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: math.min(width, contentMaxWidth),
                          child: CustomScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
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
                                  36,
                                ),
                                sliver: _searchQuery.isEmpty
                                    ? SliverList(
                                        delegate: SliverChildListDelegate(
                                          [
                                            _buildMainCards(
                                              wide: sideBySideCards,
                                              compact: isLandscapePhone,
                                            ),
                                            const SizedBox(height: 26),
                                            _buildQuickAccess(
                                                wide: isFoldableOrTablet),
                                            const SizedBox(height: 30),
                                            _buildQuickLinks(),
                                            const SizedBox(height: 24),
                                          ],
                                        ),
                                      )
                                    : _buildSearchResultsSliver(filteredItems),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildBottomNavigation(
                      wide: isFoldableOrTablet,
                      compact: isLandscapePhone,
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

  Widget _buildHeader({required bool compact, required bool wide}) {
    final horizontalPadding = wide ? 32.0 : 20.0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        compact ? 16 : 22,
        horizontalPadding,
        compact ? 24 : 32,
      ),
      decoration: BoxDecoration(
        color: primaryNavy,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryNavy.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?auto=format&fit=crop&w=1400&q=85',
          ),
          fit: BoxFit.cover,
          opacity: 0.14,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildLiquidGlassButton(
                icon: Icons.menu_rounded,
                onTap: () => HapticFeedback.lightImpact(),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'TEC',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Georgia',
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                  Container(
                    width: 2.5,
                    height: 26,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: alertRed,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    'Tecnológico\nde Costa Rica',
                    style: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'Georgia',
                      fontSize: 10.5,
                      height: 1.15,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildLiquidGlassButton(
                    icon: Icons.notifications_none_rounded,
                    onTap: () => HapticFeedback.lightImpact(),
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
                        border: Border.all(color: primaryNavy, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: compact ? 18 : 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  ],
                ),
              ),
              // Insignia Activo con Liquid Glass
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: Colors.amberAccent, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'Activo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Escuela de Ingeniería con Liquid Glass
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.engineering_outlined,
                        color: Colors.white70, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Escuela de Ingeniería en Producción Industrial',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: compact ? 16 : 20),

          // --- BARRA DE BÚSQUEDA LIQUID GLASS (DEBAJO DE LA ESCUELA) ---
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
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
                    Icon(Icons.search_rounded,
                        color: _searchQuery.isNotEmpty
                            ? accentTeal
                            : Colors.white70,
                        size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
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
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
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
                          child: const Icon(Icons.close_rounded,
                              color: Colors.white, size: 15),
                        ),
                      )
                    else
                      Icon(Icons.tune_rounded,
                          color: Colors.white.withOpacity(0.6), size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiquidGlassButton(
      {required IconData icon, required VoidCallback onTap}) {
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

  Widget _buildSearchResultsSliver(List<AppSearchItem> results) {
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
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(Icons.search_off_rounded,
                    size: 44, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 18),
              const Text(
                'Sin resultados encontrados',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: primaryNavy,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Prueba con otra palabra clave o término.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Text(
                    'Resultados de búsqueda (${results.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryNavy,
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
                    child: const Text('Limpiar búsqueda',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            );
          }

          final item = results[index - 1];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
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
                onTap: () {
                  HapticFeedback.selectionClick();
                  item.onTap();
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: deepBlue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(item.icon, color: deepBlue, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryNavy,
                                fontSize: 14.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: deepBlue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          item.category,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: deepBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        childCount: results.length + 1,
      ),
    );
  }

  Widget _buildMainCards({required bool wide, required bool compact}) {
    final cards = [
      _MainCardData(
        gradientColors: [deepBlue, const Color(0xFF1B3C73)],
        icon: Icons.verified_outlined,
        title: 'Técnico en\nCalidad',
        description:
            'Desarrolla tus habilidades en control, mejora y aseguramiento de la calidad industrial.',
        imageUrl:
            'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?auto=format&fit=crop&w=800&q=85',
      ),
      _MainCardData(
        gradientColors: [const Color(0xFF0D9488), const Color(0xFF14B8A6)],
        icon: Icons.workspace_premium_rounded,
        title: 'Licenciatura\nIndustrial',
        description:
            'Obtén tu grado académico superior con planes de estudio orientados a la alta gerencia.',
        imageUrl:
            'https://images.unsplash.com/photo-1531482615713-2afd69097998?auto=format&fit=crop&w=800&q=85',
      ),
      _MainCardData(
        gradientColors: [accentPurple, const Color(0xFF4E46B4)],
        icon: Icons.school_outlined,
        title: 'Posgrados\nIndustrial',
        description:
            'Lleva tu conocimiento al siguiente nivel con programas de posgrado especializados.',
        imageUrl:
            'https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=800&q=85',
      ),
    ];

    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: 16),
            Expanded(
              child: _buildProCard(data: cards[i], height: 175, wide: true),
            ),
          ],
        ],
      );
    }

    return Column(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(height: 14),
          _buildProCard(data: cards[i], height: compact ? 130 : 145),
        ],
      ],
    );
  }

  Widget _buildProCard({
    required _MainCardData data,
    required double height,
    bool wide = false,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => HapticFeedback.selectionClick(),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: data.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: data.gradientColors.first.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: wide ? 210 : 165,
                    height: height,
                    child: Image.network(
                      data.imageUrl,
                      fit: BoxFit.cover,
                      color: data.gradientColors.first.withOpacity(0.78),
                      colorBlendMode: BlendMode.hardLight,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.15)),
                        ),
                        child: Icon(data.icon,
                            color: Colors.white, size: wide ? 34 : 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              data.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: wide ? 18 : 16,
                                fontWeight: FontWeight.bold,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              data.description,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.92),
                                fontSize: 11.5,
                                height: 1.35,
                              ),
                              maxLines: wide ? 3 : 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccess({required bool wide}) {
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              elevation: 0,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  if (items[i].label == 'Calendario') {
                    setState(() => selectedIndex = 1);
                  } else if (items[i].label == 'Mi Perfil') {
                    setState(() => selectedIndex = 3);
                  } else {
                    _showSnackbar('Abriendo ${items[i].label}');
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: wide ? 100 : 90,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
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
                        child: Icon(items[i].icon,
                            color: items[i].color, size: 22),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          items[i].label,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
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

  Widget _buildQuickLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Enlaces rápidos',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: primaryNavy,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            TextButton(
              onPressed: () => HapticFeedback.lightImpact(),
              style: TextButton.styleFrom(
                foregroundColor: primaryNavy,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Row(
                children: [
                  Text('Ver todo',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 14),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () => HapticFeedback.selectionClick(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
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
                      child: Icon(Icons.school_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Conoce más sobre la Escuela\nde Ingeniería en Producción Industrial',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: primaryNavy,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8), size: 22),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation({required bool wide, required bool compact}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: wide ? 960 : 460),
          child: NavigationBar(
            height: compact ? 62 : 72,
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              HapticFeedback.selectionClick();
              setState(() => selectedIndex = index);
            },
            backgroundColor: Colors.white,
            indicatorColor: deepBlue.withOpacity(0.12),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded, color: deepBlue),
                label: 'Inicio',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon:
                    Icon(Icons.calendar_month_rounded, color: deepBlue),
                label: 'Calendario',
              ),
              NavigationDestination(
                icon: Icon(Icons.notifications_none_outlined),
                selectedIcon:
                    Icon(Icons.notifications_rounded, color: deepBlue),
                label: 'Notificaciones',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_outlined),
                selectedIcon: Icon(Icons.person_rounded, color: deepBlue),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MainCardData {
  final List<Color> gradientColors;
  final IconData icon;
  final String title;
  final String description;
  final String imageUrl;

  const _MainCardData({
    required this.gradientColors,
    required this.icon,
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}

class _QuickItem {
  final IconData icon;
  final String label;
  final Color color;

  const _QuickItem(this.icon, this.label, this.color);
}