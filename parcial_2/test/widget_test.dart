// Pruebas de la pantalla de login: validaciones y alertas del formulario.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parcial_2/config/theme/app_theme.dart';
import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/presentation/public/auth/auth_screen.dart';

Future<void> pumpLogin(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  FlutterSecureStorage.setMockInitialValues({});

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        locale: const Locale('es'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.light(),
        home: const AuthScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Si los campos están vacíos muestra las alertas', (tester) async {
    await pumpLogin(tester);

    await tester.tap(find.text('Iniciar sesión'));
    await tester.pump();

    expect(find.text('Este campo es obligatorio'), findsNWidgets(2));
    expect(find.text('Por favor completa todos los campos'), findsOneWidget);
  });

  testWidgets('Valida el formato con regex antes de enviar', (tester) async {
    await pumpLogin(tester);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'jp'); // muy corto
    await tester.enterText(fields.at(1), '123'); // muy corta
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pump();

    expect(
      find.text(
        'Usa de 3 a 50 caracteres (letras, números, . _ -) o un correo válido',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'La contraseña debe tener entre 6 y 72 caracteres, sin espacios',
      ),
      findsOneWidget,
    );
    expect(find.text('Revisa los campos marcados en rojo'), findsOneWidget);
  });

  testWidgets('El usuario no acepta espacios', (tester) async {
    await pumpLogin(tester);

    await tester.enterText(find.byType(TextFormField).first, 'juan melo');
    expect(find.text('juanmelo'), findsOneWidget);
  });
}
