// lib/main.dart (Versión Final con Todos los Providers Correctos)

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' show User; // Importa solo User
import 'package:provider/provider.dart'; // Importa Provider

// Importa el archivo de opciones generado por FlutterFire
import 'firebase_options.dart';

// --- Importa tus clases ---
// (Asegúrate que estas rutas sean correctas para tu proyecto)
import 'repositories/auth_repository_base.dart';
import 'repositories/firebase_auth_repository.dart';
import 'repositories/user_repository_base.dart';
import 'repositories/firestore_user_repository.dart';
import 'providers/auth_provider.dart';
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

        // 1. Repositorio de Autenticación (Base)
        Provider<AuthRepositoryBase>(
          create: (_) => FirebaseAuthRepository(),
        ),

        // 2. Repositorio de Datos de Usuario (Base)
        Provider<UserRepositoryBase>(
          create: (_) => FirestoreUserRepository(),
        ),

        // --- Proveedores de Estado y Streams ---

        // 3. ProxyProvider para el Stream de Estado de Autenticación (User?)
        //    Depende de AuthRepositoryBase. Provee el Stream<User?>.
        ProxyProvider<AuthRepositoryBase, Stream<User?>>(
          update: (context, authRepo, previousStream) => authRepo.authStateChanges,
        ),

        // 4. ChangeNotifierProxyProvider2 para el AuthProvider (ViewModel)
        //    Depende de AuthRepositoryBase y UserRepositoryBase. Provee AuthProvider.
        ChangeNotifierProxyProvider2<AuthRepositoryBase, UserRepositoryBase, AuthProvider>(
          // Crea la instancia inicial leyendo las dependencias ya provistas.
          create: (context) => AuthProvider(
              context.read<AuthRepositoryBase>(),
              context.read<UserRepositoryBase>(),
          ),
          // Actualiza (o simplemente devuelve la existente) cuando las dependencias cambian.
          update: (context, authRepo, userRepo, previousAuthProvider) =>
              previousAuthProvider ?? AuthProvider(authRepo, userRepo),
        ),

        // --- Otros providers globales irían aquí ---
      ],

      // El hijo del MultiProvider es MaterialApp.
      child: MaterialApp(
        title: 'Voley App', // Título de la aplicación
        theme: ThemeData(
          // Tema visual
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), // Cambia el color si quieres
          useMaterial3: true,
        ),
        // El widget 'home' es el AuthWrapper, que manejará la navegación inicial.
        home: const AuthWrapper(),
        // Quita el banner "DEBUG".
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}