import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fundatec/registro.dart';

Widget _pantallaDeRegistro(VoidCallback alCompletar) {
  return MaterialApp(home: RegistroPage(onRegistrationComplete: alCompletar));
}

Future<void> _esperarHasta(
  WidgetTester tester,
  bool Function() condicion,
) async {
  for (var intento = 0; intento < 100; intento++) {
    await tester.pump();
    if (condicion()) return;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
  }
  expect(condicion(), isTrue);
}

void main() {
  testWidgets('registra una cuenta y valida sus credenciales al ingresar', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    var accesosCorrectos = 0;
    await tester.pumpWidget(_pantallaDeRegistro(() => accesosCorrectos++));

    await tester.tap(find.text('¿No tienes cuenta? Regístrate'));
    await tester.pumpAndSettle();
    expect(find.text('Activar acceso biométrico'), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Prueba@tec.ac.cr',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'ClaveSegura123');
    await tester.enterText(find.byType(TextFormField).at(2), 'ClaveSegura123');

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Empresa').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('CREAR CUENTA'));
    await _esperarHasta(
      tester,
      () => find
          .text('Cuenta creada. Ahora inicia sesión.')
          .evaluate()
          .isNotEmpty,
    );
    expect(accesosCorrectos, 0);
    expect(find.text('Inicia sesión'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    final cuentas = jsonDecode(
      preferences.getString(cuentasUsuariosPreferenceKey)!,
    ) as Map<String, dynamic>;
    expect(cuentas['prueba@tec.ac.cr']['tipo'], 'Empresa');
    expect(preferences.getBool(registroCompletadoPreferenceKey), isFalse);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'prueba@tec.ac.cr',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'clave-incorrecta',
    );
    await tester.tap(find.text('INICIAR SESIÓN'));
    await _esperarHasta(
      tester,
      () => find
          .text('El correo o la contraseña no son correctos.')
          .evaluate()
          .isNotEmpty,
    );
    expect(
      find.text('El correo o la contraseña no son correctos.'),
      findsOneWidget,
    );
    expect(accesosCorrectos, 0);
    expect(preferences.getBool(registroCompletadoPreferenceKey), isFalse);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(1), 'ClaveSegura123');
    await tester.tap(find.text('INICIAR SESIÓN'));
    await _esperarHasta(tester, () => accesosCorrectos == 1);
    expect(preferences.getBool(registroCompletadoPreferenceKey), isTrue);
  });
}
