import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:provider/provider.dart';
import 'package:voleyballtraining/providers/chat_provider.dart';
import 'firebase_options.dart'; // Opciones de Firebase

// --- Importaciones de Estilos ---
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
import 'providers/auth_provider.dart';
import 'providers/training_plan_provider.dart';
import 'providers/user_provider.dart';

// Wrapper
import 'auth_wrapper.dart';

// Menú principal
import 'Views/menu/main_menu_view.dart'; // <--- IMPORTANTE

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepositoryBase>(create: (_) => FirebaseAuthRepository()),
        Provider<UserRepositoryBase>(create: (_) => FirestoreUserRepository()),
        Provider<TrainingPlanRepositoryBase>(create: (_) => FirestoreTrainingPlanRepository()),
        Provider<PlanAssignmentRepositoryBase>(create: (_) => FirestorePlanAssignmentRepository()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        StreamProvider<User?>(
          create: (context) => context.read<AuthRepositoryBase>().authStateChanges,
          initialData: null,
          catchError: (context, err) {
            print('>>> ERROR en StreamProvider<User?>: $err');
            return null;
          },
        ),
        ChangeNotifierProxyProvider2<AuthRepositoryBase, UserRepositoryBase, AuthProvider>(
          create: (context) => AuthProvider(
            context.read<AuthRepositoryBase>(),
            context.read<UserRepositoryBase>(),
          ),
          update: (context, authRepo, userRepo, previous) =>
              previous ?? AuthProvider(authRepo, userRepo),
        ),
        ChangeNotifierProxyProvider3<AuthRepositoryBase, TrainingPlanRepositoryBase, PlanAssignmentRepositoryBase, TrainingPlanProvider>(
          create: (context) => TrainingPlanProvider(
            context.read<TrainingPlanRepositoryBase>(),
            context.read<AuthRepositoryBase>(),
            context.read<PlanAssignmentRepositoryBase>(),
          ),
          update: (context, authRepo, planRepo, assignRepo, previous) =>
              previous ?? TrainingPlanProvider(planRepo, authRepo, assignRepo),
        ),
        ChangeNotifierProxyProvider<UserRepositoryBase, UserProvider>(
          create: (context) => UserProvider(context.read<UserRepositoryBase>()),
          update: (context, userRepo, previous) => previous ?? UserProvider(userRepo),
        ),
      ],
      child: MaterialApp(
        title: 'Voley App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: AppColors.primary,
          fontFamily: 'Poppins',
          colorScheme: const ColorScheme(
            brightness: Brightness.dark,
            primary: AppColors.primary,
            onPrimary: AppColors.textLight,
            secondary: AppColors.secondary,
            onSecondary: AppColors.textLight,
            error: AppColors.errorDark,
            onError: AppColors.textDark,
            background: AppColors.backgroundDark,
            onBackground: AppColors.textLight,
            surface: AppColors.surfaceDark,
            onSurface: AppColors.textLight,
          ),
          scaffoldBackgroundColor: AppColors.backgroundDark,
          textTheme: TextTheme(
            displayLarge: CustomTextStyles.h1White.copyWith(color: AppColors.primary),
            displayMedium: CustomTextStyles.h1White.copyWith(color: AppColors.primary),
            displaySmall: CustomTextStyles.h2White.copyWith(color: AppColors.primary),
            headlineLarge: CustomTextStyles.h2White.copyWith(color: AppColors.primary),
            headlineMedium: CustomTextStyles.h3White.copyWith(color: AppColors.primary),
            headlineSmall: CustomTextStyles.h3White.copyWith(color: AppColors.primary),
            titleLarge: CustomTextStyles.h3White.copyWith(color: AppColors.primary),
            titleMedium: CustomTextStyles.bodyWhite,
            titleSmall: CustomTextStyles.bodyWhite,
            bodyLarge: CustomTextStyles.bodyWhite,
            bodyMedium: CustomTextStyles.bodyWhite,
            bodySmall: CustomTextStyles.captionWhite,
            labelLarge: CustomTextStyles.button,
            labelMedium: CustomTextStyles.captionWhite,
            labelSmall: CustomTextStyles.captionWhite,
          ),
          appBarTheme: AppBarTheme(
            color: AppColors.surfaceDark,
            foregroundColor: AppColors.textLight,
            elevation: 0,
            titleTextStyle: CustomTextStyles.h3White,
            iconTheme: const IconThemeData(color: AppColors.textLight),
            actionsIconTheme: const IconThemeData(color: AppColors.textLight),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: CustomButtonStyles.primary(),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: CustomButtonStyles.outlined(),
          ),
          textButtonTheme: TextButtonThemeData(
            style: CustomButtonStyles.text(),
          ),
          cardTheme: CardTheme(
            elevation: 1,
            color: AppColors.surfaceDark,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(
                color: AppColors.divider.withOpacity(0.5),
                width: 0.5,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
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
              borderSide: BorderSide(color: AppColors.primary, width: 2.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: AppColors.errorDark, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: AppColors.errorDark, width: 2.0),
            ),
            labelStyle: CustomTextStyles.bodyWhite.copyWith(color: AppColors.textGray),
            hintStyle: CustomTextStyles.bodyWhite.copyWith(color: AppColors.textGray),
            fillColor: AppColors.surfaceDark.withOpacity(0.5),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          dividerTheme: const DividerThemeData(
            color: AppColors.divider,
            thickness: 1,
            space: 1,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textLight,
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: AppColors.surfaceDark,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textGray,
            selectedLabelStyle: CustomTextStyles.caption.copyWith(color: AppColors.primary),
            unselectedLabelStyle: CustomTextStyles.caption.copyWith(color: AppColors.textGray),
            type: BottomNavigationBarType.fixed,
            elevation: 2,
          ),
        ),
        routes: {
          '/menu': (context) => MainMenuView(), // <--- Ruta agregada
        },
        home: const AuthWrapper(), // Tu widget que maneja la lógica de autenticación
      ),
    );
  }
}
