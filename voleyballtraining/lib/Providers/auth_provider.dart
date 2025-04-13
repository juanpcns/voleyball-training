// lib/providers/auth_provider.dart

import 'package:flutter/foundation.dart'; // Necesario para ChangeNotifier y kDebugMode
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException, UserCredential;
import 'package:cloud_firestore/cloud_firestore.dart'; // Necesario para Timestamp
// Asegúrate de que las rutas a tus repositorios y modelo sean correctas
import '../repositories/auth_repository_base.dart';
import '../repositories/user_repository_base.dart';
import '../models/user_model.dart';

/// Gestiona el estado y la lógica relacionados con la autenticación
/// y el perfil de usuario inicial. Notifica a los listeners (UI) sobre cambios.
class AuthProvider with ChangeNotifier {
  final AuthRepositoryBase _authRepository;
  final UserRepositoryBase _userRepository;

  // Constructor: Recibe las dependencias (implementaciones de repositorios)
  AuthProvider(this._authRepository, this._userRepository);

  // --- Estado Interno ---
  bool _isLoading = false;
  String? _errorMessage;

  // --- Getters Públicos para el Estado ---
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- Métodos Privados para Modificar Estado y Notificar ---
  void _setLoading(bool loadingState) {
    if (_isLoading != loadingState) {
      _isLoading = loadingState;
      // Solo notificar si el estado realmente cambió para evitar reconstrucciones innecesarias
      notifyListeners();
    }
  }

  void _setError(String? message) {
    if (_errorMessage != message) {
      _errorMessage = message;
      // Podríamos notificar aquí, pero usualmente se notifica junto con _setLoading(false)
      // notifyListeners();
    }
  }

  // --- Métodos Públicos (Lógica de Negocio) ---

  /// Registra un nuevo usuario. Si el email ya existe, intenta iniciar sesión.
  Future<bool> signUpUser({
    required String email,
    required String password,
    required String fullName,
    required String role, // 'Entrenador' o 'Jugador'
    String? idNumber,
    Timestamp? dateOfBirth,
    String? phoneNumber,
  }) async {
    // Siempre limpiar errores y empezar a cargar al inicio de la acción
    _setError(null);
    _setLoading(true);
    notifyListeners(); // Notificar cambio inicial de estado (error limpio, cargando)

    try {
      if (kDebugMode) print("--- AuthProvider: Iniciando signUpUser ---");
      if (kDebugMode) print("--- AuthProvider: Intentando crear usuario en Auth... ---");
      // 1. Intentar crear en Firebase Auth
      UserCredential userCredential = await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (kDebugMode) print("--- AuthProvider: Usuario NUEVO creado en Auth con UID: ${userCredential.user?.uid} ---");

      // Validación post-creación (aunque raro que falle si la llamada anterior tuvo éxito)
      if (userCredential.user == null) {
        if (kDebugMode) print("--- AuthProvider: ERROR - UserCredential.user es null después del registro ---");
        throw Exception('Fallo en la creación del usuario en Firebase Auth.');
      }

      // 2. Preparar datos para Firestore
      if (kDebugMode) print("--- AuthProvider: Preparando perfil para Firestore... ---");
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

      // 3. Intentar crear el perfil en Firestore
      if (kDebugMode) print("--- AuthProvider: Intentando crear perfil en Firestore... ---");
      await _userRepository.createUserProfile(newUserProfile);
      if (kDebugMode) print("--- AuthProvider: Perfil creado en Firestore para nuevo usuario ---");

      // Éxito completo (nuevo usuario creado y perfil guardado)
      // El cambio de estado de Auth hará que AuthWrapper redirija.
      _setLoading(false); // Detener carga
      if (kDebugMode) print("--- AuthProvider: signUpUser finalizado con ÉXITO (Nuevo Usuario) ---");
      return true;

    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print("--- AuthProvider: ERROR de FirebaseAuth - Código: ${e.code} ---");

      // *** Lógica para manejar email existente ***
      if (e.code == 'email-already-in-use') {
        if (kDebugMode) print("--- AuthProvider: Email ya existe. Intentando iniciar sesión en su lugar... ---");
        _setError(null); // Limpiar el error de "email ya existe"
        // Llamamos a signInUser. Él se encargará de loading y errores.
        bool signInSuccess = await signInUser(email: email, password: password);
        if (kDebugMode) print("--- AuthProvider: Resultado del intento de signIn automático: $signInSuccess ---");
        // Devolvemos el resultado del login. Si fue true, AuthWrapper redirige.
        // Si fue false, signInUser ya puso el error (ej. contraseña incorrecta).
        // _setLoading ya fue manejado por signInUser.
        return signInSuccess;
      } else {
        // Otro error de FirebaseAuth durante el registro
        _setError(_mapAuthErrorCodeToMessage(e.code));
        _setLoading(false); // Detener carga
        notifyListeners(); // Notificar UI del error
         if (kDebugMode) print("--- AuthProvider: signUpUser finalizado con ERROR (Auth - Otro) ---");
        return false;
      }
      // *** Fin lógica email existente ***

    } catch (e) {
      // Error de Firestore o cualquier otro error inesperado durante el registro/creación de perfil
       if (kDebugMode) print("--- AuthProvider: ERROR inesperado durante signUp - ${e.toString()} ---");
      _setError('Error al guardar perfil: ${e.toString()}');
      _setLoading(false); // Detener carga
      notifyListeners(); // Notificar UI del error
       if (kDebugMode) print("--- AuthProvider: signUpUser finalizado con ERROR (Otro) ---");
      return false;
    }
  }

