// lib/repositories/firestore_user_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // para kDebugMode
import '../models/user_model.dart'; // Ajusta la ruta si es necesario
import 'user_repository_base.dart'; // Ajusta la ruta si es necesario

class FirestoreUserRepository implements UserRepositoryBase {
  final FirebaseFirestore _firestore;

  // Constructor que permite inyectar una instancia de Firestore (útil para tests)
  // o usa la instancia global por defecto.
  FirestoreUserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Referencia a la colección 'users' en Firestore.
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users'); // Nombre de tu colección de usuarios

  @override
  Future<void> createUserProfile(UserModel user) async {
    // Guarda el documento usando el UID del usuario como ID del documento.
    // .set() crea o reemplaza completamente el documento.
    try {
      await _usersCollection.doc(user.userId).set(user.toMap());
       if (kDebugMode) print("--- FirestoreUserRepo: Perfil creado/actualizado para ${user.userId} ---");
    } on FirebaseException catch (e) {
       if (kDebugMode) print("Error Firestore al crear perfil (${user.userId}): $e");
      // Puedes decidir relanzar un error más específico o genérico.
      throw Exception('Error al guardar el perfil de usuario.');
    } catch (e) {
       if (kDebugMode) print("Error inesperado al crear perfil (${user.userId}): $e");
       throw Exception('Ocurrió un error inesperado.');
    }
  }

  @override
  Future<UserModel?> getUserProfile(String userId) async {
     if (kDebugMode) print("--- FirestoreUserRepo: Obteniendo perfil para userId: $userId ---");
     try {
      final DocumentSnapshot<Map<String, dynamic>> doc =
          await _usersCollection.doc(userId).get();

      if (doc.exists) {
         if (kDebugMode) print("--- FirestoreUserRepo: Perfil encontrado para $userId ---");
        // Usa el factory del modelo para convertir los datos.
        return UserModel.fromFirestore(doc);
      } else {
         if (kDebugMode) print("--- FirestoreUserRepo: Perfil NO encontrado para $userId ---");
        // Devuelve null si el documento no existe.
        return null;
      }
    } on FirebaseException catch (e) {
       if (kDebugMode) print("Error Firestore al obtener perfil ($userId): $e");
       throw Exception('Error al obtener el perfil de usuario.');
    } catch (e) {
       if (kDebugMode) print("Error inesperado al obtener perfil ($userId): $e");
       throw Exception('Ocurrió un error inesperado.');
    }
  }

  // --- Implementación del nuevo método ---
  @override
  Stream<List<UserModel>> getUsers() {
    if (kDebugMode) print("--- FirestoreUserRepo: Obteniendo stream de TODOS los usuarios ---");
    // Query para obtener todos los usuarios, ordenados por nombre.
    final query = _usersCollection.orderBy('fullName', descending: false);

    // .snapshots() devuelve un Stream<QuerySnapshot> con actualizaciones en tiempo real.
    return query.snapshots().map((snapshot) {
       if (kDebugMode) print("--- FirestoreUserRepo: Recibido snapshot con ${snapshot.docs.length} usuarios ---");
       // Mapea cada documento a un objeto UserModel.
       return snapshot.docs.map((doc) {
         try {
           // Usa el factory del modelo para la conversión.
           return UserModel.fromFirestore(doc);
         } catch (e) {
            // Si un documento está corrupto o incompleto, loguea y lo ignora.
            if (kDebugMode) print("Error convirtiendo UserModel ${doc.id}: $e");
           return null;
         }
       }).whereType<UserModel>().toList(); // Filtra los nulos y devuelve la lista.
    }).handleError((error){ // Maneja errores generales del stream.
        if (kDebugMode) print("--- FirestoreUserRepo: ERROR en stream getUsers: $error ---");
        // Devuelve una lista vacía para que la UI no se rompa.
        return <UserModel>[];
    });
  }
  // --- Fin nuevo método ---

}