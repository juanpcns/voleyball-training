// lib/repositories/firestore_user_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart'; // Ajusta la ruta si es necesario
import 'user_repository_base.dart'; // Ajusta la ruta si es necesario

// Implementación concreta que usa Firestore para gestionar datos de UserModel. (SRP)
class FirestoreUserRepository implements UserRepositoryBase {
  // Inyección de la dependencia de Firestore. (DIP)
  final FirebaseFirestore _firestore;

  // Constructor que permite inyectar una instancia o usa la global por defecto.
  FirestoreUserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Referencia reutilizable a la colección 'users'.
  // El tipado <Map<String, dynamic>> ayuda a trabajar con los snapshots.
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  @override
  Future<void> createUserProfile(UserModel user) async {
    try {
      // .doc(user.userId) especifica el ID del documento (que es el UID de Auth).
      // .set(user.toMap()) guarda los datos del mapa en ese documento.
      // Si el documento ya existe, .set() lo sobrescribe.
      await _usersCollection.doc(user.userId).set(user.toMap());
    } on FirebaseException catch (e) {
      // Captura errores específicos de Firestore y relánzalos.
      // La capa superior (Provider/ViewModel) decidirá cómo informar al usuario.
      // POSIBLE PRINT AQUI print('Error Firestore al crear perfil: $e');
      rethrow;
    } catch (e) {
      // Captura cualquier otro error inesperado.
      // POSIBLE PRINT AQUI('Error inesperado al crear perfil: $e');
      throw Exception('Ocurrió un error inesperado al guardar el perfil.');
    }
  }

  @override
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc =
          await _usersCollection.doc(userId).get();

      if (doc.exists) {
        // Si el documento existe, usa el factory 'fromFirestore' del modelo.
        return UserModel.fromFirestore(doc);
      } else {
        // Si no existe un perfil para ese ID, devuelve null.
        return null;
      }
    } on FirebaseException catch (e) {
      // print('Error Firestore al obtener perfil: $e');
      rethrow;
    } catch (e) {
      // print('Error inesperado al obtener perfil: $e');
      throw Exception('Ocurrió un error inesperado al obtener el perfil.');
    }
  }
}