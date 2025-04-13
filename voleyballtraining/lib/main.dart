// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' show User; // Importa solo User
import 'package:provider/provider.dart'; // Importa Provider

// Importa el archivo de opciones generado por FlutterFire
import 'firebase_options.dart';

// --- Asegúrate que estas rutas sean correctas según tu estructura ---
import 'repositories/auth_repository_base.dart';
import 'repositories/firebase_auth_repository.dart';
import 'repositories/user_repository_base.dart';
import 'repositories/firestore_user_repository.dart';
import 'Providers/auth_provider.dart';
import 'auth_wrapper.dart'; // Importa el AuthWrapper que creamos
// --- Fin de Imports ---

void main() async {
  // Necesario para asegurar que Flutter esté listo antes de Firebase.
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa Firebase usando las opciones generadas por FlutterFire.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Ejecuta la aplicación principal.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider para inyectar/proporcionar nuestros servicios y estados.
    return MultiProvider(
      providers: [
        // 1. Proporciona la implementación del AuthRepository.
        Provider<AuthRepositoryBase>(
          create: (_) => FirebaseAuthRepository(),
        ),
        // 2. Proporciona la implementación del UserRepository.
        Provider<UserRepositoryBase>(
          create: (_) => FirestoreUserRepository(),
        ),
        // 3. StreamProvider para el estado de autenticación (User?).
        //    Lee AuthRepositoryBase para obtener el stream.
        StreamProvider<User?>.value(
          value: context.read<AuthRepositoryBase>().authStateChanges,
          initialData: null, // Estado inicial mientras carga.
           catchError: (_, err) { // Manejo básico de errores en el stream.
              print('Error en authStateChanges StreamProvider: $err');
              return null;
           },
        ),
        // 4. ChangeNotifierProvider para el AuthProvider (ViewModel).
        //    Lee ambos repositorios para pasarlos a su constructor.
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            context.read<AuthRepositoryBase>(),
            context.read<UserRepositoryBase>(),
          ),
        ),
      ],
      // El hijo del MultiProvider es la MaterialApp.
      child: MaterialApp(
        title: 'Voley App', // Puedes cambiar el título.
        theme: ThemeData(
          // Define tu tema aquí.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), // Ejemplo
          useMaterial3: true,
        ),
        // El punto de entrada visual ahora es AuthWrapper.
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false, // Quita el banner "Debug".
      ),
    );
  }
}
