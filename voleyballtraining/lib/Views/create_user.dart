import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Para Timestamp
import 'package:voleyballtraining/providers/auth_provider.dart'; // Ajusta la ruta
// Ajusta las rutas a tus estilos y widgets personalizados
import 'package:voleyballtraining/Views/Styles/placeholders/placeholder_default.dart';
import 'package:voleyballtraining/Views/Styles/templates/container_default.dart';
import 'package:voleyballtraining/Views/Styles/templates/home_view.dart';
import 'package:voleyballtraining/Views/Styles/tipography/text_styles.dart';
import 'package:voleyballtraining/Views/Styles/buttons/button_styles.dart';

// Asegúrate que el nombre de la clase coincida con cómo la llamas en AuthView
class CreateUser extends StatefulWidget {
  const CreateUser({super.key});

  @override
  State<CreateUser> createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  // final _idNumberController = TextEditingController(); // Descomenta si añades el campo
  // final _phoneController = TextEditingController(); // Descomenta si añades el campo

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
    print("--- Botón 'Crear Usuario' presionado ---"); // DEBUG

    final isValid = _formKey.currentState?.validate() ?? false;
    print("--- Resultado de validación del formulario: $isValid ---"); // DEBUG
    if (!isValid) {
       print("--- Validación fallida. No se continúa. ---"); // DEBUG
      return;
    }
    _formKey.currentState!.save();
     print("--- Formulario validado. Rol: $_selectedRole ---"); // DEBUG

    final authProvider = context.read<AuthProvider>();
     print("--- Llamando a authProvider.signUpUser... ---"); // DEBUG

    final success = await authProvider.signUpUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _fullNameController.text.trim(),
        role: _selectedRole!, // La validación asegura que no es null
        // idNumber: _idNumberController.text.trim(), // Pasa los opcionales si los tienes
        // phoneNumber: _phoneController.text.trim(),
        // dateOfBirth: ... , // Necesitarías un DatePicker
        );

     print("--- Resultado de signUpUser: $success ---"); // DEBUG
    if (!success && mounted) {
       print("--- Error reportado por AuthProvider: ${authProvider.errorMessage} ---"); // DEBUG
       ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Ocurrió un error desconocido.'),
            backgroundColor: Colors.red,
          ),
        );
    } else if (success) {
        print("--- Registro exitoso. AuthWrapper debería redirigir. ---"); // DEBUG
    }
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>(); // Escucha cambios

    return Scaffold(
      // Evita que el fondo se redimensione cuando aparece el teclado
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Considera si realmente quieres HomeView como fondo aquí,
          // podría ser simplemente un color o una imagen estática.
          const HomeView(), // Fondo
          ContainerDefault( // Contenedor semi-transparente
            child: GestureDetector(
               onTap: () => FocusScope.of(context).unfocus(), // Ocultar teclado al tocar fuera
               child: SingleChildScrollView( // Permite scroll
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40), // Más padding
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
                          decoration: const InputDecoration(labelText: 'Nombre Completo'), // Usar InputDecoration estándar
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Ingresa tu nombre completo';
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        // --- Email ---
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Ingresa tu correo';
                            if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Correo inválido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        // --- Contraseña ---
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(labelText: 'Contraseña'),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
                            if (value.length < 6) return 'Mínimo 6 caracteres';
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                         // --- Rol ---
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: const InputDecoration(labelText: 'Selecciona tu Rol'),
                          items: _roles.map((String role) => DropdownMenuItem<String>(value: role, child: Text(role))).toList(),
                          onChanged: (String? newValue) => setState(() => _selectedRole = newValue),
                          validator: (value) => value == null || value.isEmpty ? 'Selecciona un rol' : null,
                        ),
                        const SizedBox(height: 30),

                        // --- Indicador de Carga / Botón ---
                        // Muestra indicador si está cargando, si no, muestra el botón
                        authProvider.isLoading
                         ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator())) // Añadido Padding
                         : ButtonDefault(
                            text: 'Crear Usuario',
                            // Deshabilita el botón si está cargando
                            onPressed: authProvider.isLoading ? null : _submitForm,
                            padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 20),
                           ),

                        // (Opcional) Espacio para link a Login
                        const SizedBox(height: 20),
                        // TextButton(onPressed: () { /* TODO: Navegar a Login */ }, child: Text('¿Ya tienes cuenta? Inicia Sesión'))
                      ],
                    ),
                  ),
                ),
               ),
             ),
          ),
        ]
      ),
    );
  }
}