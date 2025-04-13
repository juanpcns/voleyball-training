// lib/providers/user_provider.dart (COMPLETO con getter playerUsers y typo corregido)

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../repositories/user_repository_base.dart';

class UserProvider with ChangeNotifier {
  final UserRepositoryBase _userRepository;

  UserProvider(this._userRepository);

  // --- State ---
  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _usersSubscription;

  // --- Getters ---
  List<UserModel> get users => _users; // Todos los usuarios
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// *** GETTER AÑADIDO: Filtra la lista para obtener solo Jugadores ***
  List<UserModel> get playerUsers =>
      _users.where((user) => user.role == 'Jugador').toList();
  // --- Fin Getter Añadido ---

  // --- Métodos ---

  /// Carga y escucha la lista de todos los usuarios.
  Future<void> loadUsers() async {
    if (kDebugMode) print("--- UserProvider: Iniciando carga/escucha de usuarios ---");
    _updateUserState(loading: true, error: null); // Usa helper para notificar

    await _usersSubscription?.cancel(); // Cancela anterior
    _usersSubscription = _userRepository.getUsers().listen(
      (fetchedUsers) {
        if (kDebugMode) print("--- UserProvider: Usuarios recibidos: ${fetchedUsers.length} ---");
        _users = fetchedUsers;
        _updateUserState(loading: false); // Usa helper para notificar
      },
      onError: (error) {
        if (kDebugMode) print("--- UserProvider: ERROR en stream de usuarios: $error ---");
        _users = [];
        _updateUserState(loading: false, error: "No se pudieron cargar los usuarios: ${error.toString()}");
      },
      onDone: () {
        if (kDebugMode) print("--- UserProvider: Stream de usuarios cerrado ---");
        _updateUserState(loading: false); // Asegurar que pare la carga
      }
    );
  }


  // --- State Helper ---
  /// Helper para actualizar el estado y notificar a los listeners una sola vez.
  void _updateUserState({bool? loading, String? error}) {
      bool changed = false;
      if (loading != null && _isLoading != loading) { _isLoading = loading; changed = true; }
      if ((loading == true && _errorMessage != null) || (error == null && _errorMessage != null)) { _errorMessage = null; changed = true; }
      if (error != null && _errorMessage != error) { _errorMessage = error; changed = true; }
      if (changed) { notifyListeners(); }
  }


  // --- Cleanup ---
  @override
  void dispose() {
    if (kDebugMode) print("--- UserProvider: Disposing ---");
    _usersSubscription?.cancel();
    super.dispose();
  }
} // <-- Llave de cierre correcta para la clase