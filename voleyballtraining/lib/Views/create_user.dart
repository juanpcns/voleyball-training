// lib/Views/create_user.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voleyballtraining/Views/Styles/buttons/custom_button_styles.dart';
import 'package:voleyballtraining/providers/auth_provider.dart';

// --- > Importaciones Corregidas y Añadidas <---
import 'package:voleyballtraining/Views/Styles/templates/container_default.dart';
import 'package:voleyballtraining/Views/Styles/colors/app_colors.dart';
// --- > IMPORTAR LA PLANTILLA <---
import 'package:voleyballtraining/Views/Styles/templates/home_view_template.dart';
// Ya no necesitamos importar text_styles aquí si usamos el Theme

class CreateUser extends StatefulWidget {
  final VoidCallback? onGoToLogin;
  const CreateUser({super.key, this.onGoToLogin});

  @override
  State<CreateUser> createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  // Descomenta si los usas
  // final _idNumberController = TextEditingController();
  // final _phoneController = TextEditingController();

  String? _selectedRole;
  final List<String> _roles = ['Jugador', 'Entrenador'];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    // _idNumberController.dispose();
    // _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || _selectedRole == null) {
       if (_selectedRole == null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: const Text('Por favor, selecciona un rol.'),
               backgroundColor: Theme.of(context).colorScheme.error,
             ),
           );
       }
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUpUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _fullNameController.text.trim(),
        role: _selectedRole!,
        // idNumber: _idNumberController.text.trim(),
        // phone: _phoneController.text.trim(),
        );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Ocurrió un error al registrar.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    // final colorScheme = theme.colorScheme; // No se usa aquí directamente

    // --- Construimos el contenido que irá DENTRO de la plantilla ---
    Widget formContent = Center( // Centrar el contenido
      child: ContainerDefault( // Usar el contenedor por defecto
        margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0), // Ajusta margen
        child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView( // Permite scroll si el teclado ocupa espacio
             child: Padding(
               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24), // Ajusta padding interno
               child: Form(
                 key: _formKey,
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   crossAxisAlignment: CrossAxisAlignment.stretch, // Estira los widgets hijos horizontalmente
                   children: [
                     Image.asset('assets/images/Logo-icon.png', height: 80), // Más pequeño
                     const SizedBox(height: 20),
                     Text('Crear Usuario', style: textTheme.headlineMedium, textAlign: TextAlign.center), // <-- Usar estilo del tema
                     const SizedBox(height: 30), // Aumentar espacio

                     // --- Nombre Completo ---
                      TextFormField(
                        controller: _fullNameController,
                        enabled: !authProvider.isLoading,
                        decoration: const InputDecoration(labelText: 'Nombre Completo'), // <-- Tema maneja el estilo
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) { if(value == null || value.trim().isEmpty) return 'Ingresa nombre'; return null;},
                      ),
                     const SizedBox(height: 20), // Aumentar espacio

                     // --- Email ---
                     TextFormField(
                       controller: _emailController,
                       enabled: !authProvider.isLoading,
                       decoration: const InputDecoration(labelText: 'Correo Electrónico'), // <-- Tema maneja el estilo
                       keyboardType: TextInputType.emailAddress,
                       validator: (value) { if(value == null || value.trim().isEmpty) return 'Ingresa correo'; if(!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Correo inválido'; return null;},
                     ),
                     const SizedBox(height: 20), // Aumentar espacio

                     // --- Contraseña ---
                     TextFormField(
                       controller: _passwordController,
                       enabled: !authProvider.isLoading,
                       decoration: const InputDecoration(labelText: 'Contraseña'), // <-- Tema maneja el estilo
                       obscureText: true,
                       validator: (value) { if(value == null || value.isEmpty) return 'Ingresa contraseña'; if(value.length < 6) return 'Mínimo 6 caracteres'; return null;},
                     ),
                     const SizedBox(height: 20), // Aumentar espacio

                     // --- Rol ---
                     DropdownButtonFormField<String>(
                       value: _selectedRole,
                       dropdownColor: AppColors.surfaceDark.withOpacity(0.95), // <-- Color del menú
                       decoration: const InputDecoration(labelText: 'Selecciona tu Rol'), // <-- Tema maneja el estilo del label
                       items: _roles.map((String role) => DropdownMenuItem<String>(
                         value: role,
                         child: Text(role, style: textTheme.bodyMedium?.copyWith(color: AppColors.textLight)), // <-- Usar estilo del tema/AppColors
                       )).toList(),
                       onChanged: authProvider.isLoading ? null : (String? newValue) {
                         setState(() => _selectedRole = newValue);
                       },
                       validator: (value) => value == null || value.isEmpty ? 'Selecciona un rol' : null,
                       iconEnabledColor: AppColors.primary, // Color del icono del dropdown
                     ),
                     const SizedBox(height: 35), // Aumentar espacio

                     // --- Indicador de Carga / Botón ---
                     authProvider.isLoading
                       ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: CircularProgressIndicator()))
                       : ElevatedButton(
                           style: CustomButtonStyles.primary(), // <-- Aplicar estilo primario
                           onPressed: authProvider.isLoading ? null : _submitForm,
                           child: const Text('Crear Usuario'),
                         ),
                     const SizedBox(height: 15), // Reducir espacio

                     // --- Botón/Texto para ir a Login ---
                     TextButton(
                       onPressed: authProvider.isLoading ? null : widget.onGoToLogin,
                       child: const Text('¿Ya tienes cuenta? Inicia Sesión'),
                     ),
                   ],
                 ),
               ),
             ),
            ),
           ),
         ),
       );
    // --- Fin construcción del contenido ---


    // --- Retornamos la PLANTILLA pasando el título y el contenido ---
    return HomeViewTemplate(
      title: '', // El título para el AppBar de la plantilla
      body: formContent,     // El widget que acabamos de construir arriba
    );
  }
}