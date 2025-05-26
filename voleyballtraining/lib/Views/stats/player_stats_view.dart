import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../Views/Styles/colors/app_colors.dart';

class PlayerStatsView extends StatelessWidget {
  final String playerId;
  final String playerName;

  const PlayerStatsView({
    super.key,
    required this.playerId,
    required this.playerName,
  });

  // MOCK DATA para cada letra
  Map<String, dynamic> get _mockStatsJ => {
        'totalAssigned': 20,
        'totalAccepted': 18,
        'totalRejected': 0,
        'totalCompleted': 16,
        'averageProgress': 0.95,
        'progressOverTime': [
          {'date': DateTime(2024, 5, 1), 'progress': 0.25},
          {'date': DateTime(2024, 5, 5), 'progress': 0.55},
          {'date': DateTime(2024, 5, 10), 'progress': 0.75},
          {'date': DateTime(2024, 5, 15), 'progress': 0.92},
          {'date': DateTime(2024, 5, 20), 'progress': 1.0},
        ],
        'statusDistribution': {
          'Pendiente': 2,
          'Aceptado': 10,
          'Rechazado': 0,
          'Completado': 8,
        },
        'weeklyComparison': [
          {'week': 'Semana 1', 'completed': 4},
          {'week': 'Semana 2', 'completed': 5},
          {'week': 'Semana 3', 'completed': 3},
          {'week': 'Semana 4', 'completed': 4},
        ]
      };

  Map<String, dynamic> get _mockStatsA => {
        'totalAssigned': 8,
        'totalAccepted': 6,
        'totalRejected': 2,
        'totalCompleted': 3,
        'averageProgress': 0.55,
        'progressOverTime': [
          {'date': DateTime(2024, 5, 3), 'progress': 0.10},
          {'date': DateTime(2024, 5, 7), 'progress': 0.30},
          {'date': DateTime(2024, 5, 12), 'progress': 0.48},
          {'date': DateTime(2024, 5, 18), 'progress': 0.55},
          {'date': DateTime(2024, 5, 21), 'progress': 0.61},
        ],
        'statusDistribution': {
          'Pendiente': 1,
          'Aceptado': 4,
          'Rechazado': 2,
          'Completado': 3,
        },
        'weeklyComparison': [
          {'week': 'Semana 1', 'completed': 1},
          {'week': 'Semana 2', 'completed': 0},
          {'week': 'Semana 3', 'completed': 2},
          {'week': 'Semana 4', 'completed': 0},
        ]
      };

  Map<String, dynamic> get _mockStatsO => {
        'totalAssigned': 15,
        'totalAccepted': 10,
        'totalRejected': 3,
        'totalCompleted': 7,
        'averageProgress': 0.70,
        'progressOverTime': [
          {'date': DateTime(2024, 5, 2), 'progress': 0.15},
          {'date': DateTime(2024, 5, 6), 'progress': 0.32},
          {'date': DateTime(2024, 5, 11), 'progress': 0.58},
          {'date': DateTime(2024, 5, 16), 'progress': 0.72},
          {'date': DateTime(2024, 5, 22), 'progress': 0.90},
        ],
        'statusDistribution': {
          'Pendiente': 3,
          'Aceptado': 6,
          'Rechazado': 2,
          'Completado': 4,
        },
        'weeklyComparison': [
          {'week': 'Semana 1', 'completed': 2},
          {'week': 'Semana 2', 'completed': 2},
          {'week': 'Semana 3', 'completed': 1},
          {'week': 'Semana 4', 'completed': 2},
        ]
      };

