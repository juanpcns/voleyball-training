// lib/views/profile/user_profile_view.dart

import 'package:flutter/material.dart';
import '../../models/user_model.dart'; // Ajusta la ruta si es necesario
// Importa intl para formatear fechas si quieres: flutter pub add intl
// import 'package:intl/intl.dart';

class UserProfileView extends StatelessWidget {
  // Recibe el perfil del usuario ya cargado desde HomeView
  final UserModel userProfile;

  const UserProfileView({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    // Construye la interfaz de usuario para mostrar los datos del perfil
    // TODO: Diseña esta vista como prefieras
    return Center(
      child: Padding(
         padding: const EdgeInsets.all(16.0),
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           crossAxisAlignment: CrossAxisAlignment.start, // Alinea texto a la izquierda
           children: [
              // Título de la sección
              Text(
                'Mi Perfil',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold) // Usa el tema para estilo
              ),
              const SizedBox(height: 25), // Más espacio

              // Muestra los datos del UserModel recibido
              _buildProfileInfoRow('Nombre:', userProfile.fullName),
              _buildProfileInfoRow('Email:', userProfile.email),
              _buildProfileInfoRow('Rol:', userProfile.role),

              // Muestra la fecha de creación (formateada opcionalmente)
              _buildProfileInfoRow(
                'Miembro desde:',
                // DateFormat('dd/MM/yyyy').format(userProfile.createdAt.toDate()) // Ejemplo con intl
                userProfile.createdAt.toDate().toLocal().toString().split(' ')[0] // Formato simple YYYY-MM-DD
              ),

              // Muestra campos opcionales solo si tienen valor
              if (userProfile.idNumber != null && userProfile.idNumber!.isNotEmpty)
                _buildProfileInfoRow('Cédula:', userProfile.idNumber!),

              if (userProfile.phoneNumber != null && userProfile.phoneNumber!.isNotEmpty)
                _buildProfileInfoRow('Teléfono:', userProfile.phoneNumber!),

              if (userProfile.dateOfBirth != null)
                 _buildProfileInfoRow(
                  'Fecha Nacimiento:',
                   userProfile.dateOfBirth!.toDate().toLocal().toString().split(' ')[0] // Formato simple
                 ),

              const SizedBox(height: 30), // Espacio antes del botón

              // TODO: Añadir un botón para "Editar Perfil" que navegue a otra pantalla
              // ElevatedButton(
              //   onPressed: () { /* Navegar a pantalla de edición */ },
              //   child: const Text('Editar Perfil'),
              // ),
           ],
         ),
      )
    );
  }

  // Widget helper para mostrar una fila de información (Label: Valor)
  Widget _buildProfileInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: const TextStyle(fontWeight: FontWeight.bold), // Label en negrita
          ),
          Expanded( // Permite que el valor ocupe el resto del espacio y haga wrap
            child: Text(value),
          ),
        ],
      ),
    );
  }
}