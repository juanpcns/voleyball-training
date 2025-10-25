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

  testWidgets('TC-003: Verificación de la creación de chats', (WidgetTester tester) async {
    // 1. Precondición: Iniciar sesión como Jugador
    await loginAs(tester, 'jugadortest@gmail.com', '12345678');

    // 2. Ir a chats
    await tester.tap(find.byKey(const Key('menu_chats_button')));
    await longDelay(tester);

    // 3. Presionar botón de crear chat (FAB)
    await tester.tap(find.byKey(const Key('chats_new_chat_fab')));
    await longDelay(tester); // Esperar que cargue la lista de usuarios

    // 4. Verificar que el entrenador está listado
    expect(find.text('Entrenador Test'), findsOneWidget);

    // 5. Pulsar el nombre del entrenador
    await tester.tap(find.text('Entrenador Test'));
    await longDelay(tester); // Esperar que cree/navegue al chat

    // 6. Resultado Esperado (Estamos en la interfaz de chat)
    expect(find.byKey(const Key('chat_message_field')), findsOneWidget);
  });
}