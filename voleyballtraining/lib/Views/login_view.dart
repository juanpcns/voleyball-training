// lib/Views/login_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voleyballtraining/Views/Styles/buttons/custom_button_styles.dart';
import 'package:voleyballtraining/providers/auth_provider.dart';

// --- > Importaciones Corregidas y Añadidas <---
import 'package:voleyballtraining/Views/Styles/templates/container_default.dart';
// --- > IMPORTAR LA PLANTILLA <---
import 'package:voleyballtraining/Views/Styles/templates/home_view_template.dart';
// Ya no necesitamos importar AppColors aquí directamente para el fondo

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

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Error al iniciar sesión.'),
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

    // --- Construimos el contenido que irá DENTRO de la plantilla ---
    Widget formContent = Center( // Centrar el contenido
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
                     Image.asset('assets/images/Logo-icon.png', height: 100),
                     const SizedBox(height: 25),
                     Text('Iniciar Sesión', style: textTheme.headlineMedium, textAlign: TextAlign.center),
                     const SizedBox(height: 35),

                     // --- Email ---
                      TextFormField(
                        controller: _emailController,
                        enabled: !authProvider.isLoading,
                        decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                        keyboardType: TextInputType.emailAddress,
                         validator: (value) { if(value == null || value.trim().isEmpty) return 'Ingresa correo'; if(!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Correo inválido'; return null;},
                     ),
                     const SizedBox(height: 20),

                     // --- Contraseña ---
                     TextFormField(
                       controller: _passwordController,
                       enabled: !authProvider.isLoading,
                       decoration: const InputDecoration(labelText: 'Contraseña'),
                       obscureText: true,
                        validator: (value) { if(value == null || value.isEmpty) return 'Ingresa contraseña'; return null;},
                     ),
                     const SizedBox(height: 45),

                     // --- Indicador de Carga / Botón ---
                     authProvider.isLoading
                       ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 16.0), child: CircularProgressIndicator()))
                       : ElevatedButton(
                           style: CustomButtonStyles.primary(),
                           onPressed: authProvider.isLoading ? null : _submitLogin,
                           child: const Text('Iniciar Sesión'),
                         ),
                     const SizedBox(height: 20),

                     // --- Botón para ir a Registro ---
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
       );
    // --- Fin construcción del contenido ---


    // --- Retornamos la PLANTILLA pasando el título y el contenido ---
    return HomeViewTemplate(
      title: '', // El título para el AppBar de la plantilla
      body: formContent,       // El widget que acabamos de construir arriba
      // backgroundImagePath: 'assets/images/otra_imagen.png' // Opcional: si quieres un fondo diferente aquí
    );
  }
}