// lib/views/plans/training_plans_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Para formatear fechas

// Importa modelos y providers necesarios (ajusta rutas)
import '../../models/user_model.dart';
import '../../providers/training_plan_provider.dart';
// La importación del modelo TrainingPlan ya no es estrictamente necesaria aquí
// import '../../models/training_plan_model.dart';

// Importa la vista para crear plan
import 'create_plan_view.dart'; // <-- ASEGÚRATE DE IMPORTAR ESTO
// Importa la vista de detalle del plan (la crearemos después)
// import 'plan_detail_view.dart';
// Importa la vista/dialog para asignar plan (la crearemos después)
// import 'assign_plan_view.dart';


class TrainingPlansView extends StatefulWidget {
  final UserModel userModel;
  const TrainingPlansView({super.key, required this.userModel});

  @override
  State<TrainingPlansView> createState() => _TrainingPlansViewState();
}

class _TrainingPlansViewState extends State<TrainingPlansView> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final planProvider = context.read<TrainingPlanProvider>();
      if (widget.userModel.role == 'Entrenador') {
        planProvider.loadCoachPlans();
      } else {
        // TODO: planProvider.loadPlayerPlans();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isCoach = widget.userModel.role == 'Entrenador';
    final planProvider = context.watch<TrainingPlanProvider>();

    return Scaffold(
      body: _buildPlanList(planProvider, isCoach, context),

      // FloatingActionButton para Entrenador
      floatingActionButton: isCoach
          ? FloatingActionButton(
              onPressed: () {
                // *** NAVEGACIÓN A CreatePlanView ***
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreatePlanView()),
                );
                // *** FIN NAVEGACIÓN ***
              },
              tooltip: 'Crear Nuevo Plan',
              child: const Icon(Icons.add),
            )
          : null, // Sin botón para jugador
    );
  }

  // Widget helper para construir el cuerpo principal
  Widget _buildPlanList(TrainingPlanProvider planProvider, bool isCoach, BuildContext context) {
    if (planProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (planProvider.errorMessage != null) {
      return Center(/* ... Error UI ... */);
    }

    // --- Lógica para Entrenador ---
    if (isCoach) {
      if (planProvider.plans.isEmpty) {
        return const Center(/* ... Mensaje sin planes ... */);
      }
      // Lista de planes del coach
      return ListView.builder(
        itemCount: planProvider.plans.length,
        itemBuilder: (context, index) {
          final plan = planProvider.plans[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: ListTile(
              title: Text(plan.planName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Ejercicios: ${plan.exercises.length} - Creado: ${DateFormat('dd/MM/yyyy').format(plan.createdAt.toDate())}'),
              trailing: IconButton( /* ... Botón Asignar (TODO) ... */ onPressed: (){}, icon: Icon(Icons.assignment_ind_outlined)),
              onTap: () { /* ... Navegar a Detalles (TODO) ... */ },
            ),
          );
        },
      );
    }
    // --- Lógica para Jugador ---
    else {
      // TODO: Implementar vista jugador
       if (planProvider.plans.isEmpty) { // TEMPORAL
         return const Center(child: Text('Aún no tienes planes asignados.'));
       }
       // TODO: Cambiar para mostrar planes asignados (HU6, HU15)
       return ListView.builder(
         itemCount: planProvider.plans.length, // TEMPORAL
         itemBuilder: (context, index) { /* ... ListTile Jugador (TODO) ... */ }
       );
    }
  }
}