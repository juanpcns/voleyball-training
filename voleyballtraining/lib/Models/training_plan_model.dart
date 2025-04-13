// lib/models/training_plan_model.dart (Nombre de Parámetro Corregido)
import 'package:cloud_firestore/cloud_firestore.dart';

class TrainingPlan {
  final String id;
  final String creatorId;
  final String planName;
  final String? averageDailyTime;
  final String? description;
  final Timestamp createdAt;
  // El campo interno sigue siendo 'exercises' (List<String>)
  final List<String> exercises;

  // Constructor privado (sigue esperando 'exercises')
  TrainingPlan._({
    required this.id,
    required this.creatorId,
    required this.planName,
    this.averageDailyTime,
    this.description,
    required this.createdAt,
    required this.exercises, // <-- Parámetro interno
  });

  /// Factory Constructor para crear y validar nuevos planes (HU5)
  /// *** AHORA ESPERA el parámetro nombrado 'exercises' ***
  factory TrainingPlan.create({
    required String creatorId,
    required String planName,
    required List<String> exercises, // <-- NOMBRE CORREGIDO AQUÍ
    String? averageDailyTime,
    String? description,
  }) {
    // Validaciones
    if (exercises.length < 2) { // <-- Usa el parámetro 'exercises'
      throw ArgumentError('Un plan debe tener al menos 2 ejercicios.');
    }
    if (planName.trim().isEmpty) {
        throw ArgumentError('El nombre del plan no puede estar vacío.');
    }
    // ... (otras validaciones) ...

    // Llama al constructor privado pasando la lista recibida
    // al parámetro 'exercises' del constructor privado.
    return TrainingPlan._(
      id: '',
      creatorId: creatorId,
      planName: planName.trim(),
      averageDailyTime: averageDailyTime,
      description: description,
      createdAt: Timestamp.now(),
      exercises: exercises, // <-- Pasa el parámetro 'exercises'
    );
  }

  // toMap se mantiene igual (usa el campo 'exercises')
  Map<String, dynamic> toMap() {
    return {
      'creatorId': creatorId,
      'planName': planName,
      'averageDailyTime': averageDailyTime,
      'description': description,
      'createdAt': createdAt,
      'exercises': exercises, // <-- Campo 'exercises'
    };
  }

  // fromFirestore se mantiene igual (lee el campo 'exercises')
  factory TrainingPlan.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic>? data = doc.data();
    if (data == null) throw StateError('Datos no encontrados para TrainingPlan ID: ${doc.id}');

    List<String> exercisesFromDb = [];
    if (data['exercises'] is List) {
       exercisesFromDb = List<String>.from((data['exercises'] as List).map((item) => item.toString()));
    }

    // Llama al constructor privado pasando la lista al parámetro 'exercises'
    return TrainingPlan._(
      id: doc.id,
      creatorId: data['creatorId'] ?? '',
      planName: data['planName'] ?? 'Plan sin nombre',
      averageDailyTime: data['averageDailyTime'] as String?,
      description: data['description'] as String?,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      exercises: exercisesFromDb, // <-- Pasa al parámetro 'exercises'
    );
  }
}