// lib/views/login_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voleyballtraining/providers/auth_provider.dart'; // Ajusta la ruta

// --- Importa tus estilos y widgets personalizados ---
// import 'package/voleyballtraining/Views/Styles/placeholders/placeholder_default.dart';
import 'package:voleyballtraining/Views/Styles/templates/container_default.dart';
import 'package:voleyballtraining/Views/Styles/templates/home_view.dart'; // Para el fondo
import 'package:voleyballtraining/Views/Styles/tipography/text_styles.dart';
import 'package:voleyballtraining/Views/Styles/buttons/button_styles.dart';
// --- Fin Imports ---

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
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Error al iniciar sesión.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // --- Define los estilos ---
    // *** ¡¡REEMPLAZA TextStyles.title().color con tu color naranja real!! ***
    final Color naranjaTitulo = TextStyles.title().color ?? Colors.orange;

    final inputTextStyle = const TextStyle(color: Colors.white); // <-- Texto de entrada BLANCO
    final labelTextStyle = TextStyle(color: naranjaTitulo); // <-- Label NARANJA
    // --- Fin definición de estilos ---

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const HomeView(), // Fondo
          ContainerDefault(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Image.asset('assets/images/Logo-icon.png', height: 120),
                        const SizedBox(height: 25),
                        Text('Iniciar Sesión', style: TextStyles.title(), textAlign: TextAlign.center),
                        const SizedBox(height: 35),

                        // --- Email ---
                        TextFormField(
                          controller: _emailController,
                          enabled: !authProvider.isLoading,
                          style: inputTextStyle, // <-- Aplicado estilo blanco
                          decoration: InputDecoration(
                            labelText: 'Correo Electrónico',
                            labelStyle: labelTextStyle, // <-- Aplicado estilo naranja
                          ),
                          keyboardType: TextInputType.emailAddress,
                           validator: (value) { if(value == null || value.trim().isEmpty) return 'Ingresa correo'; if(!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Correo inválido'; return null;},
                        ),
                        const SizedBox(height: 20),

                        // --- Contraseña ---
                        TextFormField(
                          controller: _passwordController,
                          enabled: !authProvider.isLoading,
                          style: inputTextStyle, // <-- Aplicado estilo blanco
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            labelStyle: labelTextStyle, // <-- Aplicado estilo naranja
                          ),
                          obscureText: true,
                           validator: (value) { if(value == null || value.isEmpty) return 'Ingresa contraseña'; return null;},
                        ),
                        const SizedBox(height: 45),

                        // --- Indicador de Carga / Botón ---
                        authProvider.isLoading
                          ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
                          : ButtonDefault(
                              text: 'Iniciar Sesión',
                              onPressed: authProvider.isLoading ? null : _submitLogin,
                              padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 20),
                            ),
                        const SizedBox(height: 25),

                        // --- Botón para ir a Registro ---
                        TextButton(
                          onPressed: authProvider.isLoading ? null : widget.onGoToRegister,
                          child: const Text(
                            '¿No tienes cuenta? Regístrate',
                            // style: TextStyle(color: naranjaTitulo), // Opcional
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}