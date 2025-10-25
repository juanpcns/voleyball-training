// Importa los paquetes necesarios
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:voleyballtraining/Views/plans/create_plan_view.dart';
import 'package:voleyballtraining/Views/plans/training_plans_view.dart';

// Importa tu aplicación para poder iniciarla
import 'package:voleyballtraining/main.dart' as app; 
// (Asegúrate de que tu main.dart tenga 'void main() => runApp(...)')

/// FUNCIÓN DE AYUDA:
/// Un delay largo para esperar operaciones de red (Firebase).
/// pumpAndSettle() espera a que todas las animaciones y futuros terminen.
Future<void> longDelay(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(seconds: 5));
}

/// FUNCIÓN DE AYUDA:
/// Un delay corto para actualizaciones de estado locales.
Future<void> shortDelay(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}

/// FUNCIÓN DE AYUDA:
/// Inicia la app e inicia sesión con un usuario específico.
Future<void> loginAs(WidgetTester tester, String email, String password) async {
  // Inicia la app desde cero
  app.main();
  // Espera a que la app se cargue y se asiente
  await tester.pumpAndSettle();

  // Encontramos los widgets por las Keys que definimos en el Paso 1
  await tester.enterText(find.byKey(const Key('login_email_field')), email);
  await tester.enterText(find.byKey(const Key('login_password_field')), password);
  
  await tester.tap(find.byKey(const Key('login_button')));

  // Espera larga para que Firebase autentique y navegue al menú
  await longDelay(tester);

  // Verificación rápida de que el login fue exitoso y estamos en el menú
  expect(find.text('Bienvenido'), findsOneWidget);
}


