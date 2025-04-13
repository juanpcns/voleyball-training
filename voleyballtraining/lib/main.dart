// lib/main.dart (Completo - Versión Final con todos los Providers)

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' show User; // Importa solo User
import 'package:provider/provider.dart'; // Importa Provider

// Importa el archivo de opciones generado por FlutterFire
import 'firebase_options.dart';

// --- Importa tus Repositorios (Interfaces e Implementaciones) ---
// (Asegúrate que estas rutas sean correctas para tu proyecto)
import 'repositories/auth_repository_base.dart';
import 'repositories/firebase_auth_repository.dart';
import 'repositories/user_repository_base.dart';
import 'repositories/firestore_user_repository.dart';
import 'repositories/training_plan_repository_base.dart';
import 'repositories/firestore_training_plan_repository.dart';
import 'repositories/plan_assignment_repository_base.dart';
import 'repositories/firestore_plan_assignment_repository.dart'; // Verifica nombre de archivo

// --- Importa tus Providers (ChangeNotifiers) ---
import 'providers/auth_provider.dart';
import 'providers/training_plan_provider.dart';
import 'providers/user_provider.dart'; // Asegúrate de importar UserProvider

// --- Importa tu Wrapper de Autenticación ---
import 'auth_wrapper.dart'; // El widget que decide entre AuthView y HomeView
// --- Fin Imports ---

// Punto de entrada principal de la aplicación Dart/Flutter
void main() async {
  // Necesario para asegurar que los bindings de Flutter estén listos
  // antes de llamar a código nativo o asíncrono como Firebase.initializeApp
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase usando las opciones específicas de la plataforma
  // generadas por FlutterFire CLI.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicia la aplicación Flutter ejecutando el widget principal MyApp.
  runApp(const MyApp());
}

// Widget raíz de la aplicación.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider envuelve toda la aplicación para hacer disponibles los
    // servicios (repositorios) y estados (providers) globalmente.
    return MultiProvider(
      providers: [
        // --- 1. Proveedores de Repositorios (Capa de Datos) ---
        // Se proveen las implementaciones concretas.

        Provider<AuthRepositoryBase>( create: (_) => FirebaseAuthRepository()),
        Provider<UserRepositoryBase>( create: (_) => FirestoreUserRepository()),
        Provider<TrainingPlanRepositoryBase>( create: (_) => FirestoreTrainingPlanRepository()),
        Provider<PlanAssignmentRepositoryBase>( create: (_) => FirestorePlanAssignmentRepository()),

        // --- 2. Proveedores de Streams y Estado (Lógica de Negocio/UI) ---
        // Pueden depender de los repositorios definidos arriba.

        // StreamProvider para el estado de autenticación global (User?)
        StreamProvider<User?>(
          create: (context) => context.read<AuthRepositoryBase>().authStateChanges,
          initialData: null,
           catchError: (context, err) {
              print('>>> ERROR en StreamProvider<User?>: $err');
              return null;
           },
        ),

        // ChangeNotifierProxyProvider2 para AuthProvider
        // Depende de AuthRepositoryBase y UserRepositoryBase.
        ChangeNotifierProxyProvider2<AuthRepositoryBase, UserRepositoryBase, AuthProvider>(
          create: (context) => AuthProvider(
              context.read<AuthRepositoryBase>(),
              context.read<UserRepositoryBase>(),
          ),
          update: (context, authRepo, userRepo, previousAuthProvider) =>
              previousAuthProvider ?? AuthProvider(authRepo, userRepo),
        ),

        // ChangeNotifierProxyProvider3 para TrainingPlanProvider
        // Depende de AuthRepo(T), PlanRepo(T2), y AssignmentRepo(T3).
        ChangeNotifierProxyProvider3<AuthRepositoryBase, TrainingPlanRepositoryBase, PlanAssignmentRepositoryBase, TrainingPlanProvider>(
          create: (context) => TrainingPlanProvider(
            context.read<TrainingPlanRepositoryBase>(),    // planRepo
            context.read<AuthRepositoryBase>(),         // authRepo
            context.read<PlanAssignmentRepositoryBase>(), // assignmentRepo
          ),
          update: (context, authRepo, planRepo, assignmentRepo, previousPlanProvider) =>
              previousPlanProvider ?? TrainingPlanProvider(planRepo, authRepo, assignmentRepo),
        ),

         // ChangeNotifierProxyProvider para UserProvider
         // Depende solo de UserRepositoryBase (T).
        ChangeNotifierProxyProvider<UserRepositoryBase, UserProvider>(
           create: (context) => UserProvider(context.read<UserRepositoryBase>()),
           update: (context, userRepo, previousUserProvider) =>
              previousUserProvider ?? UserProvider(userRepo),
        ),

        // --- Otros providers globales irían aquí ---

      ],
      // El widget hijo es MaterialApp, que define la estructura visual base.
      child: MaterialApp(
        title: 'Voley App', // Título de la aplicación
        theme: ThemeData(
          // Tema visual
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        // Punto de entrada visual después de los providers.
        home: const AuthWrapper(), // AuthWrapper decide qué mostrar
        debugShowCheckedModeBanner: false, // Quita el banner "DEBUG"
      ),
    );
  }
}