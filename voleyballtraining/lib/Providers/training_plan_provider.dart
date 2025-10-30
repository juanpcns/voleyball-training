// lib/providers/training_plan_provider.dart (COMPLETO con assignPlanToPlayer)

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/training_plan_model.dart';
import '../models/plan_assignment_model.dart';
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
  final bool _isLoadingCoachPlans = false;
  String? _coachPlansError;
  StreamSubscription? _coachPlansSubscription;

  // --- Estado Jugador ---
  List<PlanAssignment> _playerAssignments = [];
  final bool _isLoadingPlayerAssignments = false;
  String? _playerAssignmentsError;
  StreamSubscription? _playerAssignmentsSubscription;

  // --- Estado General (para errores de acciones) ---
  String? _actionErrorMessage;

  // --- Getters ---
  List<TrainingPlan> get coachPlans => _coachPlans;
  bool get isLoadingCoachPlans => _isLoadingCoachPlans;
  String? get coachPlansError => _coachPlansError;

  List<PlanAssignment> get playerAssignments => _playerAssignments;
  bool get isLoadingPlayerAssignments => _isLoadingPlayerAssignments;
  String? get playerAssignmentsError => _playerAssignmentsError;

  String? get errorMessage => _actionErrorMessage; // Para errores de acciones

  // --- Métodos Coach ---
  void loadCoachPlans() {
    final userId = _authRepository.getCurrentUser()?.uid;
    if (userId == null) { _updateCoachState(loading: false, error: "Usuario no autenticado."); return; }
    if (kDebugMode) print("--- TP_Provider: Cargando planes Coach: $userId ---");
    _updateCoachState(loading: true, error: null);
    _coachPlansSubscription?.cancel();
    _coachPlansSubscription = _planRepository.getTrainingPlansForCreator(userId).listen(
      (fetchedPlans) {
        _coachPlans = fetchedPlans; _updateCoachState(loading: false);
      },
      onError: (error) { _coachPlans = []; _updateCoachState(loading: false, error: "Error cargando planes: ${error.toString()}"); },
      onDone: () { if (_isLoadingCoachPlans) _updateCoachState(loading: false); }
    );
  }

  Future<bool> createPlan({
      required String planName,
      required List<String> exercises,
      String? averageDailyTime,
      String? description,
  }) async {
      final userId = _authRepository.getCurrentUser()?.uid;
      if (userId == null) { _setActionError("No autenticado."); notifyListeners(); return false; }
       _setActionError(null);
      try {
          TrainingPlan newPlan = TrainingPlan.create(creatorId: userId, planName: planName, exercises: exercises, averageDailyTime: averageDailyTime, description: description);
          await _planRepository.addTrainingPlan(newPlan);
          return true;
      } on ArgumentError catch (e) { _setActionError("Error: ${e.message}"); notifyListeners(); return false; }
      catch (e) { _setActionError("Error: ${e.toString()}"); notifyListeners(); return false; }
  }

  /// *** MÉTODO AÑADIDO PARA ASIGNAR PLAN (HU9) ***
  Future<bool> assignPlanToPlayer({
    required String planId,
    required String playerId,
    String? planName, // Nombre denormalizado (opcional pero útil)
  }) async {
    final coachId = _authRepository.getCurrentUser()?.uid;
    if (coachId == null) {
      _setActionError("No autenticado.");
      notifyListeners();
      return false;
    }
     _setActionError(null); // Limpiar error previo de acción
     // Considerar un estado específico _isAssigning si se necesita feedback visual detallado

    try {
        if (kDebugMode) print("--- TP_Provider: Asignando plan $planId a jugador $playerId por coach $coachId ---");
        await _assignmentRepository.createAssignment(
          planId: planId, playerId: playerId, coachId: coachId, planName: planName,
        );
        if (kDebugMode) print("--- TP_Provider: Asignación creada exitosamente ---");
        return true; // Éxito
    } catch (e) {
         if (kDebugMode) print("--- TP_Provider: ERROR al asignar plan: $e ---");
        _setActionError("Error al asignar el plan: ${e.toString()}");
        notifyListeners(); // Notificar que hay un error
        return false; // Fallo
    }
  }
  // --- Fin Método Añadido ---


  // --- Métodos Jugador ---
  void loadPlayerAssignments() {
     final userId = _authRepository.getCurrentUser()?.uid;
     if (userId == null) { _updatePlayerState(loading: false, error: "Usuario no autenticado."); return; }
     if (kDebugMode) print("--- TP_Provider: Cargando asignaciones Jugador: $userId ---");
     _updatePlayerState(loading: true, error: null);
     _playerAssignmentsSubscription?.cancel();
     _playerAssignmentsSubscription = _assignmentRepository.getAssignmentsForPlayer(userId).listen(
       (assignments) { _playerAssignments = assignments; _updatePlayerState(loading: false); },
       onError: (error) { _playerAssignments = []; _updatePlayerState(loading: false, error: "Error cargando asignaciones: ${error.toString()}"); },
       onDone: () { if (_isLoadingPlayerAssignments) _updatePlayerState(loading: false); }
     );
  }

  Future<bool> updatePlayerAssignmentStatus(String assignmentId, PlanAssignmentStatus newStatus) async {
       _setActionError(null);
       try {
          await _assignmentRepository.updateAssignmentStatus(assignmentId, newStatus);
          return true;
       } catch (e) {
           _setActionError("Error al actualizar estado: ${e.toString()}");
           notifyListeners();
           return false;
       }
  }

  // --- Helpers Internos y Dispose ---
  void _updateCoachState({bool? loading, String? error}) { /* ... */ }
  void _updatePlayerState({bool? loading, String? error}) { /* ... */ }
  void _setActionError(String? message) { if (_actionErrorMessage != message) _actionErrorMessage = message; }
  @override
  void dispose() { _coachPlansSubscription?.cancel(); _playerAssignmentsSubscription?.cancel(); super.dispose(); }
}