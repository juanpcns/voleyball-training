import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voleyballtraining/Views/Styles/buttons/custom_button_styles.dart';
import 'package:voleyballtraining/providers/auth_provider.dart';
import 'package:voleyballtraining/Views/Styles/templates/container_default.dart';
import 'package:voleyballtraining/Views/Styles/templates/home_view_template.dart';

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

    if (success && mounted) {
      // Usamos la navegación por rutas nombradas
      Navigator.pushReplacementNamed(context, '/menu');
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
                    Image.asset('assets/images/Logo-icon.png', height: 100),
                    const SizedBox(height: 25),
                    Text('Iniciar Sesión', style: textTheme.headlineMedium, textAlign: TextAlign.center),
                    const SizedBox(height: 35),

                    TextFormField(
                      // <<<--- AÑADIDO (para TC-001, TC-002, TC-003, TC-004, TC-007, TC-008, TC-009, TC-010)
                      key: const Key('login_email_field'),
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
                      // <<<--- AÑADIDO (para TC-001, TC-002, TC-003, TC-004, TC-007, TC-008, TC-009, TC-010)
                      key: const Key('login_password_field'),
                      controller: _passwordController,
                      enabled: !authProvider.isLoading,
                      decoration: const InputDecoration(labelText: 'Contraseña'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingresa contraseña';
                        return null;
                      },
                    ),
                    const SizedBox(height: 45),

                    authProvider.isLoading
                        ? const Center(child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: CircularProgressIndicator(),
                          ))
                        : ElevatedButton(
                            // <<<--- AÑADIDO (para TC-001, TC-002, TC-003, TC-004, TC-007, TC-008, TC-009, TC-010)
                            key: const Key('login_button'),
                            style: CustomButtonStyles.primary(),
                            onPressed: authProvider.isLoading ? null : _submitLogin,
                            child: const Text('Iniciar Sesión'),
                          ),
                    const SizedBox(height: 20),

                    TextButton(
                      // <<<--- AÑADIDO (para TC-005, TC-006)
                      key: const Key('login_register_button'),
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

    return HomeViewTemplate(
      title: '',
      body: formContent,
    );
  }
}