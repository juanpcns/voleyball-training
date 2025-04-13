// lib/repositories/firebase_auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException, User, UserCredential;
import 'auth_repository_base.dart'; // Importa la interfaz

// Implementación concreta del repositorio de autenticación usando Firebase Auth. (SRP)
class FirebaseAuthRepository implements AuthRepositoryBase {
  // Dependencia de FirebaseAuth, inyectada para facilitar pruebas y seguir DIP.
  final FirebaseAuth _firebaseAuth;

  // Constructor que recibe la instancia de FirebaseAuth.
  FirebaseAuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? getCurrentUser() => _firebaseAuth.currentUser;

  @override
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      // Simplemente relanzamos la excepción para que la capa superior (ViewModel/Provider) la maneje.
      rethrow;
    }
    // Considerar manejo de otros errores genéricos si es necesario.
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      rethrow; // Permite a la UI/Provider mostrar mensajes de error específicos de Firebase.
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}