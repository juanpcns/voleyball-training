// integration_test/tc_004_test.dart

// --- INICIO DEL BLOQUE COMÚN ---
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// Importa tu app
import 'package:voleyballtraining/main.dart' as app; 

// Importa las vistas que necesitamos para las pruebas

/// FUNCIÓN DE AYUDA:
/// Un delay largo para esperar operaciones de red (Firebase).
Future<void> longDelay(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(seconds: 6)); 
}

/// FUNCIÓN DE AYUDA:
/// Un delay corto para actualizaciones de estado locales.
Future<void> shortDelay(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}

/// FUNCIÓN DE AYUDA:
/// Inicia la app e inicia sesión con un usuario específico (con pausas).
Future<void> loginAs(WidgetTester tester, String email, String password) async {
  app.main();
  await tester.pumpAndSettle();
  await tester.pump(const Duration(seconds: 2)); // Pausa
  await tester.enterText(find.byKey(const Key('login_email_field')), email);
  await tester.pump(const Duration(seconds: 2)); // Pausa
  await tester.enterText(find.byKey(const Key('login_password_field')), password);
  await tester.pump(const Duration(seconds: 2)); // Pausa
  await tester.tap(find.byKey(const Key('login_button')));
  await longDelay(tester); 
  await tester.pump(const Duration(seconds: 2)); // Pausa
  expect(find.text('Bienvenido'), findsOneWidget);
}
// --- FIN DEL BLOQUE COMÚN ---


// --- INICIO DE LA PRUEBA TC-004 ---
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TC-004: Verificación de interacción en tiempo real', (WidgetTester tester) async {
    // 1. Precondición: Iniciar sesión como Jugador (con pausas)
    print("Paso 1: Iniciando sesión como Jugador...");
    await loginAs(tester, 'jugadortest@gmail.com', '12345678');
    print("Paso 1 completado: Sesión iniciada como Jugador.");

    // 2. Ir a chats desde el menú
    print("Paso 2: Navegando a la vista de Chats...");
    await tester.tap(find.byKey(const Key('menu_chats_button')));
    await longDelay(tester); // Esperar que carguen los chats existentes
    await tester.pump(const Duration(seconds: 2)); // Pausa extra
    print("Paso 2 completado: Vista de Chats cargada.");

    // 3 & 4. Abrir un chat existente con 'Entrenador Test'
    // (Asume que el chat ya existe por TC-003 o manualmente)
    print("Paso 3 & 4: Abriendo chat existente con 'Entrenador Test'...");
    await tester.tap(find.text('Entrenador Test')); // Toca el ListTile del chat
    await longDelay(tester); // Esperar que carguen los mensajes del chat
    await tester.pump(const Duration(seconds: 2)); // Pausa extra
    print("Paso 3 & 4 completados: Chat con 'Entrenador Test' abierto.");

    // 5. Enviar un mensaje único para identificarlo
    print("Paso 5: Escribiendo y enviando un mensaje de prueba...");
    final testMessage = 'Hola! Mensaje T:${DateTime.now().second}s';
    await tester.enterText(find.byKey(const Key('chat_message_field')), testMessage);
    await tester.pump(const Duration(seconds: 2)); // Pausa para ver el texto escrito

    await tester.tap(find.byKey(const Key('chat_send_button')));
    // Usamos pump aquí en lugar de pumpAndSettle porque el stream actualizará la UI,
    // no hay una animación o futuro directo que esperar del tap.
    // Damos tiempo suficiente para que Firebase procese y el StreamBuilder reconstruya.
    await tester.pump(const Duration(seconds: 4)); 
    print("Paso 5 completado: Mensaje enviado.");

    // 6-9. Resultado Esperado (El mensaje enviado aparece en la pantalla del jugador)
    print("Paso 6-9: Verificando que el mensaje '$testMessage' aparezca en la pantalla...");
    expect(find.text(testMessage), findsOneWidget);
    print("Paso 6-9 completados: ¡Mensaje encontrado en la pantalla!");

    // Pausa final para observar el resultado
    await tester.pump(const Duration(seconds: 3)); 
    print("Prueba TC-004 finalizada.");
  });
}
// --- FIN DE LA PRUEBA TC-004 ---