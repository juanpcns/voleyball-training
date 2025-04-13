// lib/providers/training_plan_provider.dart (Nombre de Parámetro Corregido)

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/training_plan_model.dart'; // Importa el modelo corregido
import '../repositories/training_plan_repository_base.dart';
import '../repositories/auth_repository_base.dart';

class TrainingPlanProvider with ChangeNotifier {
  final TrainingPlanRepositoryBase _planRepository;
  final AuthRepositoryBase _authRepository;

  TrainingPlanProvider(this._planRepository, this._authRepository);

  List<TrainingPlan> _plans = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _plansSubscription;

  List<TrainingPlan> get plans => _plans;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void loadCoachPlans() {
    final userId = _authRepository.getCurrentUser()?.uid;
    if (userId == null) { /* ... manejo de error ... */ return; }

    if (kDebugMode) print("--- TP_Provider: Iniciando carga planes Coach: $userId ---");
    _setLoading(true); _setError(null); notifyListeners();
    _plansSubscription?.cancel();
    _plansSubscription = _planRepository.getTrainingPlansForCreator(userId).listen(
      (fetchedPlans) { /* ... actualizar estado ... */ },
      onError: (error) { /* ... actualizar estado con error ... */ },
      onDone: () { /* ... actualizar estado si es necesario ... */ }
    );
  }

  /// Método para crear un nuevo plan.
  /// *** AHORA ESPERA el parámetro 'exercises' (List<String>) ***
  Future<bool> createPlan({
      required String planName,
      required List<String> exercises, // <-- NOMBRE CORREGIDO AQUÍ
      String? averageDailyTime,
      String? description,
  }) async {
      final userId = _authRepository.getCurrentUser()?.uid;
      if (userId == null) { /* ... manejo error ... */ return false; }
       _setError(null);

      try {
          if (kDebugMode) print("--- TP_Provider: Usando Factory para crear plan: $planName ---");

          // *** LLAMADA CORREGIDA: Usa el nombre de parámetro 'exercises' ***
          TrainingPlan newPlan = TrainingPlan.create(
              creatorId: userId,
              planName: planName,
              exercises: exercises, // <--- Nombre correcto del parámetro
              averageDailyTime: averageDailyTime,
              description: description,
          );
          // *** FIN CORRECCIÓN ***
          if (kDebugMode) print("--- TP_Provider: Plan validado por Factory ---");

          if (kDebugMode) print("--- TP_Provider: Llamando a addTrainingPlan... ---");
          await _planRepository.addTrainingPlan(newPlan);
          if (kDebugMode) print("--- TP_Provider: Plan añadido a Firestore ---");

          return true; // Éxito

      } on ArgumentError catch (e) {
           if (kDebugMode) print("--- TP_Provider: Error Factory: $e ---");
          _setError("Error al crear plan: ${e.message}");
          notifyListeners();
          return false;
      } catch (e) {
           if (kDebugMode) print("--- TP_Provider: Error Firestore/Otro: $e ---");
           _setError("Error al guardar el plan: ${e.toString()}");
           notifyListeners();
           return false;
      }
  }

  void _setLoading(bool loadingState) { /* ... */}
  void _setError(String? message) { /* ... */}

  @override
  void dispose() { /* ... cancelar suscripción ... */ }
}