// lib/main.dart (CON ThemeData PERSONALIZADO APLICADO)

// --- Importaciones ---
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:provider/provider.dart';
import 'firebase_options.dart'; // Opciones de Firebase

// Repositorios
import 'repositories/auth_repository_base.dart';
import 'repositories/firebase_auth_repository.dart';
import 'repositories/user_repository_base.dart';
import 'repositories/firestore_user_repository.dart';
import 'repositories/training_plan_repository_base.dart';
import 'repositories/firestore_training_plan_repository.dart';
import 'repositories/plan_assignment_repository_base.dart';
import 'repositories/firestore_plan_assignment_repository.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/training_plan_provider.dart';
import 'providers/user_provider.dart';

// Wrapper y Estilos
import 'auth_wrapper.dart';
// IMPORTANTE: Asegúrate que la ruta a TextStyles sea correcta
import 'views/Styles/tipography/text_styles.dart'; // Importa tus estilos

// --- Función main (sin cambios) ---
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

// --- Widget Raíz MyApp (MODIFICADO con ThemeData) ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Define los colores principales de tu diseño para usarlos en el tema
  static const Color primaryColor = Color(0xFFFF8C00); // Naranja principal
  static const Color secondaryColor = Color(0xFF007BFF); // Azul secundario
  static const Color darkBackground = Colors.black;
  // Usamos el gris oscuro semi-transparente de ButtonDefault como superficie base
  static const Color darkSurface = Color.fromRGBO(30, 30, 30, 0.9);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // --- Tus Providers (sin cambios) ---
        Provider<AuthRepositoryBase>( create: (_) => FirebaseAuthRepository()),
        Provider<UserRepositoryBase>( create: (_) => FirestoreUserRepository()),
        Provider<TrainingPlanRepositoryBase>( create: (_) => FirestoreTrainingPlanRepository()),
        Provider<PlanAssignmentRepositoryBase>( create: (_) => FirestorePlanAssignmentRepository()),
        StreamProvider<User?>(
          create: (context) => context.read<AuthRepositoryBase>().authStateChanges,
          initialData: null,
           catchError: (context, err) { print('>>> ERROR en StreamProvider<User?>: $err'); return null; },
        ),
        ChangeNotifierProxyProvider2<AuthRepositoryBase, UserRepositoryBase, AuthProvider>(
          create: (context) => AuthProvider( context.read<AuthRepositoryBase>(), context.read<UserRepositoryBase>(), ),
          update: (context, authRepo, userRepo, previous) => previous ?? AuthProvider(authRepo, userRepo),
        ),
        ChangeNotifierProxyProvider3<AuthRepositoryBase, TrainingPlanRepositoryBase, PlanAssignmentRepositoryBase, TrainingPlanProvider>(
          create: (context) => TrainingPlanProvider( context.read<TrainingPlanRepositoryBase>(), context.read<AuthRepositoryBase>(), context.read<PlanAssignmentRepositoryBase>(), ),
          update: (context, authRepo, planRepo, assignRepo, previous) => previous ?? TrainingPlanProvider(planRepo, authRepo, assignRepo),
        ),
        ChangeNotifierProxyProvider<UserRepositoryBase, UserProvider>(
          create: (context) => UserProvider(context.read<UserRepositoryBase>()),
          update: (context, userRepo, previous) => previous ?? UserProvider(userRepo),
        ),
      ],
      // --- MaterialApp con ThemeData personalizado ---
      child: MaterialApp(
        title: 'Voley App',
        theme: ThemeData(
          // *** ThemeData Personalizado ***
          brightness: Brightness.dark, // Tema oscuro
          fontFamily: 'Poppins',      // Fuente por defecto

          // Esquema de colores principal
          colorScheme: const ColorScheme(
            brightness: Brightness.dark,
            primary: primaryColor,         // Naranja
            onPrimary: Colors.white,       // Texto sobre Naranja
            secondary: secondaryColor,       // Azul
            onSecondary: Colors.white,     // Texto sobre Azul
            error: Colors.redAccent,       // Rojo para errores
            onError: Colors.white,         // Texto sobre Error
            surface: darkSurface,          // Superficies (cards, dialogs, etc.)
            onSurface: Colors.white,       // Texto sobre Superficies
            background: darkBackground,      // Fondo de Scaffolds (negro)
            onBackground: Colors.white,    // Texto sobre Fondo
          ),

          // Estilos de texto base derivados de TextStyles
          textTheme: TextTheme(
            bodyLarge: TextStyles.defaultText.copyWith(fontSize: 14),
            bodyMedium: TextStyles.defaultText, // Base (size 12)
            // Define otros estilos base si quieres (opcional, puedes usar TextStyles directamente)
            titleLarge: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            titleMedium: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white70),
            titleSmall: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white70),
            labelLarge: TextStyles.button, // Para botones
            bodySmall: TextStyles.defaultText.copyWith(fontSize: 11, color: Colors.white70),
          ),

          // Estilo para FloatingActionButton
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: primaryColor, // Naranja
            foregroundColor: Colors.white,  // Icono blanco
          ),

           // (Opcional) Puedes añadir más personalizaciones aquí:
           scaffoldBackgroundColor: darkBackground, // Asegura fondo negro por defecto
           // appBarTheme: AppBarTheme( // Si usaras AppBar estándar
           //   backgroundColor: Colors.transparent, // Ejemplo: AppBar transparente
           //   elevation: 0,
           //   titleTextStyle: TextStyles.button.copyWith(fontSize: 18), // Título con estilo botón
           //   iconTheme: IconThemeData(color: Colors.white), // Iconos blancos
           // ),
           // cardTheme: CardTheme( // Estilo base para Cards si los usas
           //    color: darkSurface.withOpacity(0.8), // Ejemplo: superficie oscura
           //    elevation: 0,
           //    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
           // ),

        ),
        home: const AuthWrapper(), // Punto de entrada
        debugShowCheckedModeBanner: false, // Quitar banner DEBUG
      ),
    );
  }
}