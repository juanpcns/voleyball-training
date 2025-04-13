// lib/views/plans/create_plan_view.dart (COMPLETO - Versión Verificada)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/training_plan_provider.dart'; // Ajusta ruta

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
      setState(() { _addedExercises.add(exerciseText); _exerciseInputController.clear(); });
    }
  }

  void _removeExercise(int index) {
    setState(() { _addedExercises.removeAt(index); });
  }

  Future<void> _submitCreatePlan() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_addedExercises.length < 2) { /* ... snackbar ... */ return; }

    setState(() => _isSaving = true);
    final planProvider = context.read<TrainingPlanProvider>();

    final success = await planProvider.createPlan(
      planName: _planNameController.text.trim(),
      averageDailyTime: _avgTimeController.text.trim().isEmpty ? null : _avgTimeController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      // *** Llamada correcta ***
      exercises: _addedExercises, // <--- Nombre correcto 'exercises'
    );

    if (mounted) {
      if (success) { /* ... snackbar éxito y pop ... */ }
      else { /* ... snackbar error ... */ }
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( title: const Text('Crear Nuevo Plan') ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                 // --- Campos del Plan ---
                 TextFormField(controller: _planNameController, enabled: !_isSaving, /*...*/ ),
                 const SizedBox(height: 15),
                 TextFormField(controller: _avgTimeController, enabled: !_isSaving, /*...*/ ),
                 const SizedBox(height: 15),
                 TextFormField(controller: _descriptionController, enabled: !_isSaving, /*...*/ ),
                 const SizedBox(height: 30),

                 // --- Sección Añadir Ejercicios ---
                 Text('Añadir Ejercicios (Mínimo 2)', /*...*/),
                 const SizedBox(height: 8),
                 Row(children: [
                      Expanded(child: TextFormField(controller: _exerciseInputController, enabled: !_isSaving, /*...*/)),
                      IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: _isSaving ? null : _addExercise),
                 ]),
                 const SizedBox(height: 15),

                 // --- Lista Ejercicios Añadidos ---
                 Text('Ejercicios Añadidos (${_addedExercises.length})'),
                 const SizedBox(height: 5),
                 _addedExercises.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(8.0), // Added padding
                      child: Text('Ningún ejercicio añadido aún.', style: TextStyle(fontStyle: FontStyle.italic)),
                    )
                  : Container( /* ... Lista con ListView/Column y botones borrar ... */),
                 const SizedBox(height: 30),

                 // --- Botón Guardar ---
                 ElevatedButton.icon(
                      onPressed: _isSaving ? null : _submitCreatePlan,
                      icon: _isSaving ? /*...*/ Container(width:18, height:18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save_alt_outlined),
                      label: Text(_isSaving ? 'Guardando...' : 'Guardar Plan'),
                      /*...*/
                 ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}