// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:provider/provider.dart';
import 'firebase_options.dart'; // Opciones de Firebase

// --- Importaciones de Estilos ---
// Importaciones robustas usando el nombre del paquete
import 'package:voleyballtraining/Views/Styles/colors/app_colors.dart';
import 'package:voleyballtraining/Views/Styles/tipography/text_styles.dart';
import 'package:voleyballtraining/Views/Styles/buttons/custom_button_styles.dart';
// --- Fin Importaciones de Estilos ---

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
// (Se asume que no requieren cambios para el tema)
import 'providers/auth_provider.dart';
import 'providers/training_plan_provider.dart';
import 'providers/user_provider.dart';

// Wrapper
import 'auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Los colores ahora se definen en AppColors.dart

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // --- Tus Providers (sin cambios respecto a tu versión) ---
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
      child: MaterialApp(
        title: 'Voley App', // Puedes ajustar el título
        debugShowCheckedModeBanner: false,

        // --- Configuración del Tema Global (Oscuro) ---
        theme: ThemeData(
          // --- Paleta de Colores ---
          brightness: Brightness.dark, // Tema Oscuro
          primaryColor: AppColors.primary, // Naranja (definido en AppColors)
          fontFamily: 'Poppins', // Fuente por defecto

          // Usar ColorScheme es más moderno y recomendado
          colorScheme: const ColorScheme(
            brightness: Brightness.dark,
            primary: AppColors.primary,          // Naranja
            onPrimary: AppColors.textLight,      // Texto claro sobre naranja
            secondary: AppColors.secondary,      // Azul
            onSecondary: AppColors.textLight,     // Texto claro sobre azul
            error: AppColors.errorDark,          // Rojo específico para modo oscuro
            onError: AppColors.textDark,         // Texto oscuro sobre color de error (para contraste)
            background: AppColors.backgroundDark,// Negro Material
            onBackground: AppColors.textLight,   // Texto claro sobre fondo oscuro
            surface: AppColors.surfaceDark,      // Gris oscuro Material
            onSurface: AppColors.textLight,      // Texto claro sobre superficie oscura
          ),
          scaffoldBackgroundColor: AppColors.backgroundDark, // Fondo por defecto oscuro

          // --- Estilos de Texto Base ---
          // Mapea tus estilos personalizados a los roles semánticos del tema
          // Aplicando el color naranja a los estilos de título/encabezado
        textTheme: TextTheme(
          // --- > Títulos/Encabezados en Naranja <---
          displayLarge: CustomTextStyles.h1White.copyWith(color: AppColors.primary),
          displayMedium: CustomTextStyles.h1White.copyWith(color: AppColors.primary),
          displaySmall: CustomTextStyles.h2White.copyWith(color: AppColors.primary),
          headlineLarge: CustomTextStyles.h2White.copyWith(color: AppColors.primary),
          headlineMedium: CustomTextStyles.h3White.copyWith(color: AppColors.primary),
          headlineSmall: CustomTextStyles.h3White.copyWith(color: AppColors.primary), // O un estilo más pequeño si lo tienes
          titleLarge: CustomTextStyles.h3White.copyWith(color: AppColors.primary),    // Títulos en AppBars (si no se sobrescribe), Dialogs

          // --- > Otros estilos mantienen color claro por defecto <---
          titleMedium: CustomTextStyles.bodyWhite, // Cuerpo blanco (para títulos medianos/pequeños)
          titleSmall: CustomTextStyles.bodyWhite,
          bodyLarge: CustomTextStyles.bodyWhite,   // Cuerpo de texto principal blanco
          bodyMedium: CustomTextStyles.bodyWhite,  // Cuerpo de texto estándar blanco
          bodySmall: CustomTextStyles.captionWhite,// Caption blanco
          labelLarge: CustomTextStyles.button,    // Texto para botones (suele ser claro por defecto)
          labelMedium: CustomTextStyles.captionWhite,
          labelSmall: CustomTextStyles.captionWhite,
        ), // <--- Eliminamos el .apply() que establecía colores globales por defecto


          // --- Estilos de Componentes por Defecto ---
          appBarTheme: AppBarTheme(
            color: AppColors.surfaceDark, // Color de fondo del AppBar (superficie oscura)
            foregroundColor: AppColors.textLight, // Color de íconos y título (texto claro)
            elevation: 0, // Menos elevación es común en tema oscuro
            titleTextStyle: CustomTextStyles.h3White, // Usar h3 blanco para títulos
            iconTheme: const IconThemeData(color: AppColors.textLight),
            actionsIconTheme: const IconThemeData(color: AppColors.textLight),
          ),

          elevatedButtonTheme: ElevatedButtonThemeData(
             // Asegúrate que CustomButtonStyles.primary() funcione bien en tema oscuro
             // (El fondo es naranja, texto claro - debería estar bien)
             style: CustomButtonStyles.primary(),
          ),

          outlinedButtonTheme: OutlinedButtonThemeData(
            // El estilo outlined por defecto usa borde y texto primario (naranja)
            // Esto debería resaltar bien sobre fondo oscuro
            style: CustomButtonStyles.outlined(),
          ),

          textButtonTheme: TextButtonThemeData(
             // El estilo text por defecto usa texto primario (naranja)
             style: CustomButtonStyles.text(),
          ),

           cardTheme: CardTheme(
            elevation: 1, // Poca o ninguna elevación en oscuro
            color: AppColors.surfaceDark, // Superficie oscura para cards
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0), // Bordes más redondeados
               side: BorderSide( // Añadir borde sutil para separar del fondo si es necesario
                 color: AppColors.divider.withOpacity(0.5),
                 width: 0.5,
               ),
            ),
          ),

          inputDecorationTheme: InputDecorationTheme(
             // Bordes usando un color visible en tema oscuro
             border: OutlineInputBorder(
               borderRadius: BorderRadius.circular(8.0),
               borderSide: BorderSide(color: AppColors.divider),
             ),
             enabledBorder: OutlineInputBorder(
               borderRadius: BorderRadius.circular(8.0),
               borderSide: BorderSide(color: AppColors.divider),
             ),
             focusedBorder: OutlineInputBorder(
               borderRadius: BorderRadius.circular(8.0),
               borderSide: BorderSide(color: AppColors.primary, width: 2.0), // Resaltar con primario
             ),
             errorBorder: OutlineInputBorder(
               borderRadius: BorderRadius.circular(8.0),
               borderSide: BorderSide(color: AppColors.errorDark, width: 1.5), // Error oscuro
             ),
             focusedErrorBorder: OutlineInputBorder(
               borderRadius: BorderRadius.circular(8.0),
               borderSide: BorderSide(color: AppColors.errorDark, width: 2.0),
             ),
             // Estilos de label/hint claros
             labelStyle: CustomTextStyles.bodyWhite.copyWith(color: AppColors.textGray), // Usar gris claro
             hintStyle: CustomTextStyles.bodyWhite.copyWith(color: AppColors.textGray),
             fillColor: AppColors.surfaceDark.withOpacity(0.5), // Un relleno sutil si se desea
             // filled: true, // Descomentar si quieres relleno
             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),

          dividerTheme: const DividerThemeData(
            color: AppColors.divider, // Divisor oscuro
            thickness: 1,
            space: 1,
          ),

           floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: AppColors.primary, // Naranja
            foregroundColor: AppColors.textLight,  // Icono blanco
          ),
          // Puedes configurar más temas aquí (Dialog, BottomNavigationBar, etc.)
           bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: AppColors.surfaceDark,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textGray,
              selectedLabelStyle: CustomTextStyles.caption.copyWith(color: AppColors.primary),
              unselectedLabelStyle: CustomTextStyles.caption.copyWith(color: AppColors.textGray),
              type: BottomNavigationBarType.fixed, // O shifting
              elevation: 2,
           )
        ),
        // --- Fin Configuración del Tema Global ---

        home: const AuthWrapper(), // Tu widget que maneja la lógica de autenticación
      ),
    );
  }
}