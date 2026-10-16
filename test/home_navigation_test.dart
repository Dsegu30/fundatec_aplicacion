import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fundatec/app_theme.dart';
import 'package:fundatec/home.dart';
import 'package:fundatec/licenciatura.dart';
import 'package:fundatec/navegacion_glass.dart';
import 'package:fundatec/perfil.dart';
import 'package:fundatec/posgrados.dart';

void main() {
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

  testWidgets('Perfil integrado usa la barra compartida de Inicio', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const TecApp());
    await tester.tap(find.byTooltip('Perfil'));
    await tester.pumpAndSettle();

    expect(find.byType(PerfilPage), findsOneWidget);
    expect(find.byType(NavegacionGlass), findsNothing);
    expect(find.byTooltip('Inicio'), findsOneWidget);
    expect(find.byTooltip('Calendario'), findsOneWidget);
    expect(find.byTooltip('Avisos'), findsOneWidget);
    expect(find.byTooltip('Perfil'), findsOneWidget);
  });

  testWidgets('la búsqueda de Licenciatura abre su pantalla', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const TecApp());

    await tester.enterText(
      find.byType(TextField).first,
      'Licenciatura Industrial',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Licenciatura Industrial').last);
    await tester.pumpAndSettle();

    expect(find.byType(LicenciaturaPage), findsOneWidget);
  });

  testWidgets('Licenciatura muestra datos oficiales y contactos pendientes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LicenciaturaPage()));

    expect(
      find.textContaining(
        'planear, diseñar, implementar y optimizar sistemas de manufactura de bienes y servicios.',
      ),
      findsOneWidget,
    );

    final buttons = tester
        .widgetList<ElevatedButton>(find.byType(ElevatedButton))
        .toList();
    expect(buttons, hasLength(2));

    buttons.first.onPressed!();
    await tester.pumpAndSettle();
    expect(
      find.text('El contacto de WhatsApp se agregará próximamente.'),
      findsOneWidget,
    );

    buttons.last.onPressed!();
    await tester.pumpAndSettle();
    expect(
      find.text('El enlace para agendar una cita se agregará próximamente.'),
      findsOneWidget,
    );
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
}
