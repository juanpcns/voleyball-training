// lib/views/create_user_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voleyballtraining/providers/auth_provider.dart'; // Ajusta la ruta

// --- Importa tus estilos y widgets personalizados ---
// import 'package:voleyballtraining/Views/Styles/placeholders/placeholder_default.dart';
import 'package:voleyballtraining/Views/Styles/templates/container_default.dart';
import 'package:voleyballtraining/Views/Styles/templates/home_view.dart'; // Para el fondo
import 'package:voleyballtraining/Views/Styles/tipography/text_styles.dart';
import 'package:voleyballtraining/Views/Styles/buttons/button_styles.dart';
// --- Fin Imports ---

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
    if (!isValid) return;
    _formKey.currentState!.save();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUpUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _fullNameController.text.trim(),
        role: _selectedRole!,
        // Pasa los opcionales si los tienes
        );

    if (!success && mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Ocurrió un error al registrar.'),
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
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Image.asset('assets/images/Logo-icon.png', height: 100),
                        const SizedBox(height: 20),
                        Text('Crear Usuario', style: TextStyles.title(), textAlign: TextAlign.center),
                        const SizedBox(height: 25),

                        // --- Nombre Completo ---
                         TextFormField(
                          controller: _fullNameController,
                          enabled: !authProvider.isLoading,
                          style: inputTextStyle, // <-- Aplicado estilo blanco
                          decoration: InputDecoration(
                            labelText: 'Nombre Completo',
                            labelStyle: labelTextStyle, // <-- Aplicado estilo naranja
                          ),
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) { if(value == null || value.trim().isEmpty) return 'Ingresa nombre'; return null;},
                        ),
                        const SizedBox(height: 15),

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
                        const SizedBox(height: 15),

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
                          validator: (value) { if(value == null || value.isEmpty) return 'Ingresa contraseña'; if(value.length < 6) return 'Mínimo 6 caracteres'; return null;},
                        ),
                        const SizedBox(height: 15),

                         // --- Rol ---
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          style: inputTextStyle, // <-- Texto seleccionado blanco
                          dropdownColor: Colors.grey[800],
                          decoration: InputDecoration(
                            labelText: 'Selecciona tu Rol',
                            labelStyle: labelTextStyle, // <-- Aplicado estilo naranja
                          ),
                          items: _roles.map((String role) => DropdownMenuItem<String>(
                            value: role,
                            // Texto de los items en el menú desplegable
                            child: Text(role, style: const TextStyle(color: Colors.white)), // Items en blanco
                          )).toList(),
                          onChanged: authProvider.isLoading ? null : (String? newValue) {
                            setState(() => _selectedRole = newValue);
                          },
                          validator: (value) => value == null || value.isEmpty ? 'Selecciona un rol' : null,
                        ),
                        const SizedBox(height: 30),

                        // --- Indicador de Carga / Botón ---
                        authProvider.isLoading
                         ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
                         : ButtonDefault(
                            text: 'Crear Usuario',
                            onPressed: authProvider.isLoading ? null : _submitForm,
                            padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 20),
                           ),
                        const SizedBox(height: 20),

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
          )
        ],
      ),
    );
  }
}