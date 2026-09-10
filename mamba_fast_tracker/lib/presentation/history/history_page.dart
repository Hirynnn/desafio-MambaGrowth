import 'package:flutter/material.dart';

import '../../services/history_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryService historyService =
  HistoryService();

  List<Map<String, dynamic>> history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      isLoading = true;
    });

    final loadedHistory =
    await historyService.getHistory();

    if (!mounted) {
      return;
    }

    setState(() {
      history = loadedHistory;
      isLoading = false;
    });
  }

  String _formatDate(String date) {
    final parts = date.split('-');

    if (parts.length != 3) {
      return date;
    }

    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  String _formatFastingTime(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours == 0) {
      return '${remainingMinutes}min';
    }

    if (remainingMinutes == 0) {
      return '${hours}h';
    }

    return '${hours}h ${remainingMinutes}min';
  }

  Future<void> _showDayDetails(
      String date,
      ) async {
    final summary =
    await historyService.getDaySummary(date);

    if (!mounted || summary == null) {
      return;
    }

    final calories =
    summary['calories'] as int;

    final fastingMinutes =
    summary['fasting_minutes'] as int;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Resumo de ${_formatDate(date)}',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.local_fire_department,
                ),
                title: const Text(
                  'Calorias',
                ),
                trailing: Text(
                  '$calories kcal',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.timer,
                ),
                title: const Text(
                  'Tempo de jejum',
                ),
                trailing: Text(
                  _formatFastingTime(
                    fastingMinutes,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Fechar',
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Histórico',
        ),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: _loadHistory,
        child: history.isEmpty
            ? ListView(
          children: [
            const SizedBox(
              height: 140,
            ),
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Nenhum histórico disponível.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Os dias com refeições aparecerão aqui.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                  Colors.grey.shade600,
                ),
              ),
            ),
          ],
        )
            : ListView.builder(
          padding:
          const EdgeInsets.all(16),
          itemCount: history.length,
          itemBuilder:
              (context, index) {
            final day =
            history[index];

            final date =
            day['date'].toString();

            final calories =
            (day['calories']
            as num)
                .toInt();

            return Card(
              margin:
              const EdgeInsets.only(
                bottom: 10,
              ),
              child: ListTile(
                leading:
                const CircleAvatar(
                  child: Icon(
                    Icons.calendar_today,
                  ),
                ),
                title: Text(
                  _formatDate(date),
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '$calories kcal consumidas',
                ),
                trailing:
                const Icon(
                  Icons
                      .chevron_right,
                ),
                onTap: () {
                  _showDayDetails(
                    date,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}