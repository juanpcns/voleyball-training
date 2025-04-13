// lib/main.dart (Versión Completa con todos los Providers)

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
import 'repositories/training_plan_repository_base.dart'; // Importar interfaz
import 'repositories/firestore_training_plan_repository.dart'; // Importar implementación

// --- Importa tus Providers (ChangeNotifiers) ---
import 'providers/auth_provider.dart';
import 'providers/training_plan_provider.dart'; // Importar nuevo provider

// --- Importa tu Wrapper de Autenticación ---
import 'auth_wrapper.dart'; // El widget que decide entre AuthView y HomeView
// --- Fin Imports ---

void main() async {
  // Necesario para asegurar que Flutter esté listo antes de usar plugins
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Inicia la aplicación
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider para inyectar/proporcionar los servicios y estados.
    return MultiProvider(
      providers: [
        // --- Proveedores de Servicios (Repositorios) ---
        // Se proveen las implementaciones, pero se tipan con la interfaz.

        // 1. Repositorio de Autenticación
        Provider<AuthRepositoryBase>(
          create: (_) => FirebaseAuthRepository(),
        ),

        // 2. Repositorio de Datos de Usuario (Firestore)
        Provider<UserRepositoryBase>(
          create: (_) => FirestoreUserRepository(),
        ),

        // 3. Repositorio de Planes de Entrenamiento (Firestore)
        Provider<TrainingPlanRepositoryBase>(
          create: (_) => FirestoreTrainingPlanRepository(),
        ),


        // --- Proveedores de Estado y Streams ---

        // 4. StreamProvider para el estado de autenticación (User?)
        //    Usa 'create' para leer de forma segura el AuthRepositoryBase.
        StreamProvider<User?>(
          create: (context) => context.read<AuthRepositoryBase>().authStateChanges,
          initialData: null, // Valor inicial mientras conecta
           catchError: (context, err) { // Manejo de errores
              print('>>> ERROR en StreamProvider<User?>: $err');
              return null;
           },
        ),

        // 5. ChangeNotifierProxyProvider2 para el AuthProvider (ViewModel de Auth)
        //    Depende de AuthRepositoryBase y UserRepositoryBase.
        ChangeNotifierProxyProvider2<AuthRepositoryBase, UserRepositoryBase, AuthProvider>(
          create: (context) => AuthProvider(
              context.read<AuthRepositoryBase>(),
              context.read<UserRepositoryBase>(),
          ),
          update: (context, authRepo, userRepo, previousAuthProvider) =>
              previousAuthProvider ?? AuthProvider(authRepo, userRepo),
        ),

        // 6. ChangeNotifierProxyProvider2 para el TrainingPlanProvider
        //    Depende de AuthRepositoryBase y TrainingPlanRepositoryBase.
        ChangeNotifierProxyProvider2<AuthRepositoryBase, TrainingPlanRepositoryBase, TrainingPlanProvider>(
           // El orden en create debe coincidir con el constructor de TrainingPlanProvider
           create: (context) => TrainingPlanProvider(
             context.read<TrainingPlanRepositoryBase>(), // planRepo
             context.read<AuthRepositoryBase>(),      // authRepo
           ),
           // El orden en update es (context, T dependency1, T2 dependency2, R? previous)
           update: (context, authRepo, planRepo, previousPlanProvider) =>
               previousPlanProvider ?? TrainingPlanProvider(planRepo, authRepo),
        ),

        // --- Otros providers globales irían aquí ---

      ],
      // El widget hijo principal del MultiProvider es MaterialApp.
      child: MaterialApp(
        title: 'Voley App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        // AuthWrapper decide qué mostrar basado en el StreamProvider<User?>
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}