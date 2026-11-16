import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fundatec/registro.dart';

Widget _pantallaDeRegistro(VoidCallback alCompletar) {
  return MaterialApp(home: RegistroPage(onRegistrationComplete: alCompletar));
}

void main() {
  testWidgets('el registro requiere un nombre para mostrarlo en el perfil', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_pantallaDeRegistro(() {}));
    expect(find.text('Nombre completo'), findsNothing);

    await tester.tap(find.text('Crear una cuenta'));
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('Nombre completo'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(4));

    await tester.ensureVisible(find.text('CREAR CUENTA'));
    await tester.tap(find.text('CREAR CUENTA'));
    await tester.pump();
    expect(find.text('Escribe tu nombre completo.'), findsOneWidget);
  });
}
