
// lib/repositories/plan_assignment_repository_base.dart
import '../models/plan_assignment_model.dart'; // Ajusta ruta si es necesario

abstract class PlanAssignmentRepositoryBase {

  /// Obtiene un Stream con las asignaciones de un jugador específico,
  /// ordenadas por fecha de asignación descendente.
  Stream<List<PlanAssignment>> getAssignmentsForPlayer(String playerId);

  /// Actualiza el estado de una asignación (para HU15: Aceptar/Rechazar).
  Future<void> updateAssignmentStatus(String assignmentId, PlanAssignmentStatus newStatus);

  /// Crea una nueva asignación (para HU9: Asignar Plan).
  Future<void> createAssignment({
     required String planId,
     required String playerId,
     required String coachId,
     String? planName, // Opcional si denormalizamos nombre del plan
     // Podrías añadir más campos denormalizados si es necesario
  });

}