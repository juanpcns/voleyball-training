// lib/views/users/user_list_view.dart (COMPLETO - Sin cambios, pero verifica)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Importa el provider y el modelo necesarios (ajusta rutas)
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';

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
    // Llama a loadUsers una vez cuando el widget se inicializa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Usamos context.read aquí porque no necesitamos escuchar en initState
        context.read<UserProvider>().loadUsers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos los cambios en UserProvider para reconstruir la UI
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      body: _buildUserListBody(userProvider),
    );
  }

  Widget _buildUserListBody(UserProvider userProvider) {
    // Mostrar indicador de carga
    if (userProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Mostrar mensaje de error si existe
    if (userProvider.errorMessage != null) {
      return Center( /* ... Error UI ... */ );
    }

    // Filtrar opcionalmente al usuario actual si no quieres mostrarlo
    final displayUsers = userProvider.users.where((u) => u.userId != widget.userModel.userId).toList();

    // Mostrar mensaje si la lista (filtrada) está vacía
    if (displayUsers.isEmpty) {
      return const Center(child: Text('No hay otros usuarios registrados.'));
    }

    // Mostrar la lista de usuarios con Pull-to-refresh
    return RefreshIndicator(
      // Llama a loadUsers (que ahora devuelve Future<void>) al arrastrar
      onRefresh: () => context.read<UserProvider>().loadUsers(),
      child: ListView.builder(
        itemCount: displayUsers.length,
        itemBuilder: (context, index) {
          final user = displayUsers[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: ListTile(
              leading: CircleAvatar(child: Text(user.role == 'Entrenador' ? 'E' : 'J')),
              title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${user.role}\n${user.email}"),
              isThreeLine: true,
              // TODO: Acciones futuras (asignar plan?)
            ),
          );
        },
      ),
    );
  }
}