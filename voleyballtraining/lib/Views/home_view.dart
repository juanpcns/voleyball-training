// lib/Views/home_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:voleyballtraining/Views/Styles/buttons/custom_button_styles.dart';

// Modelos y Repositorios (Asegúrate que las rutas sean correctas)
import '../repositories/user_repository_base.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart'; // Para el botón de signOut

// Vistas de las pestañas (Asegúrate que las rutas sean correctas)
import 'plans/training_plans_view.dart';
import 'profile/user_profile_view.dart';
import 'users/user_list_view.dart';

// --- > Importaciones de Estilos <---
import 'package:voleyballtraining/Views/Styles/colors/app_colors.dart';


class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  UserModel? _currentUserModel;
  bool _isLoadingProfile = true;
  String? _loadingError;

  @override
  void initState() {
    super.initState();
    // Usamos addPostFrameCallback para asegurar que el context esté disponible para Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
       if (mounted) { // Comprobar si sigue montado
         _loadUserProfile();
       }
    });
  }

  Future<void> _loadUserProfile() async {
    if (!mounted) return;

    // Asegurar que el Provider se accede después del primer frame
    final user = Provider.of<User?>(context, listen: false);
    final userRepo = Provider.of<UserRepositoryBase>(context, listen: false);
    final authProv = Provider.of<AuthProvider>(context, listen: false);

    print("--- HomeView _loadUserProfile: User UID from Provider: ${user?.uid} ---");

    if (user != null) {
      try {
        print("--- HomeView _loadUserProfile: Calling getUserProfile for UID: ${user.uid} ---");
        final profile = await userRepo.getUserProfile(user.uid);

        if (mounted) {
          setState(() {
            _currentUserModel = profile;
            _isLoadingProfile = false;
            _loadingError = profile == null ? "No se encontró el perfil del usuario." : null;
             print("--- HomeView _loadUserProfile: Profile loaded. Role: ${_currentUserModel?.role}. Error: $_loadingError ---");
          });
        }
      } catch (e) {
         print("--- HomeView _loadUserProfile: ERROR fetching profile - $e ---");
         if (mounted) {
           setState(() {
             _isLoadingProfile = false;
             _loadingError = "Error al cargar el perfil: ${e.toString()}";
           });
         }
      }
    } else {
       print("--- HomeView _loadUserProfile: ERROR - User from Provider is null! ---");
       if (mounted) {
        setState(() {
          _isLoadingProfile = false;
          _loadingError = "Usuario no autenticado.";
        });
        // Forzar cierre de sesión si el user de provider es null inesperadamente
        await authProv.signOutUser();
      }
    }
  }


  void _onItemTapped(int index) {
     final bool isCoach = _currentUserModel?.role == 'Entrenador';
     final int maxIndex = isCoach ? 2 : 1;
     if (index >= 0 && index <= maxIndex) {
       print("--- _onItemTapped: Tapped index: $index ---");
       setState(() { _selectedIndex = index; });
     } else {
       print("--- _onItemTapped: WARN - Tapped index $index is out of bounds ---");
     }
  }

  @override
  Widget build(BuildContext context) {
     print("--- Construyendo HomeView. Índice: $_selectedIndex. Cargando: $_isLoadingProfile. Error: $_loadingError ---");
     final authProvider = context.read<AuthProvider>(); // Para logout
     // Obtener tema para estilos
     final theme = Theme.of(context);
     final textTheme = theme.textTheme;

    // ----- UI mientras carga el perfil -----
    if (_isLoadingProfile) {
      // Usamos un Scaffold simple, sin fondo de imagen aún
      return Scaffold(
        // Usar AppBarTheme del tema
        appBar: AppBar(title: Text('Cargando...', style: textTheme.titleLarge)), // Título naranja
        body: Center(child: CircularProgressIndicator(
          // Usar color primario del tema
          color: theme.colorScheme.primary,
        )),
        backgroundColor: AppColors.backgroundDark, // Fondo oscuro sólido
      );
    }

    // ----- UI si hubo error al cargar el perfil o no se encontró -----
    if (_loadingError != null || _currentUserModel == null) {
        return Scaffold(
          // Usar AppBarTheme del tema
          appBar: AppBar(title: Text('Error', style: textTheme.titleLarge)), // Título naranja
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Usar TextTheme para el mensaje de error
                  Text(
                    _loadingError ?? 'No se pudo cargar la información del usuario.',
                    style: textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error), // Texto en color de error
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                   // Usar ElevatedButton con estilo primario
                  ElevatedButton(
                    style: CustomButtonStyles.primary(), // <-- Aplicar estilo
                    onPressed: () async => await authProvider.signOutUser(),
                    child: const Text('Cerrar Sesión'),
                  )
                ],
              ),
            ),
          ),
          backgroundColor: AppColors.backgroundDark, // Fondo oscuro sólido
        );
    }

    // ----- UI Principal (Perfil cargado correctamente) -----
    final bool isCoach = _currentUserModel!.role == 'Entrenador';
     print("--- HomeView Build: Perfil Cargado. Rol: ${_currentUserModel!.role}. Mostrando UI con índice: $_selectedIndex ---");

    final List<Widget> widgetOptions = [
      TrainingPlansView(userModel: _currentUserModel!),
      UserProfileView(userProfile: _currentUserModel!),
      if (isCoach) UserListView(userModel: _currentUserModel!),
    ];

    final int effectiveIndex = (_selectedIndex >= 0 && _selectedIndex < widgetOptions.length) ? _selectedIndex : 0;
    if (_selectedIndex != effectiveIndex) {
        print("--- HomeView Build: WARN - _selectedIndex ($_selectedIndex) fuera de rango. Usando índice 0. ---");
    }

    // --- > Aplicamos el fondo con Stack aquí <---
    return Stack(
      children: [
        // --- Capa 1: Imagen de Fondo ---
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/fondo.png'), // <-- Imagen de fondo
              fit: BoxFit.cover,
            ),
          ),
        ),
         // --- Capa 2: Scaffold Transparente con Contenido ---
        Scaffold(
          backgroundColor: Colors.transparent, // <-- Scaffold transparente
          appBar: AppBar(
             // El título dinámico hereda el color naranja del textTheme.titleLarge
            title: Text(_getTitleForIndex(effectiveIndex, isCoach)),
             // El fondo, elevación, color de iconos vienen del AppBarTheme
            backgroundColor: Colors.transparent, // <-- AppBar transparente
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout), // Icono hereda color de actionsIconTheme
                tooltip: 'Cerrar Sesión',
                onPressed: () async {
                  await authProvider.signOutUser();
                },
              ),
            ],
          ),
          body: IndexedStack( // Mantiene el estado de las pestañas
              index: effectiveIndex,
              children: widgetOptions,
            ),
          bottomNavigationBar: BottomNavigationBar( // Estilos vienen de BottomNavigationBarThemeData
              items: <BottomNavigationBarItem>[
                const BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Planes'),
                const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
                if (isCoach)
                  const BottomNavigationBarItem(icon: Icon(Icons.group_outlined), label: 'Usuarios'),
              ],
              currentIndex: effectiveIndex,
              onTap: _onItemTapped,
              // Los colores/estilos selected/unselected vienen del tema global
            ),
        ),
      ],
    );
  }

  // Helper para obtener el título del AppBar basado en la pestaña activa
  String _getTitleForIndex(int index, bool isCoach) {
    switch (index) {
      case 0: return 'Planes de Entrenamiento';
      case 1: return 'Mi Perfil';
      case 2: // Solo Coach
          return 'Gestionar Usuarios';
      default: return 'Voley App'; // Fallback
    }
  }
}