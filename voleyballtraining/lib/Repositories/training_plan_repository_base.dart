// lib/repositories/training_plan_repository_base.dart
import '../models/training_plan_model.dart'; // Ajusta ruta si es necesario

// Contrato para las operaciones de Firestore relacionadas con TrainingPlan
abstract class TrainingPlanRepositoryBase {

  /// Añade un nuevo plan a Firestore. Devuelve el ID generado.
  Future<String> addTrainingPlan(TrainingPlan plan);

  /// Obtiene un Stream con la lista de planes creados por un entrenador específico.
  Stream<List<TrainingPlan>> getTrainingPlansForCreator(String creatorId);

  /// Obtiene los planes asignados a un jugador específico.
  /// (Se implementará más adelante cuando trabajemos con asignaciones)
  // Stream<List<TrainingPlan>> getTrainingPlansForPlayer(String playerId);

  /// Obtiene un plan específico por su ID. Devuelve null si no existe.
  Future<TrainingPlan?> getTrainingPlanById(String planId);

  // --- Métodos Futuros (Opcional) ---
  // Future<void> updateTrainingPlan(TrainingPlan plan);
  // Future<void> deleteTrainingPlan(String planId);
}