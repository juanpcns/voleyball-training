import 'package:flutter/foundation.dart'; // ChangeNotifier y kDebugMode
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException, UserCredential;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/auth_repository_base.dart';
import '../repositories/user_repository_base.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepositoryBase _authRepository;
  final UserRepositoryBase _userRepository;

  AuthProvider(this._authRepository, this._userRepository);

  // --- Estado Interno ---
  bool _isLoading = false;
  String? _errorMessage;

  // --- Usuario autenticado (modelo completo) ---
  UserModel? _currentUserModel;
  UserModel? get currentUserModel => _currentUserModel;

  // --- Getters Públicos para el Estado ---
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loadingState) {
    if (_isLoading != loadingState) {
      _isLoading = loadingState;
      notifyListeners();
    }
  }

  void _setError(String? message) {
    if (_errorMessage != message) {
      _errorMessage = message;
    }
  }

  // --- MÉTODOS PRINCIPALES ---

  /// Registra un nuevo usuario y crea perfil en Firestore.
  Future<bool> signUpUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? idNumber,
    Timestamp? dateOfBirth,
    String? phoneNumber,
  }) async {
    _setError(null);
    _setLoading(true);
    notifyListeners();

    try {
      if (kDebugMode) print("--- AuthProvider: Iniciando signUpUser ---");
      UserCredential userCredential = await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (kDebugMode) print("--- AuthProvider: Usuario creado en Auth con UID: ${userCredential.user?.uid} ---");

      if (userCredential.user == null) {
        throw Exception('Fallo en la creación del usuario en Firebase Auth.');
      }

      // 2. Crear perfil en Firestore
      UserModel newUserProfile = UserModel(
        userId: userCredential.user!.uid,
        email: email,
        fullName: fullName,
        role: role,
        idNumber: idNumber,
        dateOfBirth: dateOfBirth,
        phoneNumber: phoneNumber,
        createdAt: Timestamp.now(),
      );

      await _userRepository.createUserProfile(newUserProfile);

      // 3. Cargar y exponer el modelo tras registro
      _currentUserModel = newUserProfile;
      notifyListeners();

      _setLoading(false);
      if (kDebugMode) print("--- AuthProvider: signUpUser finalizado con ÉXITO ---");
      return true;

    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _setError(null);
        bool signInSuccess = await signInUser(email: email, password: password);
        return signInSuccess;
      } else {
        _setError(_mapAuthErrorCodeToMessage(e.code));
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _setError('Error al guardar perfil: ${e.toString()}');
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Inicia sesión y carga perfil de usuario de Firestore.
  Future<bool> signInUser({
    required String email,
    required String password,
  }) async {
    final wasAlreadyLoading = _isLoading;
    if (!wasAlreadyLoading) {
      _setError(null);
      _setLoading(true);
    } else {
      _setError(null);
      notifyListeners();
    }

    try {
      if (kDebugMode) print("--- AuthProvider: Intentando signInUser... ---");
      final userCredential = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (kDebugMode) print("--- AuthProvider: signInUser Exitoso ---");

      // Cargar modelo de usuario desde Firestore
      final user = userCredential.user ?? FirebaseAuth.instance.currentUser;
      if (user != null) {
        _currentUserModel = await _userRepository.getUserProfile(user.uid);
        notifyListeners();
      }

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapAuthErrorCodeToMessage(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Ocurrió un error inesperado al iniciar sesión.');
      _setLoading(false);
      return false;
    }
  }

  /// Cierra la sesión y limpia el usuario actual.
  Future<void> signOutUser() async {
    if (kDebugMode) print("--- AuthProvider: Intentando signOutUser... ---");
    _setError(null);
    _currentUserModel = null; // <--- Limpia el modelo de usuario
    notifyListeners();
    try {
      await _authRepository.signOut();
    } catch (e) {
      _setError('Error al cerrar sesión.');
      notifyListeners();
    }
  }

  // --- Helper Privado ---
  String _mapAuthErrorCodeToMessage(String code) {
    switch (code) {
      case 'invalid-email': return 'El formato del correo electrónico no es válido.';
      case 'user-disabled': return 'Este usuario ha sido deshabilitado.';
      case 'user-not-found': return 'No se encontró un usuario con este correo electrónico.';
      case 'wrong-password': return 'La contraseña es incorrecta.';
      case 'email-already-in-use': return 'Este correo electrónico ya está registrado.';
      case 'operation-not-allowed': return 'Operación no permitida (revisa Firebase Console).';
      case 'weak-password': return 'La contraseña es demasiado débil (mínimo 6 caracteres).';
      default: return 'Ocurrió un error de autenticación ($code).';
    }
  }
}
