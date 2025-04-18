// lib/views/profile/user_profile_view.dart

import 'package:flutter/material.dart';
import 'package:voleyballtraining/Views/Styles/buttons/custom_button_styles.dart';
import '../../models/user_model.dart'; // Ajusta la ruta si es necesario

// --- > Importaciones de Estilos <---
import 'package:voleyballtraining/Views/Styles/templates/container_default.dart';// Para el botón Editar
// import 'package:intl/intl.dart'; // Descomenta si usas formateo de fecha avanzado

class UserProfileView extends StatelessWidget {
  final UserModel userProfile;

  const UserProfileView({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.95,
        heightFactor: 0.95, // Puedes ajustar o quitar esto si prefieres altura automática
        child: ContainerDefault(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centrar contenido vertical
              crossAxisAlignment: CrossAxisAlignment.start, // Alinear info a la izq.
              children: [
                // --- > LOGO AÑADIDO AQUÍ <---
                Center( // Centrar logo horizontalmente
                  child: Image.asset(
                    'assets/images/Logo-icon.png', // Ruta al logo
                    height: 80, // Altura deseada (ajusta)
                  ),
                ),
                const SizedBox(height: 16), // Espacio después del logo
                // --- > FIN LOGO <---

                // Título de la sección
                Center( // Mantener título centrado
                  child: Text(
                    'Mi Perfil',
                    style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)
                  ),
                ),
                const SizedBox(height: 25),

                // Datos del perfil
                _buildProfileInfoRow('Nombre:', userProfile.fullName, context),
                _buildProfileInfoRow('Email:', userProfile.email, context),
                _buildProfileInfoRow('Rol:', userProfile.role, context),
                _buildProfileInfoRow(
                  'Miembro desde:',
                  userProfile.createdAt.toDate().toLocal().toString().split(' ')[0],
                  context
                ),
                if (userProfile.idNumber != null && userProfile.idNumber!.isNotEmpty)
                  _buildProfileInfoRow('Cédula:', userProfile.idNumber!, context),
                if (userProfile.phoneNumber != null && userProfile.phoneNumber!.isNotEmpty)
                  _buildProfileInfoRow('Teléfono:', userProfile.phoneNumber!, context),
                if (userProfile.dateOfBirth != null)
                    _buildProfileInfoRow(
                      'Fecha Nacimiento:',
                      userProfile.dateOfBirth!.toDate().toLocal().toString().split(' ')[0],
                      context
                    ),

                const Spacer(), // <--- Añadido para empujar el botón hacia abajo

                // Botón Editar Perfil
                Center(
                  child: ElevatedButton.icon(
                    style: CustomButtonStyles.primary(),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('TODO: Navegar a Editar Perfil'))
                      );
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Editar Perfil'),
                  ),
                ),
                 const SizedBox(height: 10), // Pequeño espacio al final
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper sin cambios
  Widget _buildProfileInfoRow(String label, String value, BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value, style: textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}