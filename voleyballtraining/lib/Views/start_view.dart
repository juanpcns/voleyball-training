// lib/Views/login_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voleyballtraining/Views/Styles/buttons/custom_button_styles.dart';
import 'package:voleyballtraining/providers/auth_provider.dart';

// --- > Importaciones Corregidas y Añadidas <---
import 'package:voleyballtraining/Views/Styles/templates/container_default.dart';
import 'package:voleyballtraining/Views/Styles/colors/app_colors.dart'; // Necesitamos AppColors

// Ya no necesitamos importar text_styles aquí si usamos el Theme

class LoginView extends StatefulWidget {
  final VoidCallback? onGoToRegister;
  const LoginView({super.key, this.onGoToRegister});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    // No es necesario save() con controllers

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Error al iniciar sesión.'),
          backgroundColor: Theme.of(context).colorScheme.error, // <-- Usa color de error del tema
        ),
      );
    }
    // Si el login es exitoso, el AuthWrapper debería manejar la navegación
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    // Obtener el tema para usar sus estilos definidos
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    // final colorScheme = theme.colorScheme; // No se usa aquí

    // --- Ya no necesitamos definir estilos locales aquí ---

    return Scaffold(
       appBar: AppBar( // Añadir AppBar
        title: const Text('Iniciar Sesión'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          // --- Fondo (Usando color del tema) ---
          Container(color: AppColors.backgroundDark), // <-- Fondo oscuro simple
           Center( // Centrar el contenido
            child: ContainerDefault( // Usar el contenedor por defecto
              margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0), // Ajusta margen
              child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: SingleChildScrollView( // Permite scroll
                   child: Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24), // Ajusta padding
                     child: Form(
                       key: _formKey,
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         crossAxisAlignment: CrossAxisAlignment.stretch,
                         children: [
                           Image.asset('assets/images/Logo-icon.png', height: 100), // Más pequeño
                           const SizedBox(height: 25),
                            // Título usando estilo del tema
                           Text('Iniciar Sesión', style: textTheme.headlineMedium, textAlign: TextAlign.center), // <-- Usar estilo del tema
                           const SizedBox(height: 35), // Aumentar espacio

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
                              validator: (value) { if(value == null || value.isEmpty) return 'Ingresa contraseña'; return null;},
                           ),
                           const SizedBox(height: 45), // Aumentar espacio

                           // --- Indicador de Carga / Botón ---
                           authProvider.isLoading
                             ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: CircularProgressIndicator()))
                              // --- > Usar ElevatedButton con estilo del tema <---
                             : ElevatedButton(
                                 style: CustomButtonStyles.primary(), // <-- Aplicar estilo primario
                                 onPressed: authProvider.isLoading ? null : _submitLogin,
                                 child: const Text('Iniciar Sesión'),
                               ),
                           const SizedBox(height: 20), // Reducir espacio

                           // --- Botón para ir a Registro ---
                            // TextButton hereda estilo del tema (color naranja)
                           TextButton(
                             onPressed: authProvider.isLoading ? null : widget.onGoToRegister,
                             child: const Text('¿No tienes cuenta? Regístrate'),
                           ),
                         ],
                       ),
                     ),
                   ),
                  ),
                 ),
               ),
             )
        ],
      ),
    );
  }
}