import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;

import '../repositories/user_repository_base.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';

import 'plans/training_plans_view.dart';
import 'profile/user_profile_view.dart';
import 'users/user_list_view.dart';
import 'plans/create_plan_view.dart';

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
    if (!mounted) return;
    final user = Provider.of<User?>(context, listen: false);
    final userRepo = Provider.of<UserRepositoryBase>(context, listen: false);
    final authProv = Provider.of<AuthProvider>(context, listen: false);

    print("--- HomeView _loadUserProfile: User UID from Provider: ${user?.uid} ---");

    if (user != null) {
      try {
        print("--- HomeView _loadUserProfile: Calling getUserProfile for UID: ${user.uid} ---");
        final profile = await userRepo.getUserProfile(user.uid);

        print(">>> PERFIL CARGADO: $profile");

        if (mounted) {
          setState(() {
            _currentUserModel = profile;
            _isLoadingProfile = false;
            _loadingError = profile == null ? "No se encontró el perfil del usuario." : null;
            print("--- HomeView _loadUserProfile: Profile loaded. Role: ${_currentUserModel?.role}. Error: $_loadingError ---");
          });
        }
      } catch (e) {
        print("--- ERROR en getUserProfile ---");
        print(e);
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
    final bool isCoach = _currentUserModel?.role == 'Entrenador';
    final int maxIndex = isCoach ? 2 : 1;
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
    print("--- Construyendo HomeView. Índice: $_selectedIndex. Cargando: $_isLoadingProfile. Error: $_loadingError ---");

    final authProvider = context.read<AuthProvider>();
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    if (_isLoadingProfile) {
      return Scaffold(
        appBar: AppBar(title: Text('Cargando...', style: textTheme.titleLarge)),
        body: Center(child: CircularProgressIndicator(color: colorScheme.primary)),
        backgroundColor: AppColors.backgroundDark,
      );
    }

    if (_loadingError != null || _currentUserModel == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Error', style: textTheme.titleLarge)),
        body: Center(
          child: Text(
            _loadingError ?? 'Ocurrió un error inesperado.',
            style: textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
        backgroundColor: AppColors.backgroundDark,
      );
    }

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

    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/fondo.png'), fit: BoxFit.cover),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(_getTitleForIndex(effectiveIndex, isCoach)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
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
          floatingActionButton: isCoach
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreatePlanView()),
                    );
                  },
                  tooltip: 'Crear Nuevo Plan',
                  child: const Icon(Icons.add),
                )
              : null,
        ),
      ],
    );
  }

  String _getTitleForIndex(int index, bool isCoach) {
    switch (index) {
      case 0:
        return 'Planes de Entrenamiento';
      case 1:
        return 'Mi Perfil';
      case 2:
        return 'Gestionar Usuarios';
      default:
        return 'Voley App';
    }
  }
}
