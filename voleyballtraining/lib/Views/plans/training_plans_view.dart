// lib/views/plans/training_plans_view.dart (COMPLETO con Vista Coach y Jugador)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Importa intl si no lo has hecho: flutter pub add intl
import 'package:intl/intl.dart'; // Para formatear fechas

// --- Importa Modelos y Providers (Ajusta rutas si es necesario) ---
import '../../models/user_model.dart';
import '../../providers/training_plan_provider.dart';
import '../../models/plan_assignment_model.dart'; // Necesario para el Enum y la lista del jugador
// --- Fin Imports ---

// --- Importa Vistas para Navegación Futura (Ajusta rutas) ---
import 'create_plan_view.dart';
// import 'plan_detail_view.dart'; // Para ver detalles del plan
// import 'assign_plan_view.dart'; // Para asignar plan (coach)
// --- Fin Imports ---


class TrainingPlansView extends StatefulWidget {
  // Recibe el UserModel desde HomeView para saber el rol
  final UserModel userModel;

  const TrainingPlansView({super.key, required this.userModel});

  @override
  State<TrainingPlansView> createState() => _TrainingPlansViewState();
}

class _TrainingPlansViewState extends State<TrainingPlansView> {

  @override
  void initState() {
    super.initState();
    // Llamamos al método apropiado del provider basado en el rol al iniciar
    // Usamos addPostFrameCallback para asegurar que el context esté listo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // Verificar si el widget sigue montado
      final planProvider = context.read<TrainingPlanProvider>();

      if (widget.userModel.role == 'Entrenador') {
        planProvider.loadCoachPlans(); // Carga los planes del coach
      } else { // Es Jugador
        planProvider.loadPlayerAssignments(); // Carga las asignaciones del jugador
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determinamos el rol para mostrar UI condicional
    final bool isCoach = widget.userModel.role == 'Entrenador';
    // Escuchamos al TrainingPlanProvider para reaccionar a cambios
    final planProvider = context.watch<TrainingPlanProvider>();

    return Scaffold(
      // Construimos el cuerpo usando un método helper
      body: _buildBody(planProvider, isCoach, context),

      // Botón flotante (+) solo para Entrenadores (HU5)
      floatingActionButton: isCoach
          ? FloatingActionButton(
              onPressed: () {
                // Navegar a la pantalla de crear plan
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreatePlanView()),
                );
              },
              tooltip: 'Crear Nuevo Plan',
              child: const Icon(Icons.add),
            )
          : null, // Los jugadores no tienen este botón aquí
    );
  }

  /// Construye el contenido principal de la pantalla (Loading/Error/Lista)
  Widget _buildBody(TrainingPlanProvider planProvider, bool isCoach, BuildContext context) {
    // --- Lógica para Entrenador ---
    if (isCoach) {
      // Indicador de carga para planes del coach
      if (planProvider.isLoadingCoachPlans) {
        return const Center(child: CircularProgressIndicator());
      }
      // Mensaje de error para planes del coach
      if (planProvider.coachPlansError != null) {
        return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: ${planProvider.coachPlansError}', style: const TextStyle(color: Colors.red))));
      }
      // Mensaje si el coach no tiene planes
      if (planProvider.coachPlans.isEmpty) {
        return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('Aún no has creado ningún plan.\nUsa el botón (+) para empezar!', textAlign: TextAlign.center)));
      }

      // Lista de planes creados por el coach (HU6 Coach)
      return ListView.builder(
        itemCount: planProvider.coachPlans.length,
        itemBuilder: (context, index) {
          final plan = planProvider.coachPlans[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: ListTile(
              leading: const Icon(Icons.fitness_center), // Icono para plan
              title: Text(plan.planName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Ejercicios: ${plan.exercises.length} - Creado: ${DateFormat('dd/MM/yyyy').format(plan.createdAt.toDate())}'),
              trailing: IconButton( // Botón para Asignar (HU9)
                    icon: const Icon(Icons.assignment_ind_outlined, color: Colors.blue),
                    tooltip: 'Asignar Plan a Jugador',
                    onPressed: () {
                       // TODO: Implementar lógica/navegación para asignar plan (HU9)
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text('Asignar "${plan.planName}" (Pendiente)')),
                       );
                    },
                 ),
              onTap: () {
                 // TODO: Navegar a la vista de detalle del plan (HU6)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ver Detalles "${plan.planName}" (Pendiente)')),
                  );
              },
            ),
          );
        },
      );
    }
    // --- Lógica para Jugador ---
    else { // Es Jugador
      // Indicador de carga para asignaciones del jugador
      if (planProvider.isLoadingPlayerAssignments) {
        return const Center(child: CircularProgressIndicator());
      }
      // Mensaje de error para asignaciones del jugador
      if (planProvider.playerAssignmentsError != null) {
         return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: ${planProvider.playerAssignmentsError}', style: const TextStyle(color: Colors.red))));
      }
      // Mensaje si el jugador no tiene asignaciones
      if (planProvider.playerAssignments.isEmpty) {
         return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('No tienes planes de entrenamiento asignados actualmente.')));
      }

      // Mostrar lista de asignaciones del jugador (HU6 Jugador)
      return ListView.builder(
         itemCount: planProvider.playerAssignments.length,
         itemBuilder: (context, index) {
            final assignment = planProvider.playerAssignments[index];

            // Determinar icono y color según el estado de la asignación
            IconData statusIcon;
            Color statusColor;
            String statusText;
            switch(assignment.status) {
                case PlanAssignmentStatus.aceptado:
                    statusIcon = Icons.check_circle; statusColor = Colors.green; statusText = "Aceptado";
                    break;
                case PlanAssignmentStatus.rechazado:
                    statusIcon = Icons.cancel; statusColor = Colors.red; statusText = "Rechazado";
                    break;
                case PlanAssignmentStatus.pendiente:
                default:
                    statusIcon = Icons.pending_actions; statusColor = Colors.orange; statusText = "Pendiente";
                    break;
            }

             // Construye el ListTile para mostrar la asignación
             return Card(
               // Opcional: Color de fondo según estado
               // color: assignment.status == PlanAssignmentStatus.aceptado ? Colors.green.shade50 : assignment.status == PlanAssignmentStatus.rechazado ? Colors.red.shade50 : null,
               margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
               child: ListTile(
                 leading: Tooltip( // Muestra el texto del estado al mantener presionado el icono
                   message: statusText,
                   child: Icon(statusIcon, color: statusColor),
                 ),
                 // Muestra nombre del plan (si se guardó) o el ID
                 title: Text(assignment.planName ?? 'Plan ID: ${assignment.planId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                 subtitle: Text('Asignado: ${DateFormat('dd/MM/yyyy').format(assignment.assignedAt.toDate())}'),
                 // Botones de Aceptar/Rechazar solo si está pendiente (HU15)
                 trailing: assignment.status == PlanAssignmentStatus.pendiente
                    ? Row(
                        mainAxisSize: MainAxisSize.min, // Ocupar mínimo espacio
                        children: <Widget>[
                          // Botón Aceptar
                          IconButton(
                            icon: const Icon(Icons.check_circle_outline),
                            color: Colors.green,
                            tooltip: 'Aceptar Plan',
                            // TODO: Considerar deshabilitar botones si una acción está en progreso
                            onPressed: () async {
                              final prov = context.read<TrainingPlanProvider>();
                              final success = await prov.updatePlayerAssignmentStatus(
                                assignment.id,
                                PlanAssignmentStatus.aceptado
                              );
                              if (!success && mounted) {
                                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                   content: Text(prov.errorMessage ?? 'Error al aceptar'),
                                   backgroundColor: Colors.red,
                                 ));
                              }
                            },
                          ),
                          // Botón Rechazar
                          IconButton(
                            icon: const Icon(Icons.cancel_outlined),
                            color: Colors.red,
                            tooltip: 'Rechazar Plan',
                            onPressed: () async {
                               final prov = context.read<TrainingPlanProvider>();
                               final success = await prov.updatePlayerAssignmentStatus(
                                assignment.id,
                                PlanAssignmentStatus.rechazado
                              );
                               if (!success && mounted) {
                                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                   content: Text(prov.errorMessage ?? 'Error al rechazar'),
                                   backgroundColor: Colors.red,
                                 ));
                              }
                            },
                          ),
                        ],
                      )
                    : null, // No mostrar botones si ya fue aceptado/rechazado
                 onTap: () {
                   // TODO: Navegar a la vista de detalle del plan (HU6 Jugador)
                   // Probablemente pasarías assignment.planId a la vista de detalle
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ver Detalles "${assignment.planName ?? assignment.planId}" (Pendiente)')),
                    );
                 },
               ),
             );
         }
       );
    }
  }
}