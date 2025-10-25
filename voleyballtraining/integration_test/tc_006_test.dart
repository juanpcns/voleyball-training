// [ Pega el BLOQUE COMÚN de arriba aquí ]
// --- INICIO DEL BLOQUE COMÚN ---
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:voleyballtraining/main.dart' as app; 
import 'package:voleyballtraining/Views/plans/create_plan_view.dart';
import 'package:voleyballtraining/Views/plans/training_plans_view.dart';

Future<void> longDelay(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(seconds: 5));
}
Future<void> shortDelay(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}
Future<void> loginAs(WidgetTester tester, String email, String password) async {
  app.main();
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('login_email_field')), email);
  await tester.enterText(find.byKey(const Key('login_password_field')), password);
  await tester.tap(find.byKey(const Key('login_button')));
  await longDelay(tester);
  expect(find.text('Bienvenido'), findsOneWidget);
}
// --- FIN DEL BLOQUE COMÚN ---


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TC-006: Registro fallido por duplicado', (WidgetTester tester) async {
    // 1. Iniciar App (¡SIN LOGIN!)
    app.main();
    await tester.pumpAndSettle();

    // 2. Ir a la vista de registro
    await tester.tap(find.byKey(const Key('login_register_button')));
    await shortDelay(tester);

    // 3. Completar formulario con email EXISTENTE (del PDF)
    await tester.enterText(find.byKey(const Key('register_name_field')), 'Usuario Duplicado');
    await tester.enterText(find.byKey(const Key('register_email_field')), 'jpvl6833@gmail.com');
    await tester.enterText(find.byKey(const Key('register_password_field')), '1234#@');
    await tester.enterText(find.byKey(const Key('register_confirm_password_field')), '1234#@');
    
    await tester.tap(find.byKey(const Key('register_role_dropdown')));
    await shortDelay(tester);
    await tester.tap(find.text('Jugador').last);
    await shortDelay(tester);

    // 4. Enviar formulario
    await tester.tap(find.byKey(const Key('register_button')));
    await longDelay(tester);

    // 5. Resultado Esperado (según tu PDF)
    expect(find.text('Este usuario ya existe'), findsOneWidget);
  });
}