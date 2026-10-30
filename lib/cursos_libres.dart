import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';
import 'calendario.dart';
import 'curso_detalle.dart';
import 'navegacion_glass.dart';
import 'notificaciones.dart';
import 'perfil.dart';
import 'responsive_layout.dart';

const Color _primaryNavy = Color(0xFF061424);
const Color _deepBlue = Color(0xFF0D233A);
const Color _accentBlue = Color(0xFF0EA5E9);

class CursosLibresCatalogoPage extends StatefulWidget {
  const CursosLibresCatalogoPage({super.key});

  @override
  State<CursosLibresCatalogoPage> createState() =>
      _CursosLibresCatalogoPageState();
}

class _CursoData {
  final String titulo;
  final String categoria;
  final String descripcion;
  final String niveles;
  final String imagen;
  final String idDetalle;
  final IconData icono;
  final List<Color> colores;

  const _CursoData({
    required this.titulo,
    required this.categoria,
    required this.descripcion,
    required this.niveles,
    required this.imagen,
    required this.idDetalle,
    required this.icono,
    required this.colores,
  });
}

class _CursosLibresCatalogoPageState extends State<CursosLibresCatalogoPage>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;

  String _busqueda = '';
  String _filtro = 'Todos';

  final TextEditingController _busquedaController = TextEditingController();

  late final AnimationController _entradaController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  final ScrollController _scrollController = ScrollController();

  static const List<_CursoData> _cursos = [
    _CursoData(
      titulo: 'Excel',
      categoria: 'Herramientas digitales',
      descripcion: 'Aprendé a organizar información, utilizar fórmulas y trabajar con hojas de cálculo para facilitar las tareas profesionales.',
      niveles: '3 niveles',
      imagen: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=90',
      idDetalle: 'excel-avanzado-ii',
      icono: Icons.table_chart_rounded,
      colores: [Color(0xFF061424), Color(0xFF2878B5)],
    ),
    _CursoData(
      titulo: 'Power BI',
      categoria: 'Análisis de datos',
      descripcion: 'Creá informes, paneles y visualizaciones para analizar datos y facilitar la toma de decisiones.',
      niveles: 'Consultar niveles',
      imagen: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=1200&q=90',
      idDetalle: 'power-bi-produccion-calidad',
      icono: Icons.bar_chart_rounded,
      colores: [Color(0xFF061424), Color(0xFF2878B5)],
    ),
    _CursoData(
      titulo: 'Minitab',
      categoria: 'Estadística',
      descripcion: 'Utilizá herramientas estadísticas para analizar datos, estudiar procesos y apoyar la mejora continua.',
      niveles: '6 niveles',
      imagen: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=90',
      idDetalle: 'minitab',
      icono: Icons.analytics_rounded,
      colores: [Color(0xFF061424), Color(0xFF2878B5)],
    ),
    _CursoData(
      titulo: 'Gerencia de Proyectos',
      categoria: 'Gestión',
      descripcion: 'Conocé herramientas para planificar, organizar, ejecutar y dar seguimiento a proyectos.',
      niveles: 'Consultar niveles',
      imagen: 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?auto=format&fit=crop&w=1200&q=90',
      idDetalle: 'fundamentos-gerencia-proyectos',
      icono: Icons.account_tree_rounded,
      colores: [Color(0xFF343A78), Color(0xFF7C3AED)],
    ),
    _CursoData(
      titulo: 'Caracterización y Análisis de Fallas',
      categoria: 'Calidad',
      descripcion: 'Aprendé a identificar fallas, estudiar sus causas y proponer acciones correctivas para mejorar los procesos.',
      niveles: 'Consultar niveles',
      imagen: 'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?auto=format&fit=crop&w=1200&q=90',
      idDetalle: 'caracterizacion-analisis-fallas',
      icono: Icons.troubleshoot_rounded,
      colores: [Color(0xFF087F8C), Color(0xFF14B8A6)],
    ),
    _CursoData(
      titulo: 'Normas ISO 14001, 45001 y 50001',
      categoria: 'Normativas',
      descripcion: 'Conocé normas relacionadas con la gestión ambiental, la seguridad y salud en el trabajo y la gestión de la energía.',
      niveles: '3 normas',
      imagen: 'https://images.unsplash.com/photo-1497366754035-f200968a6e72?auto=format&fit=crop&w=1200&q=90',
      idDetalle: 'normas-iso-14001-45001-50001',
      icono: Icons.verified_user_outlined,
      colores: [Color(0xFF854D0E), Color(0xFFEA8A24)],
    ),
    _CursoData(
      titulo: 'Servicio al Cliente',
      categoria: 'Servicio',
      descripcion: 'Desarrollá habilidades de comunicación y atención para brindar un mejor servicio y fortalecer las relaciones con los clientes.',
      niveles: 'Consultar niveles',
      imagen: 'https://images.unsplash.com/photo-1521737711867-e3b97375f902?auto=format&fit=crop&w=1200&q=90',
      idDetalle: 'introduccion-servicio-cliente',
      icono: Icons.support_agent_rounded,
      colores: [Color(0xFF7C3A70), Color(0xFFC25691)],
    ),
    _CursoData(
      titulo: 'Habilidades Blandas',
      categoria: 'Desarrollo personal',
      descripcion: 'Fortalecé la comunicación, el trabajo en equipo, la adaptabilidad y las relaciones interpersonales.',
      niveles: 'Consultar niveles',
      imagen: 'https://images.unsplash.com/photo-1556761175-b413da4baf72?auto=format&fit=crop&w=1200&q=90',
      idDetalle: 'habilidades-blandas',
      icono: Icons.groups_rounded,
      colores: [Color(0xFF7C3A70), Color(0xFFC25691)],
    ),
    _CursoData(
      titulo: 'Innovación y Cambio',
      categoria: 'Innovación',
      descripcion: 'Aprendé a impulsar ideas nuevas, identificar oportunidades y adaptarte a los cambios de las organizaciones.',
      niveles: 'Consultar niveles',
      imagen: 'https://images.unsplash.com/photo-1558655146-9f40138edfeb?auto=format&fit=crop&w=1200&q=90',
      idDetalle: 'innovacion-cambio',
      icono: Icons.lightbulb_outline_rounded,
      colores: [Color(0xFF166534), Color(0xFF65A30D)],
    ),
    _CursoData(
      titulo: 'Liderazgo',
      categoria: 'Gestión',
      descripcion: 'Desarrollá capacidades para orientar equipos, tomar decisiones y trabajar en el cumplimiento de objetivos.',
      niveles: 'Consultar niveles',
      imagen: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=1200&q=90',
      idDetalle: 'liderazgo',
      icono: Icons.workspace_premium_outlined,
      colores: [Color(0xFF343A78), Color(0xFF7C3AED)],
    ),
    _CursoData(
      titulo: 'Producción Esbelta',
      categoria: 'Producción',
      descripcion: 'Conocé principios para optimizar procesos, aprovechar recursos y reducir actividades que no agregan valor.',
      niveles: 'Consultar niveles',
      imagen: 'https://images.unsplash.com/photo-1581092160562-40aa08e78837?auto=format&fit=crop&w=1200&q=90',
      idDetalle: 'produccion-esbelta',
      icono: Icons.precision_manufacturing_outlined,
      colores: [Color(0xFF14532D), Color(0xFF16A34A)],
    ),
    _CursoData(
      titulo: 'Taller Norma 17025',
      categoria: 'Normativas',
      descripcion: 'Conocé aspectos de la norma relacionada con la competencia de los laboratorios de ensayo y calibración.',
      niveles: 'Taller',
      imagen: 'https://images.unsplash.com/photo-1582719471384-894fbb16e074?auto=format&fit=crop&w=1200&q=90',
      idDetalle: 'norma-17025',
      icono: Icons.fact_check_outlined,
      colores: [Color(0xFF854D0E), Color(0xFFEA8A24)],
    ),
    _CursoData(
      titulo: 'Norma ISO 37002',
      categoria: 'Normativas',
      descripcion: 'Conocé lineamientos para establecer sistemas de gestión de denuncias y promover una respuesta adecuada en las organizaciones.',
      niveles: 'Norma',
      imagen: 'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?auto=format&fit=crop&w=1200&q=90',
      idDetalle: 'norma-iso-37002',
      icono: Icons.gpp_good_outlined,
      colores: [Color(0xFF854D0E), Color(0xFFEA8A24)],
    ),
    _CursoData(
      titulo: 'Eliminación de Desperdicios',
      categoria: 'Mejora continua',
      descripcion: 'Identificá desperdicios en los procesos y aprendé a reducir actividades innecesarias para mejorar el aprovechamiento de los recursos.',
      niveles: 'Consultar niveles',
      imagen: 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?auto=format&fit=crop&w=1200&q=90',
      idDetalle: 'eliminacion-desperdicios',
      icono: Icons.delete_sweep_outlined,
      colores: [Color(0xFF087F8C), Color(0xFF14B8A6)],
    ),
    _CursoData(
      titulo: 'Buenas Prácticas para un Ambiente Productivo y Seguro',
      categoria: 'Seguridad y productividad',
      descripcion: 'Reforzá prácticas para promover espacios de trabajo ordenados, productivos y seguros.',
      niveles: 'Consultar niveles',
      imagen: 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?auto=format&fit=crop&w=1200&q=90',
      idDetalle: 'ambiente-productivo-seguro',
      icono: Icons.health_and_safety_outlined,
      colores: [Color(0xFF854D0E), Color(0xFFEA8A24)],
    ),
  ];

  static const Map<String, List<String>> _categorias = {
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

  List<String> get _filtros => ['Todos', ..._categorias.keys];

  List<_CursoData> get _cursosFiltrados {
    final consulta = _busqueda.trim().toLowerCase();

    return _cursos.where((curso) {
      final coincideTexto =
          consulta.isEmpty ||
          curso.titulo.toLowerCase().contains(consulta) ||
          curso.categoria.toLowerCase().contains(consulta) ||
          curso.descripcion.toLowerCase().contains(consulta);

      final categoriasSeleccionadas = _categorias[_filtro] ?? const [];

      final coincideCategoria =
          _filtro == 'Todos' ||
          categoriasSeleccionadas.contains(curso.categoria);

      return coincideTexto && coincideCategoria;
    }).toList();
  }

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
        return const Color(0xFF16A34A);
      default:
        return _accentBlue;
    }
  }

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
    _busquedaController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // NAVEGACIÓN
  // ----------------------------------------------------------

  void _abrirCurso(_CursoData curso) {
    HapticFeedback.selectionClick();

    Navigator.push(
      context,
      appPageRoute<void>(
        builder: (_) => CursoDetallePage(
          curso: CursoLibreData(
            id: curso.idDetalle,
            nombre: curso.titulo,
            categoria: curso.categoria,
            tipo: 'Curso libre',
            grupo: curso.niveles,
            descripcion: curso.descripcion,
            aspectos: [curso.niveles],
            imagen: curso.imagen,
            colores: curso.colores,
            icono: curso.icono,
          ),
        ),
      ),
    );
  }

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
  // ENCABEZADO
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
          colors: [_primaryNavy, _deepBlue, Color(0xFF1B3C73)],
        ),
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: _primaryNavy.withValues(alpha: 0.20),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            Positioned(
              top: -100,
              right: -60,
              child: _burbuja(220, _accentBlue.withValues(alpha: 0.12)),
            ),
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
                    'Ampliá tus habilidades con opciones prácticas para tu desarrollo profesional.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.5,
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

  Widget _burbuja(double size, Color color) {
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: 35, sigmaY: 35),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  // ----------------------------------------------------------
  // BÚSQUEDA Y FILTROS
  // ----------------------------------------------------------

  Widget _construirBusqueda() {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: TextField(
          controller: _busquedaController,
          onChanged: (value) {
            setState(() => _busqueda = value);
          },
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Buscar un curso...',
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
            prefixIcon: const Icon(Icons.search_rounded, color: _accentBlue),
            suffixIcon: _busqueda.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _busquedaController.clear();
                      setState(() => _busqueda = '');
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHigh.withValues(
              alpha: 0.78,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 17,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: _accentBlue, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirFiltros() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _filtros.map((filtro) {
          final activo = _filtro == filtro;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filtro),
              selected: activo,
              onSelected: (_) {
                setState(() => _filtro = filtro);
              },
              showCheckmark: false,
              labelStyle: TextStyle(
                color: activo
                    ? Colors.white
                    : theme.colorScheme.onSurfaceVariant,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
              selectedColor: _primaryNavy,
              backgroundColor: theme.colorScheme.surfaceContainerHigh
                  .withValues(alpha: 0.8),
              side: BorderSide(
                color: activo ? _primaryNavy : theme.colorScheme.outlineVariant,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ----------------------------------------------------------
  // TARJETAS DE CURSOS CON FOTOGRAFÍAS
  // ----------------------------------------------------------

  Widget _crearTarjeta(
    _CursoData curso, {
    required double height,
    required double cardWidth,
  }) {
    final contenidoAmplio = height >= 200 || cardWidth >= 600;
    const radio = 25.0;

    return GelPress(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radio),
        child: InkWell(
          onTap: () => _abrirCurso(curso),
          borderRadius: BorderRadius.circular(radio),
          child: Container(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radio),
              gradient: LinearGradient(
                colors: curso.colores,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.38)),
              boxShadow: [
                BoxShadow(
                  color: curso.colores.first.withValues(alpha: 0.22),
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
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
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
                            curso.colores.first.withValues(alpha: 0.94),
                            curso.colores.first.withValues(alpha: 0.72),
                            curso.colores.last.withValues(alpha: 0.28),
                          ],
                          stops: const [0.0, 0.48, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(17, 15, 43, 15),
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
                                curso.icono,
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
                                curso.titulo,
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
                                      color: Colors.black.withValues(
                                        alpha: 0.16,
                                      ),
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
                    right: 11,
                    bottom: 11,
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

  // ----------------------------------------------------------
  // CATÁLOGO AGRUPADO POR CATEGORÍA
  // ----------------------------------------------------------

  Widget _construirCatalogo({required double ancho, required double alto}) {
    final theme = Theme.of(context);
    final cursosFiltrados = _cursosFiltrados;

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
                    'Explorá el catálogo',
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
                    color: theme.brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.07)
                        : Colors.white.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.white,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.grid_view_rounded,
                        color: _accentBlue,
                        size: 16,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        '${cursosFiltrados.length} cursos',
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
              'Explorá las áreas y encontrá tu próximo aprendizaje.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            _construirBusqueda(),
            const SizedBox(height: 13),
            _construirFiltros(),
            const SizedBox(height: 23),

            if (cursosFiltrados.isEmpty)
              _construirSinResultados()
            else
              for (final grupo in _categorias.entries)
                Builder(
                  builder: (context) {
                    final cursosGrupo = cursosFiltrados
                        .where((curso) => grupo.value.contains(curso.categoria))
                        .toList();

                    if (cursosGrupo.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    final color = _colorGrupo(grupo.key);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 25),
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
                                for (
                                  var i = 0;
                                  i < cursosGrupo.length;
                                  i++
                                ) ...[
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
                              itemBuilder: (context, index) {
                                return _crearTarjeta(
                                  cursosGrupo[index],
                                  height: alturaTarjeta,
                                  cardWidth:
                                      (anchoDisponible -
                                          espacio * (columnas - 1)) /
                                      columnas,
                                );
                              },
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

  Widget _construirSinResultados() {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 45,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'No encontramos cursos',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Probá con otro nombre o seleccioná otra categoría.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
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
                    colors: [Color(0xFF164B73), _accentBlue],
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
                  'Descubrí nuevas oportunidades de formación.',
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
                color: _accentBlue,
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
