import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';
import 'calendario.dart';
import 'navegacion_glass.dart';
import 'notificaciones.dart';
import 'perfil.dart';
import 'responsive_layout.dart';

class PosgradosPage extends StatefulWidget {
  const PosgradosPage({super.key});

  @override
  State<PosgradosPage> createState() => _PosgradosPageState();
}

class _PosgradosPageState extends State<PosgradosPage> {
  static const Color primaryNavy = Color(0xFF061424);
  static const Color deepBlue = Color(0xFF0D233A);
  int selectedIndex = 0;

  final List<_PosgradoData> posgrados = const [
    _PosgradoData(
      titulo: 'Doctorado Académico en Ingeniería',
      descripcion: 'Desarrolla investigación avanzada, genera conocimiento y aporta soluciones innovadoras en el campo de la ingeniería.',
      icono: Icons.engineering_outlined,
      colores: [Color(0xFF102A43), Color(0xFF176B87)],
      imagen: 'https://images.unsplash.com/photo-1581092160562-40aa08e78837?auto=format&fit=crop&w=1500&q=92',
    ),
    _PosgradoData(
      titulo: 'Maestría en Cadena de Abastecimiento',
      descripcion: 'Especialízate en logística, planificación y gestión eficiente de las cadenas de suministro.',
      icono: Icons.local_shipping_outlined,
      colores: [Color(0xFF182848), Color(0xFF315C91)],
      imagen: 'https://images.unsplash.com/photo-1773399881946-8371e1c538d9?auto=format&fit=crop&w=1500&q=92',
    ),
    _PosgradoData(
      titulo: 'Maestría en Sistemas Modernos de Manufactura',
      descripcion: 'Aprende sobre tecnologías modernas, automatización y optimización de procesos de manufactura.',
      icono: Icons.precision_manufacturing_outlined,
      colores: [Color(0xFF162D3D), Color(0xFF247B87)],
      imagen: 'https://images.unsplash.com/photo-1647427060118-4911c9821b82?auto=format&fit=crop&w=1500&q=92',
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
              Navigator.pop(context);
              setState(() => selectedIndex = 0);
            } else if (index == 1) {
              Navigator.pop(context);
              _abrirCalendario();
            } else if (index == 3) {
              Navigator.pop(context);
              _abrirPerfil();
            }
          },
        ),
      ),
    );
  }

  void _seleccionarSeccion(int index) {
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    setState(() => selectedIndex = index);

    switch (index) {
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: _construirEncabezado(),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
                    sliver: SliverToBoxAdapter(
                      child: ResponsiveCardGrid(
                        itemCount: posgrados.length,
                        itemBuilder: (context, index) =>
                            _construirTarjeta(posgrados[index]),
                      ),
                    ),
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
            children: [
              AppBackButton(
                onDarkBackground: true,
                onPressed: () {
                  Navigator.of(context).maybePop();
                },
              ),
              const Spacer(),
              GelPress(
                child: IconButton(
                  tooltip: 'Avisos',
                  onPressed: _abrirAvisos,
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
          const Text(
            'Posgrados',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Descubre nuevas oportunidades para especializarte y avanzar profesionalmente.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _construirTarjeta(_PosgradoData posgrado) {
    const radio = 25.0;

    return GelPress(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radio),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            _mostrarMensaje('Seleccionaste: ${posgrado.titulo}');
          },
          borderRadius: BorderRadius.circular(radio),
          child: Container(
            height: 178,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radio),
              gradient: LinearGradient(
                colors: posgrado.colores,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: posgrado.colores.first.withValues(alpha: 0.22),
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
                        posgrado.imagen,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
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
                            posgrado.colores.first.withValues(alpha: 0.82),
                            posgrado.colores.first.withValues(alpha: 0.58),
                            posgrado.colores.last.withValues(alpha: 0.16),
                          ],
                          stops: const [0.0, 0.38, 1.0],
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
                            posgrado.icono,
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
                                posgrado.titulo,
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
                                posgrado.descripcion,
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
      ),
    );
  }

  Widget _construirNavegacionInferior() {
    return NavegacionGlass(
      selectedIndex: selectedIndex,
      onSelected: _seleccionarSeccion,
      wide: MediaQuery.sizeOf(context).width >= 720,
    );
  }
}

class _PosgradoData {
  final String titulo;
  final String descripcion;
  final IconData icono;
  final List<Color> colores;
  final String imagen;

  const _PosgradoData({
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.colores,
    required this.imagen,
  });
}
