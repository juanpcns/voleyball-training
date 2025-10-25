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
  
  // <<< PAUSA EXTRA antes de escribir email
  await tester.pump(const Duration(seconds: 2));
  
  await tester.enterText(find.byKey(const Key('login_email_field')), email);
  
  // <<< PAUSA EXTRA después de escribir email
  await tester.pump(const Duration(seconds: 2));
  
  await tester.enterText(find.byKey(const Key('login_password_field')), password);
  
  // <<< PAUSA EXTRA después de escribir contraseña
  await tester.pump(const Duration(seconds: 2));
  
  await tester.tap(find.byKey(const Key('login_button')));
  await longDelay(tester); // Espera larga para el login
  
  // <<< PAUSA EXTRA después del login
  await tester.pump(const Duration(seconds: 2));
  
  expect(find.text('Bienvenido'), findsOneWidget);
}
// --- FIN DEL BLOQUE COMÚN ---


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TC-001: Asignación exitosa de un plan a un jugador', (WidgetTester tester) async {
    // 1. Precondición: Iniciar sesión como Entrenador (con pausas añadidas en loginAs)
    await loginAs(tester, 'entrenadortest@gmail.com', '12345678');

    // 2. Pasos (según PDF)
    print("Paso 2: Pulsando botón de Planes..."); // Mensaje en consola
    await tester.tap(find.byKey(const Key('menu_plans_button')));
    await longDelay(tester); // Esperar que carguen los planes
    
    // <<< PAUSA EXTRA después de cargar planes
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
    
    // <<< PAUSA EXTRA después de abrir diálogo de jugadores
    await tester.pump(const Duration(seconds: 2));
    print("Paso 3 completado: Diálogo de jugadores abierto.");

    // 4. Seleccionar al "Jugador Test" del diálogo
    print("Paso 4: Seleccionando 'Jugador Test'...");
    await tester.tap(find.text('Jugador Test'));
    await longDelay(tester); // Esperar que se cierre el diálogo y se asigne
    
    // <<< PAUSA EXTRA después de asignar
    await tester.pump(const Duration(seconds: 2));
    print("Paso 4 completado: Jugador seleccionado y asignación procesada.");

    // 5. Resultado Esperado (El SnackBar de éxito)
    print("Paso 5: Verificando mensaje de éxito...");
    expect(find.text('¡Plan asignado!'), findsOneWidget);
    print("Paso 5 completado: ¡Prueba TC-001 Exitosa!");
    
    // <<< PAUSA EXTRA al final para ver el resultado
    await tester.pump(const Duration(seconds: 3));
  });
}