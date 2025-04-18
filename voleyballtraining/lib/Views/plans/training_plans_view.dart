// lib/views/plans/training_plans_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// --- Importa Modelos y Providers ---
import '../../models/user_model.dart';
import '../../providers/training_plan_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/plan_assignment_model.dart';

// --- Importa Vistas ---
// import 'create_plan_view.dart'; // No se usa aquí
import 'plan_detail_view.dart';

// --- > Importaciones de Estilos <---
import 'package:voleyballtraining/Views/Styles/colors/app_colors.dart';
// --- > IMPORTAR EL CONTENEDOR <---
import 'package:voleyballtraining/Views/Styles/templates/container_default.dart';
// import 'package:voleyballtraining/Views/Styles/buttons/button_styles.dart'; // No se usan botones grandes aquí

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
        context.read<UserProvider>().loadUsers();
      } else {
        planProvider.loadPlayerAssignments();
      }
    });
  }

  Future<void> _showPlayerSelectionDialog(BuildContext context, String planId, String planName) async {
     final theme = Theme.of(context);
     final textTheme = theme.textTheme;
     final colorScheme = theme.colorScheme;
     final userProvider = context.read<UserProvider>();
     final List<UserModel> players = userProvider.playerUsers;

     if (players.isEmpty && mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
          SnackBar( content: const Text('No hay jugadores registrados.'), backgroundColor: AppColors.warningDark)
       );
       return;
     }

     final String? selectedPlayerId = await showDialog<String>(
       context: context,
       builder: (BuildContext dialogContext) {
         // ... (Código del AlertDialog sin cambios aquí, ya estaba estilizado) ...
         return AlertDialog(
           backgroundColor: AppColors.surfaceDark,
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
           title: Text('Asignar plan:\n"${planName}"', style: textTheme.titleLarge),
           contentPadding: EdgeInsets.zero,
           content: Container(
             width: double.maxFinite,
             constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
             child: ListView.separated(
               shrinkWrap: true,
               itemCount: players.length,
               itemBuilder: (listContext, index) {
                 final player = players[index];
                 return ListTile(
                   title: Text(player.fullName, style: textTheme.bodyLarge),
                   subtitle: Text(player.email, style: textTheme.bodyMedium?.copyWith(color: AppColors.textGray)),
                   onTap: () => Navigator.pop(dialogContext, player.userId),
                   splashColor: AppColors.primary.withOpacity(0.1),
                 );
               },
               separatorBuilder: (context, index) => Divider(
                   height: 1, thickness: 1, color: AppColors.divider.withOpacity(0.5)),
             ),
           ),
           actions: <Widget>[
             TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.pop(dialogContext)),
           ],
           actionsPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
         );
       },
     );

     if (selectedPlayerId != null && mounted) {
        final planProvider = context.read<TrainingPlanProvider>();
        final success = await planProvider.assignPlanToPlayer(planId: planId, playerId: selectedPlayerId, planName: planName);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
             content: Text(success ? '¡Plan asignado!' : planProvider.errorMessage ?? 'Error al asignar.'),
             backgroundColor: success ? AppColors.successDark : colorScheme.error
          ));
        }
     }
  }

  @override
  Widget build(BuildContext context) {
    // Quitamos el Scaffold de aquí
    final planProvider = context.watch<TrainingPlanProvider>();
    final bool isCoach = widget.userModel.role == 'Entrenador';
    // Devolvemos directamente el contenido del cuerpo
    return _buildBody(planProvider, isCoach, context);
  }

  // El cuerpo de la vista
  Widget _buildBody(TrainingPlanProvider planProvider, bool isCoach, BuildContext context) {
     final theme = Theme.of(context);
     final textTheme = theme.textTheme;
     final colorScheme = theme.colorScheme;

    // --- Estado de Carga ---
    if ((isCoach && planProvider.isLoadingCoachPlans) || (!isCoach && planProvider.isLoadingPlayerAssignments)) {
      // --- > Envuelto en ContainerDefault <---
      return ContainerDefault(
          margin: const EdgeInsets.all(16), // Margen para separar de bordes
          child: Center(child: CircularProgressIndicator(color: colorScheme.primary)),
      );
    }

    // --- Estado de Error ---
    final String? error = isCoach ? planProvider.coachPlansError : planProvider.playerAssignmentsError;
    if (error != null) {
       // --- > Envuelto en ContainerDefault <---
       return ContainerDefault(
          margin: const EdgeInsets.all(16),
          child: Center(child: Padding(
            padding: const EdgeInsets.all(16.0), // Padding interno del texto
            child: Text('Error: $error', style: textTheme.bodyLarge?.copyWith(color: colorScheme.error), textAlign: TextAlign.center)
          )),
       );
    }

    // --- Lógica para Entrenador ---
    if (isCoach) {
       if (planProvider.coachPlans.isEmpty) {
         // --- > Envuelto en ContainerDefault <---
         return ContainerDefault(
            margin: const EdgeInsets.all(16),
            child: Center(child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Aún no has creado ningún plan.\nUsa el botón (+) para empezar!',
                style: textTheme.bodyLarge?.copyWith(color: AppColors.textGray),
                textAlign: TextAlign.center,
              )
            )),
         );
       }

       // --- > ListView envuelto en ContainerDefault <---
       return ContainerDefault(
          // Quitamos el padding interno del ContainerDefault para la lista
          padding: EdgeInsets.zero,
          // Ajustamos margen si es necesario (o quitamos si queremos que llene más espacio)
          margin: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 80), // Margen exterior y espacio para FAB
          child: ListView.builder(
             // El padding interno lo manejan los Card o el ListView si es necesario
             // padding: const EdgeInsets.only(top: 8.0, bottom: 8.0), // Podemos añadir padding aquí
             itemCount: planProvider.coachPlans.length,
             itemBuilder: (context, index) {
               final plan = planProvider.coachPlans[index];
               // Usamos Card para cada elemento, hereda estilo del CardTheme
               return Card(
                 // El margen del Card crea separación entre elementos
                 margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                 child: ListTile(
                   leading: Icon(Icons.fitness_center, color: colorScheme.primary.withOpacity(0.8)),
                   title: Text(plan.planName, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                   subtitle: Text(
                       'Ejercicios: ${plan.exercises.length} - Creado: ${DateFormat('dd/MM/yyyy').format(plan.createdAt.toDate())}',
                       style: textTheme.bodySmall,
                    ),
                   trailing: IconButton(
                       icon: Icon(Icons.assignment_ind_outlined, color: colorScheme.secondary),
                       tooltip: 'Asignar Plan a Jugador',
                       onPressed: () => _showPlayerSelectionDialog(context, plan.id, plan.planName),
                   ),
                   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlanDetailView(planId: plan.id))),
                   splashColor: AppColors.primary.withOpacity(0.1),
                 ),
               );
             },
          ),
       );
    }
    // --- Lógica para Jugador ---
    else {
       if (planProvider.playerAssignments.isEmpty) {
           // --- > Envuelto en ContainerDefault <---
          return ContainerDefault(
              margin: const EdgeInsets.all(16),
              child: Center(child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('No tienes planes asignados.', style: textTheme.bodyLarge?.copyWith(color: AppColors.textGray))
             )),
          );
       }

        // --- > ListView envuelto en ContainerDefault <---
       return ContainerDefault(
         padding: EdgeInsets.zero,
         margin: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 80), // Margen exterior y espacio para FAB/NavBar
         child: ListView.builder(
           // padding: const EdgeInsets.only(top: 8.0, bottom: 8.0), // Padding interno de la lista
           itemCount: planProvider.playerAssignments.length,
           itemBuilder: (context, index) {
             final assignment = planProvider.playerAssignments[index];
             IconData statusIcon; Color statusColor; String statusText;
             switch(assignment.status) {
               case PlanAssignmentStatus.aceptado: statusIcon = Icons.check_circle; statusColor = AppColors.successDark; statusText = "Aceptado"; break;
               case PlanAssignmentStatus.rechazado: statusIcon = Icons.cancel; statusColor = AppColors.errorDark; statusText = "Rechazado"; break;
               case PlanAssignmentStatus.pendiente:
               default: statusIcon = Icons.pending_actions; statusColor = AppColors.warningDark; statusText = "Pendiente"; break;
             }

             return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
               child: ListTile(
                 leading: Tooltip(message: statusText, child: Icon(statusIcon, color: statusColor)),
                 title: Text(assignment.planName ?? 'Plan ID: ${assignment.planId}', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                 subtitle: Text(
                    'Asignado: ${DateFormat('dd/MM/yyyy').format(assignment.assignedAt.toDate())}\nEstado: $statusText',
                    style: textTheme.bodySmall
                 ),
                 isThreeLine: true,
                 trailing: assignment.status == PlanAssignmentStatus.pendiente
                   ? Row( mainAxisSize: MainAxisSize.min, children: <Widget>[
                       IconButton(
                         icon: const Icon(Icons.check_circle_outline), color: AppColors.successDark, tooltip: 'Aceptar Plan',
                         padding: EdgeInsets.zero, visualDensity: VisualDensity.compact, constraints: const BoxConstraints(), splashRadius: 20,
                         onPressed: () async { /* ... Lógica Aceptar ... */
                           final prov = context.read<TrainingPlanProvider>();
                           final success = await prov.updatePlayerAssignmentStatus(assignment.id, PlanAssignmentStatus.aceptado);
                            if (mounted && !success) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Error al aceptar'), backgroundColor: colorScheme.error)); }
                         },
                       ),
                       const SizedBox(width: 4),
                       IconButton(
                         icon: const Icon(Icons.cancel_outlined), color: AppColors.errorDark, tooltip: 'Rechazar Plan',
                         padding: EdgeInsets.zero, visualDensity: VisualDensity.compact, constraints: const BoxConstraints(), splashRadius: 20,
                         onPressed: () async { /* ... Lógica Rechazar ... */
                            final prov = context.read<TrainingPlanProvider>();
                            final success = await prov.updatePlayerAssignmentStatus(assignment.id, PlanAssignmentStatus.rechazado);
                             if (mounted && !success) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Error al rechazar'), backgroundColor: colorScheme.error)); }
                         },
                       ),
                     ])
                   : null,
                 onTap: () {
                   if (assignment.planId.isNotEmpty) {
                     Navigator.push(context, MaterialPageRoute(builder: (_) => PlanDetailView(planId: assignment.planId)));
                   } else {
                     if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('ID de plan inválido'), backgroundColor: colorScheme.error)); }
                   }
                 },
                 splashColor: AppColors.primary.withOpacity(0.1),
               ),
             );
           }
         ),
       );
    }
  }
}