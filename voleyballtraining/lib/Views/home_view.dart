// lib/Views/home_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;

// Modelos y Repositorios
import '../repositories/user_repository_base.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';

// Vistas de las pestañas
import 'plans/training_plans_view.dart';
import 'profile/user_profile_view.dart';
import 'users/user_list_view.dart';
// --- > IMPORTAR VISTA PARA EL FAB <---
import 'plans/create_plan_view.dart';

// --- Importaciones de Estilos ---
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
       if (mounted) {
         _loadUserProfile();
       }
    });
  }

  Future<void> _loadUserProfile() async {
     // ... (lógica de _loadUserProfile sin cambios) ...
     if (!mounted) return;
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
        await authProv.signOutUser();
      }
    }
  }

  void _onItemTapped(int index) {
     // ... (lógica de _onItemTapped sin cambios) ...
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
     final authProvider = context.read<AuthProvider>();
     final theme = Theme.of(context);
     final textTheme = theme.textTheme;
     final colorScheme = theme.colorScheme;

    // ----- UI mientras carga el perfil -----
    if (_isLoadingProfile) {
      return Scaffold(
        appBar: AppBar(title: Text('Cargando...', style: textTheme.titleLarge)),
        body: Center(child: CircularProgressIndicator(color: colorScheme.primary)),
        backgroundColor: AppColors.backgroundDark,
      );
    }

    // ----- UI si hubo error al cargar el perfil -----
    if (_loadingError != null || _currentUserModel == null) {
        return Scaffold(
          appBar: AppBar(title: Text('Error', style: textTheme.titleLarge)),
          body: Center( /* ... Contenido del error ... */ ),
          backgroundColor: AppColors.backgroundDark,
        );
    }

    // ----- UI Principal -----
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

    // Stack con fondo y Scaffold principal
    return Stack(
      children: [
        // Capa 1: Fondo
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage( image: AssetImage('assets/images/fondo.png'), fit: BoxFit.cover),
          ),
        ),
         // Capa 2: Scaffold Transparente
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(_getTitleForIndex(effectiveIndex, isCoach)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [ /* ... Botón Logout ... */
               IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Cerrar Sesión',
                onPressed: () async { await authProvider.signOutUser(); },
              ),
            ],
          ),
          body: IndexedStack(
              index: effectiveIndex,
              children: widgetOptions,
            ),
          bottomNavigationBar: BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                const BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Planes'),
                const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
                if (isCoach)
                  const BottomNavigationBarItem(icon: Icon(Icons.group_outlined), label: 'Usuarios'),
              ],
              currentIndex: effectiveIndex,
              onTap: _onItemTapped,
            ),
           // --- > FLOATING ACTION BUTTON AÑADIDO AQUÍ <---
           floatingActionButton: isCoach // Solo para entrenadores
             ? FloatingActionButton(
                 onPressed: () {
                   // Navegar a la pantalla de creación de planes
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (_) => const CreatePlanView()),
                   );
                 },
                 tooltip: 'Crear Nuevo Plan',
                 // El estilo (color naranja, icono blanco) viene del FloatingActionButtonThemeData en main.dart
                 child: const Icon(Icons.add),
               )
             : null, // No mostrar botón si no es coach
            // --- > FIN FLOATING ACTION BUTTON <---
        ),
      ],
    );
  }

  // Helper para obtener el título del AppBar
  String _getTitleForIndex(int index, bool isCoach) {
     // ... (lógica de _getTitleForIndex sin cambios) ...
      switch (index) {
      case 0: return 'Planes de Entrenamiento';
      case 1: return 'Mi Perfil';
      case 2: return 'Gestionar Usuarios';
      default: return 'Voley App';
    }
  }
}