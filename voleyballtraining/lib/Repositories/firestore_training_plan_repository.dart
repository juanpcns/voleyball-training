// lib/repositories/firestore_training_plan_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/training_plan_model.dart'; // Ajusta ruta
import 'training_plan_repository_base.dart'; // Ajusta ruta

class FirestoreTrainingPlanRepository implements TrainingPlanRepositoryBase {
  final FirebaseFirestore _firestore;

  FirestoreTrainingPlanRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Referencia a la colección
  CollectionReference<Map<String, dynamic>> get _plansCollection =>
      _firestore.collection('training_plans'); // Nombre de la colección en Firestore

  @override
  Future<String> addTrainingPlan(TrainingPlan plan) async {
    try {
      // add() genera un ID automático
      DocumentReference<Map<String, dynamic>> docRef =
          await _plansCollection.add(plan.toMap());
      return docRef.id;
    } on FirebaseException catch (e) {
      print('Error Firestore al añadir plan: $e');
      rethrow; // Relanzar para manejo en capas superiores
    } catch (e) {
      print('Error inesperado al añadir plan: $e');
      throw Exception('Ocurrió un error inesperado al guardar el plan.');
    }
  }

  @override
  Stream<List<TrainingPlan>> getTrainingPlansForCreator(String creatorId) {
    // Query para obtener planes del creador, ordenados por fecha descendente
    final query = _plansCollection
        .where('creatorId', isEqualTo: creatorId)
        .orderBy('createdAt', descending: true);

    // snapshots() devuelve un Stream<QuerySnapshot> que se actualiza en tiempo real
    return query.snapshots().map((snapshot) {
      // Mapea los documentos del snapshot a objetos TrainingPlan
      return snapshot.docs.map((doc) {
        try {
          return TrainingPlan.fromFirestore(doc);
        } catch (e) {
          print("Error convirtiendo TrainingPlan ${doc.id}: $e");
          return null; // Ignorar documentos con error de formato
        }
      }).whereType<TrainingPlan>().toList(); // Filtra los nulos y convierte a lista
    });
    // Añadir .handleError() si quieres manejar errores del stream aquí mismo
    // .handleError((error) {
    //   print("Error en stream getTrainingPlansForCreator: $error");
    //   // Podrías devolver una lista vacía o lanzar el error
    //   return <TrainingPlan>[];
    // });
  }

   @override
  Future<TrainingPlan?> getTrainingPlanById(String planId) async {
     try {
      final DocumentSnapshot<Map<String, dynamic>> doc =
          await _plansCollection.doc(planId).get();

      if (doc.exists) {
        return TrainingPlan.fromFirestore(doc);
      } else {
        return null; // No encontrado
      }
    } on FirebaseException catch (e) {
       print('Error Firestore al obtener plan por ID ($planId): $e');
      rethrow;
    } catch (e) {
       print('Error inesperado al obtener plan por ID ($planId): $e');
       throw Exception('Ocurrió un error inesperado al obtener el plan.');
    }
  }

  // La implementación de getTrainingPlansForPlayer vendrá después...
}