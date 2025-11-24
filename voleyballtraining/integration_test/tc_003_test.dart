// integration_test/tc_003_test.dart

// --- INICIO DEL BLOQUE COMÚN ---
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// Importa tu app
import 'package:voleyballtraining/main.dart' as app; 

// Importa las vistas que necesitamos para las pruebas
// (Aunque TC-003 no las usa directamente, las mantenemos por consistencia
// y porque las funciones de ayuda podrían necesitarlas indirectamente)

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


// --- INICIO DE LA PRUEBA TC-003 ---
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TC-003: Verificación de la creación de chats', (WidgetTester tester) async {
    // 1. Precondición: Iniciar sesión como Jugador (con pausas)
    print("Paso 1: Iniciando sesión como Jugador...");
    await loginAs(tester, 'jugadortest@gmail.com', '12345678');
    print("Paso 1 completado: Sesión iniciada como Jugador.");

    // 2. Ir a chats desde el menú
    print("Paso 2: Navegando a la vista de Chats...");
    await tester.tap(find.byKey(const Key('menu_chats_button')));
    await longDelay(tester); // Esperar que carguen los chats existentes (si hay)
    await tester.pump(const Duration(seconds: 2)); // Pausa extra
    print("Paso 2 completado: Vista de Chats cargada.");

    // 3. Presionar botón de crear chat (FloatingActionButton)
    print("Paso 3: Pulsando el botón para crear un nuevo chat...");
    await tester.tap(find.byKey(const Key('chats_new_chat_fab')));
    await longDelay(tester); // Esperar que cargue la lista de usuarios para seleccionar
    await tester.pump(const Duration(seconds: 2)); // Pausa extra
    print("Paso 3 completado: Vista de selección de usuario cargada.");

    // 4. Verificar que el entrenador 'Entrenador Test' está listado
    print("Paso 4: Verificando que 'Entrenador Test' esté en la lista...");
    expect(find.text('Entrenador Test'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2)); // Pausa extra
    print("Paso 4 completado: 'Entrenador Test' encontrado en la lista.");

    // 5. Pulsar el nombre del entrenador para iniciar/abrir el chat
    print("Paso 5: Seleccionando 'Entrenador Test' para abrir el chat...");
    await tester.tap(find.text('Entrenador Test'));
    await longDelay(tester); // Esperar que se cree/cargue el chat y navegue
    await tester.pump(const Duration(seconds: 2)); // Pausa extra
    print("Paso 5 completado: Navegación a la vista de chat individual.");

    // 6. Resultado Esperado (Estamos en la interfaz de chat, verificamos buscando el campo de texto)
    print("Paso 6: Verificando que estamos en la interfaz de chat...");
    expect(find.byKey(const Key('chat_message_field')), findsOneWidget);
    print("Paso 6 completado: ¡Interfaz de chat cargada correctamente!");

    // Pausa final para observar el resultado
    await tester.pump(const Duration(seconds: 3)); 
    print("Prueba TC-003 finalizada.");
  });
}
// --- FIN DE LA PRUEBA TC-003 ---