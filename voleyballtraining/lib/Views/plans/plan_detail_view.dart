// lib/views/plans/plan_detail_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Para formatear fechas

// Modelos y Repositorios (Asegúrate que las rutas sean correctas)
import '../../models/training_plan_model.dart';
import '../../repositories/training_plan_repository_base.dart';

// --- > Importaciones de Estilos <---
import 'package:voleyballtraining/Views/Styles/colors/app_colors.dart';
// --- > IMPORTAR EL CONTENEDOR <---
import 'package:voleyballtraining/Views/Styles/templates/container_default.dart';
// import 'package:voleyballtraining/Views/Styles/buttons/button_styles.dart'; // Para futuros botones

class PlanDetailView extends StatefulWidget {
  final String planId;

  const PlanDetailView({super.key, required this.planId});

  @override
  State<PlanDetailView> createState() => _PlanDetailViewState();
}

class _PlanDetailViewState extends State<PlanDetailView> {
  late Future<TrainingPlan?> _planFuture;
  bool _isInitialized = false;

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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // Mantenemos AppBar propio de la vista de detalle
      appBar: AppBar(
        title: const Text('Detalles del Plan'),
        // backgroundColor: Colors.transparent, // Opcional si quieres ver fondo global
        // elevation: 0,
      ),
      // Mantenemos fondo oscuro sólido por defecto del Scaffold
      // backgroundColor: AppColors.backgroundDark, // Ya viene del tema

      body: !_isInitialized
          // Estado inicial antes de empezar a cargar
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : FutureBuilder<TrainingPlan?>(
              future: _planFuture,
              builder: (context, snapshot) {
                // --- Estado: Cargando --- (Se muestra sobre fondo oscuro sólido)
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: colorScheme.primary)
                  );
                }
                // --- Estado: Error --- (Se muestra sobre fondo oscuro sólido)
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Error al cargar detalles: ${snapshot.error}',
                        style: textTheme.bodyLarge?.copyWith(color: colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    )
                  );
                }
                // --- Estado: Sin Datos --- (Se muestra sobre fondo oscuro sólido)
                if (!snapshot.hasData || snapshot.data == null) {
                  return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                            'El plan solicitado no fue encontrado.',
                            style: textTheme.bodyLarge?.copyWith(color: AppColors.textGray),
                            textAlign: TextAlign.center,
                        ),
                      )
                  );
                }

                // --- Estado: Datos Cargados -> Mostrarlos DENTRO del ContainerDefault ---
                final plan = snapshot.data!;

                // --- > Aplicamos la estructura de UserProfileView aquí <---
                return Center( // Centra el contenedor en la pantalla
                  child: FractionallySizedBox( // Le da tamaño porcentual
                    widthFactor: 0.9,  // 90% Ancho
                    heightFactor: 0.85, // 85% Alto (Ajusta si es necesario)
                    child: ContainerDefault( // Contenedor con Hinata, overlay, borde/resplandor
                      child: SingleChildScrollView( // Contenido scrollable DENTRO del contenedor
                        child: Padding(
                          // Padding interno del contenido
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nombre del Plan (Título Principal dentro del contenedor)
                              Text(
                                plan.planName,
                                style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              // Fecha de Creación
                              Text(
                                 'Creado: ${DateFormat('dd/MM/yyyy HH:mm').format(plan.createdAt.toDate())}',
                                 style: textTheme.bodySmall?.copyWith(color: AppColors.textGray),
                              ),
                              const Divider(height: 30, thickness: 1),

                              // Mostrar Tiempo Promedio si existe
                              if (plan.averageDailyTime != null && plan.averageDailyTime!.isNotEmpty) ...[
                                _buildDetailRow(context, 'Tiempo Promedio:', plan.averageDailyTime!),
                                const SizedBox(height: 15),
                              ],

                              // Mostrar Descripción si existe
                              if (plan.description != null && plan.description!.isNotEmpty) ...[
                                Text('Descripción:', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), // Label negrita
                                const SizedBox(height: 6),
                                Text(plan.description!, style: textTheme.bodyMedium),
                                const SizedBox(height: 25),
                              ],

                              // Mostrar Lista de Ejercicios
                              Text('Ejercicios (${plan.exercises.length}):', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), // Label negrita
                              const SizedBox(height: 10),
                              if (plan.exercises.isEmpty)
                                Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                        'No hay ejercicios detallados en este plan.',
                                        style: textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: AppColors.textGray)
                                     )
                                )
                              else
                                // Usamos Column para listar los ejercicios
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

                              // TODO: Añadir botones de acción aquí usando CustomButtonStyles
                              const SizedBox(height: 20), // Espacio al final

                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
                 // --- > Fin estructura aplicada <---
              },
            ),
          );
        }

      // Helper para construir filas de detalle (Label en negrita)
      Widget _buildDetailRow(BuildContext context, String label, String value) {
        final textTheme = Theme.of(context).textTheme;
        return Padding(
           padding: const EdgeInsets.symmetric(vertical: 4.0),
           child: Row(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(label, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), // Label en negrita
               const SizedBox(width: 8),
               Expanded(child: Text(value, style: textTheme.bodyMedium)), // Valor normal
             ],
           ),
        );
      }
    }