// lib/models/plan_assignment_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

// Enum para manejar los estados de forma segura y legible
enum PlanAssignmentStatus {
  pendiente,
  aceptado,
  rechazado;

  // Convierte un String (de Firestore) a un valor del Enum
  static PlanAssignmentStatus fromString(String? statusString) {
    switch (statusString?.toLowerCase()) {
      case 'aceptado': return PlanAssignmentStatus.aceptado;
      case 'rechazado': return PlanAssignmentStatus.rechazado;
      case 'pendiente': // Valor por defecto si es null o no coincide
      default: return PlanAssignmentStatus.pendiente;
    }
  }

  // Convierte el Enum a un String para guardarlo en Firestore
  String toJson() => name; // 'name' devuelve el nombre del enum como string
}


class PlanAssignment {
  final String id;            // ID del documento de asignación
  final String planId;        // ID del TrainingPlan asignado
  final String playerId;      // UID del jugador
  final String assignedById;  // UID del entrenador que asignó
  final Timestamp assignedAt; // Fecha de asignación
  final PlanAssignmentStatus status; // Estado usando el Enum
  final Timestamp? respondedAt; // Fecha de aceptación/rechazo (opcional)

  // Campo denormalizado opcional para mostrar el nombre del plan fácilmente
  final String? planName;


  PlanAssignment({
    required this.id,
    required this.planId,
    required this.playerId,
    required this.assignedById,
    required this.assignedAt,
    required this.status,
    this.respondedAt,
    this.planName, // Incluir en constructor si se usa
  });

  // Método toMap (Omitido por brevedad, no creamos asignaciones desde el modelo directamente ahora)
  // Map<String, dynamic> toMap() { ... } // Necesario si crearas/actualizaras desde aquí

  // Factory para crear desde Firestore
  factory PlanAssignment.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic>? data = doc.data();
    if (data == null) throw StateError('Datos no encontrados para PlanAssignment ID: ${doc.id}');

    return PlanAssignment(
      id: doc.id,
      planId: data['planId'] ?? '',
      playerId: data['playerId'] ?? '',
      assignedById: data['assignedById'] ?? '',
      assignedAt: data['assignedAt'] ?? Timestamp.now(),
      // Usa el helper para convertir el String de Firestore al Enum
      status: PlanAssignmentStatus.fromString(data['status'] as String?),
      respondedAt: data['respondedAt'] as Timestamp?,
      planName: data['planName'] as String?, // Leer si está denormalizado
    );
  }

   @override
  String toString() {
    return 'PlanAssignment(id: $id, planId: $planId, playerId: $playerId, status: ${status.name})';
  }
}