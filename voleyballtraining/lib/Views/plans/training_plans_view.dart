// lib/views/plans/training_plans_view.dart (VERSIÓN FINAL CORREGIDA)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// --- Importa Modelos y Providers ---
import '../../models/user_model.dart';
import '../../providers/training_plan_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/plan_assignment_model.dart';

// --- Importa Vistas ---
import 'create_plan_view.dart';
import 'plan_detail_view.dart';


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
    // Cargar datos apropiados al iniciar la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final planProvider = context.read<TrainingPlanProvider>();
      if (widget.userModel.role == 'Entrenador') {
        planProvider.loadCoachPlans();
        context.read<UserProvider>().loadUsers();
      } else {
        planProvider.loadPlayerAssignments();
      }
    });
  }

  /// Muestra diálogo para seleccionar jugador (para Coach)
  Future<void> _showPlayerSelectionDialog(BuildContext context, String planId, String planName) async {
     final userProvider = context.read<UserProvider>();
     final List<UserModel> players = userProvider.playerUsers;

     if (players.isEmpty && mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay jugadores registrados.'), backgroundColor: Colors.orange)
       );
       return;
     }

     final String? selectedPlayerId = await showDialog<String>(
       context: context,
       builder: (BuildContext dialogContext) {
         return AlertDialog(
           title: Text('Asignar plan:\n"${planName}"', style: const TextStyle(fontSize: 18)),
           contentPadding: const EdgeInsets.only(top: 10.0, left: 0, right: 0, bottom: 0),
           content: Container(
             width: double.maxFinite,
             constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
             child: ListView.builder(
               shrinkWrap: true,
               itemCount: players.length,
               itemBuilder: (listContext, index) {
                 final player = players[index];
                 return ListTile(
                   title: Text(player.fullName),
                   subtitle: Text(player.email),
                   onTap: () => Navigator.pop(dialogContext, player.userId),
                 );
               },
             ),
           ),
           actions: <Widget>[ TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.pop(dialogContext)), ],
         );
       },
     );

     if (selectedPlayerId != null && mounted) {
        final planProvider = context.read<TrainingPlanProvider>();
        final success = await planProvider.assignPlanToPlayer(planId: planId, playerId: selectedPlayerId, planName: planName);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? '¡Plan asignado!' : planProvider.errorMessage ?? 'Error al asignar.'), backgroundColor: success ? Colors.green : Colors.red));
        }
     }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCoach = widget.userModel.role == 'Entrenador';
    final planProvider = context.watch<TrainingPlanProvider>();

    return Scaffold(
      body: _buildBody(planProvider, isCoach, context),
      floatingActionButton: isCoach
          ? FloatingActionButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePlanView())), // Correcto
              tooltip: 'Crear Nuevo Plan',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildBody(TrainingPlanProvider planProvider, bool isCoach, BuildContext context) {

    // --- Lógica para Entrenador ---
    if (isCoach) {
       if (planProvider.isLoadingCoachPlans) return const Center(child: CircularProgressIndicator());
       if (planProvider.coachPlansError != null) return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: ${planProvider.coachPlansError}', style: const TextStyle(color: Colors.red))));
       if (planProvider.coachPlans.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('Aún no has creado ningún plan.\nUsa el botón (+) para empezar!', textAlign: TextAlign.center)));

       return ListView.builder(
           itemCount: planProvider.coachPlans.length,
           itemBuilder: (context, index) {
             final plan = planProvider.coachPlans[index];
             return Card(
               margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
               child: ListTile(
                 leading: const Icon(Icons.fitness_center),
                 title: Text(plan.planName, style: const TextStyle(fontWeight: FontWeight.bold)),
                 subtitle: Text('Ejercicios: ${plan.exercises.length} - Creado: ${DateFormat('dd/MM/yyyy').format(plan.createdAt.toDate())}'),
                 trailing: IconButton(
                       icon: const Icon(Icons.assignment_ind_outlined, color: Colors.blue),
                       tooltip: 'Asignar Plan a Jugador',
                       onPressed: () => _showPlayerSelectionDialog(context, plan.id, plan.planName), // Correcto
                    ),
                 onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlanDetailView(planId: plan.id))), // Correcto
               ),
             );
           },
       );
    }
    // --- Lógica para Jugador ---
    else { // Es Jugador
      if (planProvider.isLoadingPlayerAssignments) return const Center(child: CircularProgressIndicator());
      if (planProvider.playerAssignmentsError != null) return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: ${planProvider.playerAssignmentsError}', style: const TextStyle(color: Colors.red))));
      if (planProvider.playerAssignments.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('No tienes planes asignados.')));

      return ListView.builder(
         itemCount: planProvider.playerAssignments.length,
         itemBuilder: (context, index) {
            final assignment = planProvider.playerAssignments[index];

            // --- SWITCH CORREGIDO Y COMPLETO ---
            IconData statusIcon;
            Color statusColor;
            String statusText;
            switch(assignment.status) {
                case PlanAssignmentStatus.aceptado: statusIcon = Icons.check_circle; statusColor = Colors.green; statusText = "Aceptado"; break;
                case PlanAssignmentStatus.rechazado: statusIcon = Icons.cancel; statusColor = Colors.red; statusText = "Rechazado"; break;
                // Caso explícito para Pendiente (cubre el default también)
                case PlanAssignmentStatus.pendiente:
                default:
                    statusIcon = Icons.pending_actions; statusColor = Colors.orange; statusText = "Pendiente"; break;
            }
            // --- FIN SWITCH CORREGIDO ---

             return Card(
               margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
               child: ListTile(
                 leading: Tooltip(message: statusText, child: Icon(statusIcon, color: statusColor)),
                 title: Text(assignment.planName ?? 'Plan ID: ${assignment.planId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                 subtitle: Text('Asignado: ${DateFormat('dd/MM/yyyy').format(assignment.assignedAt.toDate())}\nEstado: $statusText'),
                 isThreeLine: true,
                 trailing: assignment.status == PlanAssignmentStatus.pendiente
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          // IconButton Aceptar (con ajustes de layout)
                          IconButton(
                            icon: const Icon(Icons.check_circle_outline), color: Colors.green, tooltip: 'Aceptar Plan',
                            padding: EdgeInsets.zero, visualDensity: VisualDensity.compact, constraints: const BoxConstraints(), splashRadius: 20,
                            onPressed: () async {
                              final prov = context.read<TrainingPlanProvider>();
                              final success = await prov.updatePlayerAssignmentStatus(assignment.id, PlanAssignmentStatus.aceptado);
                              if (!success && mounted) { /* SnackBar Error */ }
                            },
                          ),
                          // IconButton Rechazar (con ajustes de layout)
                          IconButton(
                            icon: const Icon(Icons.cancel_outlined), color: Colors.red, tooltip: 'Rechazar Plan',
                            padding: EdgeInsets.zero, visualDensity: VisualDensity.compact, constraints: const BoxConstraints(), splashRadius: 20,
                            onPressed: () async {
                               final prov = context.read<TrainingPlanProvider>();
                               final success = await prov.updatePlayerAssignmentStatus(assignment.id, PlanAssignmentStatus.rechazado);
                               if (!success && mounted) { /* SnackBar Error */ }
                            },
                          ),
                        ],
                      )
                    : null,
                 onTap: () { // Navegar a detalles
                   if (assignment.planId.isNotEmpty) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => PlanDetailView(planId: assignment.planId)));
                   } else { /* SnackBar error ID inválido */ }
                 },
               ),
             );
         }
       );
    }
  }
}