import '../models/user_model.dart';

abstract class UserRepositoryBase {
  /// Guarda el perfil completo del usuario en la base de datos.
  Future<void> createUserProfile(UserModel user);

  /// Obtiene un perfil por su UID.
  Future<UserModel?> getUserProfile(String userId);

  /// Devuelve todos los usuarios en tiempo real.
  Stream<List<UserModel>> getUsers();

  /// ✅ Devuelve usuarios filtrados por rol ('Jugador', 'Entrenador', etc).
  Future<List<UserModel>> getUsersByRole(String role);
}
