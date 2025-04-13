// lib/repositories/firestore_plan_assignment_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // para kDebugMode
import '../models/plan_assignment_model.dart'; // Ajusta ruta
import 'plan_assignment_repository_base.dart'; // Ajusta ruta

class FirestorePlanAssignmentRepository implements PlanAssignmentRepositoryBase {
  final FirebaseFirestore _firestore;

  FirestorePlanAssignmentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Referencia a la colección 'plan_assignments' en Firestore
  CollectionReference<Map<String, dynamic>> get _assignmentsCollection =>
      _firestore.collection('plan_assignments'); // Nombre de la colección

  @override
  Stream<List<PlanAssignment>> getAssignmentsForPlayer(String playerId) {
    if (kDebugMode) print("--- FirestorePARepo: Obteniendo stream de asignaciones para Player: $playerId ---");
    final query = _assignmentsCollection
        .where('playerId', isEqualTo: playerId) // Filtrar por jugador
        .orderBy('assignedAt', descending: true); // Ordenar por fecha

    // Escuchar cambios en tiempo real
    return query.snapshots().map((snapshot) {
      if (kDebugMode) print("--- FirestorePARepo: Recibido snapshot con ${snapshot.docs.length} asignaciones ---");
      // Mapear cada documento a un objeto PlanAssignment
      return snapshot.docs.map((doc) {
        try {
          return PlanAssignment.fromFirestore(doc);
        } catch (e) {
          if (kDebugMode) print("Error convirtiendo PlanAssignment ${doc.id}: $e");
          return null; // Ignorar documentos con error
        }
      }).whereType<PlanAssignment>().toList(); // Filtrar nulos y convertir a lista
    }).handleError((error) { // Manejar errores del stream
       if (kDebugMode) print("--- FirestorePARepo: ERROR en stream getAssignmentsForPlayer: $error ---");
       // Propagar el error o devolver lista vacía
       // throw error;
       return <PlanAssignment>[]; // Devolver lista vacía en caso de error del stream
    });
  }

  @override
  Future<void> updateAssignmentStatus(String assignmentId, PlanAssignmentStatus newStatus) async {
     if (kDebugMode) print("--- FirestorePARepo: Actualizando estado de $assignmentId a ${newStatus.name} ---");
    try {
      await _assignmentsCollection.doc(assignmentId).update({
        'status': newStatus.toJson(), // Guardar el string del enum
        'respondedAt': Timestamp.now(), // Marcar fecha de respuesta
      });
       if (kDebugMode) print("--- FirestorePARepo: Estado de $assignmentId actualizado ---");
    } on FirebaseException catch (e) {
       if (kDebugMode) print("Error Firestore al actualizar asignación ($assignmentId): $e");
      throw Exception('Error al actualizar el estado del plan.'); // Error más genérico para la UI
    } catch (e) {
       if (kDebugMode) print("Error inesperado al actualizar asignación ($assignmentId): $e");
       throw Exception('Ocurrió un error inesperado.');
    }
  }

  @override
  Future<void> createAssignment({
     required String planId,
     required String playerId,
     required String coachId,
     String? planName,
  }) async {
    if (kDebugMode) print("--- FirestorePARepo: Creando asignación para Plan: $planId, Player: $playerId ---");
    try {
      await _assignmentsCollection.add({
        'planId': planId,
        'playerId': playerId,
        'assignedById': coachId,
        'assignedAt': Timestamp.now(),
        'status': PlanAssignmentStatus.pendiente.toJson(), // Estado inicial
        'respondedAt': null,
        'planName': planName, // Guardar nombre si se pasó
      });
      if (kDebugMode) print("--- FirestorePARepo: Asignación creada ---");
    } on FirebaseException catch (e) {
       if (kDebugMode) print("Error Firestore al crear asignación: $e");
       throw Exception('Error al asignar el plan.');
    } catch (e) {
       if (kDebugMode) print("Error inesperado al crear asignación: $e");
       throw Exception('Ocurrió un error inesperado al asignar.');
    }
  }
}