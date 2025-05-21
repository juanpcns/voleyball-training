import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../repositories/user_repository_base.dart';

class UserProvider with ChangeNotifier {
  final UserRepositoryBase _userRepository;

  UserProvider(this._userRepository);

  // --- Estado interno ---
  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _usersSubscription;

  // --- Getters públicos ---
  List<UserModel> get users => _users;

  /// ✅ Getter para obtener solo jugadores del estado actual
  List<UserModel> get playerUsers =>
      _users.where((user) => user.role == 'Jugador').toList();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- Carga con stream (modo en tiempo real) ---
  Future<void> loadUsers() async {
    if (kDebugMode) print("🔄 UserProvider: Cargando usuarios en tiempo real...");
    _updateUserState(loading: true, error: null);

    await _usersSubscription?.cancel();

    _usersSubscription = _userRepository.getUsers().listen(
      (fetchedUsers) {
        if (kDebugMode) print("✅ UserProvider: Usuarios recibidos: ${fetchedUsers.length}");
        _users = fetchedUsers;
        _updateUserState(loading: false);
      },
      onError: (error) {
        if (kDebugMode) print("❌ UserProvider: Error al obtener usuarios: $error");
        _users = [];
        _updateUserState(loading: false, error: "Error al cargar usuarios: $error");
      },
    );
  }

  /// ✅ Consulta directa a Firestore para traer solo jugadores
  Future<List<UserModel>> fetchPlayers() async {
    try {
      if (kDebugMode) print("➡️ UserProvider: Buscando jugadores desde repositorio...");
      return await _userRepository.getUsersByRole('Jugador');
    } catch (e) {
      if (kDebugMode) print("❌ Error al obtener jugadores: $e");
      return [];
    }
  }

  // --- Ayuda para actualizar estado y notificar cambios ---
  void _updateUserState({bool? loading, String? error}) {
    bool changed = false;
    if (loading != null && _isLoading != loading) {
      _isLoading = loading;
      changed = true;
    }
    if (error != null && _errorMessage != error) {
      _errorMessage = error;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  // --- Cleanup ---
  @override
  void dispose() {
    if (kDebugMode) print("🧹 UserProvider: Cancelando stream...");
    _usersSubscription?.cancel();
    super.dispose();
  }
}
