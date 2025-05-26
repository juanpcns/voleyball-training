import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../Views/Styles/colors/app_colors.dart';

import '../../models/plan_assignment_model.dart';
import '../../repositories/plan_assignment_repository_base.dart';

extension IterableExtension<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(int index, E e) f) sync* {
    int index = 0;
    for (final e in this) {
      yield f(index, e);
      index++;
    }
  }
}

class PlayerStatsView extends StatelessWidget {
  final String playerId;
  final String playerName;
  final bool isCoach;

  const PlayerStatsView({
    super.key,
    required this.playerId,
    required this.playerName,
    required this.isCoach,
  });

  @override
  Widget build(BuildContext context) {
    final planAssignmentRepo = Provider.of<PlanAssignmentRepositoryBase>(context, listen: false);

    return Scaffold(
      appBar: isCoach
          ? AppBar(
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(
                'Estadísticas de $playerName',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            )
          : null,
      
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/fondo.png', fit: BoxFit.cover),
          ),
          // NO se pone Container con color negro semitransparente para que el fondo se vea claro
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<List<PlanAssignment>>(
              stream: planAssignmentRepo.getAssignmentsForPlayer(playerId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error al cargar planes: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                final playerAssignments = snapshot.data ?? [];

                final Map<String, int> statusDistribution = {
                  'Pendiente': playerAssignments.where((a) => a.status == PlanAssignmentStatus.pendiente).length,
                  'Aceptado': playerAssignments.where((a) => a.status == PlanAssignmentStatus.aceptado).length,
                  'Rechazado': playerAssignments.where((a) => a.status == PlanAssignmentStatus.rechazado).length,
                  'Completado': playerAssignments.where((a) => a.status == PlanAssignmentStatus.completado).length,
                };

                final totalAssigned = playerAssignments.length;
                final totalCompleted = statusDistribution['Completado'] ?? 0;
                final totalAccepted = statusDistribution['Aceptado'] ?? 0;
                final totalRejected = statusDistribution['Rechazado'] ?? 0;
                final averageProgress = totalAssigned > 0 ? totalCompleted / totalAssigned : 0.0;

                return ListView(
                  children: [
                    Card(
                      color: AppColors.surfaceDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      margin: const EdgeInsets.only(bottom: 14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 22),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _StatBox(
                                  value: totalAssigned,
                                  label: "Asignados",
                                  color: AppColors.primary,
                                ),
                                _StatBox(
                                  value: totalAccepted,
                                  label: "Aceptados",
                                  color: AppColors.successDark,
                                ),
                                _StatBox(
                                  value: totalRejected,
                                  label: "Rechazados",
                                  color: AppColors.errorDark,
                                ),
                                _StatBox(
                                  value: totalCompleted,
                                  label: "Completados",
                                  color: AppColors.secondary,
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Text(
                              "Progreso promedio: ${(averageProgress * 100).toStringAsFixed(1)}%",
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _SectionTitle('Estados de los Planes'),
                    SizedBox(
                      height: 180,
                      child: PieChart(
                        PieChartData(
                          sections: statusDistribution.entries.map((e) {
                            final color = _pieColor(e.key);
                            return PieChartSectionData(
                              value: e.value.toDouble(),
                              color: color,
                              title: '${e.key} (${e.value})',
                              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              radius: 48,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    _SectionTitle('Distribución de Planes por Estado (Barras)'),
                    SizedBox(
                      height: 180,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: (statusDistribution.values.isEmpty)
                              ? 1
                              : (statusDistribution.values.reduce((a, b) => a > b ? a : b)).toDouble() + 1,
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  final keys = statusDistribution.keys.toList();
                                  if (value.toInt() < keys.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        keys[value.toInt()],
                                        style: TextStyle(
                                          color: _pieColor(keys[value.toInt()]),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                                reservedSize: 42,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: statusDistribution.entries.mapIndexed((index, entry) {
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: entry.value.toDouble(),
                                  color: _pieColor(entry.key),
                                  width: 24,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    // Puedes agregar aquí otras gráficas o widgets si quieres
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static Color _pieColor(String key) {
    switch (key) {
      case 'Pendiente':
        return AppColors.warningDark;
      case 'Aceptado':
        return AppColors.successDark;
      case 'Rechazado':
        return AppColors.errorDark;
      case 'Completado':
        return AppColors.secondary;
      default:
        return AppColors.primary.withOpacity(0.4);
    }
  }
}

class _StatBox extends StatelessWidget {
  final int value;
  final String label;
  final Color color;
  const _StatBox({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "$value",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textGray)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Text(text,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                )),
      );
}
