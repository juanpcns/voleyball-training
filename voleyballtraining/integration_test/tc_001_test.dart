// --- INICIO DEL BLOQUE COMÚN ---
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:voleyballtraining/main.dart' as app; 

/// SOLUCIÓN 1: Delay robusto para esperar red (Firebase)
/// Reemplazamos pumpAndSettle por un pump (espera dura) + pumpAndSettle (espera de animaciones)
Future<void> longDelay(WidgetTester tester) async {
  // 1. Espera "dura" de 8 segundos para operaciones de red (Firebase/Firestore)
  await tester.pump(const Duration(seconds: 8));
  // 2. Espera para que terminen las animaciones (navegación, etc.)
  await tester.pumpAndSettle();
}

Future<void> shortDelay(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}

/// SOLUCIÓN 2: Función de Login corregida
Future<void> loginAs(WidgetTester tester, String email, String password) async {
  // 1. Iniciar la app
  app.main();
  await tester.pumpAndSettle();
  
  // SOLUCIÓN 2a: Espera inicial única y larga (10s) para que Firebase 
  // se inicialice y muestre la pantalla de Login.
  // (Reemplaza todas tus pausas de 2 segundos)
  await tester.pump(const Duration(seconds: 10)); 
  
  // 2. Escribir en los campos
  await tester.enterText(find.byKey(const Key('login_email_field')), email);
  await tester.enterText(find.byKey(const Key('login_password_field')), password);
  
  // SOLUCIÓN 2b: ¡LA CORRECCIÓN CLAVE!
  // Ocultamos el teclado simulando que el usuario presiona "Hecho".
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pump(); // Damos un frame para que la UI reaccione y el teclado se oculte
  
  // 3. Pulsar el botón de login (ahora sí está visible)
  await tester.tap(find.byKey(const Key('login_button')));
  
  // 4. Usar el longDelay robusto para esperar el login y la navegación
  await longDelay(tester); 
  
  // 5. Verificar que el login fue exitoso
  expect(find.text('Bienvenido'), findsOneWidget);
}
// --- FIN DEL BLOQUE COMÚN ---


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TC-001: Asignación exitosa de un plan a un jugador', (WidgetTester tester) async {
    // 1. Precondición: Iniciar sesión como Entrenador (con la función corregida)
    await loginAs(tester, 'entrenadortest@gmail.com', '12345678');

    // 2. Pasos (según PDF)
    print("Paso 2: Pulsando botón de Planes..."); // Mensaje en consola
    await tester.tap(find.byKey(const Key('menu_plans_button')));
    await longDelay(tester); // Esperar que carguen los planes
    
    // (Tus pausas extras ya no son tan necesarias, pero no hacen daño)
    await tester.pump(const Duration(seconds: 2));
    print("Paso 2 completado: Lista de planes cargada.");

    // 3. Encontrar el plan "testPlan" y pulsar su botón de asignar
    print("Paso 3: Buscando 'testPlan' y su botón de asignar...");
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
    
    await tester.pump(const Duration(seconds: 2));
    print("Paso 3 completado: Diálogo de jugadores abierto.");

    // 4. Seleccionar al "Jugador Test" del diálogo
    print("Paso 4: Seleccionando 'Jugador Test'...");
    await tester.tap(find.text('Jugador Test'));
    await longDelay(tester); // Esperar que se cierre el diálogo y se asigne
    
    await tester.pump(const Duration(seconds: 2));
    print("Paso 4 completado: Jugador seleccionado y asignación procesada.");

    // 5. Resultado Esperado (El SnackBar de éxito)
    print("Paso 5: Verificando mensaje de éxito...");
    expect(find.text('¡Plan asignado!'), findsOneWidget);
    print("Paso 5 completado: ¡Prueba TC-001 Exitosa!");
    
    await tester.pump(const Duration(seconds: 3));
  });
}