import '../database/database_helper.dart';

class FastingTimerService {
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;

  Future<void> startFasting(int fastingHours) async {
    final db = await databaseHelper.database;

    final now = DateTime.now();
    final duration = Duration(hours: fastingHours);
    final endTime = now.add(duration);

    await db.delete(
      'fasting_sessions',
      where: 'status IN (?, ?)',
      whereArgs: ['active', 'paused'],
    );

    await db.insert(
      'fasting_sessions',
      {
        'start_time': now.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'status': 'active',
        'remaining_seconds': duration.inSeconds,
        'accumulated_seconds': 0,
      },
    );
  }

  Future<Map<String, dynamic>?> getActiveFasting() async {
    final db = await databaseHelper.database;

    final result = await db.query(
      'fasting_sessions',
      where: 'status = ?',
      whereArgs: ['active'],
      orderBy: 'id DESC',
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    final session = result.first;

    final endTime = DateTime.parse(
      session['end_time'].toString(),
    );

    if (!endTime.isAfter(DateTime.now())) {
      await finishFasting();

      return null;
    }

    return session;
  }

  Future<void> pauseFasting() async {
    final db = await databaseHelper.database;

    final result = await db.query(
      'fasting_sessions',
      where: 'status = ?',
      whereArgs: ['active'],
      orderBy: 'id DESC',
      limit: 1,
    );

    if (result.isEmpty) {
      return;
    }

    final session = result.first;

    final startTime = DateTime.parse(
      session['start_time'].toString(),
    );

    final now = DateTime.now();

    final elapsedSeconds =
        now.difference(startTime).inSeconds;

    final previousAccumulated =
        (session['accumulated_seconds'] as num?)?.toInt() ?? 0;

    final accumulatedSeconds =
        previousAccumulated +
            (elapsedSeconds > 0 ? elapsedSeconds : 0);

    final endTime = DateTime.parse(
      session['end_time'].toString(),
    );

    final remainingSeconds =
        endTime.difference(now).inSeconds;

    await db.update(
      'fasting_sessions',
      {
        'status': 'paused',
        'remaining_seconds':
        remainingSeconds > 0 ? remainingSeconds : 0,
        'accumulated_seconds': accumulatedSeconds,
      },
      where: 'id = ?',
      whereArgs: [session['id']],
    );
  }

  Future<void> resumeFasting() async {
    final db = await databaseHelper.database;

    final result = await db.query(
      'fasting_sessions',
      where: 'status = ?',
      whereArgs: ['paused'],
      orderBy: 'id DESC',
      limit: 1,
    );

    if (result.isEmpty) {
      return;
    }

    final session = result.first;

    final remainingSeconds =
        (session['remaining_seconds'] as num?)?.toInt() ?? 0;

    if (remainingSeconds <= 0) {
      await db.update(
        'fasting_sessions',
        {
          'status': 'finished',
          'remaining_seconds': 0,
        },
        where: 'id = ?',
        whereArgs: [session['id']],
      );

      return;
    }

    final now = DateTime.now();

    final endTime = now.add(
      Duration(seconds: remainingSeconds),
    );

    await db.update(
      'fasting_sessions',
      {
        'status': 'active',
        'start_time': now.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'remaining_seconds': remainingSeconds,
      },
      where: 'id = ?',
      whereArgs: [session['id']],
    );
  }

  Future<Map<String, dynamic>?> getPausedFasting() async {
    final db = await databaseHelper.database;

    final result = await db.query(
      'fasting_sessions',
      where: 'status = ?',
      whereArgs: ['paused'],
      orderBy: 'id DESC',
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  Future<void> finishFasting() async {
    final db = await databaseHelper.database;

    final result = await db.query(
      'fasting_sessions',
      where: 'status IN (?, ?)',
      whereArgs: ['active', 'paused'],
      orderBy: 'id DESC',
      limit: 1,
    );

    if (result.isEmpty) {
      return;
    }

    final session = result.first;

    int accumulatedSeconds =
        (session['accumulated_seconds'] as num?)?.toInt() ?? 0;

    if (session['status'] == 'active') {
      final startTime = DateTime.parse(
        session['start_time'].toString(),
      );

      final elapsedSeconds =
          DateTime.now().difference(startTime).inSeconds;

      if (elapsedSeconds > 0) {
        accumulatedSeconds += elapsedSeconds;
      }
    }

    await db.update(
      'fasting_sessions',
      {
        'status': 'finished',
        'remaining_seconds': 0,
        'accumulated_seconds': accumulatedSeconds,
      },
      where: 'id = ?',
      whereArgs: [session['id']],
    );
  }
}