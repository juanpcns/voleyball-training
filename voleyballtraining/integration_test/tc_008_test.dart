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

  testWidgets('TC-008: Visualización de lista de usuarios (sin usuarios)', (WidgetTester tester) async {
    // NOTA: Esta prueba requiere un usuario "Entrenador" especial en tu
    // base de datos que no tenga jugadores asociados, o una BD vacía.
    // Asumiremos que tenemos un usuario "entrenadorvacio@test.com" para esta prueba.
    
    // 1. Precondición: Iniciar sesión como Entrenador (sin jugadores)
    await loginAs(tester, 'entrenadorvacio@test.com', '12345678');

    // 2. Navegar a Usuarios
    await tester.tap(find.byKey(const Key('menu_users_button')));
    await longDelay(tester); 

    // 3. Resultado Esperado (Mensaje de lista vacía)
    expect(find.byKey(const Key('users_empty_list_text')), findsOneWidget);
  });
}