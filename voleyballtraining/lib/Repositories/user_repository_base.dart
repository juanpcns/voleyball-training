// lib/repositories/user_repository_base.dart
import '../models/user_model.dart'; // Asegúrate que la ruta al modelo sea correcta

// Contrato para las operaciones de base de datos relacionadas con los usuarios.
abstract class UserRepositoryBase {

  /// Guarda el perfil completo del usuario en la base de datos.
  /// Usualmente se llama después de un registro exitoso.
  Future<void> createUserProfile(UserModel user);

  /// Obtiene el perfil de un usuario específico usando su ID (UID de Auth).
  /// Devuelve [null] si el perfil no se encuentra.
  Future<UserModel?> getUserProfile(String userId);

  /// Obtiene un Stream con la lista de todos los usuarios registrados.
  /// El Stream se actualiza automáticamente si hay cambios en Firestore.
  Stream<List<UserModel>> getUsers();

  // --- Posibles métodos futuros ---
  // Future<void> updateUserProfile(UserModel user);
  // Future<void> deleteUserProfile(String userId);
  // Stream<List<UserModel>> getPlayers(); // Podría ser un método específico para obtener solo jugadores
}