void main() {
  // Inicializa el binding de Integration Test
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // --- GRUPO 1: HISTORIA DE USUARIO HU001 (Creación de Usuario) ---
  group('HU001: Creación de Usuario', () {
    
    testWidgets('TC-005: Registro exitoso', (WidgetTester tester) async {
      // 1. Iniciar App
      app.main();
      await tester.pumpAndSettle();

      // 2. Ir a la vista de registro
      await tester.tap(find.byKey(const Key('login_register_button')));
      await shortDelay(tester);

      // 3. Completar formulario con datos NUEVOS
      // Usamos DateTime para asegurar un email único en cada ejecución
      final uniqueEmail = 'jpv${DateTime.now().millisecondsSinceEpoch}@gmail.com';
      
      await tester.enterText(find.byKey(const Key('register_name_field')), 'Juan Pablo Velez Londoño');
      await tester.enterText(find.byKey(const Key('register_email_field')), uniqueEmail);
      await tester.enterText(find.byKey(const Key('register_password_field')), '1234#@');
      await tester.enterText(find.byKey(const Key('register_confirm_password_field')), '1234#@');

      // Seleccionar Rol
      await tester.tap(find.byKey(const Key('register_role_dropdown')));
      await shortDelay(tester);
      await tester.tap(find.text('Entrenador').last); // .last para evitar el del label
      await shortDelay(tester);

      // 4. Enviar formulario
      await tester.tap(find.byKey(const Key('register_button')));
      await longDelay(tester);

      // 5. Resultado Esperado (según tu PDF)
      expect(find.text('El usuario fue registrado correctamente'), findsOneWidget);
    });


    testWidgets('TC-006: Registro fallido por duplicado', (WidgetTester tester) async {
      // 1. Iniciar App
      app.main();
      await tester.pumpAndSettle();

      // 2. Ir a la vista de registro
      await tester.tap(find.byKey(const Key('login_register_button')));
      await shortDelay(tester);

      // 3. Completar formulario con email EXISTENTE (del PDF)
      await tester.enterText(find.byKey(const Key('register_name_field')), 'Usuario Duplicado');
      await tester.enterText(find.byKey(const Key('register_email_field')), 'jpvl6833@gmail.com');
      await tester.enterText(find.byKey(const Key('register_password_field')), '1234#@');
      await tester.enterText(find.byKey(const Key('register_confirm_password_field')), '1234#@');
      
      await tester.tap(find.byKey(const Key('register_role_dropdown')));
      await shortDelay(tester);
      await tester.tap(find.text('Jugador').last);
      await shortDelay(tester);

      // 4. Enviar formulario
      await tester.tap(find.byKey(const Key('register_button')));
      await longDelay(tester);

      // 5. Resultado Esperado (según tu PDF)
      expect(find.text('Este usuario ya existe'), findsOneWidget);
    });
  });


  // --- GRUPO 2: HISTORIA DE USUARIO HU009 (Asignación de Planes) ---
  group('HU009: Asignación de Planes', () {

    testWidgets('TC-001: Asignación exitosa de un plan a un jugador', (WidgetTester tester) async {
      // 1. Precondición: Iniciar sesión como Entrenador
      await loginAs(tester, 'entrenadortest@gmail.com', '12345678');

      // 2. Pasos (según PDF)
      await tester.tap(find.byKey(const Key('menu_plans_button')));
      await longDelay(tester); // Esperar que carguen los planes

      // 3. Encontrar el plan "testPlan" y pulsar su botón de asignar
      // Buscamos el ancestro (el ListTile) que contiene el texto "testPlan"
      final planTile = find.ancestor(
        of: find.text('testPlan'), 
        matching: find.byType(ListTile),
      );
      // Dentro de ese ListTile, buscamos el botón con el Tooltip
      final assignButton = find.descendant(
        of: planTile,
        matching: find.byTooltip('Asignar Plan a Jugador'),
      );

      expect(assignButton, findsOneWidget);
      await tester.tap(assignButton);
      await longDelay(tester); // Esperar que cargue la lista de jugadores

      // 4. Seleccionar al "Jugador Test" del diálogo
      await tester.tap(find.text('Jugador Test'));
      await longDelay(tester); // Esperar que se cierre el diálogo y se asigne

      // 5. Resultado Esperado (El SnackBar de éxito)
      expect(find.text('¡Plan asignado!'), findsOneWidget);
    });


    testWidgets('TC-002: Verificación del plan asignado (Jugador)', (WidgetTester tester) async {
      // 1. Precondición: Iniciar sesión como Jugador
      await loginAs(tester, 'jugadortest@gmail.com', '12345678');

      // 2. Navegar a planes
      await tester.tap(find.byKey(const Key('menu_plans_button')));
      await longDelay(tester); // Esperar que carguen las asignaciones

      // 3. Verificar que el plan "testPlan" está visible
      expect(find.text('testPlan'), findsOneWidget);

      // 4. Pulsar el botón "Aceptar" de ese plan
      final assignmentTile = find.ancestor(
        of: find.text('testPlan'),
        matching: find.byType(ListTile),
      );
      final acceptButton = find.descendant(
        of: assignmentTile,
        matching: find.byTooltip('Aceptar Plan'),
      );

      expect(acceptButton, findsOneWidget);
      await tester.tap(acceptButton);
      await longDelay(tester); // Esperar que se procese el clic

      // 5. Resultado Esperado (El estado cambia a "Aceptado")
      final statusText = find.descendant(
        of: assignmentTile,
        matching: find.text('Estado: Aceptado'),
      );

      // ESTA PRUEBA CAPTURARÁ EL BUG que mencionaste en tu PDF.
      // Si el botón no funciona, el estado no cambiará y esta prueba fallará.
      expect(statusText, findsOneWidget, reason: 'El estado del plan no cambió a Aceptado. El botón puede estar roto.');
    });
  });


  // --- GRUPO 3: HISTORIA DE USUARIO HU010 (Chats) ---
  group('HU010: Chats', () {

    testWidgets('TC-003: Verificación de la creación de chats', (WidgetTester tester) async {
      // 1. Precondición: Iniciar sesión como Jugador
      await loginAs(tester, 'jugadortest@gmail.com', '12345678');

      // 2. Ir a chats
      await tester.tap(find.byKey(const Key('menu_chats_button')));
      await longDelay(tester);

      // 3. Presionar botón de crear chat (FAB)
      await tester.tap(find.byKey(const Key('chats_new_chat_fab')));
      await longDelay(tester); // Esperar que cargue la lista de usuarios

      // 4. Verificar que el entrenador está listado
      expect(find.text('Entrenador Test'), findsOneWidget);

      // 5. Pulsar el nombre del entrenador
      await tester.tap(find.text('Entrenador Test'));
      await longDelay(tester); // Esperar que cree/navegue al chat

      // 6. Resultado Esperado (Estamos en la interfaz de chat)
      expect(find.byKey(const Key('chat_message_field')), findsOneWidget);
    });

    testWidgets('TC-004: Verificación de interacción en tiempo real', (WidgetTester tester) async {
      // 1. Precondición: Iniciar sesión como Jugador
      await loginAs(tester, 'jugadortest@gmail.com', '12345678');

      // 2. Ir a chats y abrir un chat existente
      await tester.tap(find.byKey(const Key('menu_chats_button')));
      await longDelay(tester);
      await tester.tap(find.text('Entrenador Test')); // Asume que el chat ya existe
      await longDelay(tester); // Esperar que carguen los mensajes

      // 5. Enviar un mensaje único
      final testMessage = 'Mensaje de prueba ${DateTime.now().toIso8601String()}';
      await tester.enterText(find.byKey(const Key('chat_message_field')), testMessage);
      await tester.tap(find.byKey(const Key('chat_send_button')));
      await longDelay(tester); // Dar tiempo a que se envíe y el stream lo reciba

      // 9. Resultado Esperado (El mensaje aparece en la pantalla)
      expect(find.text(testMessage), findsOneWidget);
    });
  });


  // --- GRUPO 4: HISTORIA DE USUARIO HU002 (Visualizar Usuarios) ---
  group('HU002: Visualizar Usuarios', () {

    testWidgets('TC-007: Visualización de lista de usuarios (con usuarios)', (WidgetTester tester) async {
      // 1. Precondición: Iniciar sesión como Entrenador
      await loginAs(tester, 'entrenadortest@gmail.com', '12345678');

      // 2. Navegar a Usuarios
      await tester.tap(find.byKey(const Key('menu_users_button')));
      await longDelay(tester); // Esperar que cargue de Firestore

      // 3. Resultado Esperado (Encuentra al menos un jugador)
      expect(find.text('Jugador Test'), findsOneWidget);
    });

    testWidgets('TC-008: Visualización de lista de usuarios (sin usuarios)', (WidgetTester tester) async {
      await loginAs(tester, 'entrenadorvacio@test.com', '12345678');

      // 2. Navegar a Usuarios
      await tester.tap(find.byKey(const Key('menu_users_button')));
      await longDelay(tester); 

      // 3. Resultado Esperado (Mensaje de lista vacía)
      expect(find.byKey(const Key('users_empty_list_text')), findsOneWidget);
    });
  });


  // --- GRUPO 5: HISTORIA DE USUARIO HU005 (Creación de Planes) ---
  group('HU005: Creación de Planes', () {

    testWidgets('TC-009: Validar que solo el rol "Entrenador" puede crear planes', (WidgetTester tester) async {
      // 1. Precondición: Iniciar sesión como Entrenador
      await loginAs(tester, 'entrenadortest@gmail.com', '12345678');

      // 2. Acceder a "Planes"
      await tester.tap(find.byKey(const Key('menu_plans_button')));
      await shortDelay(tester);

      // 3. Resultado Esperado (El botón "+" para crear plan es visible)
      expect(find.byKey(const Key('plans_create_plan_fab')), findsOneWidget);
    });


    testWidgets('TC-010: Validar que un plan tenga como mínimo 2 ejercicios', (WidgetTester tester) async {
      // 1. Precondición: Iniciar sesión como Entrenador
      await loginAs(tester, 'entrenadortest@gmail.com', '12345678');

      // 2. Acceder a "Planes" y presionar "Crear plan"
      await tester.tap(find.byKey(const Key('menu_plans_button')));
      await shortDelay(tester);
      await tester.tap(find.byKey(const Key('plans_create_plan_fab')));
      await shortDelay(tester);

      // 4. Completar campos
      await tester.enterText(find.byKey(const Key('create_plan_name_field')), 'Plan de Prueba (TC-010)');
      await tester.enterText(find.byKey(const Key('create_plan_time_field')), '60 min');

      // 5. Agregar SOLO 1 ejercicio
      await tester.enterText(find.byKey(const Key('create_plan_exercise_input_field')), 'Ejercicio 1');
      await tester.tap(find.byKey(const Key('create_plan_add_exercise_button')));
      await shortDelay(tester);

      // 6. Pulsar "Confirmar"
      await tester.tap(find.byKey(const Key('create_plan_save_button')));
      await shortDelay(tester); // Esperar que el SnackBar aparezca

      // 7. Resultado Esperado (Aparece el SnackBar de error)
      expect(find.text('Debes añadir al menos 2 ejercicios.'), findsOneWidget);

      // 8. (Opcional) Completar la prueba exitosamente
      await tester.enterText(find.byKey(const Key('create_plan_exercise_input_field')), 'Ejercicio 2');
      await tester.tap(find.byKey(const Key('create_plan_add_exercise_button')));
      await shortDelay(tester);
      
      await tester.tap(find.byKey(const Key('create_plan_save_button')));
      await longDelay(tester); // Esperar que se guarde y navegue hacia atrás

      // 9. Resultado Esperado (Volvimos a la lista de planes)
      expect(find.byType(CreatePlanView), findsNothing);
      expect(find.byType(TrainingPlansView), findsOneWidget);
    });
  });
}