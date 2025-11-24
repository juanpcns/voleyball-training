// integration_test/tc_006_test.dart

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


// --- INICIO DE LA PRUEBA TC-006 ---
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TC-006: Registro fallido por duplicado', (WidgetTester tester) async {
    // 1. Iniciar App (SIN LOGIN!)
    print("Paso 1: Iniciando la aplicación...");
    app.main();
    await tester.pumpAndSettle(); 
    await tester.pump(const Duration(seconds: 2)); 
    print("Paso 1 completado: Aplicación iniciada.");

    // 2. Ir a la vista de registro
    print("Paso 2: Navegando a la vista de Registro...");
    await tester.tap(find.byKey(const Key('login_register_button')));
    await shortDelay(tester); 
    await tester.pump(const Duration(seconds: 2)); 
    print("Paso 2 completado: Vista de Registro cargada.");

    // 3. Completar formulario con email EXISTENTE (del PDF)
    print("Paso 3: Completando el formulario con email duplicado...");
    await tester.enterText(find.byKey(const Key('register_name_field')), 'Usuario Duplicado Prueba');
    await tester.pump(const Duration(seconds: 1)); 
    
    await tester.enterText(find.byKey(const Key('register_email_field')), 'jpvl6833@gmail.com'); // Email existente
    await tester.pump(const Duration(seconds: 1)); 
    
    await tester.enterText(find.byKey(const Key('register_password_field')), 'password123');
    await tester.pump(const Duration(seconds: 1)); 
    
    await tester.enterText(find.byKey(const Key('register_confirm_password_field')), 'password123');
    await tester.pump(const Duration(seconds: 1)); 

    // Cerrar teclado
    print("Cerrando teclado...");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await shortDelay(tester); 
    print("Teclado cerrado.");

    // Seleccionar Rol
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

    // 4. Enviar formulario (Hacer clic en "Crear cuenta")
    print("Paso 4: Enviando el formulario...");
    final registerButtonFinder = find.byKey(const Key('register_button'));
    await tester.ensureVisible(registerButtonFinder);
    await shortDelay(tester);
    await tester.tap(registerButtonFinder);
    await longDelay(tester); // Espera larga para la validación en Firebase
    await tester.pump(const Duration(seconds: 2)); 
    print("Paso 4 completado: Formulario enviado.");

    // 5. Resultado Esperado (Mensaje de error según PDF)
    print("Paso 5: Verificando mensaje de error por duplicado...");
    // Buscamos el texto exacto que mencionaste en el PDF para TC-006 (Resultado esperado)
    // NOTA: El PDF dice "Este usuario ya existe", ajusta si tu app muestra algo ligeramente diferente.
    expect(find.text('Este usuario ya existe'), findsOneWidget); 
    print("Paso 5 completado: ¡Mensaje de error por duplicado encontrado!");

    // Pausa final para observar el resultado
    await tester.pump(const Duration(seconds: 3)); 
    print("Prueba TC-006 finalizada.");
  });
}
// --- FIN DE LA PRUEBA TC-006 ---