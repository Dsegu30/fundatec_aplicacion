import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fundatec/calendario.dart';
import 'package:fundatec/cursos_libres.dart';
import 'package:fundatec/licenciatura.dart';
import 'package:fundatec/main.dart';
import 'package:fundatec/notificaciones.dart';
import 'package:fundatec/perfil.dart';
import 'package:fundatec/posgrados.dart';
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

      await tester.pumpWidget(const MaterialApp(home: CursosLibresPage()));
      await tester.pump(const Duration(milliseconds: 700));
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

  testWidgets('posgrados ocupa la fila disponible en horizontal', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(880, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const TecApp());
    await tester.pump(const Duration(milliseconds: 600));

    final card = find.ancestor(
      of: find.text('Posgrados Industrial'),
      matching: find.byType(InkWell),
    );
    expect(tester.getSize(card).width, greaterThan(700));
    expectNoLayoutException(tester);
  });

  testWidgets('posgrados se alarga en pantalla Fold', (
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

    await tester.pumpWidget(const TecApp());
    await tester.pump(const Duration(milliseconds: 600));

    final card = find.ancestor(
      of: find.text('Posgrados Industrial'),
      matching: find.byType(InkWell),
    );
    final cardRect = tester.getRect(card);
    expect(cardRect.width, greaterThan(700));
    expect(cardRect.left, lessThan(432));
    expect(cardRect.right, greaterThan(452));
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

    await tester.pumpWidget(const MaterialApp(home: CursosLibresPage()));
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

  testWidgets(
    'la pantalla principal alinea licenciatura y posgrados en laptop',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1366, 768);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const TecApp());
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
        tester.getTopLeft(posgrados).dy,
      );
      expect(
        tester.getSize(posgrados).width,
        greaterThan(tester.getSize(licenciatura).width),
      );
      expectNoLayoutException(tester);
    },
  );
}
