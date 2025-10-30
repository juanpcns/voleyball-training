// integration_test/tc_008_test.dart

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


// --- INICIO DE LA PRUEBA TC-008 ---
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TC-008: Visualización de lista de usuarios (sin usuarios)', (WidgetTester tester) async {
    // 1. Precondición: Iniciar sesión como Entrenador SIN JUGADORES (con pausas)
    print("Paso 1: Iniciando sesión como Entrenador sin jugadores (entrenadorvacio@test.com)...");
    //*** ASEGÚRATE DE QUE ESTE USUARIO EXISTA Y NO TENGA JUGADORES ***
    await loginAs(tester, 'entrenadortest@gmail.com', '12345678'); 
    print("Paso 1 completado: Sesión iniciada.");

    // 2. Navegar a Usuarios desde el menú
    print("Paso 2: Navegando a la vista de Usuarios...");
    await tester.tap(find.byKey(const Key('menu_users_button')));
    await longDelay(tester); // Esperar la carga (aunque debería ser rápida)
    await tester.pump(const Duration(seconds: 2)); // Pausa extra para ver el resultado
    print("Paso 2 completado: Vista de Usuarios cargada.");

    // 3. Resultado Esperado (Mensaje de lista vacía según PDF)
    print("Paso 3: Verificando que se muestre el mensaje de lista vacía...");
    // Buscamos el texto exacto del PDF para TC-008, asegurándonos que SÍ exista la Key que pusimos antes
    // NOTA: Si tu widget de texto no tiene la key 'users_empty_list_text', usa find.text(...)
    // expect(find.text('No hay usuarios disponibles en este momento'), findsOneWidget); 
    expect(find.byKey(const Key('users_empty_list_text')), findsOneWidget); 
    print("Paso 3 completado: ¡Mensaje de lista vacía encontrado!");

    // Pausa final para observar el resultado
    await tester.pump(const Duration(seconds: 3)); 
    print("Prueba TC-008 finalizada.");
  });
}
// --- FIN DE LA PRUEBA TC-008 ---