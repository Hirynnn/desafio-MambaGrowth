import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../services/statistics_service.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() =>
      _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final StatisticsService statisticsService =
  StatisticsService();

  List<Map<String, dynamic>> weeklyData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      isLoading = true;
    });

    final data =
    await statisticsService.getWeeklyCalories();

    if (!mounted) {
      return;
    }

    setState(() {
      weeklyData = data;
      isLoading = false;
    });
  }

  String _getDayLabel(String date) {
    final parts = date.split('-');

    if (parts.length != 3) {
      return '';
    }

    final day = int.tryParse(parts[2]);

    if (day == null) {
      return '';
    }

    return day.toString();
  }

  double _getMaxCalories() {
    if (weeklyData.isEmpty) {
      return 1000;
    }

    int maxCalories = 0;

    for (final day in weeklyData) {
      final calories =
      (day['calories'] as num).toInt();

      if (calories > maxCalories) {
        maxCalories = calories;
      }
    }

    if (maxCalories == 0) {
      return 1000;
    }

    return (maxCalories * 1.2).ceilToDouble();
  }

  int _getTotalCalories() {
    int total = 0;

    for (final day in weeklyData) {
      total +=
          (day['calories'] as num).toInt();
    }

    return total;
  }

  double _getAverageCalories() {
    if (weeklyData.isEmpty) {
      return 0;
    }

    return _getTotalCalories() /
        weeklyData.length;
  }

  @override
  Widget build(BuildContext context) {
    final maxCalories = _getMaxCalories();
    final totalCalories = _getTotalCalories();
    final averageCalories =
    _getAverageCalories();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Estatísticas',
        ),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: _loadStatistics,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Últimos 7 dias',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Acompanhe suas calorias consumidas.',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      maxY: maxCalories,
                      minY: 0,
                      alignment:
                      BarChartAlignment.spaceAround,
                      gridData: FlGridData(
                        show: true,
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 45,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            getTitlesWidget:
                                (value, meta) {
                              final index =
                              value.toInt();

                              if (index < 0 ||
                                  index >=
                                      weeklyData.length) {
                                return const SizedBox();
                              }

                              return Padding(
                                padding:
                                const EdgeInsets.only(
                                  top: 8,
                                ),
                                child: Text(
                                  _getDayLabel(
                                    weeklyData[index]
                                    ['date']
                                        .toString(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups:
                      List.generate(
                        weeklyData.length,
                            (index) {
                          final calories =
                          (weeklyData[index]
                          ['calories']
                          as num)
                              .toDouble();

                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: calories,
                                width: 22,
                                borderRadius:
                                BorderRadius.circular(
                                  4,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Total da semana',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalCalories kcal',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Média diária',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${averageCalories.round()} kcal',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}