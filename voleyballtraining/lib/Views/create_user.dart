import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voleyballtraining/Views/Styles/buttons/custom_button_styles.dart';
import 'package:voleyballtraining/providers/auth_provider.dart';
import 'package:voleyballtraining/Views/Styles/templates/container_default.dart';
import 'package:voleyballtraining/Views/Styles/colors/app_colors.dart';
import 'package:voleyballtraining/Views/Styles/templates/home_view_template.dart';

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
  final _confirmPasswordController = TextEditingController(); // Nuevo controlador
  final _fullNameController = TextEditingController();

  String? _selectedRole;
  final List<String> _roles = ['Jugador', 'Entrenador'];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose(); // Liberar controlador
    _fullNameController.dispose();
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

    Widget formContent = Center(
      child: ContainerDefault(
        margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset('assets/images/Logo-icon.png', height: 80),
                    const SizedBox(height: 20),
                    Text('Crear Usuario', style: textTheme.headlineMedium, textAlign: TextAlign.center),
                    const SizedBox(height: 30),

                    TextFormField(
                      // <<<--- AÑADIDO (para TC-005, TC-006)
                      key: const Key('register_name_field'),
                      controller: _fullNameController,
                      enabled: !authProvider.isLoading,
                      decoration: const InputDecoration(labelText: 'Nombre Completo'),
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Ingresa nombre';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      // <<<--- AÑADIDO (para TC-005, TC-006)
                      key: const Key('register_email_field'),
                      controller: _emailController,
                      enabled: !authProvider.isLoading,
                      decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Ingresa correo';
                        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Correo inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      // <<<--- AÑADIDO (para TC-005, TC-006)
                      key: const Key('register_password_field'),
                      controller: _passwordController,
                      enabled: !authProvider.isLoading,
                      decoration: const InputDecoration(labelText: 'Contraseña'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingresa contraseña';
                        if (value.length < 6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      // <<<--- AÑADIDO (para TC-005, TC-006)
                      key: const Key('register_confirm_password_field'),
                      controller: _confirmPasswordController,
                      enabled: !authProvider.isLoading,
                      decoration: const InputDecoration(labelText: 'Confirmar Contraseña'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Confirma la contraseña';
                        if (value != _passwordController.text) return 'Las contraseñas no coinciden';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      // <<<--- AÑADIDO (para TC-005, TC-006)
                      key: const Key('register_role_dropdown'),
                      value: _selectedRole,
                      dropdownColor: AppColors.surfaceDark.withOpacity(0.95),
                      decoration: const InputDecoration(labelText: 'Selecciona tu Rol'),
                      items: _roles
                          .map((role) => DropdownMenuItem<String>(
                                value: role,
                                child: Text(role, style: textTheme.bodyMedium?.copyWith(color: AppColors.textLight)),
                              ))
                          .toList(),
                      onChanged: authProvider.isLoading
                          ? null
                          : (newValue) {
                              setState(() => _selectedRole = newValue);
                            },
                      validator: (value) => value == null || value.isEmpty ? 'Selecciona un rol' : null,
                      iconEnabledColor: AppColors.primary,
                    ),
                    const SizedBox(height: 35),

                    authProvider.isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : ElevatedButton(
                            // <<<--- AÑADIDO (para TC-005, TC-006)
                            key: const Key('register_button'),
                            style: CustomButtonStyles.primary(),
                            onPressed: authProvider.isLoading ? null : _submitForm,
                            child: const Text('Crear Usuario'),
                          ),
                    const SizedBox(height: 15),

                    TextButton(
                      // <<<--- AÑADIDO
                      key: const Key('register_login_button'),
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

    return HomeViewTemplate(
      title: '',
      body: formContent,
    );
  }
}