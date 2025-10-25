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

  testWidgets('TC-002: Verificación del plan asignado (Jugador)', (WidgetTester tester) async {
    // 1. Precondición: Iniciar sesión como Jugador
    await loginAs(tester, 'jugadortest@gmail.com', '12345678');

    // 2. Navegar a planes
    await tester.tap(find.byKey(const Key('menu_plans_button')));
    await longDelay(tester); // Esperar que carguen las asignaciones

    // 3. Verificar que el plan "testPlan" está visible
    expect(find.text('testPlan'), findsOneWidget);

    // 4. Pulsar el botón "Aceptar" de ese plan
    final assignmentTile = find.ancestor(
      of: find.text('testPlan'),
      matching: find.byType(ListTile),
    );
    final acceptButton = find.descendant(
      of: assignmentTile,
      matching: find.byTooltip('Aceptar Plan'),
    );

    expect(acceptButton, findsOneWidget);
    await tester.tap(acceptButton);
    await longDelay(tester); // Esperar que se procese el clic

    // 5. Resultado Esperado (El estado cambia a "Aceptado")
    final statusText = find.descendant(
      of: assignmentTile,
      matching: find.text('Estado: Aceptado'),
    );

    expect(statusText, findsOneWidget, reason: 'El estado del plan no cambió a Aceptado. El botón puede estar roto.');
  });
}