// integration_test/tc_005_test.dart

// --- INICIO DEL BLOQUE COMÚN ---
// ... (El bloque común se mantiene igual) ...
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
  // ... (loginAs se mantiene igual) ...
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


// --- INICIO DE LA PRUEBA TC-005 (CORREGIDA OTRA VEZ) ---
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TC-005: Registro exitoso', (WidgetTester tester) async {
    print("Paso 1: Iniciando la aplicación...");
    app.main();
    await tester.pumpAndSettle(); 
    await tester.pump(const Duration(seconds: 2)); 
    print("Paso 1 completado: Aplicación iniciada.");

    print("Paso 2: Navegando a la vista de Registro...");
    await tester.tap(find.byKey(const Key('login_register_button')));
    await shortDelay(tester); 
    await tester.pump(const Duration(seconds: 2)); 
    print("Paso 2 completado: Vista de Registro cargada.");

    print("Paso 3: Completando el formulario de registro...");
    final uniqueEmail = 'nuevo_usuario_${DateTime.now().millisecondsSinceEpoch}@test.com';
    
    await tester.enterText(find.byKey(const Key('register_name_field')), 'Usuario Nuevo Exitoso');
    await tester.pump(const Duration(seconds: 1)); 
    await tester.enterText(find.byKey(const Key('register_email_field')), uniqueEmail);
    await tester.pump(const Duration(seconds: 1)); 
    await tester.enterText(find.byKey(const Key('register_password_field')), 'password123');
    await tester.pump(const Duration(seconds: 1)); 
    await tester.enterText(find.byKey(const Key('register_confirm_password_field')), 'password123');
    await tester.pump(const Duration(seconds: 1)); 

    print("Cerrando teclado...");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await shortDelay(tester); 
    print("Teclado cerrado.");

    final dropdownFinder = find.byKey(const Key('register_role_dropdown'));
    print("Asegurando visibilidad del Dropdown...");
    await tester.ensureVisible(dropdownFinder);
    await shortDelay(tester); 
    print("Dropdown visible.");
    print("Abriendo Dropdown de Rol...");
    await tester.tap(dropdownFinder);
    await shortDelay(tester); 
    await tester.pump(const Duration(seconds: 2)); 
    print("Dropdown abierto.");
    print("Seleccionando Rol 'Jugador'...");
    await tester.tap(find.text('Jugador').last); 
    await shortDelay(tester); 
    await tester.pump(const Duration(seconds: 1)); 
    print("Rol 'Jugador' seleccionado.");
    print("Paso 3 completado: Formulario completado.");

    print("Paso 4: Enviando el formulario...");
    final registerButtonFinder = find.byKey(const Key('register_button'));
    await tester.ensureVisible(registerButtonFinder);
    await shortDelay(tester);
    await tester.tap(registerButtonFinder);
    await longDelay(tester); // Espera larga para el registro Y la navegación
    await tester.pump(const Duration(seconds: 2)); 
    print("Paso 4 completado: Formulario enviado y navegación realizada.");

    // 5. Resultado Esperado (VERIFICAR QUE ESTAMOS EN EL MENÚ PRINCIPAL)
    print("Paso 5: Verificando que se navegó al Menú Principal...");
    // <<<--- CAMBIO AQUÍ: Buscar un widget del MainMenuView ---<<<
    expect(find.text('Bienvenido'), findsOneWidget, reason: "Después de registrarse, debería navegar al MainMenuView que muestra 'Bienvenido'"); 
    print("Paso 5 completado: ¡Navegación al Menú Principal confirmada!");

    await tester.pump(const Duration(seconds: 3)); 
    print("Prueba TC-005 finalizada.");
  });
}
// --- FIN DE LA PRUEBA TC-005 ---