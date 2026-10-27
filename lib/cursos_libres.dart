import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';
import 'calendario.dart';
import 'navegacion_glass.dart';
import 'notificaciones.dart';
import 'perfil.dart';
import 'responsive_layout.dart';

const Color primaryNavy = Color(0xFF061424);
const Color deepBlue = Color(0xFF0D233A);
const Color accentBlue = Color(0xFF0EA5E9);
const Color accentCyan = Color(0xFF9DEBFF);

class CursosLibresPage extends StatefulWidget {
  const CursosLibresPage({super.key});

  @override
  State<CursosLibresPage> createState() => _CursosLibresPageState();
}

class _CursoLibre {
  final String nombre;
  final String descripcion;
  final String categoria;
  final String niveles;
  final String imagen;

  const _CursoLibre({
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.niveles,
    required this.imagen,
  });
}

class _CursosLibresPageState extends State<CursosLibresPage>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;

  late final AnimationController _entradaController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  final ScrollController _scrollController = ScrollController();

  final List<_CursoLibre> _cursos = const [
    _CursoLibre(
      nombre: 'Excel',
      descripcion: 'Aprende a organizar información, utilizar fórmulas y trabajar con hojas de cálculo.',
      categoria: 'Herramientas digitales',
      niveles: '3 niveles',
      imagen: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=90',
    ),
    _CursoLibre(
      nombre: 'Power BI',
      descripcion: 'Crea informes y visualizaciones para analizar datos y facilitar la toma de decisiones.',
      categoria: 'Análisis de datos',
      niveles: 'Consultar niveles',
      imagen: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=1200&q=90',
    ),
    _CursoLibre(
      nombre: 'Minitab',
      descripcion: 'Utiliza herramientas estadísticas para analizar datos y mejorar procesos.',
      categoria: 'Estadística',
      niveles: '6 niveles',
      imagen: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=90',
    ),
    _CursoLibre(
      nombre: 'Gerencia de Proyectos',
      descripcion: 'Conoce herramientas para planificar, organizar y dar seguimiento a proyectos.',
      categoria: 'Gestión',
      niveles: 'Consultar niveles',
      imagen: 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?auto=format&fit=crop&w=1200&q=90',
    ),
    _CursoLibre(
      nombre: 'Caracterización y Análisis de Fallas',
      descripcion: 'Aprende a identificar fallas, estudiar sus causas y proponer acciones de mejora.',
      categoria: 'Calidad',
      niveles: 'Consultar niveles',
      imagen: 'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?auto=format&fit=crop&w=1200&q=90',
    ),
    _CursoLibre(
      nombre: 'Normas ISO 14001, 45001 y 50001',
      descripcion: 'Conoce normas relacionadas con la gestión ambiental, la seguridad laboral y la energía.',
      categoria: 'Normativas',
      niveles: '3 normas',
      imagen: 'https://images.unsplash.com/photo-1497366754035-f200968a6e72?auto=format&fit=crop&w=1200&q=90',
    ),
    _CursoLibre(
      nombre: 'Servicio al Cliente',
      descripcion: 'Desarrolla habilidades para atender clientes y mejorar su experiencia de servicio.',
      categoria: 'Servicio',
      niveles: 'Consultar niveles',
      imagen: 'https://images.unsplash.com/photo-1521737711867-e3b97375f902?auto=format&fit=crop&w=1200&q=90',
    ),
    _CursoLibre(
      nombre: 'Habilidades Blandas',
      descripcion: 'Fortalece la comunicación, el trabajo en equipo y las relaciones interpersonales.',
      categoria: 'Desarrollo personal',
      niveles: 'Consultar niveles',
      imagen: 'https://images.unsplash.com/photo-1556761175-b413da4baf72?auto=format&fit=crop&w=1200&q=90',
    ),
    _CursoLibre(
      nombre: 'Innovación y Cambio',
      descripcion: 'Aprende a impulsar ideas nuevas y adaptarte a los cambios en las organizaciones.',
      categoria: 'Innovación',
      niveles: 'Consultar niveles',
      imagen: 'https://images.unsplash.com/photo-1558655146-9f40138edfeb?auto=format&fit=crop&w=1200&q=90',
    ),
    _CursoLibre(
      nombre: 'Liderazgo',
      descripcion: 'Desarrolla capacidades para orientar equipos, tomar decisiones y alcanzar objetivos.',
      categoria: 'Gestión',
      niveles: 'Consultar niveles',
      imagen: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=1200&q=90',
    ),
    _CursoLibre(
      nombre: 'Producción Esbelta',
      descripcion: 'Conoce principios para mejorar procesos, aprovechar recursos y reducir actividades innecesarias.',
      categoria: 'Producción',
      niveles: 'Consultar niveles',
      imagen: 'https://images.unsplash.com/photo-1581092160562-40aa08e78837?auto=format&fit=crop&w=1200&q=90',
    ),
    _CursoLibre(
      nombre: 'Taller Norma 17025',
      descripcion: 'Conoce aspectos de la norma relacionada con la competencia de laboratorios de ensayo y calibración.',
      categoria: 'Normativas',
      niveles: 'Taller',
      imagen: 'https://images.unsplash.com/photo-1582719471384-894fbb16e074?auto=format&fit=crop&w=1200&q=90',
    ),
    _CursoLibre(
      nombre: 'Norma ISO 37002',
      descripcion: 'Conoce lineamientos para implementar sistemas de gestión de denuncias en las organizaciones.',
      categoria: 'Normativas',
      niveles: 'Norma',
      imagen: 'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?auto=format&fit=crop&w=1200&q=90',
    ),
    _CursoLibre(
      nombre: 'Eliminación de Desperdicios',
      descripcion: 'Identifica desperdicios en los procesos y aprende a reducir actividades que no agregan valor.',
      categoria: 'Mejora continua',
      niveles: 'Consultar niveles',
      imagen: 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?auto=format&fit=crop&w=1200&q=90',
    ),
    _CursoLibre(
      nombre: 'Buenas Prácticas para un Ambiente Productivo y Seguro',
      descripcion: 'Refuerza prácticas para promover espacios de trabajo organizados, productivos y seguros.',
      categoria: 'Seguridad y productividad',
      niveles: 'Consultar niveles',
      imagen: 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?auto=format&fit=crop&w=1200&q=90',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _entradaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entradaController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.035),
      end: Offset.zero,
    ).animate(_fadeAnimation);

    _entradaController.forward();
  }

  @override
  void dispose() {
    _entradaController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // CATEGORÍAS Y COLORES
  // ----------------------------------------------------------

  final Map<String, List<String>> _categorias = const {
    'Herramientas digitales y datos': [
      'Herramientas digitales',
      'Análisis de datos',
      'Estadística',
    ],
    'Gestión y desarrollo': [
      'Gestión',
      'Servicio',
      'Desarrollo personal',
      'Innovación',
    ],
    'Calidad y mejora continua': ['Calidad', 'Mejora continua'],
    'Normativas y seguridad': ['Normativas', 'Seguridad y productividad'],
    'Producción': ['Producción'],
  };

  Color _colorGrupo(String grupo) {
    switch (grupo) {
      case 'Herramientas digitales y datos':
        return const Color(0xFF2878B5);
      case 'Gestión y desarrollo':
        return const Color(0xFF7C3AED);
      case 'Calidad y mejora continua':
        return const Color(0xFF0D9488);
      case 'Normativas y seguridad':
        return const Color(0xFFEA8A24);
      case 'Producción':
        return const Color(0xFF166534);
      default:
        return accentBlue;
    }
  }

  List<Color> _coloresCurso(_CursoLibre curso) {
    switch (curso.categoria) {
      case 'Herramientas digitales':
      case 'Análisis de datos':
      case 'Estadística':
        return const [Color(0xFF061424), Color(0xFF2878B5)];

      case 'Gestión':
        return const [Color(0xFF343A78), Color(0xFF7C3AED)];

      case 'Calidad':
      case 'Mejora continua':
        return const [Color(0xFF087F8C), Color(0xFF14B8A6)];

      case 'Normativas':
      case 'Seguridad y productividad':
        return const [Color(0xFF854D0E), Color(0xFFEA8A24)];

      case 'Servicio':
      case 'Desarrollo personal':
        return const [Color(0xFF7C3A70), Color(0xFFC25691)];

      case 'Innovación':
        return const [Color(0xFF166534), Color(0xFF65A30D)];

      case 'Producción':
        return const [Color(0xFF14532D), Color(0xFF16A34A)];

      default:
        return const [Color(0xFF0D233A), Color(0xFF1B3C73)];
    }
  }

  IconData _iconoCurso(_CursoLibre curso) {
    switch (curso.categoria) {
      case 'Herramientas digitales':
        return Icons.table_chart_rounded;
      case 'Análisis de datos':
        return Icons.bar_chart_rounded;
      case 'Estadística':
        return Icons.analytics_rounded;
      case 'Gestión':
        return Icons.account_tree_rounded;
      case 'Calidad':
        return Icons.troubleshoot_rounded;
      case 'Normativas':
        return Icons.verified_user_outlined;
      case 'Servicio':
        return Icons.support_agent_rounded;
      case 'Desarrollo personal':
        return Icons.groups_rounded;
      case 'Innovación':
        return Icons.lightbulb_outline_rounded;
      case 'Producción':
        return Icons.precision_manufacturing_outlined;
      case 'Mejora continua':
        return Icons.delete_sweep_outlined;
      case 'Seguridad y productividad':
        return Icons.health_and_safety_outlined;
      default:
        return Icons.school_outlined;
    }
  }

  // ----------------------------------------------------------
  // NAVEGACIÓN
  // ----------------------------------------------------------

  void _abrirCalendario() {
    HapticFeedback.selectionClick();

    Navigator.push(
      context,
      appPageRoute<void>(builder: (_) => const CalendarioPage()),
    );
  }

  void _abrirPerfil() {
    HapticFeedback.selectionClick();

    Navigator.push(
      context,
      appPageRoute<void>(builder: (_) => const PerfilPage()),
    );
  }

  void _abrirAvisos() {
    HapticFeedback.selectionClick();

    Navigator.push(
      context,
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

    setState(() => selectedIndex = index);

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

  // ----------------------------------------------------------
  // DETALLES DEL CURSO
  // ----------------------------------------------------------

  void _mostrarDetalles(_CursoLibre curso) {
    HapticFeedback.selectionClick();

    final colores = _coloresCurso(curso);
    final esOscuro = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: primaryNavy.withValues(alpha: 0.58),
      builder: (_) => DisplayFeatureSubScreen(
        child: Builder(
          builder: (sheetContext) {
            final tamanoPantalla = MediaQuery.sizeOf(sheetContext);
            final anchoDialogo = math
                .min(1000.0, tamanoPantalla.width - 24)
                .clamp(0.0, tamanoPantalla.width)
                .toDouble();

            return SafeArea(
              top: false,
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: anchoDialogo,
                    maxHeight: tamanoPantalla.height * 0.88,
                  ),
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                      child: Container(
                        decoration: BoxDecoration(
                          color: esOscuro
                              ? const Color(0xFF101E2C).withValues(alpha: 0.97)
                              : Colors.white.withValues(alpha: 0.97),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryNavy.withValues(alpha: 0.28),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: math
                                    .min(225.0, tamanoPantalla.height * 0.32)
                                    .clamp(120.0, 225.0)
                                    .toDouble(),
                                width: double.infinity,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      curso.imagen,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Container(
                                        color: deepBlue,
                                        child: const Icon(
                                          Icons.school_rounded,
                                          size: 65,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            primaryNavy.withValues(alpha: 0.05),
                                            primaryNavy.withValues(alpha: 0.15),
                                            primaryNavy.withValues(alpha: 0.92),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 14,
                                      right: 14,
                                      child: _botonCristal(
                                        icono: Icons.close_rounded,
                                        onTap: () =>
                                            Navigator.pop(sheetContext),
                                      ),
                                    ),
                                    Positioned(
                                      left: 22,
                                      right: 22,
                                      bottom: 20,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            width: 55,
                                            height: 55,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha: 0.17,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              border: Border.all(
                                                color: Colors.white.withValues(
                                                  alpha: 0.38,
                                                ),
                                              ),
                                            ),
                                            child: Icon(
                                              _iconoCurso(curso),
                                              color: Colors.white,
                                              size: 29,
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Text(
                                              curso.nombre,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.w800,
                                                height: 1.15,
                                                letterSpacing: -0.4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  22,
                                  22,
                                  22,
                                  24,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: accentBlue.withValues(alpha: 0.10),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: accentBlue.withValues(alpha: 0.18),
                                        ),
                                      ),
                                      child: Text(
                                        curso.categoria.toUpperCase(),
                                        style: const TextStyle(
                                          color: accentBlue,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    Text(
                                      curso.descripcion,
                                      style: TextStyle(
                                        color: esOscuro
                                            ? Colors.white70
                                            : const Color(0xFF526173),
                                        fontSize: 15,
                                        height: 1.65,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Container(
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: esOscuro
                                            ? Colors.white.withValues(alpha: 0.06)
                                            : const Color(0xFFEDF5FB),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: esOscuro
                                              ? Colors.white.withValues(alpha: 0.12)
                                              : const Color(0xFFD8E8F5),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: colores,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: const Icon(
                                              Icons.menu_book_rounded,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 13),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Información del curso',
                                                  style: TextStyle(
                                                    color: esOscuro
                                                        ? Colors.white54
                                                        : const Color(
                                                            0xFF64748B,
                                                          ),
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  curso.niveles,
                                                  style: TextStyle(
                                                    color: esOscuro
                                                        ? Colors.white
                                                        : primaryNavy,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 22),
                                    _botonAccionGlass(
                                      texto: 'Cerrar detalles',
                                      icono: Icons.check_rounded,
                                      onTap: () => Navigator.pop(sheetContext),
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
              ),
            );
          },
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // TARJETAS DE CURSOS
  // ----------------------------------------------------------

  Widget _crearTarjeta(
    _CursoLibre curso, {
    required double height,
    required double cardWidth,
  }) {
    final colores = _coloresCurso(curso);
    final contenidoAmplio = height >= 200 || cardWidth >= 600;
    const radio = 25.0;

    return GelPress(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radio),
        child: InkWell(
          onTap: () => _mostrarDetalles(curso),
          borderRadius: BorderRadius.circular(radio),
          child: Container(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radio),
              gradient: LinearGradient(
                colors: colores,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.38)),
              boxShadow: [
                BoxShadow(
                  color: colores.first.withValues(alpha: 0.22),
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
                        curso.imagen,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        alignment: Alignment.centerRight,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
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
                            colores.first.withValues(alpha: 0.88),
                            colores.first.withValues(alpha: 0.66),
                            colores.last.withValues(alpha: 0.22),
                          ],
                          stops: const [0.0, 0.40, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colores.first.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(17, 16, 45, 16),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(17),
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              width: height >= 200 ? 58 : 51,
                              height: height >= 200 ? 58 : 51,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.17),
                                borderRadius: BorderRadius.circular(17),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.38),
                                ),
                              ),
                              child: Icon(
                                _iconoCurso(curso),
                                color: Colors.white,
                                size: 27,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                curso.nombre,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: contenidoAmplio ? 17 : 15.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                  height: 1.16,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.16),
                                      blurRadius: 8,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                curso.descripcion,
                                maxLines: contenidoAmplio ? 3 : 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.90),
                                  fontSize: contenidoAmplio ? 12 : 11.2,
                                  height: 1.36,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 5,
                                runSpacing: 5,
                                children: [
                                  _etiquetaGlass(curso.categoria),
                                  _etiquetaGlass(curso.niveles),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      width: 33,
                      height: 33,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.42),
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
    );
  }

  Widget _etiquetaGlass(String texto) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 180),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
          ),
          child: Text(
            texto,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _botonCristal({required IconData icono, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.19),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.40)),
              ),
              child: Icon(icono, color: Colors.white, size: 22),
            ),
          ),
        ),
      ),
    );
  }

  Widget _botonAccionGlass({
    required String texto,
    required IconData icono,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF164B73), Color(0xFF061424)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
              boxShadow: [
                BoxShadow(
                  color: primaryNavy.withValues(alpha: 0.20),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icono, color: Colors.white, size: 19),
                const SizedBox(width: 10),
                Text(
                  texto,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // ENCABEZADO COMPARTIDO CON LAS DEMÁS SECCIONES
  // ----------------------------------------------------------

  Widget _construirEncabezado({required bool compact, required bool wide}) {
    final horizontalPadding = wide ? 32.0 : 22.0;
    const borderRadius = BorderRadius.only(
      bottomLeft: Radius.circular(30),
      bottomRight: Radius.circular(30),
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryNavy, deepBlue, Color(0xFF1B3C73)],
        ),
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: primaryNavy.withValues(alpha: 0.20),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                compact ? 12 : 16,
                horizontalPadding,
                compact ? 18 : 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppBackButton(
                    onDarkBackground: true,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  SizedBox(height: compact ? 5 : 10),
                  Text(
                    'Cursos libres',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: wide ? 30 : 25,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Amplía tus habilidades con opciones prácticas para tu desarrollo profesional.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  if (!compact) ...[
                    const SizedBox(height: 16),
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
                            Icons.school_outlined,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // CATÁLOGO AGRUPADO POR CATEGORÍA
  // ----------------------------------------------------------

  Widget _construirCatalogo({required double ancho, required double alto}) {
    final theme = Theme.of(context);
    final esOscuro = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final anchoDisponible = constraints.maxWidth;
        final hinge = ResponsiveLayout.verticalHinge(context);

        final columnasSugeridas = ResponsiveLayout.columnsForWidth(
          anchoDisponible,
          hinge: hinge,
          threeColumnMinWidth: 1050,
          twoColumnMinWidth: 570,
        );
        final landscape = ancho > alto && alto < 600;
        final columnas = landscape && hinge == null && anchoDisponible < 900
            ? 1
            : columnasSugeridas;
        final escalaTexto = MediaQuery.textScalerOf(context).scale(1);
        final alturaBase = landscape
            ? 176.0
            : columnas == 1
            ? 188.0
            : 205.0;
        final alturaTarjeta = alturaBase * math.max(1, escalaTexto);

        final espacio = ResponsiveLayout.spacingFor(context, minimum: 15);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Explora el catálogo',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.7,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: esOscuro
                        ? Colors.white.withValues(alpha: 0.07)
                        : Colors.white.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: esOscuro
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.white,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.grid_view_rounded,
                        color: accentBlue,
                        size: 16,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        '${_cursos.length} cursos',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Explora las áreas y encuentra tu próximo aprendizaje.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 19),
            for (final grupo in _categorias.entries)
              Builder(
                builder: (context) {
                  final cursosGrupo = _cursos
                      .where((curso) => grupo.value.contains(curso.categoria))
                      .toList();

                  if (cursosGrupo.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final color = _colorGrupo(grupo.key);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 28,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.25),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Text(
                                grupo.key,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.35,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.11),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: color.withValues(alpha: 0.14),
                                ),
                              ),
                              child: Text(
                                '${cursosGrupo.length}',
                                style: TextStyle(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 13),
                        if (columnas == 1)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var i = 0; i < cursosGrupo.length; i++) ...[
                                if (i > 0) SizedBox(height: espacio),
                                _crearTarjeta(
                                  cursosGrupo[i],
                                  height: alturaTarjeta,
                                  cardWidth: anchoDisponible,
                                ),
                              ],
                            ],
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: cursosGrupo.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columnas,
                                  crossAxisSpacing: espacio,
                                  mainAxisSpacing: espacio,
                                  mainAxisExtent: alturaTarjeta,
                                ),
                            itemBuilder: (context, index) => _crearTarjeta(
                              cursosGrupo[index],
                              height: alturaTarjeta,
                              cardWidth:
                                  (anchoDisponible - espacio * (columnas - 1)) /
                                  columnas,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            _construirPieCatalogo(),
          ],
        );
      },
    );
  }

  Widget _construirPieCatalogo() {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: dark
                ? Colors.white.withValues(alpha: 0.045)
                : Colors.white.withValues(alpha: 0.76),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: dark
                  ? Colors.white.withValues(alpha: 0.10)
                  : Colors.white.withValues(alpha: 0.95),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF164B73), Color(0xFF0EA5E9)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  'Descubre nuevas oportunidades de formación.',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 12,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: accentBlue,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // PANTALLA PRINCIPAL
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            final wide = width >= 720;
            final landscape = ResponsiveLayout.isCompactLandscape(
              width,
              height,
            );

            final maxWidth = ResponsiveLayout.contentMaxWidth(width);

            return Stack(
              children: [
                const FondoAppDifuminado(),
                Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: math.min(width, maxWidth),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: CustomScrollView(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          slivers: [
                            SliverToBoxAdapter(
                              child: _construirEncabezado(
                                compact: landscape,
                                wide: wide,
                              ),
                            ),
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                wide ? 26 : 16,
                                landscape ? 17 : 23,
                                wide ? 26 : 16,
                                landscape ? 120 : 130,
                              ),
                              sliver: SliverToBoxAdapter(
                                child: _construirCatalogo(
                                  ancho: width,
                                  alto: height,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: NavegacionGlass(
                    selectedIndex: selectedIndex,
                    wide: wide,
                    compact: landscape,
                    onSelected: _seleccionarSeccion,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
