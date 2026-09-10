import 'package:flutter/material.dart';

import '../../services/daily_summary_service.dart';

class DailySummaryPage extends StatefulWidget {
  const DailySummaryPage({super.key});

  @override
  State<DailySummaryPage> createState() =>
      _DailySummaryPageState();
}

class _DailySummaryPageState
    extends State<DailySummaryPage> {
  final DailySummaryService summaryService =
  DailySummaryService();

  int calories = 0;
  int fastingMinutes = 0;
  int fastingGoalHours = 0;
  bool goalReached = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() {
      isLoading = true;
    });

    final summary =
    await summaryService.getTodaySummary();

    if (!mounted) {
      return;
    }

    setState(() {
      calories = summary['calories'] as int;
      fastingMinutes =
      summary['fasting_time_minutes'] as int;
      fastingGoalHours =
      summary['fasting_goal_hours'] as int;
      goalReached =
      summary['goal_reached'] as bool;
      isLoading = false;
    });
  }

  String _formatFastingTime() {
    final hours = fastingMinutes ~/ 60;
    final minutes = fastingMinutes % 60;

    if (hours == 0) {
      return '${minutes}min';
    }

    return '${hours}h ${minutes}min';
  }

  String _getGoalStatus() {
    if (fastingGoalHours <= 0) {
      return 'Nenhuma meta configurada';
    }

    if (goalReached) {
      return 'Meta atingida!';
    }

    return 'Meta ainda não atingida';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Resumo de hoje',
        ),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: _loadSummary,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Resumo diário',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Acompanhe como foi seu dia.',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Calorias consumidas',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$calories kcal',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.timer,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tempo total de jejum',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatFastingTime(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.flag,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Meta de jejum',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      fastingGoalHours > 0
                          ? '$fastingGoalHours horas'
                          : 'Não configurada',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getGoalStatus(),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: goalReached
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            if (goalReached)
              Card(
                child: Padding(
                  padding:
                  const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Parabéns!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Você atingiu sua meta de jejum hoje.',
                        textAlign:
                        TextAlign.center,
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