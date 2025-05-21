import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import 'user_repository_base.dart';

class FirestoreUserRepository implements UserRepositoryBase {
  final FirebaseFirestore _firestore;

  FirestoreUserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  @override
  Future<void> createUserProfile(UserModel user) async {
    try {
      await _usersCollection.doc(user.userId).set(user.toMap());
      if (kDebugMode) {
        print("✅ FirestoreUserRepository: Perfil creado para ${user.userId}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error al crear perfil en Firestore: $e");
      }
      throw Exception('No se pudo guardar el perfil del usuario.');
    }
  }

  @override
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error al obtener perfil para $userId: $e");
      }
      return null;
    }
  }

  @override
  Stream<List<UserModel>> getUsers() {
    final query = _usersCollection.orderBy('fullName');
    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              return UserModel.fromFirestore(doc);
            } catch (e) {
              if (kDebugMode) {
                print("⚠️ Error al convertir usuario ${doc.id}: $e");
              }
              return null;
            }
          })
          .whereType<UserModel>()
          .toList();
    }).handleError((error) {
      if (kDebugMode) {
        print("❌ Error en el stream de usuarios: $error");
      }
      return <UserModel>[];
    });
  }

  /// ✅ Implementación del método pendiente
  @override
  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final querySnapshot = await _usersCollection
          .where('role', isEqualTo: role)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error al obtener usuarios con rol '$role': $e");
      }
      return [];
    }
  }
}
