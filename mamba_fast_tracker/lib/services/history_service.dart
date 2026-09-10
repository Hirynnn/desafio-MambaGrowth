import '../database/database_helper.dart';

class HistoryService {
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await databaseHelper.database;

    final mealDates = await db.rawQuery('''
      SELECT DISTINCT DATE(meal_time) AS date
      FROM meals
    ''');

    final fastingDates = await db.rawQuery('''
      SELECT DISTINCT DATE(start_time) AS date
      FROM fasting_sessions
    ''');

    final Set<String> dates = {};

    for (final row in mealDates) {
      dates.add(row['date'].toString());
    }

    for (final row in fastingDates) {
      dates.add(row['date'].toString());
    }

    final List<String> sortedDates = dates.toList()
      ..sort((a, b) => b.compareTo(a));

    final List<Map<String, dynamic>> history = [];

    for (final date in sortedDates) {
      final summary = await getDaySummary(date);

      if (summary != null) {
        history.add(summary);
      }
    }

    return history;
  }

  Future<Map<String, dynamic>?> getDaySummary(
      String date,
      ) async {
    final db = await databaseHelper.database;

    final mealResult = await db.rawQuery(
      '''
      SELECT
        COALESCE(SUM(calories), 0) AS calories
      FROM meals
      WHERE DATE(meal_time) = ?
      ''',
      [date],
    );

    final dayStart = DateTime.parse(
      '${date}T00:00:00',
    );

    final dayEnd = dayStart.add(
      const Duration(days: 1),
    );

    final fastingResult = await db.query(
      'fasting_sessions',
      where: '''
        start_time < ?
        AND end_time > ?
      ''',
      whereArgs: [
        dayEnd.toIso8601String(),
        dayStart.toIso8601String(),
      ],
      orderBy: 'id ASC',
    );

    int fastingSeconds = 0;

    for (final session in fastingResult) {
      final accumulatedSeconds =
          (session['accumulated_seconds'] as num?)?.toInt() ?? 0;

      if (session['status'] == 'paused' ||
          session['status'] == 'finished') {
        fastingSeconds += accumulatedSeconds;
        continue;
      }

      if (session['status'] == 'active') {
        final startTime = DateTime.parse(
          session['start_time'].toString(),
        );

        final elapsedSeconds =
            DateTime.now().difference(startTime).inSeconds;

        fastingSeconds += accumulatedSeconds;

        if (elapsedSeconds > 0) {
          fastingSeconds += elapsedSeconds;
        }
      }
    }

    final calories =
    (mealResult.first['calories'] as num).toInt();

    final fastingMinutes =
        Duration(
          seconds: fastingSeconds,
        ).inMinutes;

    if (calories == 0 && fastingMinutes == 0) {
      return null;
    }

    return {
      'date': date,
      'calories': calories,
      'fasting_minutes': fastingMinutes,
    };
  }
}