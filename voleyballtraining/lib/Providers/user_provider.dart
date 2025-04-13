// lib/providers/user_provider.dart

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
  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- Métodos ---

  /// Carga y escucha la lista de usuarios. Devuelve Future<void> para onRefresh.
  /// *** CAMBIO: Añadido 'async' ***
  Future<void> loadUsers() async {
    // Evitar múltiples cargas simultáneas si ya está cargando
    // Aunque para pull-to-refresh podríamos querer permitirlo.
    // Por ahora, si ya carga, no hacemos nada más aquí.
    // if (_isLoading) return;

    if (kDebugMode) print("--- UserProvider: Iniciando carga/escucha de usuarios ---");
    // Usaremos un helper para actualizar estado y notificar
    _updateUserState(loading: true, error: null);

    // Cancelar suscripción anterior es importante
    // Usamos await para asegurar que se complete antes de seguir (opcional, pero más claro)
    await _usersSubscription?.cancel();

    _usersSubscription = _userRepository.getUsers().listen(
      (fetchedUsers) {
        if (kDebugMode) print("--- UserProvider: Usuarios recibidos: ${fetchedUsers.length} ---");
        _users = fetchedUsers;
        _updateUserState(loading: false); // Actualizar estado y notificar
      },
      onError: (error) {
        if (kDebugMode) print("--- UserProvider: ERROR en stream de usuarios: $error ---");
        _users = []; // Vaciar lista
        _updateUserState(loading: false, error: "No se pudieron cargar los usuarios: ${error.toString()}");
      },
      onDone: () {
        if (kDebugMode) print("--- UserProvider: Stream de usuarios cerrado ---");
        _updateUserState(loading: false); // Asegurar que la carga termine
      }
    );

    // El Future se completa aquí (iniciar la escucha es rápido).
    // RefreshIndicator usará el estado 'isLoading' para saber cuándo parar.
  }


  // --- State Helper ---
  /// Helper para actualizar el estado y notificar a los listeners una sola vez.
  void _updateUserState({bool? loading, String? error}) {
      bool changed = false;
      // Actualizar estado de carga si es diferente
      if (loading != null && _isLoading != loading) {
          _isLoading = loading;
          changed = true;
      }
      // Limpiar error si empezamos a cargar O si se provee un error null explícito
      if ((loading == true && _errorMessage != null) || (error == null && _errorMessage != null)) {
           _errorMessage = null;
           changed = true;
      }
      // Asignar nuevo error si viene uno y es diferente
      if (error != null && _errorMessage != error) {
          _errorMessage = error;
          changed = true;
      }
      // Notificar solo si algo cambió
      if (changed) {
          notifyListeners();
      }
  }

  // Ya no necesitamos _setLoading y _setError separados si usamos el helper _updateUserState
  // void _setLoading(bool loadingState){ ... }
  // void _setError(String? message){ ... }


  // --- Cleanup ---
  @override
  void dispose() {
    if (kDebugMode) print("--- UserProvider: Disposing ---");
    _usersSubscription?.cancel();
    super.dispose();
  }

}