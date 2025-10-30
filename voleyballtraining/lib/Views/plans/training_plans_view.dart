import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:voleyballtraining/Views/plans/create_plan_view.dart';

// --- Importa Modelos y Providers ---
import '../../models/user_model.dart';
import '../../providers/training_plan_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/plan_assignment_model.dart';

// --- Importa Vistas ---
import 'plan_detail_view.dart';

// --- > IMPORTA EL TEMPLATE DE FONDO <---
import 'package:voleyballtraining/Views/Styles/templates/home_view_template.dart';
import 'package:voleyballtraining/Views/Styles/colors/app_colors.dart';

class TrainingPlansView extends StatefulWidget {
  final UserModel userModel;
  const TrainingPlansView({super.key, required this.userModel});

  @override
  State<TrainingPlansView> createState() => _TrainingPlansViewState();
}

class _TrainingPlansViewState extends State<TrainingPlansView> {
  bool _hasLoadedPlans = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Solo carga si no se ha hecho antes y si hay usuario cargado
    if (!_hasLoadedPlans && widget.userModel.userId.isNotEmpty) {
      final planProvider = context.read<TrainingPlanProvider>();
      final userProvider = context.read<UserProvider>();
      if (widget.userModel.role == 'Entrenador') {
        planProvider.loadCoachPlans();
        userProvider.loadUsers();
      } else {
        planProvider.loadPlayerAssignments();
      }
      _hasLoadedPlans = true;
    }
  }

  Future<void> _showPlayerSelectionDialog(BuildContext context, String planId, String planName) async {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final userProvider = context.read<UserProvider>();
    final List<UserModel> players = userProvider.playerUsers;

    if (players.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay jugadores registrados.'), backgroundColor: AppColors.warningDark));
      return;
    }

    final String? selectedPlayerId = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          title: Text('Asignar plan:\n"$planName"', style: textTheme.titleLarge),
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
                  // <<<--- AÑADIDO (para TC-001)
                  key: Key('select_player_item_${player.userId}'),
                  title: Text(player.fullName, style: textTheme.bodyLarge),
                  subtitle: Text(player.email, style: textTheme.bodyMedium?.copyWith(color: AppColors.textGray)),
                  onTap: () => Navigator.pop(dialogContext, player.userId),
                  splashColor: AppColors.primary.withOpacity(0.1),
                );
              },
              separatorBuilder: (context, index) =>
                  Divider(height: 1, thickness: 1, color: AppColors.divider.withOpacity(0.5)),
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
      final success =
          await planProvider.assignPlanToPlayer(planId: planId, playerId: selectedPlayerId, planName: planName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(success ? '¡Plan asignado!' : planProvider.errorMessage ?? 'Error al asignar.'),
            backgroundColor: success ? AppColors.successDark : colorScheme.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final planProvider = context.watch<TrainingPlanProvider>();
    final bool isCoach = widget.userModel.role == 'Entrenador';

    return HomeViewTemplate(
      title: 'Planes de Entrenamiento',
      body: _buildBody(planProvider, isCoach, context),
      floatingActionButton: isCoach
          ? FloatingActionButton(
              // <<<--- AÑADIDO (para TC-009, TC-010)
              key: const Key('plans_create_plan_fab'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              tooltip: 'Crear nuevo plan',
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreatePlanView()),
                );
              },
            )
          : null,
    );
  }

  Widget _buildBody(TrainingPlanProvider planProvider, bool isCoach, BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    if ((isCoach && planProvider.isLoadingCoachPlans) || (!isCoach && planProvider.isLoadingPlayerAssignments)) {
      return Center(child: CircularProgressIndicator(color: colorScheme.primary));
    }

    final String? error = isCoach ? planProvider.coachPlansError : planProvider.playerAssignmentsError;
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error: $error', style: textTheme.bodyLarge?.copyWith(color: colorScheme.error), textAlign: TextAlign.center),
        ),
      );
    }

    if (isCoach) {
      if (planProvider.coachPlans.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Aún no has creado ningún plan.\nUsa el botón (+) para empezar!',
              style: textTheme.bodyLarge?.copyWith(color: AppColors.textGray),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 80),
        itemCount: planProvider.coachPlans.length,
        itemBuilder: (context, index) {
          final plan = planProvider.coachPlans[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: ListTile(
              // <<<--- AÑADIDO (para TC-001)
              key: Key('plan_item_${plan.id}'),
              leading: Icon(Icons.fitness_center, color: colorScheme.primary.withOpacity(0.8)),
              title: Text(plan.planName, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              subtitle: Text(
                'Ejercicios: ${plan.exercises.length} - Creado: ${DateFormat('dd/MM/yyyy').format(plan.createdAt.toDate())}',
                style: textTheme.bodySmall,
              ),
              trailing: IconButton(
                // <<<--- AÑADIDO (para TC-001)
                key: Key('plan_assign_button_${plan.id}'),
                icon: Icon(Icons.assignment_ind_outlined, color: colorScheme.secondary),
                tooltip: 'Asignar Plan a Jugador',
                onPressed: () => _showPlayerSelectionDialog(context, plan.id, plan.planName),
              ),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlanDetailView(planId: plan.id))),
              splashColor: AppColors.primary.withOpacity(0.1),
            ),
          );
        },
      );
    } else {
      if (planProvider.playerAssignments.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('No tienes planes asignados.', style: textTheme.bodyLarge?.copyWith(color: AppColors.textGray)),
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 80),
        itemCount: planProvider.playerAssignments.length,
        itemBuilder: (context, index) {
          final assignment = planProvider.playerAssignments[index];
          IconData statusIcon;
          Color statusColor;
          String statusText;
          switch (assignment.status) {
            case PlanAssignmentStatus.aceptado:
              statusIcon = Icons.check_circle;
              statusColor = AppColors.successDark;
              statusText = "Aceptado";
              break;
            case PlanAssignmentStatus.rechazado:
              statusIcon = Icons.cancel;
              statusColor = AppColors.errorDark;
              statusText = "Rechazado";
              break;
            case PlanAssignmentStatus.completado:
              statusIcon = Icons.done_all;
              statusColor = AppColors.secondary;
              statusText = "Completado";
              break;
            case PlanAssignmentStatus.pendiente:
            default:
              statusIcon = Icons.pending_actions;
              statusColor = AppColors.warningDark;
              statusText = "Pendiente";
              break;
          }

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: ListTile(
              // <<<--- AÑADIDO (para TC-002)
              key: Key('assignment_item_${assignment.id}'),
              leading: Tooltip(message: statusText, child: Icon(statusIcon, color: statusColor)),
              title: Text(assignment.planName ?? 'Plan ID: ${assignment.planId}', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              subtitle: Text(
                'Asignado: ${DateFormat('dd/MM/yyyy').format(assignment.assignedAt.toDate())}\nEstado: $statusText',
                style: textTheme.bodySmall,
              ),
              isThreeLine: true,
              trailing: assignment.status == PlanAssignmentStatus.pendiente
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          // <<<--- AÑADIDO (para TC-002)
                          key: Key('assignment_accept_button_${assignment.id}'),
                          icon: const Icon(Icons.check_circle_outline),
                          color: AppColors.successDark,
                          tooltip: 'Aceptar Plan',
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(),
                          splashRadius: 20,
                          onPressed: () async {
                            final prov = context.read<TrainingPlanProvider>();
                            final success = await prov.updatePlayerAssignmentStatus(assignment.id, PlanAssignmentStatus.aceptado);
                            if (mounted && !success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: const Text('Error al aceptar'), backgroundColor: colorScheme.error),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          // <<<--- AÑADIDO (para TC-002)
                          key: Key('assignment_reject_button_${assignment.id}'),
                          icon: const Icon(Icons.cancel_outlined),
                          color: AppColors.errorDark,
                          tooltip: 'Rechazar Plan',
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(),
                          splashRadius: 20,
                          onPressed: () async {
                            final prov = context.read<TrainingPlanProvider>();
                            final success = await prov.updatePlayerAssignmentStatus(assignment.id, PlanAssignmentStatus.rechazado);
                            if (mounted && !success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: const Text('Error al rechazar'), backgroundColor: colorScheme.error),
                              );
                            }
                          },
                        ),
                      ],
                    )
                  : null,
              onTap: () {
                if (assignment.planId.isNotEmpty) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PlanDetailView(planId: assignment.planId)));
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: const Text('ID de plan inválido'), backgroundColor: colorScheme.error),
                    );
                  }
                }
              },
              splashColor: AppColors.primary.withOpacity(0.1),
            ),
          );
        },
      );
    }
  }
}