import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fundatec/especialidades.dart';

void _expectNoLayoutException(WidgetTester tester) {
  var exception = tester.takeException();
  while (exception is NetworkImageLoadException) {
    exception = tester.takeException();
  }
  if (exception != null) fail(exception.toString());
}

void main() {
  for (final size in <Size>[
    const Size(280, 600),
    const Size(884, 344),
    const Size(1366, 768),
  ]) {
    testWidgets('especialidades se adapta a ${size.width}x${size.height}', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: EspecialidadesIndustrialesPage()),
      );
      await tester.pump(const Duration(milliseconds: 600));

      for (final nombre in <String>[
        'Auditoría de calidad',
        'Estadística Experimental',
        'Seis Sigma Yellow Belt',
        'Servicio al cliente',
        'Metrología',
      ]) {
        expect(find.text(nombre), findsOneWidget);
      }
      _expectNoLayoutException(tester);
    });
  }

  testWidgets('abre el detalle y ofrece el enlace oficial del TEC', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: EspecialidadesIndustrialesPage()),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Auditoría de calidad'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Información de la especialidad'), findsOneWidget);
    final enlaceOficial = find.text('Consultar oferta oficial');
    await tester.ensureVisible(enlaceOficial);
    expect(enlaceOficial, findsOneWidget);
    _expectNoLayoutException(tester);
  });
}
