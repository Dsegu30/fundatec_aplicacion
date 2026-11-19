import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fundatec/calendario.dart';
import 'package:fundatec/cursos_especialidades.dart';
import 'package:fundatec/cursos_libres.dart';
import 'package:fundatec/especialidades.dart';
import 'package:fundatec/home.dart';
import 'package:fundatec/licenciatura.dart';
import 'package:fundatec/main.dart';
import 'package:fundatec/notificaciones.dart';
import 'package:fundatec/perfil.dart';
import 'package:fundatec/posgrados.dart';
import 'package:fundatec/posgrados_detalle.dart';
import 'package:fundatec/tecnicos.dart';

void expectNoLayoutException(WidgetTester tester) {
  var exception = tester.takeException();
  while (exception is NetworkImageLoadException) {
    exception = tester.takeException();
  }
  if (exception != null) {
    fail(
      exception is FlutterError
          ? exception.toStringDeep()
          : exception.toString(),
    );
  }
}

void main() {
  for (final size in <Size>[
    const Size(280, 600),
    const Size(320, 568),
    const Size(360, 800),
    const Size(412, 915),
    const Size(745, 832),
    const Size(884, 344),
    const Size(1024, 1366),
    const Size(1366, 768),
    const Size(1920, 1080),
    const Size(800, 360),
    const Size(768, 1024),
    const Size(1440, 900),
  ]) {
    testWidgets('las pantallas se adaptan a ${size.width}x${size.height}', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const TecApp());
      await tester.pump(const Duration(milliseconds: 600));
      expectNoLayoutException(tester);

      await tester.tap(find.byTooltip('Avisos'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expectNoLayoutException(tester);

      await tester.tap(find.byTooltip('Perfil'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expectNoLayoutException(tester);

      await tester.tap(find.byTooltip('Calendario'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expectNoLayoutException(tester);

      await tester.pumpWidget(const MaterialApp(home: TecnicosPage()));
      await tester.pump(const Duration(milliseconds: 100));
      expectNoLayoutException(tester);

      await tester.pumpWidget(const MaterialApp(home: PosgradosPage()));
      await tester.pump(const Duration(milliseconds: 100));
      expectNoLayoutException(tester);

      await tester.pumpWidget(const MaterialApp(home: LicenciaturaPage()));
      await tester.pump(const Duration(milliseconds: 100));
      expectNoLayoutException(tester);

      await tester.pumpWidget(const MaterialApp(home: CalendarioPage()));
      await tester.pump(const Duration(milliseconds: 100));
      expectNoLayoutException(tester);

      await tester.pumpWidget(const MaterialApp(home: NotificacionesScreen()));
      await tester.pump(const Duration(milliseconds: 600));
      expectNoLayoutException(tester);

      await tester.pumpWidget(const MaterialApp(home: PerfilPage()));
      await tester.pump(const Duration(milliseconds: 100));
      expectNoLayoutException(tester);
    });
  }

  testWidgets('selector mantiene las tarjetas fuera de la bisagra del Fold', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(884, 832);
    tester.view.devicePixelRatio = 1;
    tester.view.displayFeatures = const <ui.DisplayFeature>[
      ui.DisplayFeature(
        bounds: Rect.fromLTRB(432, 0, 452, 832),
        type: ui.DisplayFeatureType.hinge,
        state: ui.DisplayFeatureState.postureHalfOpened,
      ),
    ];
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetDisplayFeatures);

    await tester.pumpWidget(
      const MaterialApp(home: CursosEspecialidadesPage()),
    );
    await tester.pumpAndSettle();

    final cursos = tester.getRect(
      find.byKey(const ValueKey('selector-cursos-libres')),
    );
    final especialidades = tester.getRect(
      find.byKey(const ValueKey('selector-especialidades')),
    );
    expect(cursos.right, lessThanOrEqualTo(432));
    expect(especialidades.left, greaterThanOrEqualTo(452));
    expectNoLayoutException(tester);
  });

  for (final size in <Size>[
    const Size(280, 600),
    const Size(320, 568),
    const Size(360, 800),
    const Size(745, 832),
    const Size(884, 344),
    const Size(1024, 1366),
    const Size(1366, 768),
    const Size(1920, 1080),
    const Size(800, 360),
  ]) {
    testWidgets('selector de cursos se adapta a ${size.width}x${size.height}', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

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
      if (size.width > size.height && size.height < 600) {
        expect(
          tester
              .getSize(find.byKey(const ValueKey('selector-cursos-libres')))
              .height,
          lessThan(200),
        );
      }
      expectNoLayoutException(tester);
    });
  }

  for (final size in <Size>[
    const Size(280, 600),
    const Size(360, 800),
    const Size(884, 344),
    const Size(1024, 1366),
    const Size(1366, 768),
  ]) {
    testWidgets('especialidades se adapta a ${size.width}x${size.height}', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: EspecialidadesIndustrialesPage()),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expectNoLayoutException(tester);
    });
  }

  for (final devicePixelRatio in <double>[1, 2, 3]) {
    testWidgets(
      'cursos libres conserva el layout a densidad $devicePixelRatio y texto ampliado',
      (WidgetTester tester) async {
        const logicalSize = Size(360, 800);
        tester.view.devicePixelRatio = devicePixelRatio;
        tester.view.physicalSize = Size(
          logicalSize.width * devicePixelRatio,
          logicalSize.height * devicePixelRatio,
        );
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            home: const CursosLibresCatalogoPage(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.5)),
              child: child!,
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 700));

        expect(tester.getSize(find.byType(Scaffold)).width, logicalSize.width);
        expectNoLayoutException(tester);
      },
    );
  }

  testWidgets('Posgrados y sus detalles usan imagen del mismo ancho', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1366, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Finder imageWidth(double width) => find.byWidgetPredicate(
      (widget) => widget is FractionallySizedBox && widget.widthFactor == width,
    );

    await tester.pumpWidget(const MaterialApp(home: PosgradosPage()));
    await tester.pump(const Duration(milliseconds: 600));
    expect(imageWidth(0.9), findsNWidgets(4));
    expectNoLayoutException(tester);

    const detailPages = <(Widget, String)>[
      (
        MaestriaCalidadProfesionalPage(),
        'assets/images/Maestria_Calidad_Modalidad_Profesional.png',
      ),
      (
        MaestriaCalidadAcademicaPage(),
        'assets/images/Maestria_Calidad_Modalidad_Academica.png',
      ),
      (
        MaestriaCadenaAbastecimientoPage(),
        'assets/images/Maestria_Cadena_de_Abastecimiento.png',
      ),
      (
        MaestriaSistemasModernosManufacturaPage(),
        'assets/images/Maestria_Sistemas_Modernos_de_Manufactura.png',
      ),
    ];

    for (final (page, imagePath) in detailPages) {
      await tester.pumpWidget(MaterialApp(home: page));
      await tester.pump(const Duration(milliseconds: 600));
      expect(imageWidth(0.9), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName == imagePath,
        ),
        findsOneWidget,
      );
      expectNoLayoutException(tester);
    }
  });

  testWidgets('posgrados y sus fichas se adaptan a texto ampliado', (
    WidgetTester tester,
  ) async {
    const logicalSize = Size(360, 800);
    tester.view.physicalSize = logicalSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Widget buildWithLargeText(Widget child) {
      return MaterialApp(
        home: child,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
      );
    }

    await tester.pumpWidget(buildWithLargeText(const PosgradosPage()));
    await tester.pump(const Duration(milliseconds: 700));
    expectNoLayoutException(tester);

    await tester.pumpWidget(
      buildWithLargeText(const MaestriaCalidadProfesionalPage()),
    );
    await tester.pump(const Duration(milliseconds: 700));
    expectNoLayoutException(tester);
  });

  for (final size in <Size>[
    const Size(280, 600),
    const Size(320, 568),
    const Size(360, 800),
    const Size(412, 915),
    const Size(745, 832),
    const Size(884, 344),
    const Size(1024, 1366),
    const Size(1366, 768),
    const Size(1920, 1080),
    const Size(800, 360),
    const Size(768, 1024),
    const Size(1440, 900),
  ]) {
    testWidgets('cursos libres se adapta a ${size.width}x${size.height}', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: CursosLibresCatalogoPage()),
      );
      await tester.pump(const Duration(milliseconds: 700));
      expectNoLayoutException(tester);
    });
  }

  for (final size in <Size>[
    const Size(280, 600),
    const Size(884, 344),
    const Size(884, 832),
    const Size(1366, 768),
    const Size(1920, 1080),
  ]) {
    testWidgets(
      'detalles de posgrados se adaptan a ${size.width}x${size.height}',
      (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        const pages = <Widget>[
          MaestriaCalidadAcademicaPage(),
          MaestriaCalidadProfesionalPage(),
          MaestriaCadenaAbastecimientoPage(),
          MaestriaSistemasModernosManufacturaPage(),
        ];

        for (final page in pages) {
          await tester.pumpWidget(MaterialApp(home: page));
          await tester.pump(const Duration(milliseconds: 600));
          expectNoLayoutException(tester);
        }
      },
    );
  }

  testWidgets('licenciatura evita una bisagra vertical en pantalla plegable', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(884, 832);
    tester.view.devicePixelRatio = 1;
    tester.view.displayFeatures = const <ui.DisplayFeature>[
      ui.DisplayFeature(
        bounds: Rect.fromLTRB(432, 0, 452, 832),
        type: ui.DisplayFeatureType.hinge,
        state: ui.DisplayFeatureState.postureHalfOpened,
      ),
    ];
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetDisplayFeatures);

    await tester.pumpWidget(const MaterialApp(home: LicenciaturaPage()));
    await tester.pump(const Duration(milliseconds: 600));

    expect(tester.getSize(find.byType(Scaffold)).width, 432);
    expectNoLayoutException(tester);
  });

  testWidgets('Home muestra dos columnas en paisaje', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(880, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: TecHomeScreen()));
    await tester.pump(const Duration(milliseconds: 600));

    final card = find.ancestor(
      of: find.text('Posgrados Industrial'),
      matching: find.byType(InkWell),
    );
    expect(tester.getSize(card).width, greaterThan(350));
    expect(tester.getSize(card).width, lessThan(500));
    expectNoLayoutException(tester);
  });

  testWidgets('Home mantiene Posgrados en un panel del Fold', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(884, 832);
    tester.view.devicePixelRatio = 1;
    tester.view.displayFeatures = const <ui.DisplayFeature>[
      ui.DisplayFeature(
        bounds: Rect.fromLTRB(432, 0, 452, 832),
        type: ui.DisplayFeatureType.hinge,
        state: ui.DisplayFeatureState.postureHalfOpened,
      ),
    ];
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetDisplayFeatures);

    await tester.pumpWidget(const MaterialApp(home: TecHomeScreen()));
    await tester.pump(const Duration(milliseconds: 600));

    final card = find.ancestor(
      of: find.text('Posgrados Industrial'),
      matching: find.byType(InkWell),
    );
    final cardRect = tester.getRect(card);
    expect(cardRect.width, greaterThan(350));
    expect(cardRect.left, greaterThanOrEqualTo(452));
    expect(cardRect.right, lessThanOrEqualTo(884));
    expectNoLayoutException(tester);
  });

  testWidgets('posgrados aprovecha ambos paneles cuando el Fold está abierto', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(884, 832);
    tester.view.devicePixelRatio = 1;
    tester.view.displayFeatures = const <ui.DisplayFeature>[
      ui.DisplayFeature(
        bounds: Rect.fromLTRB(432, 0, 452, 832),
        type: ui.DisplayFeatureType.hinge,
        state: ui.DisplayFeatureState.postureFlat,
      ),
    ];
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetDisplayFeatures);

    await tester.pumpWidget(const MaterialApp(home: PosgradosPage()));
    await tester.pump(const Duration(milliseconds: 600));

    expect(tester.getSize(find.byType(Scaffold)).width, 884);

    final doctorado = tester.getRect(
      find
          .ancestor(
            of: find.textContaining('Maestría en Calidad Académica'),
            matching: find.byType(InkWell),
          )
          .first,
    );
    final calidadProfesional = tester.getRect(
      find
          .ancestor(
            of: find.textContaining('Maestría en Calidad Profesional'),
            matching: find.byType(InkWell),
          )
          .first,
    );
    expect(doctorado.right, lessThanOrEqualTo(432));
    expect(calidadProfesional.left, greaterThanOrEqualTo(452));
    expectNoLayoutException(tester);

    const detailPages = <Widget>[
      MaestriaCalidadAcademicaPage(),
      MaestriaCalidadProfesionalPage(),
      MaestriaCadenaAbastecimientoPage(),
      MaestriaSistemasModernosManufacturaPage(),
    ];
    for (final page in detailPages) {
      await tester.pumpWidget(MaterialApp(home: page));
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.getSize(find.byType(Scaffold)).width, 884);
      expectNoLayoutException(tester);
    }
  });

  testWidgets('Posgrados no se limita a un panel con el Fold medio abierto', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(884, 832);
    tester.view.devicePixelRatio = 1;
    tester.view.displayFeatures = const <ui.DisplayFeature>[
      ui.DisplayFeature(
        bounds: Rect.fromLTRB(432, 0, 452, 832),
        type: ui.DisplayFeatureType.hinge,
        state: ui.DisplayFeatureState.postureHalfOpened,
      ),
    ];
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetDisplayFeatures);

    await tester.pumpWidget(const MaterialApp(home: PosgradosPage()));
    await tester.pump(const Duration(milliseconds: 600));

    expect(tester.getSize(find.byType(Scaffold)).width, 884);

    final doctorado = tester.getRect(
      find
          .ancestor(
            of: find.textContaining('Maestría en Calidad Académica'),
            matching: find.byType(InkWell),
          )
          .first,
    );
    final calidadProfesional = tester.getRect(
      find
          .ancestor(
            of: find.textContaining('Maestría en Calidad Profesional'),
            matching: find.byType(InkWell),
          )
          .first,
    );
    expect(doctorado.right, lessThanOrEqualTo(432));
    expect(calidadProfesional.left, greaterThanOrEqualTo(452));
    expectNoLayoutException(tester);
  });

  testWidgets('cursos libres deja libre la bisagra vertical del Fold', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(884, 832);
    tester.view.devicePixelRatio = 1;
    tester.view.displayFeatures = const <ui.DisplayFeature>[
      ui.DisplayFeature(
        bounds: Rect.fromLTRB(432, 0, 452, 832),
        type: ui.DisplayFeatureType.hinge,
        state: ui.DisplayFeatureState.postureHalfOpened,
      ),
    ];
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetDisplayFeatures);

    await tester.pumpWidget(
      const MaterialApp(home: CursosLibresCatalogoPage()),
    );
    await tester.pump(const Duration(milliseconds: 700));

    final excel = tester.getRect(
      find
          .ancestor(of: find.text('Excel'), matching: find.byType(InkWell))
          .first,
    );
    final powerBi = tester.getRect(
      find
          .ancestor(of: find.text('Power BI'), matching: find.byType(InkWell))
          .first,
    );

    expect(excel.right, lessThanOrEqualTo(432));
    expect(powerBi.left, greaterThanOrEqualTo(452));
    expectNoLayoutException(tester);
  });

  testWidgets('Home muestra Posgrados debajo en tres columnas', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1366, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: TecHomeScreen()));
    await tester.pump(const Duration(milliseconds: 600));

    final licenciatura = find.ancestor(
      of: find.text('Licenciatura Industrial'),
      matching: find.byType(InkWell),
    );
    final posgrados = find.ancestor(
      of: find.text('Posgrados Industrial'),
      matching: find.byType(InkWell),
    );

    expect(
      tester.getTopLeft(licenciatura).dy,
      lessThan(tester.getTopLeft(posgrados).dy),
    );
    expect(tester.getSize(posgrados).width, tester.getSize(licenciatura).width);
    expectNoLayoutException(tester);
  });

  testWidgets('Home coloca sus cuatro tarjetas en una fila amplia', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: TecHomeScreen()));
    await tester.pump(const Duration(milliseconds: 600));

    final titles = [
      'Especialidades y Cursos Industriales',
      'Técnico Industrial',
      'Licenciatura Industrial',
      'Posgrados Industrial',
    ];
    final cards = [
      for (final title in titles)
        find
            .ancestor(of: find.text(title), matching: find.byType(InkWell))
            .first,
    ];
    final topPositions = cards.map((card) => tester.getTopLeft(card).dy);
    final widths = cards.map((card) => tester.getSize(card).width);

    expect(topPositions.toSet(), hasLength(1));
    expect(widths.toSet(), hasLength(1));
    for (final card in cards) {
      expect(
        find.descendant(
          of: card,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is FractionallySizedBox && widget.widthFactor == 0.9,
          ),
        ),
        findsOneWidget,
      );
    }
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName !=
                'assets/images/tec_logo.png',
      ),
      findsNWidgets(3),
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/LogoPosgrados.jpeg',
      ),
      findsOneWidget,
    );
    expectNoLayoutException(tester);
  });

  testWidgets('perfil maneja Firebase no configurado sin lanzar errores', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PerfilPage()));
    expect(find.text('Inicia sesión para ver tu información'), findsOneWidget);
    expect(find.text('Estudiante · Tecnológico de Costa Rica'), findsNothing);

    await tester.tap(find.text('Información personal'));
    await tester.pump();
    expect(
      find.text('Firebase no está disponible en este momento.'),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 5));
    await tester.tap(find.text('Seguridad de la cuenta'));
    await tester.pump();
    expect(
      find.text('Firebase no está disponible en este momento.'),
      findsOneWidget,
    );
    expectNoLayoutException(tester);
  });
}
