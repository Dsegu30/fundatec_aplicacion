import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'app_theme.dart';
import 'calendario.dart';
import 'navegacion_glass.dart';
import 'notificaciones.dart';
import 'perfil.dart';
import 'responsive_layout.dart';

/// =======================================================
/// TEC MÓVIL - MÓDULO DE NOTICIAS Y ANUNCIOS
/// Conexión en tiempo real con Firebase Firestore.
/// =======================================================

void _seleccionarSeccionNoticias(BuildContext context, int index) {
  final navigator = Navigator.of(context);

  switch (index) {
    case 0:
      if (navigator.canPop()) {
        navigator.popUntil((route) => route.isFirst);
      }
      break;
    case 1:
      navigator.push(
        appPageRoute<void>(builder: (_) => const CalendarioPage()),
      );
      break;
    case 2:
      navigator.push(
        appPageRoute<void>(builder: (_) => const NotificacionesScreen()),
      );
      break;
    case 3:
      navigator.push(appPageRoute<void>(builder: (_) => const PerfilPage()));
      break;
  }
}

class NoticiasPage extends StatelessWidget {
  const NoticiasPage({super.key});

  static const Color primaryNavy = Color(0xFF061424);
  static const Color accentBlue = Color(0xFF0EA5E9);

  static const String collectionName = 'anuncios';

  DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  bool _isVisible(Map<String, dynamic> data) {
    final now = DateTime.now();

    final publicacion = _toDate(data['fechaPublicacion']);
    final vencimiento = _toDate(data['fechaVencimiento']);

    if (data['estado'] != 'publicado') return false;

    if (publicacion != null && now.isBefore(publicacion)) {
      return false;
    }

    if (vencimiento != null && now.isAfter(vencimiento)) {
      return false;
    }

    return true;
  }

