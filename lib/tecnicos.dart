import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';
import 'calendario.dart';
import 'notificaciones.dart';
import 'perfil.dart';

class TecnicosPage extends StatefulWidget {
  const TecnicosPage({super.key});

  @override
  State<TecnicosPage> createState() => _TecnicosPageState();
}

class _TecnicosPageState extends State<TecnicosPage> {
  static const Color primaryNavy = Color(0xFF061424);
  static const Color deepBlue = Color(0xFF0D233A);
  int selectedIndex = 0;

  final List<_TecnicoData> tecnicos = const [
    _TecnicoData(
      titulo: 'Técnico en Calidad',
      descripcion: 'Desarrolla tus habilidades en control, mejora y aseguramiento de la calidad industrial.',
      icono: Icons.verified_outlined,
      colores: [Color(0xFF0D233A), Color(0xFF1B3C73)],
      imagen: 'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?auto=format&fit=crop&w=900&q=85',
    ),
    _TecnicoData(
      titulo: 'Técnico en Logística e Inventarios',
      descripcion: 'Aprende sobre inventarios, almacenamiento, organización y distribución de productos.',
      icono: Icons.inventory_2_outlined,
      colores: [Color(0xFF087F8C), Color(0xFF14B8A6)],
      imagen: 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&w=900&q=85',
    ),
    _TecnicoData(
      titulo: 'Técnico en Supervisión de Producción',
      descripcion: 'Conoce los procesos industriales y la supervisión de las operaciones de producción.',
      icono: Icons.precision_manufacturing_outlined,
      colores: [Color(0xFF4F46A5), Color(0xFF7C3AED)],
      imagen: 'https://images.unsplash.com/photo-1567789884554-0b844b597180?auto=format&fit=crop&w=900&q=85',
    ),
  ];

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
        backgroundColor: deepBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _construirEncabezado()),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 22, 16, 130),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final tecnico = tecnicos[index];

                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == tecnicos.length - 1 ? 0 : 16,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1100),
                              child: _construirTarjeta(tecnico),
                            ),
                          ),
                        );
                      }, childCount: tecnicos.length),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _construirNavegacionInferior(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirEncabezado() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryNavy, deepBlue, Color(0xFF1B3C73)],
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
            'Hola, bienvenido',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Conoce nuestros técnicos y encuentra tu camino.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: const Row(
              children: [
                Icon(Icons.engineering_outlined, color: Colors.white, size: 20),
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

  Widget _construirTarjeta(_TecnicoData tecnico) {
    const radio = 25.0;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radio),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          _mostrarMensaje('Seleccionaste: ${tecnico.titulo}');
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
                // Imagen de fondo con transparencia.
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

                // Degradado para que la imagen se mezcle con los colores.
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          tecnico.colores.first.withValues(alpha: 0.82),
                          tecnico.colores.first.withValues(alpha: 0.58),
                          tecnico.colores.last.withValues(alpha: 0.16),
                        ],
                        stops: const [0.0, 0.38, 1.0],
                      ),
                    ),
                  ),
                ),

                // Capa de color suave sobre toda la fotografía.
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: tecnico.colores.first.withValues(alpha: 0.04),
                    ),
                  ),
                ),

                // Círculo decorativo.
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

                // Icono, título y descripción.
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 17, 47, 17),
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
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Botón circular con flecha.
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 19,
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

  Widget _construirNavegacionInferior() {
    final dark = Theme.of(context).brightness == Brightness.dark;
    const elementos = [
      _NavegacionItem(Icons.home_rounded, 'Inicio'),
      _NavegacionItem(Icons.calendar_month_rounded, 'Calendario'),
      _NavegacionItem(Icons.notifications_none_rounded, 'Avisos'),
      _NavegacionItem(Icons.person_outline_rounded, 'Perfil'),
    ];

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(14, 4, 14, 10),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
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
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: (dark ? const Color(0xFF8FA5BA) : Colors.white)
                        .withValues(alpha: dark ? 0.9 : 0.78),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryNavy.withValues(alpha: 0.13),
                      blurRadius: 34,
                      offset: const Offset(0, 12),
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
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 2,
                          ),
                          decoration: BoxDecoration(
                            color: seleccionado
                                ? dark
                                    ? const Color(0xFF33495F)
                                    : const Color(0xFFE3F0FB)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(23),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
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
                                      : dark
                                          ? const Color(0xFFB0C0D0)
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
                                      ? dark
                                          ? const Color(0xFFD7E9FF)
                                          : const Color(0xFF123D60)
                                      : dark
                                          ? const Color(0xFFB0C0D0)
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
