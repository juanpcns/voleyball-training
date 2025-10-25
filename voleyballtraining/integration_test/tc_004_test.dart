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

  testWidgets('TC-004: Verificación de interacción en tiempo real', (WidgetTester tester) async {
    // 1. Precondición: Iniciar sesión como Jugador
    await loginAs(tester, 'jugadortest@gmail.com', '12345678');

    // 2. Ir a chats y abrir un chat existente
    await tester.tap(find.byKey(const Key('menu_chats_button')));
    await longDelay(tester);
    await tester.tap(find.text('Entrenador Test')); // Asume que el chat ya existe
    await longDelay(tester); // Esperar que carguen los mensajes

    // 5. Enviar un mensaje único
    final testMessage = 'Mensaje de prueba ${DateTime.now().toIso8601String()}';
    await tester.enterText(find.byKey(const Key('chat_message_field')), testMessage);
    await tester.tap(find.byKey(const Key('chat_send_button')));
    await longDelay(tester); // Dar tiempo a que se envíe y el stream lo reciba

    // 9. Resultado Esperado (El mensaje aparece en la pantalla)
    expect(find.text(testMessage), findsOneWidget);
  });
}