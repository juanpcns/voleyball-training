// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart'; // Necesario para ChangeNotifier
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException, UserCredential;
import 'package:cloud_firestore/cloud_firestore.dart'; // Necesario para Timestamp
import '../repositories/auth_repository_base.dart'; // Ajusta la ruta si es necesario
import '../repositories/user_repository_base.dart'; // Ajusta la ruta si es necesario
import '../models/user_model.dart'; // Ajusta la ruta si es necesario

// Orquesta la lógica de autenticación y creación de perfil, notificando a la UI.
class AuthProvider with ChangeNotifier {
  final AuthRepositoryBase _authRepository;
  final UserRepositoryBase _userRepository;

  // Recibe las dependencias (repositorios) a través del constructor (DIP).
  AuthProvider(this._authRepository, this._userRepository);

  // Estado interno para la UI
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // --- Métodos Privados para manejar estado ---
  void _setLoading(bool loadingState) {
    _isLoading = loadingState;
    notifyListeners(); // Notifica a los widgets que escuchan
  }

  void _setError(String? message) {
    _errorMessage = message;
    // No notificamos aquí necesariamente, podrías querer mostrar el error
    // y quitar el loading al mismo tiempo en los métodos públicos.
  }
  // --- Fin Métodos Privados ---


  // --- Métodos Públicos para la UI ---

  /// Intenta registrar un usuario en Auth y luego crea su perfil en Firestore.
  Future<bool> signUpUser({
    required String email,
    required String password,
    required String fullName,
    required String role, // 'Entrenador' o 'Jugador' - Asegúrate que la UI lo envíe correctamente
    String? idNumber,
    Timestamp? dateOfBirth,
    String? phoneNumber,
  }) async {
    _setError(null); // Limpia errores previos
    _setLoading(true);

    try {
      // 1. Intentar crear en Firebase Auth
      UserCredential userCredential = await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Si llegamos aquí, Auth fue exitoso. Validar que tenemos un usuario.
      if (userCredential.user == null) {
        throw Exception('Registro en Auth exitoso pero no se obtuvo usuario.');
      }

      // 2. Preparar datos para Firestore
      UserModel newUserProfile = UserModel(
        userId: userCredential.user!.uid, // ID de Auth es el ID del documento
        email: email, // O userCredential.user!.email si confías más en él
        fullName: fullName,
        role: role,
        idNumber: idNumber,
        dateOfBirth: dateOfBirth,
        phoneNumber: phoneNumber,
        createdAt: Timestamp.now(), // Marcar el tiempo de creación
      );

      // 3. Intentar crear el perfil en Firestore
      await _userRepository.createUserProfile(newUserProfile);

      _setLoading(false); // Termina la carga
      return true; // Éxito en todo el proceso

    } on FirebaseAuthException catch (e) {
      // Capturar error específico de Auth y traducirlo
      _setError(_mapAuthErrorCodeToMessage(e.code));
      _setLoading(false);
      notifyListeners(); // Notificar cambio de error y loading
      return false; // Indicar fallo
    } catch (e) {
      // Capturar error de Firestore u otros errores inesperados
       _setError('Error al guardar perfil: ${e.toString()}');
      _setLoading(false);
      notifyListeners(); // Notificar cambio de error y loading
      return false; // Indicar fallo
    }
  }

  /// Intenta iniciar sesión de un usuario existente.
  Future<bool> signInUser({
    required String email,
    required String password,
  }) async {
    _setError(null);
    _setLoading(true);

    try {
      await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _setLoading(false);
      return true; // Éxito

    } on FirebaseAuthException catch (e) {
      _setError(_mapAuthErrorCodeToMessage(e.code));
      _setLoading(false);
      notifyListeners();
      return false; // Fallo

    } catch (e) {
      _setError('Error inesperado al iniciar sesión: ${e.toString()}');
      _setLoading(false);
      notifyListeners();
      return false; // Fallo
    }
  }

  /// Cierra la sesión del usuario actual.
  Future<void> signOutUser() async {
    _setError(null);
    // No suele necesitarse estado de carga para signOut
    try {
      await _authRepository.signOut();
      // El cambio de estado será detectado por authStateChanges
    } catch (e) {
      _setError('Error al cerrar sesión.');
      notifyListeners(); // Informar del error si ocurre
    }
  }

  // --- Fin Métodos Públicos ---


  // --- Helper para traducir errores comunes de Firebase Auth ---
  String _mapAuthErrorCodeToMessage(String code) {
    // Mapeo simple, puedes expandirlo o mejorarlo
    switch (code) {
      case 'invalid-email': return 'Correo electrónico inválido.';
      case 'user-disabled': return 'Usuario deshabilitado.';
      case 'user-not-found': return 'Usuario no encontrado.';
      case 'wrong-password': return 'Contraseña incorrecta.';
      case 'email-already-in-use': return 'El correo ya está en uso.';
      case 'operation-not-allowed': return 'Operación no permitida.';
      case 'weak-password': return 'Contraseña muy débil.';
      default: return 'Error de autenticación: $code';
    }
  }
}