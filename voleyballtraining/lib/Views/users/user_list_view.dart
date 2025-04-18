// lib/views/users/user_list_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Modelos y Providers (Asegúrate que las rutas sean correctas)
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';

// --- > Importaciones de Estilos <---
import 'package:voleyballtraining/Views/Styles/colors/app_colors.dart';
import 'package:voleyballtraining/Views/Styles/templates/container_default.dart';

class UserListView extends StatefulWidget {
  final UserModel userModel; // Recibe modelo del coach logueado
  const UserListView({super.key, required this.userModel});

  @override
  State<UserListView> createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Cargar usuarios al iniciar (si no se hizo ya en HomeView)
        // Considera si esta carga es necesaria aquí o si HomeView ya la hizo.
        // Si HomeView siempre la hace, esta línea podría ser redundante.
        context.read<UserProvider>().loadUsers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Quitamos el Scaffold de aquí
    final userProvider = context.watch<UserProvider>();
    // Devolvemos directamente el contenido del cuerpo
    return _buildUserListBody(userProvider);
  }

  Widget _buildUserListBody(UserProvider userProvider) {
    // Obtener tema para estilos
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    // --- Estado de Carga ---
    if (userProvider.isLoading) {
      // Envuelto en ContainerDefault
      return ContainerDefault(
         margin: const EdgeInsets.all(16), // Margen exterior
         child: Center(child: CircularProgressIndicator(color: colorScheme.primary)),
      );
    }

    // --- Estado de Error ---
    if (userProvider.errorMessage != null) {
       // Envuelto en ContainerDefault
       return ContainerDefault(
          margin: const EdgeInsets.all(16),
          child: Center(child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error: ${userProvider.errorMessage}',
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.error),
              textAlign: TextAlign.center,
            )
          )),
       );
    }

    // Filtrar al coach actual
    final displayUsers = userProvider.users.where((u) => u.userId != widget.userModel.userId).toList();

    // --- Estado Vacío ---
    if (displayUsers.isEmpty) {
       // Envuelto en ContainerDefault
       return ContainerDefault(
         margin: const EdgeInsets.all(16),
         child: Center(child: Padding(
           padding: const EdgeInsets.all(16.0),
           child: Text(
             'No hay otros usuarios registrados.',
             style: textTheme.bodyLarge?.copyWith(color: AppColors.textGray),
             textAlign: TextAlign.center,
           )
         )),
       );
    }

    // --- Lista de Usuarios ---
    // Envuelto en ContainerDefault
    return ContainerDefault(
      // Sin padding interno para que el Refresh/ListView ocupen todo
      padding: EdgeInsets.zero,
      // Margen exterior y espacio inferior para NavBar/FAB
      margin: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 80),
      child: RefreshIndicator(
         // Color del indicador de refresco
        color: AppColors.textLight, // Color del spinner
        backgroundColor: colorScheme.primary, // Color de fondo del círculo
        onRefresh: () => context.read<UserProvider>().loadUsers(),
        child: ListView.builder(
          // Padding interno de la lista si se desea
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: displayUsers.length,
          itemBuilder: (context, index) {
            final user = displayUsers[index];
            // Card usa CardTheme global
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: ListTile(
                 // Leading: Avatar estilizado
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: user.role == 'Entrenador'
                      ? colorScheme.secondary.withOpacity(0.3) // Azul para coach
                      : colorScheme.primary.withOpacity(0.3), // Naranja para jugador
                  child: Text(
                    user.role == 'Entrenador' ? 'E' : 'J',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: user.role == 'Entrenador'
                          ? colorScheme.secondary // Azul
                          : colorScheme.primary, // Naranja
                    ),
                  ),
                ),
                 // Title: Estilo del tema con negrita
                title: Text(user.fullName, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                 // Subtitle: Estilo del tema más pequeño y gris
                subtitle: Text(
                  "${user.role}\n${user.email}",
                  style: textTheme.bodySmall?.copyWith(color: AppColors.textGray),
                ),
                isThreeLine: true,
                 // Opcional: Añadir un trailing IconButton si necesitas acciones
                 // trailing: IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
                 onTap: () {
                    // TODO: Implementar acción al tocar un usuario (ver perfil?, asignar?)
                    print('Tapped user: ${user.fullName}');
                 },
                 splashColor: AppColors.primary.withOpacity(0.1),
              ),
            );
          },
        ),
      ),
    );
  }
}