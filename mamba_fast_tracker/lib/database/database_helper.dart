import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('mamba_fast_tracker.db');

    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 8,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(
      Database db,
      int version,
      ) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        logged_in INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE fasting_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        protocol TEXT NOT NULL,
        fasting_hours INTEGER NOT NULL,
        eating_hours INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE fasting_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        status TEXT NOT NULL,
        remaining_seconds INTEGER,
        accumulated_seconds INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE meals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        calories INTEGER NOT NULL,
        meal_time TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dark_mode INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.insert(
      'app_settings',
      {
        'dark_mode': 0,
      },
    );
  }

  Future<void> _upgradeDB(
      Database db,
      int oldVersion,
      int newVersion,
      ) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE fasting_settings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          protocol TEXT NOT NULL,
          fasting_hours INTEGER NOT NULL,
          eating_hours INTEGER NOT NULL
        )
      ''');
    }

    if (oldVersion < 3) {
      await db.execute('''
        ALTER TABLE users
        ADD COLUMN logged_in INTEGER NOT NULL DEFAULT 0
      ''');
    }

    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE fasting_sessions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          start_time TEXT NOT NULL,
          end_time TEXT NOT NULL,
          status TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE meals (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          calories INTEGER NOT NULL,
          meal_time TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 6) {
      await db.execute('''
        ALTER TABLE fasting_sessions
        ADD COLUMN remaining_seconds INTEGER
      ''');
    }

    if (oldVersion < 7) {
      await db.execute('''
        ALTER TABLE fasting_sessions
        ADD COLUMN accumulated_seconds INTEGER NOT NULL DEFAULT 0
      ''');
    }

    if (oldVersion < 8) {
      await db.execute('''
        CREATE TABLE app_settings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          dark_mode INTEGER NOT NULL DEFAULT 0
        )
      ''');

      await db.insert(
        'app_settings',
        {
          'dark_mode': 0,
        },
      );
    }
  }
}