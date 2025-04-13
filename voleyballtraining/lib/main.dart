// lib/main.dart (Versión Completa - Prueba D: Usando StreamProvider con create)

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

        // 1. Repositorio de Autenticación
        Provider<AuthRepositoryBase>(
          create: (_) => FirebaseAuthRepository(),
        ),

        // 2. Repositorio de Datos de Usuario (Firestore)
        Provider<UserRepositoryBase>(
          create: (_) => FirestoreUserRepository(),
        ),

        // --- Proveedores de Estado y Streams ---

        // 3. StreamProvider para el estado de autenticación (User?)
        //    *** Usando el constructor 'create' ***
        //    El 'context' que recibe 'create' puede leer de forma segura
        //    los providers definidos anteriormente en esta lista.
        StreamProvider<User?>(
          create: (context) {
             print("--- Creando StreamProvider<User?> usando create ---");
             // Leemos el repositorio que ya fue provisto arriba
             final stream = context.read<AuthRepositoryBase>().authStateChanges;

             // (Opcional pero útil para depurar) Escuchamos el stream base
             stream.listen((user) {
               print(">>> DEBUG main.dart (StreamProvider): Stream emitió -> UID: ${user?.uid ?? 'NULL'} <<<");
             });
             return stream; // Devolvemos el stream para que StreamProvider lo maneje
          },
          // Valor inicial mientras el stream emite el primer valor
          initialData: null,
          // Manejo de errores que puedan ocurrir en el stream
           catchError: (context, err) {
              print('>>> ERROR en StreamProvider<User?>: $err');
              // Si hay error en el stream de auth, asumimos que no hay usuario
              return null;
           },
        ),

        // 4. ChangeNotifierProxyProvider2 para el AuthProvider (ViewModel)
        //    (Se mantiene igual que en la corrección anterior)
        ChangeNotifierProxyProvider2<AuthRepositoryBase, UserRepositoryBase, AuthProvider>(
          create: (context) => AuthProvider(
              context.read<AuthRepositoryBase>(),
              context.read<UserRepositoryBase>(),
          ),
          update: (context, authRepo, userRepo, previousAuthProvider) =>
              previousAuthProvider ?? AuthProvider(authRepo, userRepo),
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
        // AuthWrapper sigue siendo el punto de entrada visual.
        // Debería reaccionar a los cambios emitidos por el StreamProvider<User?>.
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}