import '../database/database_helper.dart';

class FastingService {
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;

  Future<void> saveProtocol({
    required String protocol,
    required int fastingHours,
    required int eatingHours,
  }) async {
    final db = await databaseHelper.database;

    await db.delete('fasting_settings');

    await db.insert(
      'fasting_settings',
      {
        'protocol': protocol,
        'fasting_hours': fastingHours,
        'eating_hours': eatingHours,
      },
    );
  }

  Future<Map<String, dynamic>?> getProtocol() async {
    final db = await databaseHelper.database;

    final result = await db.query(
      'fasting_settings',
      orderBy: 'id DESC',
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }
}