  String _formatDate(dynamic value) {
    final date = _toDate(value);
    if (date == null) return 'Fecha no disponible';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBody: true,
      body: Stack(
        children: [
          const FondoAppDifuminado(),
          SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveLayout.contentMaxWidth(width),
                ),
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection(collectionName)
                      .where('estado', isEqualTo: 'publicado')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(child: _pageHeader(context)),
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: _errorView(
                              context,
                              'No fue posible cargar los anuncios.',
                            ),
                          ),
                        ],
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(child: _pageHeader(context)),
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: accentBlue,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    final documents = snapshot.data?.docs ?? [];
                    final anuncios =
                        documents.where((doc) {
                          return _isVisible(doc.data());
                        }).toList()..sort((a, b) {
                          final dateA =
                              _toDate(a.data()['fechaPublicacion']) ??
                              DateTime(2000);
                          final dateB =
                              _toDate(b.data()['fechaPublicacion']) ??
                              DateTime(2000);
                          return dateB.compareTo(dateA);
                        });

                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: _pageHeader(context, count: anuncios.length),
                        ),
                        SliverToBoxAdapter(
                          child: _sectionHeading(context, anuncios.length),
                        ),
                        if (anuncios.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: _emptyView(context),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 5, 20, 130),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final doc = anuncios[index];
                                return _announcementCard(
                                  context,
                                  doc.id,
                                  doc.data(),
                                  theme.brightness == Brightness.dark,
                                );
                              }, childCount: anuncios.length),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: NavegacionGlass(
              selectedIndex: 2,
              wide: width >= 720,
              onSelected: (index) =>
                  _seleccionarSeccionNoticias(context, index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageHeader(BuildContext context, {int? count}) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppBackButton(onPressed: () => Navigator.of(context).maybePop()),
              const Spacer(),
              _headlineIcon(context, count),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Container(
                width: 5,
                height: 17,
                decoration: BoxDecoration(
                  color: accentBlue,
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
                    color: theme.colorScheme.onSurfaceVariant,
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
                  'Centro de\nnoticias',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: size.width < 360 ? 31 : 39,
                    height: 1.02,
                    letterSpacing: -1.6,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            'Novedades, actividades y comunicados de la Escuela de '
            'Ingeniería en Producción Industrial.',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 14,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 22),
          _highlightCard(context, count),
        ],
      ),
    );
  }

  Widget _headlineIcon(BuildContext context, int? count) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: 72,
          height: 80,
          decoration: BoxDecoration(
            color: (dark ? const Color(0xFF26384A) : Colors.white).withValues(
              alpha: dark ? 0.96 : 0.68,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: (dark ? const Color(0xFF536B82) : Colors.white).withValues(
                alpha: 0.95,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: primaryNavy.withValues(alpha: 0.06),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.newspaper_rounded,
                color: theme.colorScheme.primary,
                size: 34,
              ),
              if ((count ?? 0) > 0)
                Positioned(
                  top: 15,
                  right: 14,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: accentBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.cardColor, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _highlightCard(BuildContext context, int? count) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
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
                color: primaryNavy.withValues(alpha: 0.055),
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
                        accentBlue.withValues(alpha: 0.17),
                        accentBlue.withValues(alpha: 0),
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
                          color: accentBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(
                          Icons.newspaper_rounded,
                          color: theme.colorScheme.primary,
                          size: 17,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'TU ESPACIO',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 10,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
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
                          color: theme.colorScheme.onSurfaceVariant,
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
                      color: theme.colorScheme.onSurface,
                      fontSize: 25,
                      height: 1.15,
                      letterSpacing: -0.7,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'Las noticias de tu Escuela, reunidas en un solo lugar.',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 19),
                  Row(
                    children: [
                      const Icon(
                        Icons.campaign_outlined,
                        size: 16,
                        color: accentBlue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          count == null
                              ? 'Cargando publicaciones'
                              : count == 0
                              ? 'No hay noticias nuevas'
                              : '$count publicaciones para revisar',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 17,
                        color: theme.colorScheme.primary,
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

  Widget _sectionHeading(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      child: Row(
        children: [
          const Icon(Icons.campaign_rounded, color: accentBlue, size: 20),
          const SizedBox(width: 7),
          Text(
            'Anuncios recientes',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            '$count publicaciones',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _announcementCard(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
    bool isDark,
  ) {
    final titulo = data['titulo']?.toString() ?? 'Sin título';

    final descripcion = data['descripcion']?.toString().trim() ?? '';

    final categoria = (data['categoria'] ?? data['categoría'] ?? 'General')
        .toString();

    final imagenUrl = data['imagenUrl']?.toString() ?? '';

    final importante = data['importante'] == true;

    final fecha = _formatDate(data['fechaPublicacion']);

    return GelPress(
      child: Container(
        margin: const EdgeInsets.only(bottom: 17),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: importante
                ? accentBlue.withValues(alpha: 0.5)
                : Theme.of(context).dividerColor.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.035),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                appPageRoute<void>(
                  builder: (_) => NoticiaDetallePage(id: id, anuncio: data),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imagenUrl.isNotEmpty)
                  Image.network(
                    imagenUrl,
                    width: double.infinity,
                    height: 175,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return _imagePlaceholder(context);
                    },
                  )
                else
                  _imagePlaceholder(context),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: accentBlue.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              categoria,
                              style: const TextStyle(
                                color: accentBlue,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (importante) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.push_pin_rounded,
                              size: 15,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 3),
                            const Text(
                              'Importante',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        titulo,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        descripcion,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(height: 1.5),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 15,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            fecha,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const Spacer(),
                          const Text(
                            'Leer más',
                            style: TextStyle(
                              color: accentBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: accentBlue,
                            size: 16,
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
    );
  }

  Widget _imagePlaceholder(BuildContext context) {
    return Container(
      height: 145,
      width: double.infinity,
      color: accentBlue.withValues(alpha: 0.09),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.campaign_rounded, color: accentBlue, size: 42),
          SizedBox(height: 8),
          Text(
            'Noticias TEC Móvil',
            style: TextStyle(color: accentBlue, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _emptyView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.newspaper_rounded,
              size: 65,
              color: Theme.of(context).disabledColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 18),
            Text(
              'No hay anuncios disponibles',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando se publiquen nuevas noticias, '
              'aparecerán automáticamente aquí.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, color: Colors.orange, size: 50),
            const SizedBox(height: 15),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            const Text(
              'Verificá tu conexión y los permisos de Firebase.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// =======================================================
/// PANTALLA DE DETALLE DE UNA NOTICIA
/// =======================================================

class NoticiaDetallePage extends StatelessWidget {
  final String id;
  final Map<String, dynamic> anuncio;

  const NoticiaDetallePage({
    super.key,
    required this.id,
    required this.anuncio,
  });

  DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  String _formatDate(dynamic value) {
    final date = _toDate(value);
    if (date == null) return 'Fecha no disponible';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final titulo = anuncio['titulo']?.toString() ?? 'Sin título';
    final descripcion = anuncio['descripcion']?.toString().trim() ?? '';
    final imagenUrl = anuncio['imagenUrl']?.toString() ?? '';
    final categoria =
        (anuncio['categoria'] ?? anuncio['categoría'] ?? 'General').toString();
    final fecha = _formatDate(anuncio['fechaPublicacion']);
    final importante = anuncio['importante'] == true;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBody: true,
      body: Stack(
        children: [
          const FondoAppDifuminado(),
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 130),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: ResponsiveLayout.contentMaxWidth(width),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                AppBackButton(
                                  onPressed: () =>
                                      Navigator.of(context).maybePop(),
                                ),
                                const SizedBox(width: 14),
                                Text(
                                  'Noticias',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(26),
                              child: SizedBox(
                                width: double.infinity,
                                height: width < 600 ? 210 : 300,
                                child: imagenUrl.isEmpty
                                    ? _imagePlaceholder()
                                    : Image.network(
                                        imagenUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            _imagePlaceholder(),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: theme.dividerColor.withValues(
                                    alpha: 0.45,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: theme.brightness == Brightness.dark
                                          ? 0.12
                                          : 0.035,
                                    ),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 9,
                                    runSpacing: 8,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 7,
                                        ),
                                        decoration: BoxDecoration(
                                          color: NoticiasPage.accentBlue
                                              .withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        child: Text(
                                          categoria,
                                          style: const TextStyle(
                                            color: NoticiasPage.accentBlue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      if (importante)
                                        const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.push_pin_rounded,
                                              color: Colors.orange,
                                              size: 17,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              'Importante',
                                              style: TextStyle(
                                                color: Colors.orange,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    titulo,
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          height: 1.25,
                                        ),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_rounded,
                                        size: 16,
                                        color: NoticiasPage.accentBlue,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        fecha,
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  Divider(color: theme.dividerColor),
                                  const SizedBox(height: 16),
                                  Text(
                                    descripcion,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      height: 1.75,
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  Center(
                                    child: Text(
                                      'TEC Móvil · Escuela de Ingeniería en '
                                      'Producción Industrial',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme.disabledColor,
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
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: NavegacionGlass(
              selectedIndex: 2,
              wide: width >= 720,
              onSelected: (index) =>
                  _seleccionarSeccionNoticias(context, index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFF0D233A),
      alignment: Alignment.center,
      child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 65),
    );
  }
}
