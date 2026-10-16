import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fundatec/main.dart';

void main() {
  testWidgets('la aplicación inicia en Inicio', (WidgetTester tester) async {
    await tester.pumpWidget(const TecApp());

    expect(find.byType(TecApp), findsOneWidget);
  });

  testWidgets('la navegación inferior abre los avisos integrados', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TecApp());
    await tester.tap(find.text('Avisos'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Centro de\navisos'), findsOneWidget);
    expect(find.text('Actividad académica'), findsOneWidget);
  });

  for (final size in <Size>[const Size(320, 568), const Size(800, 360)]) {
    testWidgets('avisos se desplaza en pantalla ${size.width}x${size.height}', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const TecApp());
      await tester.tap(find.text('Avisos'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      await tester.scrollUntilVisible(
        find.text('Información disponible'),
        250,
        scrollable: find.byType(Scrollable).last,
      );

      expect(find.text('Información disponible'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
