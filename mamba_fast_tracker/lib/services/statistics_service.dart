import '../database/database_helper.dart';

class StatisticsService {
  final DatabaseHelper databaseHelper =
      DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> getWeeklyCalories() async {
    final db = await databaseHelper.database;

    final today = DateTime.now();

    final startDate = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(
      const Duration(days: 6),
    );

    final endDate = DateTime(
      today.year,
      today.month,
      today.day,
    ).add(
      const Duration(days: 1),
    );

    final result = await db.rawQuery(
      '''
      SELECT
        DATE(meal_time) AS date,
        COALESCE(SUM(calories), 0) AS calories
      FROM meals
      WHERE meal_time >= ?
        AND meal_time < ?
      GROUP BY DATE(meal_time)
      ORDER BY DATE(meal_time) ASC
      ''',
      [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
    );

    final Map<String, int> caloriesByDate = {};

    for (final row in result) {
      caloriesByDate[
      row['date'].toString()
      ] = (row['calories'] as num).toInt();
    }

    final List<Map<String, dynamic>> weeklyData = [];

    for (int i = 0; i < 7; i++) {
      final date = startDate.add(
        Duration(days: i),
      );

      final dateString =
          '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';

      weeklyData.add({
        'date': dateString,
        'calories': caloriesByDate[dateString] ?? 0,
      });
    }

    return weeklyData;
  }
}