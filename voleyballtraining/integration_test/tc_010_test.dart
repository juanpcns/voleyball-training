// integration_test/tc_010_test.dart

// --- INICIO DEL BLOQUE COMÚN ---
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:voleyballtraining/main.dart' as app; 
import 'package:voleyballtraining/Views/plans/create_plan_view.dart';

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


// --- INICIO DE LA PRUEBA TC-010 ---
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TC-010: Validar que un plan tenga como mínimo 2 ejercicios', (WidgetTester tester) async {
    // 1. Precondición: Iniciar sesión como Entrenador (con pausas)
    print("Paso 1: Iniciando sesión como Entrenador...");
    await loginAs(tester, 'entrenadortest@gmail.com', '12345678');
    print("Paso 1 completado: Sesión iniciada como Entrenador.");

    // 2. Acceder a "Planes" desde el menú
    print("Paso 2: Navegando a la vista de Planes...");
    await tester.tap(find.byKey(const Key('menu_plans_button')));
    await longDelay(tester); 
    await tester.pump(const Duration(seconds: 1)); 
    print("Paso 2 completado: Vista de Planes cargada.");

    // 3. Presionar botón "Crear plan" (+)
    print("Paso 3: Pulsando el botón '+' para crear un plan...");
    await tester.tap(find.byKey(const Key('plans_create_plan_fab')));
    await shortDelay(tester); // Espera para la navegación
    await tester.pump(const Duration(seconds: 2)); // Pausa para ver el formulario
    print("Paso 3 completado: Formulario de creación de plan cargado.");

    // 4. Completar campos requeridos (Nombre, Tiempo)
    print("Paso 4: Completando campos del plan...");
    await tester.enterText(find.byKey(const Key('create_plan_name_field')), 'Plan Prueba Min Ejercicios');
    await tester.pump(const Duration(seconds: 1)); 
    await tester.enterText(find.byKey(const Key('create_plan_time_field')), '45 min');
    await tester.pump(const Duration(seconds: 1)); 
    print("Paso 4 completado: Campos completados.");

    // 5. Agregar SOLO 1 ejercicio
    print("Paso 5: Agregando solo 1 ejercicio...");
    await tester.enterText(find.byKey(const Key('create_plan_exercise_input_field')), 'Primer y único ejercicio');
    await tester.pump(const Duration(seconds: 1)); 
    await tester.tap(find.byKey(const Key('create_plan_add_exercise_button')));
    await shortDelay(tester); 
    await tester.pump(const Duration(seconds: 1)); // Pausa para ver el ejercicio añadido
    print("Paso 5 completado: 1 ejercicio añadido.");

    // Cerrar teclado (importante antes de guardar)
    print("Cerrando teclado...");
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await shortDelay(tester);
    print("Teclado cerrado.");

    // 6. Pulsar "Confirmar" (Guardar Plan)
    print("Paso 6: Intentando guardar el plan con 1 ejercicio...");
    final saveButtonFinder = find.byKey(const Key('create_plan_save_button'));
    await tester.ensureVisible(saveButtonFinder); // Asegura visibilidad
    await shortDelay(tester);
    await tester.tap(saveButtonFinder);
    await shortDelay(tester); // Espera corta para que aparezca el SnackBar
    await tester.pump(const Duration(seconds: 3)); // Pausa larga para ver el SnackBar
    print("Paso 6 completado: Botón Guardar pulsado.");

    // 7. Resultado Esperado (Aparece el SnackBar de error)
    print("Paso 7: Verificando que aparezca el mensaje de error...");
    // Buscamos el texto exacto del SnackBar que debería aparecer
    expect(find.text('Debes añadir al menos 2 ejercicios.'), findsOneWidget); 
    print("Paso 7 completado: ¡Mensaje de error encontrado!");

    // (Opcional: Verificar que NO se navegó)
    expect(find.byType(CreatePlanView), findsOneWidget, reason: "No debería haber navegado fuera de CreatePlanView");

    // Pausa final para observar el resultado
    await tester.pump(const Duration(seconds: 3)); 
    print("Prueba TC-010 finalizada.");
  });
}
// --- FIN DE LA PRUEBA TC-010 ---