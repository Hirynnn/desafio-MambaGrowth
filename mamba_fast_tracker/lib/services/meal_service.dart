import '../database/database_helper.dart';

class MealService {
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;

  Future<int> addMeal({
    required String name,
    required int calories,
  }) async {
    final db = await databaseHelper.database;

    return await db.insert(
      'meals',
      {
        'name': name,
        'calories': calories,
        'meal_time': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<List<Map<String, dynamic>>> getMeals() async {
    final db = await databaseHelper.database;

    return await db.query(
      'meals',
      orderBy: 'meal_time DESC',
    );
  }

  Future<int> updateMeal({
    required int id,
    required String name,
    required int calories,
  }) async {
    final db = await databaseHelper.database;

    return await db.update(
      'meals',
      {
        'name': name,
        'calories': calories,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteMeal(int id) async {
    final db = await databaseHelper.database;

    return await db.delete(
      'meals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getTodayCalories() async {
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

    final result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(calories), 0) AS total
      FROM meals
      WHERE meal_time >= ? AND meal_time < ?
      ''',
      [
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String(),
      ],
    );

    return (result.first['total'] as num).toInt();
  }
}