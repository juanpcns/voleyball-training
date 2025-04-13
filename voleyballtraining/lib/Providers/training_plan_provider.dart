// lib/providers/training_plan_provider.dart (COMPLETO - Versión Verificada)

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/training_plan_model.dart';
import '../models/plan_assignment_model.dart'; // Necesario para estado futuro
import '../repositories/training_plan_repository_base.dart';
import '../repositories/auth_repository_base.dart';
import '../repositories/plan_assignment_repository_base.dart';

class TrainingPlanProvider with ChangeNotifier {
  final TrainingPlanRepositoryBase _planRepository;
  final AuthRepositoryBase _authRepository;
  final PlanAssignmentRepositoryBase _assignmentRepository;

  // Constructor
  TrainingPlanProvider(
    this._planRepository,
    this._authRepository,
    this._assignmentRepository,
  );

  // --- Estado Coach ---
  List<TrainingPlan> _coachPlans = [];
  bool _isLoadingCoachPlans = false;
  String? _coachPlansError;
  StreamSubscription? _coachPlansSubscription;

  // --- Estado Jugador ---
  List<PlanAssignment> _playerAssignments = [];
  bool _isLoadingPlayerAssignments = false;
  String? _playerAssignmentsError;
  StreamSubscription? _playerAssignmentsSubscription;

  // --- Estado General (para errores de acciones como crear/actualizar) ---
  String? _actionErrorMessage;

  // --- Getters ---
  List<TrainingPlan> get coachPlans => _coachPlans;
  bool get isLoadingCoachPlans => _isLoadingCoachPlans;
  String? get coachPlansError => _coachPlansError;

  List<PlanAssignment> get playerAssignments => _playerAssignments;
  bool get isLoadingPlayerAssignments => _isLoadingPlayerAssignments;
  String? get playerAssignmentsError => _playerAssignmentsError;

  String? get errorMessage => _actionErrorMessage; // Getter para errores de acciones

  // --- Métodos Coach ---
  void loadCoachPlans() {
    final userId = _authRepository.getCurrentUser()?.uid;
    if (userId == null) { _updateCoachState(loading: false, error: "Usuario no autenticado."); return; }
    if (kDebugMode) print("--- TP_Provider: Cargando planes Coach: $userId ---");

    _updateCoachState(loading: true, error: null); // Inicia carga, limpia error
    _coachPlansSubscription?.cancel();
    _coachPlansSubscription = _planRepository.getTrainingPlansForCreator(userId).listen(
      (fetchedPlans) {
        if (kDebugMode) print("--- TP_Provider: Planes Coach recibidos: ${fetchedPlans.length} ---");
        _coachPlans = fetchedPlans;
        _updateCoachState(loading: false); // Termina carga al recibir datos
      },
      onError: (error) {
        if (kDebugMode) print("--- TP_Provider: ERROR stream planes coach: $error ---");
        _coachPlans = [];
        _updateCoachState(loading: false, error: "No se pudieron cargar los planes: ${error.toString()}");
      },
      onDone: () {
        if (kDebugMode) print("--- TP_Provider: Stream planes coach cerrado ---");
        if (_isLoadingCoachPlans) _updateCoachState(loading: false); // Asegurar que no quede cargando
      }
    );
  }

  Future<bool> createPlan({
      required String planName, // <-- Parámetro 'planName' requerido
      required List<String> exercises,
      String? averageDailyTime,
      String? description,
  }) async {
      final userId = _authRepository.getCurrentUser()?.uid;
      if (userId == null) { _setActionError("No autenticado."); notifyListeners(); return false; }
       _setActionError(null); // Limpiar error de acción previo
      // Considerar un estado _isCreatingPlan si la UI necesita feedback más específico que el general _isLoading
      // _setIsCreatingPlan(true); notifyListeners();

      try {
          TrainingPlan newPlan = TrainingPlan.create(
              creatorId: userId,
              planName: planName,
              exercises: exercises, // <-- Usa 'exercises' consistentemente
              averageDailyTime: averageDailyTime,
              description: description,
          );
          await _planRepository.addTrainingPlan(newPlan);
          // _setIsCreatingPlan(false); notifyListeners();
          return true;
      } on ArgumentError catch (e) {
          _setActionError("Error al crear plan: ${e.message}");
          // _setIsCreatingPlan(false);
          notifyListeners();
          return false;
      } catch (e) {
           _setActionError("Error al guardar el plan: ${e.toString()}");
           // _setIsCreatingPlan(false);
           notifyListeners();
           return false;
      }
  }

