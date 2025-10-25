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

  testWidgets('TC-001: Asignación exitosa de un plan a un jugador', (WidgetTester tester) async {
    // 1. Precondición: Iniciar sesión como Entrenador
    await loginAs(tester, 'entrenadortest@gmail.com', '12345678');

    // 2. Pasos (según PDF)
    await tester.tap(find.byKey(const Key('menu_plans_button')));
    await longDelay(tester); // Esperar que carguen los planes

    // 3. Encontrar el plan "testPlan" y pulsar su botón de asignar
    final planTile = find.ancestor(
      of: find.text('testPlan'), 
      matching: find.byType(ListTile),
    );
    final assignButton = find.descendant(
      of: planTile,
      matching: find.byTooltip('Asignar Plan a Jugador'),
    );

    expect(assignButton, findsOneWidget);
    await tester.tap(assignButton);
    await longDelay(tester); // Esperar que cargue la lista de jugadores

    // 4. Seleccionar al "Jugador Test" del diálogo
    await tester.tap(find.text('Jugador Test'));
    await longDelay(tester); // Esperar que se cierre el diálogo y se asigne

    // 5. Resultado Esperado (El SnackBar de éxito)
    expect(find.text('¡Plan asignado!'), findsOneWidget);
  });
}