// lib/views/home_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;

// Importa los repositorios y modelos necesarios
import '../repositories/user_repository_base.dart'; // Ajusta ruta
import '../models/user_model.dart';           // Ajusta ruta
import '../providers/auth_provider.dart';      // Ajusta ruta

// Importa las vistas de las pestañas
import 'plans/training_plans_view.dart';      // Ajusta ruta
import 'profile/user_profile_view.dart';     // Ajusta ruta
import 'users/user_list_view.dart';          // Ajusta ruta

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
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (!mounted) return;
    final user = Provider.of<User?>(context, listen: false);
    if (user != null) {
      try {
        final userRepo = Provider.of<UserRepositoryBase>(context, listen: false);
        final profile = await userRepo.getUserProfile(user.uid);
        if (mounted) {
          setState(() {
            _currentUserModel = profile;
            _isLoadingProfile = false;
            _loadingError = profile == null ? "No se encontró el perfil de usuario." : null;
          });
        }
      } catch (e) {
         if (mounted) {
           setState(() {
             _isLoadingProfile = false;
             _loadingError = "Error al cargar el perfil: ${e.toString()}";
           });
         }
      }
    } else {
      if (mounted) {
         setState(() {
           _isLoadingProfile = false;
           _loadingError = "Usuario no autenticado.";
         });
         WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Provider.of<AuthProvider>(context, listen: false).signOutUser();
            }
         });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    if (_isLoadingProfile) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cargando...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadingError != null || _currentUserModel == null) {
       return Scaffold(
         appBar: AppBar(title: const Text('Error')),
         body: Center( /* ... Error UI ... */ ),
       );
    }

    final bool isCoach = _currentUserModel!.role == 'Entrenador';

    // *** AQUI PASAMOS EL MODELO A LAS VISTAS QUE LO NECESITAN ***
    final List<Widget> widgetOptions = [
      TrainingPlansView(userModel: _currentUserModel!), // <--- PASA EL MODELO
      UserProfileView(userProfile: _currentUserModel!), // <--- PASA EL MODELO
      if (isCoach) const UserListView(), // UserListView no necesita el modelo actual aquí
    ];
    // *** FIN PASO DE MODELO ***


    final int effectiveIndex = (_selectedIndex >= 0 && _selectedIndex < widgetOptions.length)
                               ? _selectedIndex
                               : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitleForIndex(effectiveIndex, isCoach)),
        actions: [ /* ... Botón Logout ... */
           IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              await authProvider.signOutUser();
            },
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
    );
  }

  String _getTitleForIndex(int index, bool isCoach) {
    switch (index) {
      case 0: return 'Planes de Entrenamiento';
      case 1: return 'Mi Perfil';
      case 2: return 'Gestionar Usuarios';
      default: return 'Voley App';
    }
  }
}