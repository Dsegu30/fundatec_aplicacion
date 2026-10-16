import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fundatec/calendario.dart';
import 'package:fundatec/licenciatura.dart';
import 'package:fundatec/main.dart';
import 'package:fundatec/notificaciones.dart';
import 'package:fundatec/perfil.dart';
import 'package:fundatec/tecnicos.dart';

void expectNoLayoutException(WidgetTester tester) {
  var exception = tester.takeException();
  while (exception is NetworkImageLoadException) {
    exception = tester.takeException();
  }
  expect(exception, isNull);
}

void main() {
  for (final size in <Size>[
    const Size(280, 600),
    const Size(320, 568),
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
}