  /// Inicia sesión de un usuario existente.
  Future<bool> signInUser({
    required String email,
    required String password,
  }) async {
     final wasAlreadyLoading = _isLoading;
     // Solo limpiamos error e iniciamos carga si no venimos ya cargando desde signUpUser
     if (!wasAlreadyLoading) {
       _setError(null);
       _setLoading(true); // Inicia carga y notifica
     } else {
        _setError(null); // Limpia error
        notifyListeners(); // Notifica limpieza de error
     }

     try {
        if (kDebugMode) print("--- AuthProvider: Intentando signInUser... ---");
       await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
        if (kDebugMode) print("--- AuthProvider: signInUser Exitoso ---");
       // El cambio de estado de Auth hará que AuthWrapper redirija.
       _setLoading(false); // Detiene la carga y notifica
       return true; // Éxito
     } on FirebaseAuthException catch (e) {
        if (kDebugMode) print("--- AuthProvider: ERROR de FirebaseAuth en signIn - Código: ${e.code} ---");
       _setError(_mapAuthErrorCodeToMessage(e.code));
       _setLoading(false); // Detiene la carga y notifica
       return false; // Fallo
     } catch (e) {
        if (kDebugMode) print("--- AuthProvider: ERROR inesperado en signIn - ${e.toString()} ---");
       _setError('Ocurrió un error inesperado al iniciar sesión.');
       _setLoading(false); // Detiene la carga y notifica
      return false; // Fallo
     }
   }

  /// Cierra la sesión del usuario actual.
  Future<void> signOutUser() async {
    if (kDebugMode) print("--- AuthProvider: Intentando signOutUser... ---");
    _setError(null); // Limpiar cualquier error residual
    // No ponemos estado de carga para signOut, es rápido usualmente
    notifyListeners(); // Notificar limpieza de error
    try {
      await _authRepository.signOut();
       if (kDebugMode) print("--- AuthProvider: signOutUser Exitoso ---");
      // El cambio de estado será detectado por AuthWrapper via StreamProvider
    } catch (e) {
       if (kDebugMode) print("--- AuthProvider: ERROR inesperado en signOut - ${e.toString()} ---");
      // Es raro que signOut falle, pero podríamos informar
      _setError('Error al cerrar sesión.');
      notifyListeners(); // Notificar del error
    }
  }


  // --- Helper Privado ---
  /// Convierte códigos de error comunes de Firebase Auth a mensajes legibles.
  String _mapAuthErrorCodeToMessage(String code) {
    // Puedes personalizar estos mensajes
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