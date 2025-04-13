
import 'package:firebase_auth/firebase_auth.dart' show User, UserCredential; // Importa solo lo necesario

// Interfaz abstracta para desacoplar la implementación de autenticación.
// Permite cambiar de proveedor (ej. Firebase, Supabase, etc.) en el futuro. (OCP, DIP)
abstract class AuthRepositoryBase {
  // Flujo para escuchar cambios en el estado de autenticación (logueado/deslogueado).
  Stream<User?> get authStateChanges;

  // Obtiene el usuario actualmente autenticado, si existe.
  User? getCurrentUser();

  // Método para registrar un nuevo usuario.
  // Lanza FirebaseAuthException en caso de error.
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  // Método para iniciar sesión.
  // Lanza FirebaseAuthException en caso de error.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  // Método para cerrar la sesión actual.
  Future<void> signOut();
}