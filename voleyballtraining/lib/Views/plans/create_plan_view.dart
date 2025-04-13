// lib/views/plans/create_plan_view.dart (COMPLETO Y CORREGIDO FINAL)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/training_plan_provider.dart'; // Ajusta la ruta si es necesario

class CreatePlanView extends StatefulWidget {
  const CreatePlanView({super.key});

  @override
  State<CreatePlanView> createState() => _CreatePlanViewState();
}

class _CreatePlanViewState extends State<CreatePlanView> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos del plan
  final _planNameController = TextEditingController();
  final _avgTimeController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Controlador y lista para manejar los ejercicios añadidos
  final _exerciseInputController = TextEditingController();
  final List<String> _addedExercises = []; // Lista de Strings para las descripciones

  // Estado para el botón de guardar
  bool _isSaving = false;

  @override
  void dispose() {
    // Limpiar todos los controladores
    _planNameController.dispose();
    _avgTimeController.dispose();
    _descriptionController.dispose();
    _exerciseInputController.dispose();
    super.dispose();
  }

  /// Añade el ejercicio del campo de texto a la lista _addedExercises
  void _addExercise() {
    final exerciseText = _exerciseInputController.text.trim();
    if (exerciseText.isNotEmpty) {
      setState(() {
        _addedExercises.add(exerciseText);
        _exerciseInputController.clear(); // Limpiar campo después de añadir
      });
    }
  }

  /// Elimina un ejercicio de la lista _addedExercises por su índice
  void _removeExercise(int index) {
    setState(() {
      _addedExercises.removeAt(index);
    });
  }

  /// Valida el formulario y llama al provider para guardar el plan
  Future<void> _submitCreatePlan() async {
    FocusScope.of(context).unfocus(); // Ocultar teclado

    // 1. Validar formulario principal
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    // 2. Validar que haya al menos 2 ejercicios (HU5)
    if (_addedExercises.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes añadir al menos 2 ejercicios al plan.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 3. Iniciar guardado (actualiza UI para mostrar loading)
    setState(() => _isSaving = true);
    final planProvider = context.read<TrainingPlanProvider>();

    // 4. Llamar al método createPlan del provider (CON EL PARÁMETRO CORREGIDO)
    final success = await planProvider.createPlan(
      planName: _planNameController.text.trim(),
      averageDailyTime: _avgTimeController.text.trim().isEmpty ? null : _avgTimeController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      // *** ¡¡AQUÍ ESTÁ LA CORRECCIÓN!! ***
      exercises: _addedExercises, // <--- Nombre Correcto 'exercises' y pasar List<String>
    );
    // *** FIN CORRECCIÓN ***


    // 5. Manejar resultado (solo si el widget sigue montado)
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Plan creado con éxito!'), backgroundColor: Colors.green),
        );
        // Volver a la pantalla anterior si se puede
        if(Navigator.canPop(context)) {
           Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(planProvider.errorMessage ?? 'Error al crear el plan.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      // Detener el indicador de carga independientemente del resultado
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Reconstruye si _isSaving cambia (para actualizar estado de botones/campos)
    // No necesitamos 'watch' para el provider aquí si solo lo usamos para llamar métodos en _submitCreatePlan
    // Pero si quisiéramos mostrar un error general del provider aquí, usaríamos watch.
    // final planProviderStatus = context.watch<TrainingPlanProvider>(); // Opcional

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Plan'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Campos del Plan ---
                TextFormField(
                  controller: _planNameController,
                  enabled: !_isSaving, // Deshabilitar si está guardando
                  decoration: const InputDecoration(labelText: 'Nombre del Plan *'),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'El nombre es obligatorio' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _avgTimeController,
                   enabled: !_isSaving,
                  decoration: const InputDecoration(labelText: 'Tiempo Promedio Diario (Ej: 60 minutos)'),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _descriptionController,
                   enabled: !_isSaving,
                  decoration: const InputDecoration(labelText: 'Descripción (Opcional)'),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 30),

                // --- Sección para Añadir Ejercicios ---
                Text('Añadir Ejercicios (Mínimo 2)', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _exerciseInputController,
                         enabled: !_isSaving,
                        decoration: const InputDecoration(hintText: 'Descripción del ejercicio'),
                        textCapitalization: TextCapitalization.sentences,
                         onFieldSubmitted: _isSaving ? null : (_) => _addExercise(), // Añadir con Enter
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: Theme.of(context).colorScheme.primary,
                      tooltip: 'Añadir Ejercicio',
                      onPressed: _isSaving ? null : _addExercise, // Deshabilitar si guarda
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // --- Lista de Ejercicios Añadidos ---
                Text('Ejercicios Añadidos (${_addedExercises.length})'),
                const SizedBox(height: 5),
                _addedExercises.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Text('Ningún ejercicio añadido aún.', style: TextStyle(fontStyle: FontStyle.italic)),
                    )
                  : Container(
                      constraints: const BoxConstraints(maxHeight: 180),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(4.0)
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _addedExercises.length,
                        itemBuilder: (context, index) {
                         return ListTile(
                           key: ValueKey(_addedExercises[index] + index.toString()),
                           dense: true,
                           title: Text(_addedExercises[index]),
                           trailing: IconButton(
                             icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                             iconSize: 20,
                             tooltip: 'Eliminar Ejercicio',
                             onPressed: _isSaving ? null : () => _removeExercise(index), // Deshabilitar si guarda
                           ),
                         );
                        }),
                    ),
                const SizedBox(height: 30),

                // --- Botón Guardar ---
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _submitCreatePlan, // Deshabilitar si guarda
                  icon: _isSaving
                       ? Container(
                           width: 18, height: 18,
                           child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                         )
                       : const Icon(Icons.save_alt_outlined),
                  label: Text(_isSaving ? 'Guardando...' : 'Guardar Plan'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}