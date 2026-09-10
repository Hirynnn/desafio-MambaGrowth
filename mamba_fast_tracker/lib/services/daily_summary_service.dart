import '../database/database_helper.dart';
import 'fasting_service.dart';
import 'meal_service.dart';

class DailySummaryService {
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;
  final MealService mealService = MealService();
  final FastingService fastingService = FastingService();

  Future<int> getTodayCalories() async {
    return await mealService.getTodayCalories();
  }

  Future<Duration> getTodayFastingTime() async {
    final db = await databaseHelper.database;

    final today = DateTime.now();

    final startOfDay = DateTime(
      today.year,
      today.month,
      today.day,
    );

    final endOfDay = startOfDay.add(
      const Duration(days: 1),
    );

    final result = await db.query(
      'fasting_sessions',
      where: '''
        start_time < ?
        AND end_time > ?
      ''',
      whereArgs: [
        endOfDay.toIso8601String(),
        startOfDay.toIso8601String(),
      ],
      orderBy: 'id ASC',
    );

    int totalSeconds = 0;

    for (final session in result) {
      final accumulatedSeconds =
          (session['accumulated_seconds'] as num?)?.toInt() ?? 0;

      if (session['status'] == 'paused' ||
          session['status'] == 'finished') {
        totalSeconds += accumulatedSeconds;
        continue;
      }

      if (session['status'] == 'active') {
        final startTime = DateTime.parse(
          session['start_time'].toString(),
        );

        final elapsedSeconds =
            DateTime.now().difference(startTime).inSeconds;

        totalSeconds += accumulatedSeconds;

        if (elapsedSeconds > 0) {
          totalSeconds += elapsedSeconds;
        }
      }
    }

    return Duration(
      seconds: totalSeconds,
    );
  }

  Future<int> getFastingGoalHours() async {
    final protocol =
    await fastingService.getProtocol();

    if (protocol == null) {
      return 0;
    }

    return protocol['fasting_hours'] as int;
  }

  Future<bool> isTodayFastingGoalReached() async {
    final goalHours =
    await getFastingGoalHours();

    if (goalHours <= 0) {
      return false;
    }

    final fastingTime =
    await getTodayFastingTime();

    return fastingTime.inMinutes >=
        goalHours * 60;
  }

  Future<Map<String, dynamic>> getTodaySummary() async {
    final calories =
    await getTodayCalories();

    final fastingTime =
    await getTodayFastingTime();

    final goalHours =
    await getFastingGoalHours();

    final goalReached =
        goalHours > 0 &&
            fastingTime.inMinutes >= goalHours * 60;

    return {
      'calories': calories,
      'fasting_time_minutes':
      fastingTime.inMinutes,
      'fasting_goal_hours': goalHours,
      'goal_reached': goalReached,
    };
  }
}