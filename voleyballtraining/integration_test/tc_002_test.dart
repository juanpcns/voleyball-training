// integration_test/tc_002_test.dart

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
  // Usamos pumpAndSettle para esperar que las animaciones/futuros terminen.
  // Aumentamos a 6 segundos para dar más margen a la UI post-actualización.
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
  // Inicia la app desde cero
  app.main();
  // Espera a que la app se cargue y se asiente
  await tester.pumpAndSettle();
  
  // <<< PAUSA EXTRA antes de escribir email
  await tester.pump(const Duration(seconds: 2));
  
  // Encontramos los widgets por las Keys que definimos en el Paso 1
  await tester.enterText(find.byKey(const Key('login_email_field')), email);
  
  // <<< PAUSA EXTRA después de escribir email
  await tester.pump(const Duration(seconds: 2));
  
  await tester.enterText(find.byKey(const Key('login_password_field')), password);
  
  // <<< PAUSA EXTRA después de escribir contraseña
  await tester.pump(const Duration(seconds: 2));
  
  await tester.tap(find.byKey(const Key('login_button')));
  
  // Espera larga para que Firebase autentique y navegue al menú
  // NOTA: Usamos el longDelay modificado (6 segundos) aquí también.
  await longDelay(tester); 
  
  // <<< PAUSA EXTRA después del login
  await tester.pump(const Duration(seconds: 2));
  
  // Verificación rápida de que el login fue exitoso y estamos en el menú
  expect(find.text('Bienvenido'), findsOneWidget);
}
// --- FIN DEL BLOQUE COMÚN ---


// --- INICIO DE LA PRUEBA TC-002 ---
void main() {
  // Inicializa el binding de Integration Test
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Define el caso de prueba TC-002
  testWidgets('TC-002: Verificación del plan asignado (Jugador)', (WidgetTester tester) async {
    
    // 1. Precondición: Iniciar sesión como Jugador (con pausas incluidas)
    print("Paso 1: Iniciando sesión como Jugador...");
    await loginAs(tester, 'jugadortest@gmail.com', '12345678');
    print("Paso 1 completado: Sesión iniciada como Jugador.");

    // 2. Navegar a planes
    print("Paso 2: Navegando a la vista de Planes...");
    await tester.tap(find.byKey(const Key('menu_plans_button')));
    await longDelay(tester); // Esperar que carguen las asignaciones
    await tester.pump(const Duration(seconds: 2)); // Pausa extra
    print("Paso 2 completado: Lista de planes asignados cargada.");

    // 3. Verificar que AL MENOS UN plan "testPlan" está visible
    print("Paso 3: Verificando visibilidad del plan 'testPlan'...");
    expect(find.text('testPlan'), findsWidgets, reason: "Debería haber al menos un plan llamado 'testPlan'"); 
    await tester.pump(const Duration(seconds: 2)); // Pausa extra
    print("Paso 3 completado: Al menos un plan 'testPlan' encontrado.");

    // 4. Pulsar el botón "Aceptar" del *PRIMER* plan "testPlan" encontrado
    print("Paso 4: Pulsando el botón 'Aceptar' para el PRIMER 'testPlan'...");
    
    // Encuentra el ListTile ancestro del *primer* widget con texto "testPlan"
    final firstAssignmentTile = find.ancestor(
      of: find.text('testPlan').first, 
      matching: find.byType(ListTile),
    );
    // Dentro de ese ListTile, encuentra el botón con el tooltip 'Aceptar Plan'
    final acceptButton = find.descendant(
      of: firstAssignmentTile,
      matching: find.byTooltip('Aceptar Plan'),
    );

    // Asegúrate de que el botón exista antes de intentar pulsarlo
    expect(acceptButton, findsOneWidget);
    await tester.tap(acceptButton);
    
    // Espera larga para que se procese la actualización en Firebase y la UI
    await longDelay(tester); // Usa el longDelay modificado (6 segundos)
    await tester.pump(const Duration(seconds: 2)); // Pausa extra adicional
    print("Paso 4 completado: Botón 'Aceptar' del primer 'testPlan' pulsado y UI debería estar actualizada.");

    // 5. Resultado Esperado (El estado de ESE plan CONTIENE "Aceptado")
    print("Paso 5: Verificando que el estado del PRIMER plan contenga 'Aceptado'...");
    
    // Busca un widget Text DENTRO del ListTile específico que CONTENGA 'Aceptado'
    final statusTextFinder = find.descendant(
      of: firstAssignmentTile, 
      matching: find.textContaining('Aceptado', findRichText: true), 
    );

    // Verifica que se encuentre al menos un widget de texto con "Aceptado" dentro del ListTile
    expect(statusTextFinder, findsAtLeastNWidgets(1), reason: 'El estado del plan no se actualizó visualmente a "Aceptado". El botón podría no haber refrescado la UI correctamente.');
    print("Paso 5 completado: ¡El estado visual del primer plan contiene 'Aceptado'!");

    // Pausa final para observar el resultado
    await tester.pump(const Duration(seconds: 3)); 
    print("Prueba TC-002 finalizada.");
  });
}
// --- FIN DE LA PRUEBA TC-002 ---