  Map<String, dynamic> get _mockStatsDefault => {
        'totalAssigned': 12,
        'totalAccepted': 8,
        'totalRejected': 2,
        'totalCompleted': 5,
        'averageProgress': 0.75,
        'progressOverTime': [
          {'date': DateTime(2024, 5, 10), 'progress': 0.2},
          {'date': DateTime(2024, 5, 12), 'progress': 0.35},
          {'date': DateTime(2024, 5, 15), 'progress': 0.55},
          {'date': DateTime(2024, 5, 18), 'progress': 0.75},
          {'date': DateTime(2024, 5, 20), 'progress': 1.0},
        ],
        'statusDistribution': {
          'Pendiente': 3,
          'Aceptado': 8,
          'Rechazado': 1,
          'Completado': 5,
        },
        'weeklyComparison': [
          {'week': 'Semana 1', 'completed': 2},
          {'week': 'Semana 2', 'completed': 1},
          {'week': 'Semana 3', 'completed': 3},
          {'week': 'Semana 4', 'completed': 4},
        ]
      };

  Map<String, dynamic> get mockStats {
    String initial = playerName.trim().isNotEmpty ? playerName.trim()[0].toUpperCase() : '';
    if (initial == 'J') return _mockStatsJ;
    if (initial == 'A') return _mockStatsA;
    if (initial == 'O') return _mockStatsO;
    return _mockStatsDefault;
  }

  @override
  Widget build(BuildContext context) {
    final stats = mockStats;
    final progressData = stats['progressOverTime'] as List;
    final statusDistribution = stats['statusDistribution'] as Map<String, int>;
    final weeklyComparison = stats['weeklyComparison'] as List;

    return Stack(
      children: [
        // Imagen de fondo
        Positioned.fill(
          child: Image.asset(
            'assets/images/fondo.png',
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.67),
          ),
        ),
        // Contenido principal
        Scaffold(
          backgroundColor: Colors.transparent,  
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              'Estadísticas de $playerName',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(18.0),
            children: [
              _StatHeader(stats: stats),
              const SizedBox(height: 14),
              _SectionTitle('Evolución del Progreso'),
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: progressData
                            .map<FlSpot>((d) => FlSpot(
                                  (d['date'] as DateTime).millisecondsSinceEpoch.toDouble(),
                                  (d['progress'] as double),
                                ))
                            .toList(),
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 4,
                        dotData: FlDotData(show: true),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
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
                        title: e.key,
                        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        radius: 48,
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              _SectionTitle('Comparativa Semanal'),
              SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    barGroups: weeklyComparison.asMap().entries.map((entry) {
                      final i = entry.key;
                      final value = entry.value['completed'];
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: (value as int).toDouble(),
                            color: AppColors.secondary,
                            width: 16,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      );
                    }).toList(),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            final weekIndex = value.toInt();
                            if (weekIndex < weeklyComparison.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(weeklyComparison[weekIndex]['week'] ?? ''),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(show: false),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper para color del pie chart
  static Color _pieColor(String key) {
    switch (key) {
      case 'Pendiente':
        return AppColors.warningDark;
      case 'Aceptado':
        return AppColors.primary;
      case 'Rechazado':
        return AppColors.errorDark;
      case 'Completado':
        return AppColors.successDark;
      default:
        return AppColors.primary.withOpacity(0.4);
    }
  }
}

// ========== COMPONENTES DE HEADER Y SECCIONES ==========

class _StatHeader extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _StatHeader({required this.stats});

  @override
  Widget build(BuildContext context) {
    final percent = ((stats['averageProgress'] ?? 0.0) as double) * 100;

    return Card(
      color: AppColors.surfaceDark,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 22),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatBox(
                  value: stats['totalAssigned'],
                  label: "Asignados",
                  color: AppColors.primary,
                ),
                _StatBox(
                  value: stats['totalAccepted'],
                  label: "Aceptados",
                  color: AppColors.successDark,
                ),
                _StatBox(
                  value: stats['totalRejected'],
                  label: "Rechazados",
                  color: AppColors.errorDark,
                ),
                _StatBox(
                  value: stats['totalCompleted'],
                  label: "Completados",
                  color: AppColors.secondary,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              "Progreso promedio: ${percent.toStringAsFixed(1)}%",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
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
