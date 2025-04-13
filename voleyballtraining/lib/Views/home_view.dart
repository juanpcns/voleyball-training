// lib/views/home_view.dart (COMPLETO Y ACTUALIZADO)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;

// Importa los repositorios y modelos necesarios (ajusta rutas)
import '../repositories/user_repository_base.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart'; // Para el botón de signOut

// Importa las vistas de las pestañas (ajusta rutas)
import 'plans/training_plans_view.dart';
import 'profile/user_profile_view.dart';
import 'users/user_list_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0; // Índice de la pestaña activa
  UserModel? _currentUserModel; // Datos del usuario logueado
  bool _isLoadingProfile = true; // Estado de carga inicial del perfil
  String? _loadingError; // Mensaje de error si falla la carga

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // Cargar perfil al iniciar
  }

  /// Carga el perfil del usuario desde Firestore usando el UserRepository
  Future<void> _loadUserProfile() async {
    if (!mounted) return; // No hacer nada si el widget ya no existe

    final user = Provider.of<User?>(context, listen: false); // Obtener usuario de Auth
    print("--- HomeView _loadUserProfile: User UID from Provider: ${user?.uid} ---");

    if (user != null) { // Si hay usuario logueado en Auth...
      try {
        final userRepo = Provider.of<UserRepositoryBase>(context, listen: false);
        print("--- HomeView _loadUserProfile: Calling getUserProfile for UID: ${user.uid} ---");
        final profile = await userRepo.getUserProfile(user.uid); // ...buscar perfil en Firestore

        if (mounted) { // Comprobar si sigue montado antes de actualizar estado
          setState(() {
            _currentUserModel = profile; // Guardar perfil
            _isLoadingProfile = false; // Terminar carga
            // Si el perfil vino null de Firestore, es un tipo de error
            _loadingError = profile == null ? "No se encontró el perfil de usuario en la base de datos." : null;
            print("--- HomeView _loadUserProfile: Profile loaded. Role: ${_currentUserModel?.role}. Error: $_loadingError ---");
          });
        }
      } catch (e) { // Capturar error al buscar perfil
         print("--- HomeView _loadUserProfile: ERROR fetching profile - $e ---");
         if (mounted) {
           setState(() {
             _isLoadingProfile = false;
             _loadingError = "Error al cargar el perfil: ${e.toString()}";
           });
         }
      }
    } else { // Si no hay usuario de Auth (raro si AuthWrapper funciona)
      print("--- HomeView _loadUserProfile: ERROR - User from Provider is null! ---");
      if (mounted) {
         setState(() {
           _isLoadingProfile = false;
           _loadingError = "Usuario no autenticado.";
         });
         // Forzar cierre de sesión
         WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Provider.of<AuthProvider>(context, listen: false).signOutUser();
            }
         });
      }
    }
  }


  /// Cambia el índice de la pestaña seleccionada al tocar un item de la barra inferior
  void _onItemTapped(int index) {
    // Validar que el índice exista antes de cambiar (por si acaso)
     final bool isCoach = _currentUserModel?.role == 'Entrenador';
     final int maxIndex = isCoach ? 2 : 1; // Coach tiene 3 pestañas (0,1,2), Jugador 2 (0,1)
     if (index >= 0 && index <= maxIndex) {
       print("--- _onItemTapped: Tapped index: $index ---");
       setState(() {
         _selectedIndex = index;
       });
     } else {
        print("--- _onItemTapped: WARN - Tapped index $index is out of bounds ---");
     }
  }

  @override
  Widget build(BuildContext context) {
    print("--- Construyendo HomeView. Índice actual: $_selectedIndex. Cargando: $_isLoadingProfile ---");
    final authProvider = context.read<AuthProvider>(); // Para el botón de logout

    // ----- UI mientras carga el perfil -----
    if (_isLoadingProfile) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cargando...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // ----- UI si hubo error al cargar el perfil o no se encontró -----
    if (_loadingError != null || _currentUserModel == null) {
       return Scaffold(
         appBar: AppBar(title: const Text('Error')),
         body: Center(
           child: Padding(
             padding: const EdgeInsets.all(20.0),
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Text(_loadingError ?? 'No se pudo cargar la información del usuario.'),
                 const SizedBox(height: 20),
                 ElevatedButton(
                   onPressed: () async => await authProvider.signOutUser(),
                   child: const Text('Cerrar Sesión'),
                 )
               ],
             ),
           ),
         ),
       );
    }

    // ----- UI Principal (Perfil cargado correctamente) -----
    final bool isCoach = _currentUserModel!.role == 'Entrenador';
    print("--- HomeView Build: Perfil Cargado. Rol: ${_currentUserModel!.role}. Mostrando UI con índice: $_selectedIndex ---");

    // Lista de widgets para las pestañas
    // Pasamos el _currentUserModel a las vistas que lo necesitan
    final List<Widget> widgetOptions = [
      TrainingPlansView(userModel: _currentUserModel!), // Índice 0
      UserProfileView(userProfile: _currentUserModel!), // Índice 1
      if (isCoach) UserListView(userModel: _currentUserModel!), // Índice 2 (Coach) <-- PASA EL MODELO
    ];

    // Validamos el índice por si acaso antes de usarlo
    final int effectiveIndex = (_selectedIndex >= 0 && _selectedIndex < widgetOptions.length)
                               ? _selectedIndex
                               : 0;

    if (_selectedIndex != effectiveIndex) {
       print("--- HomeView Build: WARN - _selectedIndex ($_selectedIndex) fuera de rango. Usando índice 0. ---");
    }

    // Construimos el Scaffold principal
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitleForIndex(effectiveIndex, isCoach)), // Título dinámico
        actions: [
          // Botón de Cerrar Sesión
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              await authProvider.signOutUser();
              // AuthWrapper manejará la navegación
            },
          ),
        ],
      ),
      // Cuerpo principal que muestra la vista de la pestaña activa
      body: IndexedStack(
             index: effectiveIndex, // Usa el índice validado
             children: widgetOptions,
           ),
      // Barra de navegación inferior
      bottomNavigationBar: BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                // Pestaña Planes (siempre)
                const BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Planes'),
                // Pestaña Perfil (siempre)
                const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
                // Pestaña Usuarios (condicional)
                if (isCoach)
                  const BottomNavigationBarItem(icon: Icon(Icons.group_outlined), label: 'Usuarios'),
              ],
              currentIndex: effectiveIndex, // Marca la pestaña activa
              onTap: _onItemTapped, // Llama a esta función al tocar
              // Puedes añadir estilos aquí: selectedItemColor, unselectedItemColor, etc.
            ),
    );
  }

  // Helper para obtener el título del AppBar basado en la pestaña activa
  String _getTitleForIndex(int index, bool isCoach) {
    switch (index) {
      case 0: return 'Planes de Entrenamiento';
      case 1: return 'Mi Perfil';
      case 2: // Solo debería llegar aquí si isCoach es true
          return 'Gestionar Usuarios';
      default: return 'Voley App'; // Fallback
    }
  }
}