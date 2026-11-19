import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fundatec/app_theme.dart';
import 'package:fundatec/curso_detalle.dart';
import 'package:fundatec/cursos_libres.dart';
import 'package:fundatec/cursos_especialidades.dart';
import 'package:fundatec/especialidades.dart';
import 'package:fundatec/home.dart';
import 'package:fundatec/licenciatura.dart';
import 'package:fundatec/navegacion_glass.dart';
import 'package:fundatec/perfil.dart';
import 'package:fundatec/posgrados.dart';
import 'package:fundatec/posgrados_detalle.dart';
import 'package:fundatec/tecnico_detalle.dart';

void main() {
  testWidgets('el selector ofrece cursos libres y especialidades', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: CursosEspecialidadesPage()),
    );

    expect(find.text('Especialidades y Cursos Industriales'), findsOneWidget);
    expect(find.text('Cursos libres'), findsOneWidget);
    expect(find.text('Especialidades industriales'), findsOneWidget);
    for (final key in const [
      ValueKey('selector-cursos-libres'),
      ValueKey('selector-especialidades'),
    ]) {
      expect(
        find.descendant(of: find.byKey(key), matching: find.byType(GelPress)),
        findsOneWidget,
      );
    }
  });

  testWidgets('el acceso de Home abre Especialidades y Cursos Industriales', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TecHomeScreen()));
    final acceso = find.text('Especialidades y Cursos Industriales');
    await tester.ensureVisible(acceso);
    await tester.tap(acceso);
    await tester.pumpAndSettle();

    expect(find.byType(CursosEspecialidadesPage), findsOneWidget);
    expect(find.text('Especialidades y Cursos Industriales'), findsOneWidget);
  });

  testWidgets('el selector se adapta a celular, tablet y laptop', (
    WidgetTester tester,
  ) async {
    const sizes = [Size(280, 600), Size(884, 344), Size(1366, 768)];

    for (final size in sizes) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        const MaterialApp(home: CursosEspecialidadesPage()),
      );
      await tester.pumpAndSettle();

      for (final key in const [
        ValueKey('selector-cursos-libres'),
        ValueKey('selector-especialidades'),
      ]) {
        expect(
          tester.getSize(find.byKey(key)).width,
          lessThanOrEqualTo(size.width),
        );
      }
      if (size.width >= 1200) {
        expect(
          tester
              .getSize(find.byKey(const ValueKey('selector-cursos-libres')))
              .width,
          greaterThan(600),
        );
        final cardCenter = tester
            .getRect(find.byKey(const ValueKey('selector-cursos-libres')))
            .center
            .dy;
        final contentStart = tester
            .getRect(find.text('Elige qué tipo de formación quieres explorar.'))
            .bottom;
        final navigationStart = tester
            .getRect(find.byType(NavegacionGlass))
            .top;
        expect(
          (cardCenter - (contentStart + navigationStart) / 2).abs(),
          lessThan(90),
        );
      }
      if (size.width > size.height && size.height < 600) {
        expect(
          tester
              .getSize(find.byKey(const ValueKey('selector-cursos-libres')))
              .height,
          lessThan(200),
        );
      }
      expect(
        tester.takeException(),
        isNull,
        reason: 'Tamaño de pantalla: $size',
      );
    }

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });

  testWidgets('el catálogo de especialidades se adapta a varias pantallas', (
    WidgetTester tester,
  ) async {
    const sizes = [Size(280, 600), Size(884, 344), Size(1366, 768)];

    for (final size in sizes) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        const MaterialApp(home: EspecialidadesIndustrialesPage()),
      );
      await tester.pump(const Duration(milliseconds: 400));

      var exception = tester.takeException();
      while (exception is NetworkImageLoadException) {
        exception = tester.takeException();
      }
      expect(exception, isNull, reason: 'Tamaño de pantalla: $size');
    }

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });

  testWidgets('el selector conserva el diseño con texto ampliado', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: const CursosEspecialidadesPage(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('la opción de cursos abre el catálogo de cursos libres', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: CursosEspecialidadesPage()),
    );
    await tester.tap(find.byKey(const ValueKey('selector-cursos-libres')));
    await tester.pumpAndSettle();
    expect(find.byType(CursosLibresCatalogoPage), findsOneWidget);
  });

  testWidgets('la opción de especialidades abre su catálogo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: CursosEspecialidadesPage()),
    );
    await tester.tap(find.byKey(const ValueKey('selector-especialidades')));
    await tester.pumpAndSettle();
    expect(find.byType(EspecialidadesIndustrialesPage), findsOneWidget);
  });

  test('el tema claro mantiene el fondo y colores predeterminados', () {
    final theme = buildAppTheme(Brightness.light);

    expect(theme.brightness, Brightness.light);
    expect(theme.colorScheme.surface, const Color(0xFFF6F8FA));
    expect(theme.colorScheme.onSurface, const Color(0xFF172B4D));
  });

  test('el tema oscuro usa texto claro y superficies diferenciadas', () {
    final theme = buildAppTheme(Brightness.dark);

    expect(theme.brightness, Brightness.dark);
    expect(theme.colorScheme.onSurface, const Color(0xFFF7F9FC));
    expect(theme.colorScheme.onSurfaceVariant, const Color(0xFFD4DCE6));
    expect(theme.colorScheme.primary, const Color(0xFFA8C7FF));
    expect(
      theme.inputDecorationTheme.fillColor,
      theme.colorScheme.surfaceContainerHigh,
    );
    expect(theme.chipTheme.labelStyle?.color, theme.colorScheme.onSurface);
    expect(
      theme.colorScheme.surfaceContainerHigh.computeLuminance(),
      greaterThan(theme.colorScheme.surface.computeLuminance()),
    );
  });

  testWidgets('el interruptor alterna entre claro y oscuro', (
    WidgetTester tester,
  ) async {
    var dark = false;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: Center(
              child: ThemeModeSwitch(
                value: dark,
                onChanged: (value) => setState(() => dark = value),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byTooltip('Cambiar a modo oscuro'), findsOneWidget);
    await tester.tap(find.byTooltip('Cambiar a modo oscuro'));
    await tester.pumpAndSettle();
    expect(dark, isTrue);
    expect(find.byTooltip('Cambiar a modo claro'), findsOneWidget);
  });

  testWidgets('Perfil conserva la navegación inferior', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: PerfilPage(onSectionSelected: (_) {})),
    );

    expect(find.byTooltip('Inicio'), findsOneWidget);
    expect(find.byTooltip('Calendario'), findsOneWidget);
    expect(find.byTooltip('Avisos'), findsOneWidget);
    expect(find.byTooltip('Perfil'), findsOneWidget);
  });

  testWidgets('Perfil ejecuta la acción de cierre de sesión recibida', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var cerradaSesion = false;
    await tester.pumpWidget(
      MaterialApp(
        home: PerfilPage(
          onLogout: () async {
            cerradaSesion = true;
          },
        ),
      ),
    );

    await tester.ensureVisible(find.text('Cerrar sesión'));
    await tester.tap(find.text('Cerrar sesión').first);
    await tester.pumpAndSettle();
    expect(find.text('¿Cerrar sesión?'), findsOneWidget);

    await tester.tap(find.text('Cerrar sesión').last);
    await tester.pumpAndSettle();

    expect(cerradaSesion, isTrue);
  });

  testWidgets('Perfil solo muestra opciones relacionadas con la cuenta', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: PerfilPage(onSectionSelected: (_) {})),
    );

    expect(find.text('Mi carrera'), findsNothing);
    expect(find.text('Mis documentos'), findsNothing);
    expect(find.text('Ayuda'), findsNothing);
    expect(find.text('Calendario académico'), findsNothing);
    expect(find.text('Avisos y notificaciones'), findsNothing);
    expect(find.text('Información personal'), findsOneWidget);
    expect(find.text('Seguridad de la cuenta'), findsOneWidget);
    expect(find.text('Configuración'), findsOneWidget);
  });

  testWidgets('Perfil integrado usa la barra compartida de Inicio', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TecHomeScreen()));
    await tester.tap(find.byTooltip('Perfil'));
    await tester.pumpAndSettle();

    expect(find.byType(PerfilPage), findsOneWidget);
    expect(find.byType(NavegacionGlass), findsOneWidget);
    expect(find.byTooltip('Inicio'), findsOneWidget);
    expect(find.byTooltip('Calendario'), findsOneWidget);
    expect(find.byTooltip('Avisos'), findsOneWidget);
    expect(find.byTooltip('Perfil'), findsOneWidget);
  });

  testWidgets('la búsqueda de Licenciatura abre su pantalla', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TecHomeScreen()));

    expect(find.byType(TextField).first, findsOneWidget);
    expect(find.byIcon(Icons.tune_rounded), findsNothing);

    await tester.enterText(
      find.byType(TextField).first,
      'Licenciatura Industrial',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Licenciatura Industrial').last);
    await tester.pumpAndSettle();

    expect(find.byType(LicenciaturaPage), findsOneWidget);
  });

  testWidgets('la búsqueda de Doctorado abre sus detalles', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TecHomeScreen()));
    await tester.enterText(find.byType(TextField).first, 'Doctorado Académico');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Doctorado Académico en Ingeniería').last);
    await tester.pumpAndSettle();

    expect(find.byType(PosgradoDetallePage), findsOneWidget);
    expect(
      find.text('DOCTORADO ACADÉMICO · POSGRADOS INDUSTRIAL'),
      findsOneWidget,
    );
  });

  testWidgets('Home ya no muestra el menú ni la campana del encabezado', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TecHomeScreen()));

    expect(find.byIcon(Icons.menu_rounded), findsNothing);
    expect(find.byIcon(Icons.notifications_none_rounded), findsNothing);
  });

  testWidgets('Home muestra solo Agendar cita y Noticias en acceso rápido', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TecHomeScreen()));
    await tester.scrollUntilVisible(find.text('Agendar cita'), 250);

    expect(find.text('Agendar cita'), findsOneWidget);
    expect(find.text('Noticias'), findsOneWidget);
    expect(find.text('Calendario'), findsNothing);
    expect(find.text('Recursos'), findsNothing);
    expect(find.text('Mi Perfil'), findsNothing);
  });

  testWidgets('la búsqueda abre directamente el detalle del curso', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TecHomeScreen()));

    await tester.enterText(find.byType(TextField).first, 'Excel');
    await tester.pumpAndSettle();

    expect(find.text('Excel'), findsOneWidget);
    await tester.tap(find.text('Excel').last);
    await tester.pumpAndSettle();

    expect(find.byType(CursoDetallePage), findsOneWidget);
    expect(find.byType(CursosLibresCatalogoPage), findsNothing);
  });

  testWidgets('Enter abre directamente el primer programa encontrado', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TecHomeScreen()));

    await tester.enterText(
      find.byType(TextField).first,
      'Logística e Inventarios',
    );
    tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.byType(TecnicoDetallePage), findsOneWidget);
  });

  testWidgets('Licenciatura muestra el resumen del programa', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LicenciaturaPage()));

    expect(
      find.textContaining('La Licenciatura en Producción Industrial prepara'),
      findsOneWidget,
    );
    expect(find.text('Cartago'), findsOneWidget);
    expect(find.text('Ingeniero (a) en Producción Industrial'), findsOneWidget);
  });

  testWidgets('Posgrados usa los colores del tema oscuro', (
    WidgetTester tester,
  ) async {
    final darkTheme = buildAppTheme(Brightness.dark);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        darkTheme: darkTheme,
        themeMode: ThemeMode.dark,
        home: const PosgradosPage(),
      ),
    );

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, darkTheme.scaffoldBackgroundColor);
    expect(find.byType(NavegacionGlass), findsOneWidget);
  });

  testWidgets('Licenciatura usa la navegación en tema claro y oscuro', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(280, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final lightTheme = buildAppTheme(Brightness.light);
    final darkTheme = buildAppTheme(Brightness.dark);

    for (final (mode, theme) in [
      (ThemeMode.light, lightTheme),
      (ThemeMode.dark, darkTheme),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: mode,
          home: const LicenciaturaPage(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 900));

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, theme.scaffoldBackgroundColor);
      expect(find.byType(NavegacionGlass), findsOneWidget);
      expect(find.byTooltip('Calendario'), findsOneWidget);

      var exception = tester.takeException();
      while (exception is NetworkImageLoadException) {
        exception = tester.takeException();
      }
      expect(exception, isNull, reason: exception?.toString());
    }
  });
}
