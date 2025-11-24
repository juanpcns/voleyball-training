import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/training_plan_model.dart';
import '../../repositories/training_plan_repository_base.dart';
import 'package:voleyballtraining/Views/Styles/colors/app_colors.dart';
import 'package:voleyballtraining/Views/Styles/templates/container_default.dart';

// <<< NUEVOS IMPORTS PARA ESTADO COMPLETADO >>>
import '../../providers/auth_provider.dart';
import '../../repositories/plan_assignment_repository_base.dart';
import '../../models/plan_assignment_model.dart';

class PlanDetailView extends StatefulWidget {
  final String planId;

  const PlanDetailView({super.key, required this.planId});

  @override
  State<PlanDetailView> createState() => _PlanDetailViewState();
}

class _PlanDetailViewState extends State<PlanDetailView> {
  late Future<TrainingPlan?> _planFuture;
  bool _isInitialized = false;
  bool _marcandoCompletado = false; // Para evitar múltiples toques

  @override
  void initState() {
    super.initState();
    if (!_isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final planRepository = context.read<TrainingPlanRepositoryBase>();
          setState(() {
            _planFuture = planRepository.getTrainingPlanById(widget.planId);
            _isInitialized = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // >>> Obtén el usuario actual y su rol <<<
    final user = context.read<AuthProvider>().currentUserModel;
    final bool isTrainer = user != null && user.role == 'Entrenador';

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Plan'),
      ),
      body: !_isInitialized
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : FutureBuilder<TrainingPlan?>(
              future: _planFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(color: colorScheme.primary));
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Error al cargar detalles: ${snapshot.error}',
                        style: textTheme.bodyLarge?.copyWith(color: colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'El plan solicitado no fue encontrado.',
                        style: textTheme.bodyLarge?.copyWith(color: AppColors.textGray),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final plan = snapshot.data!;

                return Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.9,
                    heightFactor: 0.85,
                    child: ContainerDefault(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan.planName,
                                style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Creado: ${DateFormat('dd/MM/yyyy HH:mm').format(plan.createdAt.toDate())}',
                                style: textTheme.bodySmall?.copyWith(color: AppColors.textGray),
                              ),
                              const Divider(height: 30, thickness: 1),
                              if (plan.averageDailyTime != null && plan.averageDailyTime!.isNotEmpty) ...[
                                _buildDetailRow(context, 'Tiempo Promedio:', plan.averageDailyTime!),
                                const SizedBox(height: 15),
                              ],
                              if (plan.description != null && plan.description!.isNotEmpty) ...[
                                Text('Descripción:', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text(plan.description!, style: textTheme.bodyMedium),
                                const SizedBox(height: 25),
                              ],
                              Text('Ejercicios (${plan.exercises.length}):', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              if (plan.exercises.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    'No hay ejercicios detallados en este plan.',
                                    style: textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: AppColors.textGray),
                                  ),
                                )
                              else
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(plan.exercises.length, (index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${index + 1}. ', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                                          Expanded(child: Text(plan.exercises[index], style: textTheme.bodyMedium)),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              const SizedBox(height: 20),
                              // >>> SOLO aparece si NO es entrenador <<<
                              if (!isTrainer)
                                Center(
                                  child: ElevatedButton(
                                    // <<<--- AÑADIDO
                                    key: const Key('plan_detail_complete_button'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.successDark,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: _marcandoCompletado
                                        ? null
                                        : () async {
                                            setState(() {
                                              _marcandoCompletado = true;
                                            });
                                            try {
                                              final assignmentRepo = context.read<PlanAssignmentRepositoryBase>();
                                              final userId = user?.userId;
                                              if (userId == null) throw Exception("Usuario no identificado.");

                                              // Busca la asignación de este usuario para este plan
                                              final assignmentsStream = assignmentRepo.getAssignmentsForPlayer(userId);
                                              final assignments = await assignmentsStream.first;
                                              final assignment = assignments.firstWhere(
                                                (a) => a.planId == plan.id,
                                                orElse: () => throw Exception('No assignment found'),
                                              );

                                              await assignmentRepo.updateAssignmentStatus(
                                                assignment.id,
                                                PlanAssignmentStatus.completado,
                                              );
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Plan marcado como completado.'),
                                                  backgroundColor: AppColors.successDark,
                                                ),
                                              );
                                                                                        } catch (e) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Ocurrió un error: $e'),
                                                  backgroundColor: AppColors.errorDark,
                                                ),
                                              );
                                            } finally {
                                              setState(() {
                                                _marcandoCompletado = false;
                                              });
                                            }
                                          },
                                    child: _marcandoCompletado
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Text(
                                            'Marcar como completado',
                                            style: textTheme.titleMedium?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: textTheme.bodyMedium)),
        ],
      ),
    );
  }
}