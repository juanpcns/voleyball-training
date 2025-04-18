// lib/views/plans/create_plan_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voleyballtraining/Views/Styles/buttons/custom_button_styles.dart';
import '../../providers/training_plan_provider.dart'; // Ajusta ruta

// --- > Importaciones de Estilos <---
import 'package:voleyballtraining/Views/Styles/colors/app_colors.dart';
import 'package:voleyballtraining/Views/Styles/templates/home_view_template.dart';
import 'package:voleyballtraining/Views/Styles/templates/container_default.dart';
// Ya no necesitamos importar text_styles aquí si usamos el Theme

class CreatePlanView extends StatefulWidget {
  const CreatePlanView({super.key});

  @override
  State<CreatePlanView> createState() => _CreatePlanViewState();
}

class _CreatePlanViewState extends State<CreatePlanView> {
  final _formKey = GlobalKey<FormState>();
  final _planNameController = TextEditingController();
  final _avgTimeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _exerciseInputController = TextEditingController();
  final List<String> _addedExercises = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _planNameController.dispose();
    _avgTimeController.dispose();
    _descriptionController.dispose();
    _exerciseInputController.dispose();
    super.dispose();
  }

  void _addExercise() {
    final exerciseText = _exerciseInputController.text.trim();
    if (exerciseText.isNotEmpty) {
      setState(() {
        _addedExercises.add(exerciseText);
        _exerciseInputController.clear();
      });
    }
  }

  void _removeExercise(int index) {
     if (index >= 0 && index < _addedExercises.length) {
       setState(() { _addedExercises.removeAt(index); });
    }
  }

  Future<void> _submitCreatePlan() async {
    FocusScope.of(context).unfocus();
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (_addedExercises.length < 2) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: const Text('Debes añadir al menos 2 ejercicios.'),
             backgroundColor: AppColors.warningDark,
           ),
         );
       }
       return;
     }

    setState(() => _isSaving = true);
    final planProvider = context.read<TrainingPlanProvider>();

    final success = await planProvider.createPlan(
      planName: _planNameController.text.trim(),
      averageDailyTime: _avgTimeController.text.trim().isEmpty ? null : _avgTimeController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      exercises: _addedExercises,
    );

    if (mounted) {
      if (success) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Text('¡Plan creado con éxito!'),
             backgroundColor: AppColors.successDark,
           ),
         );
         Navigator.of(context).pop();
      } else {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text(planProvider.errorMessage ?? 'Error al guardar el plan.'),
             backgroundColor: Theme.of(context).colorScheme.error,
           ),
         );
       }
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    // --- Construimos el contenido: Center > ContainerDefault > Formulario Scrollable ---
    Widget formContent = Center(
      child: ContainerDefault(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                      // --- Logo ---
                      Image.asset(
                        'assets/images/Logo-icon.png',
                        height: 80,
                      ),
                      const SizedBox(height: 16), // Espacio reducido después del logo

                      // --- > TÍTULO AÑADIDO AQUÍ <---
                      Text(
                        'Crear Plan',
                        style: textTheme.headlineMedium, // Estilo naranja del tema
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30), // Espacio antes del primer campo
                      // --- > FIN TÍTULO <---

                      // --- Campos del Plan ---
                      TextFormField(
                        controller: _planNameController,
                        enabled: !_isSaving,
                        decoration: const InputDecoration(labelText: 'Nombre del Plan *'),
                        textCapitalization: TextCapitalization.sentences,
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'Ingresa un nombre para el plan' : null,
                       ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _avgTimeController,
                        enabled: !_isSaving,
                        decoration: const InputDecoration(labelText: 'Tiempo Promedio Diario (Ej: 30 min)'),
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _descriptionController,
                        enabled: !_isSaving,
                        decoration: const InputDecoration(labelText: 'Descripción (Opcional)'),
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 30),

                      // --- Sección Añadir Ejercicios ---
                      Text('Añadir Ejercicios (Mínimo 2)', style: textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Row(children: [
                          Expanded(
                            child: TextFormField(
                              controller: _exerciseInputController,
                              enabled: !_isSaving,
                              decoration: const InputDecoration(
                                labelText: 'Nuevo Ejercicio',
                                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                              ),
                              textCapitalization: TextCapitalization.sentences,
                              onFieldSubmitted: (_) => _isSaving ? null : _addExercise(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.add_circle, color: colorScheme.primary, size: 30),
                            tooltip: 'Añadir Ejercicio',
                            onPressed: _isSaving ? null : _addExercise,
                          ),
                      ]),
                      const SizedBox(height: 20),

                      // --- Lista Ejercicios Añadidos ---
                      Text('Ejercicios Añadidos (${_addedExercises.length})', style: textTheme.titleMedium),
                      const SizedBox(height: 5),
                      Container(
                        decoration: BoxDecoration(
                           border: Border.all(color: AppColors.divider),
                           borderRadius: BorderRadius.circular(8.0),
                           color: AppColors.surfaceDark.withOpacity(0.5),
                        ),
                        constraints: const BoxConstraints(maxHeight: 180),
                        child: _addedExercises.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                            child: Center(
                              child: Text(
                                'Ningún ejercicio añadido aún.',
                                style: textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: AppColors.textGray),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: _addedExercises.length,
                            itemBuilder: (context, index) {
                               return ListTile(
                                  dense: true,
                                  title: Text(_addedExercises[index], style: textTheme.bodyMedium),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete_outline, color: colorScheme.error, size: 20),
                                    tooltip: 'Eliminar ejercicio',
                                    onPressed: _isSaving ? null : () => _removeExercise(index),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
                                );
                             },
                           ),
                        ),
                      const SizedBox(height: 35),

                      // --- Botón Guardar ---
                      ElevatedButton.icon(
                          style: CustomButtonStyles.primary(),
                          onPressed: _isSaving ? null : _submitCreatePlan,
                          icon: _isSaving
                              ? Container(
                                  width: 18, height: 18,
                                  margin: const EdgeInsets.only(right: 8),
                                  child: CircularProgressIndicator( strokeWidth: 2,
                                    color: CustomButtonStyles.primary().foregroundColor?.resolve({}),
                                  )
                                )
                              : const Icon(Icons.save_alt_outlined),
                          label: Text(_isSaving ? 'Guardando...' : 'Guardar Plan'),
                        ),
                  ],
                ),
              ),
            ),
          ),
         ),
       );
     // --- Fin construcción del contenido ---

    // --- Retornamos la PLANTILLA ---
    return HomeViewTemplate(
      title: '', // Título del AppBar (puede ser redundante con el título interno)
      body: formContent,
    );
  }
}