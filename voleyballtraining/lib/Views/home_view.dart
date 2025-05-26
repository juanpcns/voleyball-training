import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:voleyballtraining/Providers/training_plan_provider.dart';
import 'package:voleyballtraining/Providers/user_provider.dart';
import 'package:voleyballtraining/views/plans/training_plans_view.dart';

import '../repositories/user_repository_base.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';

import 'profile/user_profile_view.dart';
import 'users/user_list_view.dart';
import 'plans/create_plan_view.dart';
import 'menu/main_menu_view.dart'; // <--- Importa tu nuevo menú visual

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

    if (user != null) {
      try {
        final profile = await userRepo.getUserProfile(user.uid);
        if (mounted) {
          setState(() {
            _currentUserModel = profile;
            _isLoadingProfile = false;
            _loadingError = profile == null ? "No se encontró el perfil del usuario." : null;
          });
        }

        // Cargar planes o usuarios según rol
        final trainingPlanProvider = Provider.of<TrainingPlanProvider>(context, listen: false);
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        if (profile != null) {
          if (profile.role == 'Entrenador') {
            trainingPlanProvider.loadCoachPlans();
            userProvider.loadUsers();
          } else {
            trainingPlanProvider.loadPlayerAssignments();
          }
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
        await authProv.signOutUser();
      }
    }
  }

  void _onItemTapped(int index) {
    final bool isCoach = _currentUserModel?.role == 'Entrenador';
    final int maxIndex = isCoach ? 2 : 1;
    if (index >= 0 && index <= maxIndex) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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

    final List<Widget> widgetOptions = [
      TrainingPlansView(userModel: _currentUserModel!),
      UserProfileView(userProfile: _currentUserModel!),
      if (isCoach) UserListView(userModel: _currentUserModel!),
    ];

    final int effectiveIndex = (_selectedIndex >= 0 && _selectedIndex < widgetOptions.length) ? _selectedIndex : 0;

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
              // --- Botón para ir al menú principal, SOLO aquí ---
              IconButton(
                icon: const Icon(Icons.home),
                tooltip: 'Menú Principal',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MainMenuView()),
                  );
                },
              ),
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
