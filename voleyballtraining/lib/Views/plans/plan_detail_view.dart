// lib/views/plans/plan_detail_view.dart (Completo y Funcional)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Para formatear fechas si es necesario

// Importa el modelo y el repositorio base (ajusta rutas)
import '../../models/training_plan_model.dart';
import '../../repositories/training_plan_repository_base.dart';

class PlanDetailView extends StatefulWidget {
  final String planId; // Recibe el ID del plan a mostrar

  const PlanDetailView({super.key, required this.planId});

  @override
  State<PlanDetailView> createState() => _PlanDetailViewState();
}

class _PlanDetailViewState extends State<PlanDetailView> {
  // Futuro para cargar los detalles del plan una sola vez
  late Future<TrainingPlan?> _planFuture;

  @override
  void initState() {
    super.initState();
    // Iniciamos la carga en initState usando el repositorio del Provider
    // Usamos context.read porque estamos fuera del método build principal
    final planRepository = context.read<TrainingPlanRepositoryBase>();
    _planFuture = planRepository.getTrainingPlanById(widget.planId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Plan'), // Título del AppBar
      ),
      // Usamos FutureBuilder para manejar el estado de carga del plan
      body: FutureBuilder<TrainingPlan?>(
        future: _planFuture, // El futuro que obtiene los datos
        builder: (context, snapshot) {
          // --- Estado: Cargando ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // --- Estado: Error ---
          if (snapshot.hasError) {
            print("Error cargando plan ${widget.planId}: ${snapshot.error}");
            return Center(child: Text('Error al cargar detalles: ${snapshot.error}'));
          }
          // --- Estado: Sin Datos / Plan No Encontrado ---
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('El plan solicitado no fue encontrado.'));
          }

          // --- Estado: Datos Cargados Exitosamente ---
          final plan = snapshot.data!; // Tenemos el objeto TrainingPlan

          // Usamos SingleChildScrollView por si el contenido es muy largo
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0), // Padding general
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Alinear todo a la izquierda
              children: [
                // Nombre del Plan (Título Principal)
                Text(
                  plan.planName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                 // Fecha de Creación
                Text(
                   'Creado: ${DateFormat('dd/MM/yyyy HH:mm').format(plan.createdAt.toDate())}',
                   style: Theme.of(context).textTheme.bodySmall,
                 ),
                const Divider(height: 25, thickness: 1), // Separador

                // Mostrar Tiempo Promedio si existe
                if (plan.averageDailyTime != null && plan.averageDailyTime!.isNotEmpty) ...[
                  _buildDetailRow(context, 'Tiempo Promedio:', plan.averageDailyTime!),
                  const SizedBox(height: 10),
                ],

                // Mostrar Descripción si existe
                if (plan.description != null && plan.description!.isNotEmpty) ...[
                  Text('Descripción:', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(plan.description!),
                  const SizedBox(height: 20),
                ],

                // Mostrar Lista de Ejercicios
                Text('Ejercicios (${plan.exercises.length}):', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (plan.exercises.isEmpty)
                  const Text('  - No hay ejercicios detallados en este plan.') // Sangría leve
                else
                  // Usamos Column para listar los ejercicios
                  Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: List.generate(plan.exercises.length, (index) {
                       return Padding(
                         padding: const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0), // Sangría y espacio vertical
                         child: Row(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text('${index + 1}. ', style: const TextStyle(fontWeight: FontWeight.bold)), // Numeración
                             Expanded(child: Text(plan.exercises[index])), // Descripción
                           ],
                         ),
                       );
                     }),
                  ),

                // TODO: Añadir aquí botones de acción si fueran necesarios en esta vista
                // Por ejemplo, un botón "Marcar como completado" para el jugador,
                // o "Editar/Eliminar/Asignar" para el coach.

              ],
            ),
          );
        },
      ),
    );
  }

  // Helper para construir filas de detalle Label: Valor
  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(width: 8),
        Expanded(child: Text(value)),
      ],
    );
  }
}