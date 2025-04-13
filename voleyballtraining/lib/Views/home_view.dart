// lib/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Para llamar a signOut
import 'package:voleyballtraining/providers/auth_provider.dart'; // Asegúrate de que la ruta sea correcta

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener el provider para poder llamar a signOut
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voley App - Inicio'), // Título de la pantalla principal
        actions: [
          // Botón para cerrar sesión
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              // Llama al método signOut del provider
              await authProvider.signOutUser();
              // AuthWrapper se encargará de navegar a AuthView automáticamente
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          '¡Bienvenido! Estás en HomeView.',
          style: TextStyle(fontSize: 18),
        ),
        // Aquí es donde eventualmente pondrás el contenido principal
        // de tu aplicación para usuarios logueados (planes, etc.)
        // Podrías incluso mostrar tu widget 'StartView' aquí si quisieras.
        // body: StartView(), // <-- Si quieres usar tu vista original aquí
      ),
    );
  }
}