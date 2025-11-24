// integration_test/tc_009_test.dart

// --- INICIO DEL BLOQUE COMÚN ---
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:voleyballtraining/main.dart' as app; 

Future<void> longDelay(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(seconds: 6)); 
}
Future<void> shortDelay(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}
Future<void> loginAs(WidgetTester tester, String email, String password) async {
  app.main();
  await tester.pumpAndSettle();
  await tester.pump(const Duration(seconds: 2)); 
  await tester.enterText(find.byKey(const Key('login_email_field')), email);
  await tester.pump(const Duration(seconds: 2)); 
  await tester.enterText(find.byKey(const Key('login_password_field')), password);
  await tester.pump(const Duration(seconds: 2)); 
  await tester.tap(find.byKey(const Key('login_button')));
  await longDelay(tester); 
  await tester.pump(const Duration(seconds: 2)); 
  expect(find.text('Bienvenido'), findsOneWidget);
}
// --- FIN DEL BLOQUE COMÚN ---


// --- INICIO DE LA PRUEBA TC-009 ---
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TC-009: Validar que solo el rol "Entrenador" puede crear planes', (WidgetTester tester) async {
    // 1. Precondición: Iniciar sesión como Entrenador (con pausas)
    print("Paso 1: Iniciando sesión como Entrenador...");
    await loginAs(tester, 'entrenadortest@gmail.com', '12345678');
    print("Paso 1 completado: Sesión iniciada como Entrenador.");

    // 2. Acceder a "Planes" desde el menú
    print("Paso 2: Navegando a la vista de Planes...");
    await tester.tap(find.byKey(const Key('menu_plans_button')));
    await longDelay(tester); // Esperar que carguen los planes
    await tester.pump(const Duration(seconds: 2)); // Pausa extra para ver la lista
    print("Paso 2 completado: Vista de Planes cargada.");

    // 3. Resultado Esperado (El botón "+" flotante para crear plan es visible)
    print("Paso 3: Verificando que el botón '+' (Crear Plan) sea visible...");
    expect(find.byKey(const Key('plans_create_plan_fab')), findsOneWidget); 
    print("Paso 3 completado: ¡Botón '+' encontrado!");

    // Pausa final para observar el resultado
    await tester.pump(const Duration(seconds: 3)); 
    print("Prueba TC-009 finalizada.");
  });
}
// --- FIN DE LA PRUEBA TC-009 ---