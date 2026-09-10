import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../database/database_helper.dart';

class AuthService {
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);

    return digest.toString();
  }

  Future<bool> login(
      String email,
      String password,
      ) async {
    final db = await databaseHelper.database;

    final hashedPassword = _hashPassword(password);

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [
        email,
        hashedPassword,
      ],
    );

    if (result.isEmpty) {
      return false;
    }

    await db.update(
      'users',
      {'logged_in': 1},
      where: 'id = ?',
      whereArgs: [result.first['id']],
    );

    return true;
  }

  Future<bool> register(
      String email,
      String password,
      ) async {
    final db = await databaseHelper.database;

    try {
      final hashedPassword = _hashPassword(password);

      await db.insert(
        'users',
        {
          'email': email,
          'password': hashedPassword,
          'logged_in': 0,
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    final db = await databaseHelper.database;

    final result = await db.query(
      'users',
      where: 'logged_in = ?',
      whereArgs: [1],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  Future<void> logout() async {
    final db = await databaseHelper.database;

    await db.update(
      'users',
      {'logged_in': 0},
      where: 'logged_in = ?',
      whereArgs: [1],
    );
  }
}