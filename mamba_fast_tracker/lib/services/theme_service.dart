import '../database/database_helper.dart';

class ThemeService {
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;

  Future<bool> isDarkMode() async {
    final db = await databaseHelper.database;

    final result = await db.query(
      'app_settings',
      orderBy: 'id DESC',
      limit: 1,
    );

    if (result.isEmpty) {
      return false;
    }

    return result.first['dark_mode'] == 1;
  }

  Future<void> setDarkMode(bool isDarkMode) async {
    final db = await databaseHelper.database;

    final result = await db.query(
      'app_settings',
      orderBy: 'id DESC',
      limit: 1,
    );

    if (result.isEmpty) {
      await db.insert(
        'app_settings',
        {
          'dark_mode': isDarkMode ? 1 : 0,
        },
      );

      return;
    }

    await db.update(
      'app_settings',
      {
        'dark_mode': isDarkMode ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [result.first['id']],
    );
  }
}