  // --- Métodos Jugador ---
  void loadPlayerAssignments() {
     final userId = _authRepository.getCurrentUser()?.uid;
     if (userId == null) { _updatePlayerState(loading: false, error: "Usuario no autenticado."); return; }
     if (kDebugMode) print("--- TP_Provider: Cargando asignaciones Jugador: $userId ---");

     _updatePlayerState(loading: true, error: null); // Inicia carga, limpia error
     _playerAssignmentsSubscription?.cancel();
     _playerAssignmentsSubscription = _assignmentRepository.getAssignmentsForPlayer(userId).listen(
       (assignments) {
          if (kDebugMode) print("--- TP_Provider: Asignaciones Jugador recibidas: ${assignments.length} ---");
          _playerAssignments = assignments;
          _updatePlayerState(loading: false); // Termina carga al recibir
       },
       onError: (error) {
          if (kDebugMode) print("--- TP_Provider: ERROR stream asignaciones jugador: $error ---");
          _playerAssignments = [];
          _updatePlayerState(loading: false, error: "Error al cargar asignaciones: ${error.toString()}");
       },
       onDone: () {
          if (kDebugMode) print("--- TP_Provider: Stream asignaciones jugador cerrado ---");
           if (_isLoadingPlayerAssignments) _updatePlayerState(loading: false);
       }
     );
  }

  Future<bool> updatePlayerAssignmentStatus(String assignmentId, PlanAssignmentStatus newStatus) async {
       _setActionError(null);
       // Considerar un estado _isUpdatingStatus si la UI necesita feedback específico
       // _setIsUpdatingStatus(true); notifyListeners();
       try {
          await _assignmentRepository.updateAssignmentStatus(assignmentId, newStatus);
          // La lista se actualiza por el stream, no necesitamos hacer nada aquí.
          // _setIsUpdatingStatus(false); notifyListeners();
          return true;
       } catch (e) {
           _setActionError("Error al actualizar estado: ${e.toString()}");
           // _setIsUpdatingStatus(false);
           notifyListeners();
           return false;
       }
  }

  // --- Helpers Internos ---
  // Funciones unificadas para actualizar estado y notificar
  void _updateCoachState({bool? loading, String? error}) {
      bool changed = false;
      if (loading != null && _isLoadingCoachPlans != loading) {
          _isLoadingCoachPlans = loading;
          changed = true;
      }
      // Siempre limpiar error si iniciamos carga
      if (loading == true && _coachPlansError != null) {
           _coachPlansError = null;
           changed = true;
      }
      // Asignar nuevo error si viene uno
      if (error != null && _coachPlansError != error) {
          _coachPlansError = error;
          changed = true;
      }
      if (changed) {
          notifyListeners();
      }
  }
   void _updatePlayerState({bool? loading, String? error}) {
      bool changed = false;
      if (loading != null && _isLoadingPlayerAssignments != loading) {
          _isLoadingPlayerAssignments = loading;
          changed = true;
      }
       if (loading == true && _playerAssignmentsError != null) {
           _playerAssignmentsError = null;
           changed = true;
      }
      if (error != null && _playerAssignmentsError != error) {
          _playerAssignmentsError = error;
          changed = true;
      }
      if (changed) {
          notifyListeners();
      }
  }
  // Para errores de acciones (create, update)
  void _setActionError(String? message) {
    if (_actionErrorMessage != message) {
      _actionErrorMessage = message;
      // Notificar inmediatamente para errores de acción puede ser útil
      // notifyListeners(); // O dejar que se notifique con el fin de la carga
    }
  }

  // --- Limpieza ---
  @override
  void dispose() {
    if (kDebugMode) print("--- TP_Provider: Disposing ---");
    _coachPlansSubscription?.cancel();
    _playerAssignmentsSubscription?.cancel();
    super.dispose();
  }
}