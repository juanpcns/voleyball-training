// integration_test/tc_007_test.dart

// --- INICIO DEL BLOQUE COMÚN ---
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:voleyballtraining/main.dart' as app; 
import 'package:voleyballtraining/Views/plans/create_plan_view.dart';
import 'package:voleyballtraining/Views/plans/training_plans_view.dart';

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


// --- INICIO DE LA PRUEBA TC-007 ---
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TC-007: Visualización de lista de usuarios (con usuarios)', (WidgetTester tester) async {
    // 1. Precondición: Iniciar sesión como Entrenador (con pausas)
    print("Paso 1: Iniciando sesión como Entrenador...");
    await loginAs(tester, 'entrenadortest@gmail.com', '12345678');
    print("Paso 1 completado: Sesión iniciada como Entrenador.");

    // 2. Navegar a Usuarios desde el menú
    print("Paso 2: Navegando a la vista de Usuarios...");
    await tester.tap(find.byKey(const Key('menu_users_button')));
    await longDelay(tester); // Esperar que cargue la lista de usuarios de Firestore
    await tester.pump(const Duration(seconds: 2)); // Pausa extra para ver la lista
    print("Paso 2 completado: Vista de Usuarios cargada.");

    // 3. Resultado Esperado (Encuentra al menos un usuario conocido, como 'Jugador Test')
    print("Paso 3: Verificando que la lista contenga usuarios (ej: 'Jugador Test')...");
    // Buscamos un usuario específico que sabemos que debe existir
    expect(find.text('Jugador Test'), findsWidgets, reason: "Debería encontrarse al menos el usuario 'Jugador Test'"); 
    print("Paso 3 completado: ¡Lista de usuarios mostrada correctamente!");

    // Pausa final para observar el resultado
    await tester.pump(const Duration(seconds: 3)); 
    print("Prueba TC-007 finalizada.");
  });
}
// --- FIN DE LA PRUEBA TC-007 ---