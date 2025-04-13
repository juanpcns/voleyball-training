// lib/repositories/user_repository_base.dart
import '../models/user_model.dart'; // Asegúrate que la ruta al modelo sea correcta

// Contrato para las operaciones de base de datos relacionadas con los usuarios. (ISP, OCP)
abstract class UserRepositoryBase {

  /// Guarda el perfil completo del usuario en la base de datos.
  /// Generalmente se llama después de un registro exitoso.
  /// Usa el user.userId como identificador del documento.
  Future<void> createUserProfile(UserModel user);

  /// Obtiene el perfil de un usuario específico usando su ID.
  /// Devuelve [null] si el perfil no se encuentra.
  Future<UserModel?> getUserProfile(String userId);

  // Aquí podrías añadir métodos futuros como updateUserProfile, deleteUserProfile, etc.
}